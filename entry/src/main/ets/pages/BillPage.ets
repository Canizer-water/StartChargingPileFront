import { router } from '@kit.ArkUI';

@Entry
@Component
struct BillPage {
  @State orderNo: string = 'CP2026090212345678';
  @State paid: boolean = true;

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
      Text('账单详情')
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
  AmountCard() {
    Column({ space: 10 }) {
      Text('应付金额')
        .fontSize(14)
        .fontColor($r('app.color.charge_secondary'))
      Text('¥27.74')
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.accent'))
      Text(this.paid ? '已支付' : '待支付')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.login_primary'))
        .padding({ left: 14, right: 14, top: 5, bottom: 5 })
        .backgroundColor($r('app.color.charge_tint_bg'))
        .borderRadius(12)
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .padding(24)
    .backgroundColor($r('app.color.charge_card_bg'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
  }

  @Builder
  FeeRow(label: string, value: string, valueColor?: ResourceColor) {
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
  FeeCard() {
    Column({ space: 8 }) {
      this.FeeRow('充电电费（23.12 度 × ¥1.2/度）', '¥27.74')
      Divider().color($r('app.color.divider'))
      this.FeeRow('充电服务费', '¥3.00')
      Divider().color($r('app.color.divider'))
      this.FeeRow('停车费', '¥0.00')
      Divider().color($r('app.color.divider'))
      this.FeeRow('优惠', '-¥3.00')
      Divider().color($r('app.color.divider'))
      this.FeeRow('应付合计', '¥27.74', $r('app.color.accent'))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor($r('app.color.charge_card_bg'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.charge_secondary'))
      Blank()
      Text(value)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.charge_title'))
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(48)
  }

  @Builder
  InfoCard() {
    Column({ space: 8 }) {
      this.InfoRow('订单号', this.orderNo)
      Divider().color($r('app.color.divider'))
      this.InfoRow('充电桩', 'P-005 · 直流快充')
      Divider().color($r('app.color.divider'))
      this.InfoRow('充电时长', '31 min')
      Divider().color($r('app.color.divider'))
      this.InfoRow('充电电量', '23.12 kWh')
      Divider().color($r('app.color.divider'))
      this.InfoRow('支付方式', '微信支付')
      Divider().color($r('app.color.divider'))
      this.InfoRow('支付时间', '2026-09-02 12:34')
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
          this.AmountCard()
          this.FeeCard()
          this.InfoCard()

          Button(this.paid ? '返回首页' : '立即支付')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.login_primary'))
            .borderRadius(8)
            .margin({ top: 8, bottom: 24 })
            .onClick(() => {
              if (this.paid) {
                router.clear();
                router.pushUrl({ url: 'pages/Login' });
              } else {
                this.getUIContext().getPromptAction().showToast({ message: '支付功能开发中', duration: 2000 });
              }
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
