import { ChargingOrder } from '../../model/Types';
import { OrderService } from '../../service/OrderService';
import { AppTopBar } from '../../component/AppTopBar';
import { InfoRow } from '../../component/InfoRow';
import { PrimaryButton } from '../../component/PrimaryButton';

/**
 * 账单详情（Story 15）：费用明细 + 订单信息，数据取自订单服务。
 * 演示口径：仅电费参与结算，服务费/停车费/优惠为 0；已完成订单视为已支付。
 */

@Component
export struct BillPage {
  pathStack: NavPathStack = new NavPathStack();
  /** 账单订单号（由路由参数注入） */
  orderId: string = '';

  @State order: ChargingOrder | null = null;
  /** 回首页（Index 注入：清页面栈 + 切首页 tab）；缺省时退化为回导航栈底 */
  onHomeTab?: () => void;

  aboutToAppear(): void {
    OrderService.getInstance().getOrderById(this.orderId).then((order) => {
      if (!order) {
        this.toast('未找到订单');
        this.pathStack.pop();
        return;
      }
      this.order = order;
    }).catch(() => {
      this.toast('订单加载失败');
    });
  }

  private toast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`BillPage toast failed: ${JSON.stringify(err)}`);
    }
  }

  private paid(): boolean {
    return this.order !== null && this.order.status === 'FINISHED';
  }

  private backHome(): void {
    if (this.onHomeTab) {
      this.onHomeTab();
      return;
    }
    this.pathStack.popToIndex(0);
  }

  @Builder
  AmountCard(o: ChargingOrder) {
    Column({ space: 10 }) {
      Text('应付金额')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
      Text(`¥${o.amount.toFixed(2)}`)
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.accent'))
      Text(this.paid() ? '已支付' : '待支付')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.btn_primary'))
        .padding({ left: 14, right: 14, top: 5, bottom: 5 })
        .backgroundColor($r('app.color.charge_tint_bg'))
        .borderRadius(12)
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .padding(24)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
  }

  @Builder
  FeeCardContent(o: ChargingOrder) {
    Column({ space: 8 }) {
      InfoRow({ label: `充电电费（${o.energyKwh.toFixed(2)} 度 × ¥${o.unitPrice.toFixed(2)}/度）`, value: `¥${o.amount.toFixed(2)}` })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电服务费', value: '¥0.00' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '停车费', value: '¥0.00' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '优惠', value: '-¥0.00' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '应付合计', value: `¥${o.amount.toFixed(2)}`, valueColor: $r('app.color.accent') })
    }
    .width('100%')
  }

  @Builder
  InfoCardContent(o: ChargingOrder) {
    Column({ space: 8 }) {
      InfoRow({ label: '订单号', value: o.id })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电订单', value: `${o.stationName} · ${o.pileCode}` })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电时长', value: `${o.durationMin} min` })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电电量', value: `${o.energyKwh.toFixed(2)} kWh` })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '支付方式', value: '余额支付（演示）' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '支付时间', value: o.endTime === '' ? '—' : o.endTime })
    }
    .width('100%')
  }

  build() {
    Column() {
      AppTopBar({ title: '账单详情', pathStack: this.pathStack })

      Scroll() {
        Column({ space: 16 }) {
          if (this.order) {
            this.AmountCard(this.order)

            Column() {
              this.FeeCardContent(this.order)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor($r('app.color.app_card'))
            .borderRadius(12)
            .border({ width: 1, color: $r('app.color.divider') })

            Column() {
              this.InfoCardContent(this.order)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor($r('app.color.app_card'))
            .borderRadius(12)
            .border({ width: 1, color: $r('app.color.divider') })

            PrimaryButton({
              label: this.paid() ? '返回首页' : '充电未结束',
              isDisabled: !this.paid(),
              onTap: () => this.backHome()
            })
          }
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
