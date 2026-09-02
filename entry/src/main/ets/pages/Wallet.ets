import { router } from '@kit.ArkUI';

@Entry
@Component
struct Wallet {
  @StorageLink('walletBalance') walletBalance: number = 0;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  @Builder
  NavBar(title: string) {
    Column() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .fontColor([$r('app.color.common_text_primary')])
          .margin({ left: 4 })
          .onClick(() => {
            router.back();
          })
        Blank()
      }
      .width('100%')
      .height(44)
      .padding({ left: 12, right: 16 })

      Text(title)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.common_text_primary'))
        .margin({ left: 16, top: 10 })
    }
    .width('100%')
  }

  @Builder
  BalanceCard() {
    Column() {
      Text('账户余额(元)')
        .fontSize(14)
        .fontColor(Color.White)
        .opacity(0.92)

      Text(this.walletBalance.toFixed(2))
        .fontSize(46)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .letterSpacing(1)
        .margin({ top: 6 })

      Row() {
        Text('查看充值记录')
          .fontSize(13)
          .fontColor(Color.White)
          .opacity(0.95)
          .onClick(() => {
            this.showToast('充值记录开发中');
          })
        Text('>>')
          .fontSize(12)
          .fontColor(Color.White)
          .opacity(0.95)
          .margin({ left: 2 })

        Blank()

        Button('充 值')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.common_primary_light'))
          .height(34)
          .borderRadius(17)
          .padding({ left: 22, right: 22 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/Recharge' }).catch((err: Error) => {
              console.error(`navigate recharge failed: ${JSON.stringify(err)}`);
            });
          })
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .width('100%')
    .padding(18)
    .borderRadius(12)
    .linearGradient({
      angle: 135,
      colors: [[0x9BC0F4, 0.0], [0x5B8CE7, 1.0]]
    })
  }

  @Builder
  WalletRow(icon: Resource, title: string, subtitle: string, value: string, hasDot: boolean, click?: () => void) {
    Row() {
      Stack() {
        SymbolGlyph(icon)
          .fontSize(18)
          .fontColor([Color.White])
      }
      .width(36)
      .height(36)
      .borderRadius(8)
      .backgroundColor($r('app.color.common_primary'))

      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.common_text_primary'))
        Text(subtitle)
          .fontSize(13)
          .fontColor($r('app.color.common_text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      Stack() {
        if (value !== '') {
          Text(value)
            .fontSize(16)
            .fontColor($r('app.color.common_text_primary'))
        }
        if (hasDot) {
          Circle()
            .width(8)
            .height(8)
            .fill($r('app.color.common_red'))
            .position({ x: 0, y: -2 })
        }
      }

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(18)
        .fontColor([$r('app.color.common_text_secondary')])
        .margin({ left: 10 })
    }
    .width('100%')
    .height(76)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      if (click) {
        click();
      }
    })
  }

  build() {
    Column() {
      this.NavBar('我的钱包')

      Scroll() {
        Column() {
          this.BalanceCard()

          Column() {
            this.WalletRow($r('sys.symbol.doc_text'), '发票', '只限开电子发票', '', false, () => {
              router.pushUrl({ url: 'pages/Invoice' }).catch((err: Error) => {
                console.error(`navigate invoice failed: ${JSON.stringify(err)}`);
              });
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.common_card_bg'))
          .borderRadius(12)
          .margin({ top: 16 })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_bg'))
  }
}
