import { router } from '@kit.ArkUI';

interface PayMethod {
  icon: Resource;
  name: string;
}

@Entry
@Component
struct Recharge {
  @StorageLink('walletBalance') walletBalance: number = 0;
  @State selectedAmount: number = 50;
  @State customAmount: string = '';
  @State selectedPay: number = 0;
  private quickAmounts: number[] = [10, 50, 100, 200, 300, 500];
  private payMethods: PayMethod[] = [
    { icon: $r('sys.symbol.creditcard'), name: '微信支付' },
    { icon: $r('sys.symbol.wallet'), name: '支付宝' }
  ];

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private currentAmount(): number {
    if (this.customAmount !== '' && Number(this.customAmount) > 0) {
      return Number(this.customAmount);
    }
    return this.selectedAmount;
  }

  @Builder
  NavBar(title: string) {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor([$r('app.color.common_text_primary')])
        .margin({ left: 4 })
        .onClick(() => {
          router.back();
        })
      Blank()
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.common_text_primary'))
      Blank()
      Row().width(24)
    }
    .width('100%')
    .height(44)
    .padding({ left: 12, right: 12 })
  }

  @Builder
  BalanceCard() {
    Column() {
      Text('账户余额(元)')
        .fontSize(13)
        .fontColor(Color.White)
        .opacity(0.92)
      Text('0.00')
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(18)
    .borderRadius(12)
    .linearGradient({
      angle: 135,
      colors: [[0x9BC0F4, 0.0], [0x5B8CE7, 1.0]]
    })
  }

  @Builder
  AmountSection() {
    Column() {
      Text('选择充值金额')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.common_text_primary'))
        .width('100%')

      Grid() {
        ForEach(this.quickAmounts, (amount: number) => {
          GridItem() {
            Text(amount + ' 元')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.selectedAmount === amount ? Color.White : $r('app.color.common_text_primary'))
              .textAlign(TextAlign.Center)
              .height(52)
              .borderRadius(10)
              .backgroundColor(this.selectedAmount === amount ? $r('app.color.common_primary') : $r('app.color.common_bg'))
              .border({ width: 1, color: this.selectedAmount === amount ? $r('app.color.common_primary') : $r('app.color.common_border') })
              .onClick(() => {
                this.selectedAmount = amount;
                this.customAmount = '';
              })
          }
        }, (amount: number) => amount.toString())
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')

      TextInput({ placeholder: '其他金额（元）', text: this.customAmount })
        .type(InputType.Number)
        .fontSize(15)
        .fontColor($r('app.color.common_text_primary'))
        .placeholderColor($r('app.color.common_text_tertiary'))
        .backgroundColor($r('app.color.common_bg'))
        .borderRadius(10)
        .height(52)
        .margin({ top: 14 })
        .onChange((value: string) => {
          this.customAmount = value;
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(12)
    .margin({ top: 14 })
  }

  @Builder
  PaySection() {
    Column() {
      Text('支付方式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.common_text_primary'))
        .width('100%')
        .margin({ bottom: 6 })

      ForEach(this.payMethods, (method: PayMethod, index: number) => {
        Row() {
          Stack() {
            SymbolGlyph(method.icon)
              .fontSize(18)
              .fontColor([Color.White])
          }
          .width(32)
          .height(32)
          .borderRadius(8)
          .backgroundColor($r('app.color.common_primary'))

          Text(method.name)
            .fontSize(15)
            .fontColor($r('app.color.common_text_primary'))
            .margin({ left: 12 })

          Blank()

          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontSize(16)
            .fontColor([this.selectedPay === index ? $r('app.color.common_primary') : $r('app.color.common_border')])
        }
        .width('100%')
        .height(56)
        .onClick(() => {
          this.selectedPay = index;
        })
      }, (method: PayMethod) => method.name)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(12)
    .margin({ top: 14 })
  }

  build() {
    Column() {
      this.NavBar('充值')

      Scroll() {
        Column() {
          this.BalanceCard()
          this.AmountSection()
          this.PaySection()

          Text('充值金额将直接计入账户余额，仅用于演示，未对接真实支付')
            .fontSize(12)
            .fontColor($r('app.color.common_text_tertiary'))
            .width('100%')
            .margin({ top: 12, bottom: 8 })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)

      Button('立即充值 ' + this.currentAmount() + ' 元')
        .width('100%')
        .height(50)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.common_primary'))
        .borderRadius(25)
        .margin({ left: 16, right: 16, bottom: 20 })
        .onClick(() => {
          this.walletBalance = this.walletBalance + this.currentAmount();
          this.showToast('充值成功，已到账 ' + this.currentAmount() + ' 元');
          this.getUIContext().getRouter().back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_bg'))
  }
}
