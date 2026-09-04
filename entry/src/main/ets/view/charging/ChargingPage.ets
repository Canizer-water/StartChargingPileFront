import { NavParam } from '../../model/Types';
import { AppTopBar } from '../../component/AppTopBar';
import { InfoRow } from '../../component/InfoRow';
import { PrimaryButton } from '../../component/PrimaryButton';

/**
 * 充电中（Story 11/12）：实时数据模拟刷新 + 结束充电。
 */
@Component
export struct ChargingPage {
  pathStack: NavPathStack = new NavPathStack();

  @State progress: number = 68;
  @State elapsed: number = 1860;
  private timerId: number = -1;

  aboutToAppear(): void {
    this.timerId = setInterval(() => {
      this.elapsed += 1;
      if (this.progress < 99) {
        this.progress += 0.05;
      }
    }, 1000);
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private formatTime(total: number): string {
    const h: number = Math.floor(total / 3600);
    const m: number = Math.floor((total % 3600) / 60);
    const s: number = Math.floor(total % 60);
    const pad = (n: number): string => (n < 10 ? `0${n}` : `${n}`);
    return `${pad(h)}:${pad(m)}:${pad(s)}`;
  }

  private getKwh(): number {
    return this.elapsed * 78.6 / 3600;
  }

  private finishCharging(): void {
    const param: NavParam = { id: 'P-005' };
    this.pathStack.pushPathByName('ChargeComplete', param);
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
        Progress({ value: this.progress, total: 100, type: ProgressType.Ring })
          .width(180)
          .height(180)
          .color($r('app.color.btn_primary'))
          .backgroundColor($r('app.color.charge_ring_bg'))
          .style({ strokeWidth: 14 })

        Column({ space: 4 }) {
          Text(`${Math.floor(this.progress)}%`)
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.btn_primary'))
          Text('充电进度')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
        }
      }

      Text('正在充电 · 直流快充')
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
        this.DataItem('已充电量', this.getKwh().toFixed(2), 'kWh')
        Column()
          .width(1)
          .height(32)
          .backgroundColor($r('app.color.divider'))
        this.DataItem('充电时长', `${Math.floor(this.elapsed / 60)}`, 'min')
        Column()
          .width(1)
          .height(32)
          .backgroundColor($r('app.color.divider'))
        this.DataItem('当前功率', '78.6', 'kW')
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
      InfoRow({ label: '充电桩', value: 'P-005' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '停车位', value: 'A-15' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '当前电压 / 电流', value: '750 V / 105 A' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电时长', value: this.formatTime(this.elapsed) })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '消费金额', value: `¥${(this.getKwh() * 1.2).toFixed(2)}`, valueColor: $r('app.color.accent') })
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
