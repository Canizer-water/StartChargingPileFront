import { router } from '@kit.ArkUI';

@Entry
@Component
struct ChargingPage {
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

  @Builder
  TitleBar() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor([$r('app.color.charge_secondary')])
        .onClick(() => {
          router.back();
        })
      Blank()
      Text('充电中')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.charge_title'))
      Blank()
      Row()
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  DataItem(label: string, value: string, unit: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.charge_secondary'))
      Row() {
        Text(value)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.login_primary'))
        Text(unit)
          .fontSize(12)
          .fontColor($r('app.color.charge_secondary'))
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
          .color($r('app.color.login_primary'))
          .backgroundColor($r('app.color.charge_ring_bg'))
          .style({ strokeWidth: 14 })

        Column({ space: 4 }) {
          Text(`${Math.floor(this.progress)}%`)
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.login_primary'))
          Text('充电进度')
            .fontSize(13)
            .fontColor($r('app.color.charge_secondary'))
        }
      }

      Text('正在充电 · 直流快充')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.login_primary'))
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
    .backgroundColor($r('app.color.charge_card_bg'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
  }

  @Builder
  InfoRow(label: string, value: string, valueColor?: ResourceColor) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.charge_secondary'))
      Blank()
      Text(value)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(valueColor ?? $r('app.color.charge_title'))
    }
    .width('100%')
    .height(48)
  }

  @Builder
  InfoCard() {
    Column({ space: 8 }) {
      this.InfoRow('充电桩', 'P-005')
      Divider().color($r('app.color.divider'))
      this.InfoRow('停车位', 'A-15')
      Divider().color($r('app.color.divider'))
      this.InfoRow('当前电压 / 电流', '750 V / 105 A')
      Divider().color($r('app.color.divider'))
      this.InfoRow('充电时长', this.formatTime(this.elapsed))
      Divider().color($r('app.color.divider'))
      this.InfoRow('消费金额', `¥${(this.getKwh() * 1.2).toFixed(2)}`, $r('app.color.accent'))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor($r('app.color.charge_card_bg'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
  }

  build() {
    Column() {
      this.TitleBar()

      Scroll() {
        Column({ space: 16 }) {
          this.StatusCard()
          this.InfoCard()

          Button('结束充电')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.accent'))
            .borderRadius(8)
            .margin({ top: 8, bottom: 24 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/ChargeCompletePage' });
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
