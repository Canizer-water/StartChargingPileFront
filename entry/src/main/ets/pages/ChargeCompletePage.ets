import { router } from '@kit.ArkUI';

@Entry
@Component
struct ChargeCompletePage {
  @State duration: string = '31';
  @State kwh: string = '23.12';
  @State cost: string = '27.74';

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
      Text('充电完成')
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
  SuccessCard() {
    Column({ space: 16 }) {
      Stack() {
        Column()
          .width(96)
          .height(96)
          .borderRadius(48)
          .backgroundColor($r('app.color.charge_tint_bg'))
        Text('✓')
          .fontSize(52)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.login_primary'))
      }
      .width(96)
      .height(96)

      Text('充电已完成')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.charge_title'))

      Text('请及时取走充电枪，注意行车安全')
        .fontSize(14)
        .fontColor($r('app.color.charge_secondary'))
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .padding(28)
    .backgroundColor($r('app.color.charge_card_bg'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
  }

  @Builder
  SummaryRow(label: string, value: string, valueColor?: ResourceColor) {
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
  SummaryCard() {
    Column({ space: 8 }) {
      this.SummaryRow('充电桩', 'P-005')
      Divider().color($r('app.color.divider'))
      this.SummaryRow('充电时长', `${this.duration} min`)
      Divider().color($r('app.color.divider'))
      this.SummaryRow('充电电量', `${this.kwh} kWh`, $r('app.color.login_primary'))
      Divider().color($r('app.color.divider'))
      this.SummaryRow('订单号', 'CP2026090212345678')
      Divider().color($r('app.color.divider'))
      this.SummaryRow('充电费用', `¥${this.cost}`, $r('app.color.accent'))
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
          this.SuccessCard()
          this.SummaryCard()

          Row({ space: 14 }) {
            Button('返回首页')
              .layoutWeight(1)
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.login_primary'))
              .backgroundColor(Color.White)
              .border({ width: 1, color: $r('app.color.login_primary'), radius: 8 })
              .onClick(() => {
                router.clear();
                router.pushUrl({ url: 'pages/Login' });
              })
            Button('查看账单')
              .layoutWeight(1)
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.login_primary'))
              .borderRadius(8)
              .onClick(() => {
                router.pushUrl({ url: 'pages/BillPage' });
              })
          }
          .width('100%')
          .margin({ top: 8, bottom: 24 })
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
