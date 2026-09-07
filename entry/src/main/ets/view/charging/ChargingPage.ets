import { ChargingOrder, ChargingPile, NavParam, RealTimeChargingData } from '../../model/Types';
import { OrderResult, OrderService } from '../../service/OrderService';
import { StationService } from '../../service/StationService';
import { pileMeta } from '../../model/MockData';
import { AppTopBar } from '../../component/AppTopBar';
import { InfoRow } from '../../component/InfoRow';
import { PrimaryButton } from '../../component/PrimaryButton';

/**
 * 充电中（Story 11/12）：1s 轮询 GET /charging/current（服务端模拟，契约 §7 一期）；
 * 结束充电走 POST /charging/{id}/stop，结算由服务端裁决。
 */

const ZERO_DATA: RealTimeChargingData = {
  voltage: 0, current: 0, powerKw: 0, durationSec: 0, energyKwh: 0, estimatedCost: 0
};

/** 进度环估算：按 60 度目标电量折算百分比 */
const TARGET_KWH: number = 60;

@Component
export struct ChargingPage {
  pathStack: NavPathStack = new NavPathStack();
  /** 充电会话订单号（由路由参数注入） */
  orderId: string = '';

  @State order: ChargingOrder | null = null;
  @State pile: ChargingPile | null = null;
  @State data: RealTimeChargingData = ZERO_DATA;
  @State finishing: boolean = false;
  private pollTimer: number = -1;

  aboutToAppear(): void {
    this.loadSession();
    this.startPolling();
  }

  aboutToDisappear(): void {
    this.stopPolling();
  }

  private loadSession(): void {
    OrderService.getInstance().getOrderById(this.orderId).then(async (order) => {
      if (!order) {
        this.toast('未找到充电会话');
        this.stopPolling();
        this.pathStack.pop();
        return;
      }
      if (order.status === 'FINISHED') {
        // 会话已结算：直接替换为汇总页，避免重复结束
        this.stopPolling();
        const param: NavParam = { id: order.id };
        this.pathStack.replacePathByName('ChargeComplete', param);
        return;
      }
      this.order = order;
      // 桩档案（停车位/接口展示用）：刷新站点缓存后取数
      try {
        await StationService.getInstance().refresh();
      } catch (err) {
        // 拉取失败则用旧缓存兜底
      }
      this.pile = StationService.getInstance().getPileByCode(order.pileCode) ?? null;
    }).catch(() => {
      this.toast('充电会话加载失败');
      this.stopPolling();
      this.pathStack.pop();
    });
  }

  private startPolling(): void {
    this.pollOnce();
    this.pollTimer = setInterval(() => this.pollOnce(), 1000);
  }

  private stopPolling(): void {
    if (this.pollTimer !== -1) {
      clearInterval(this.pollTimer);
      this.pollTimer = -1;
    }
  }

  private pollOnce(): void {
    OrderService.getInstance().currentRealtime().then((d) => {
      if (!d) {
        // 无进行中会话（可能已在别处结算）：停表并回退
        this.stopPolling();
        return;
      }
      this.data = d;
    }).catch(() => {
      // 网络抖动保留上一 tick 数据，下个间隔继续轮询
    });
  }

  private toast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`ChargingPage toast failed: ${JSON.stringify(err)}`);
    }
  }

  private progress(): number {
    return Math.min(99, this.data.energyKwh / TARGET_KWH * 100);
  }

  private formatTime(total: number): string {
    const h: number = Math.floor(total / 3600);
    const m: number = Math.floor((total % 3600) / 60);
    const s: number = Math.floor(total % 60);
    const pad = (n: number): string => (n < 10 ? `0${n}` : `${n}`);
    return `${pad(h)}:${pad(m)}:${pad(s)}`;
  }

  private slotCode(): string {
    const order = this.order;
    if (!order) {
      return '';
    }
    const pile = StationService.getInstance().getPileByCode(order.pileCode);
    return pile ? pileMeta(pile.id).slotCode : '';
  }

  private finishCharging(): void {
    if (this.finishing || !this.order) {
      return;
    }
    this.finishing = true;
    this.stopPolling();
    const orderId = this.order.id;
    OrderService.getInstance().finishOrder(orderId, this.data)
      .then((res: OrderResult) => {
        if (!res.success) {
          this.toast(res.message);
          return;
        }
        AppStorage.setOrCreate<ChargingOrder | null>('currentOrder', null);
        const param: NavParam = { id: orderId };
        this.pathStack.pushPathByName('ChargeComplete', param);
      })
      .catch(() => {
        this.toast('结束充电失败，请重试');
      })
      .finally(() => {
        this.finishing = false;
      });
  }

  @Builder
  DataItem(label: string, value: string, unit: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
      Row() {
        Text(value)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.btn_primary'))
        Text(unit)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 3, bottom: 3 })
      }
      .alignItems(VerticalAlign.Bottom)
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }

  @Builder
  StatusCard() {
    Column({ space: 20 }) {
      Stack() {
        Progress({ value: this.progress(), total: 100, type: ProgressType.Ring })
          .width(180)
          .height(180)
          .color($r('app.color.btn_primary'))
          .backgroundColor($r('app.color.charge_ring_bg'))
          .style({ strokeWidth: 14 })

        Column({ space: 4 }) {
          Text(`${Math.floor(this.progress())}%`)
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.btn_primary'))
          Text('充电进度')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
        }
      }

      Text(this.pile ? `正在充电 · ${this.pile.interfaceType}` : '正在充电')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.btn_primary'))
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .backgroundColor($r('app.color.charge_tint_bg'))
        .borderRadius(12)

      Divider()
        .color($r('app.color.divider'))
        .width('100%')

      Row() {
        this.DataItem('已充电量', this.data.energyKwh.toFixed(2), 'kWh')
        Column()
          .width(1)
          .height(32)
          .backgroundColor($r('app.color.divider'))
        this.DataItem('充电时长', `${Math.floor(this.data.durationSec / 60)}`, 'min')
        Column()
          .width(1)
          .height(32)
          .backgroundColor($r('app.color.divider'))
        this.DataItem('当前功率', this.data.powerKw.toFixed(1), 'kW')
      }
      .width('100%')
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .padding(24)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
  }

  @Builder
  InfoCardContent() {
    Column({ space: 8 }) {
      InfoRow({ label: '充电桩', value: this.order ? this.order.pileCode : '' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '停车位', value: this.slotCode() })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '当前电压 / 电流', value: `${this.data.voltage} V / ${this.data.current} A` })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电时长', value: this.formatTime(this.data.durationSec) })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '消费金额', value: `¥${this.data.estimatedCost.toFixed(2)}`, valueColor: $r('app.color.accent') })
    }
    .width('100%')
  }

  build() {
    Column() {
      AppTopBar({ title: '充电中', pathStack: this.pathStack })

      Scroll() {
        Column({ space: 16 }) {
          this.StatusCard()

          Column() {
            this.InfoCardContent()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.app_card'))
          .borderRadius(12)
          .border({ width: 1, color: $r('app.color.divider') })

          PrimaryButton({
            label: '结束充电',
            color: $r('app.color.accent'),
            isDisabled: !this.order,
            onTap: () => this.finishCharging()
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
