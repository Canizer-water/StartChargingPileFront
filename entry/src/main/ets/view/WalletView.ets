import { NavParam } from '../model/Types';
import { AppTopBar } from '../component/AppTopBar';

/**
 * 我的钱包：余额 + 充值入口 + 发票入口。
 * 余额用 AppStorage 共享（@StorageLink 自动创建默认值 0）。
 */

@Component
export struct WalletView {
  pathStack: NavPathStack = new NavPathStack();

  @StorageLink('walletBalance') walletBalance: number = 0;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private go(route: string): void {
    const param: NavParam = { id: '' };
    this.pathStack.pushPathByName(route, param);
  }

  @Builder
  BalanceCard() {
    Column() {
      Text('账户余额(元)')
        .fontSize(14)
        .fontColor(Color.White)
        .opacity(0.92)

      Text(this.walletBalance.toFixed(2))
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .letterSpacing(1)
        .margin({ top: 6 })

      Row() {
        Text('查看充值记录')
          .fontSize(13)
          .fontColor(Color.White)
          .opacity(0.95)
          .onClick(() => this.showToast('充值记录开发中'))
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
          .backgroundColor('rgba(255,255,255,0.22)')
          .height(34)
          .borderRadius(17)
          .padding({ left: 22, right: 22 })
          .onClick(() => this.go('Recharge'))
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .width('100%')
    .padding(18)
    .borderRadius(12)
    .linearGradient({
      angle: 135,
      colors: [[$r('app.color.primary_light'), 0.0], [$r('app.color.btn_primary'), 0.6], [$r('app.color.brand_deep'), 1.0]]
    })
  }

  @Builder
  WalletRow(icon: Resource, title: string, subtitle: string, value: string, hasDot: boolean, click?: () => void) {
    Row() {
      Stack() {
        SymbolGlyph(icon)
          .fontSize(18)
          .fontColor([$r('app.color.btn_primary')])
      }
      .width(36)
      .height(36)
      .borderRadius(8)
      .backgroundColor($r('app.color.tint_blue'))

      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Text(subtitle)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      Stack() {
        if (value !== '') {
          Text(value)
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
        }
        if (hasDot) {
          Circle()
            .width(8)
            .height(8)
            .fill($r('app.color.red'))
            .position({ x: 0, y: -2 })
        }
      }

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(18)
        .fontColor([$r('app.color.text_muted')])
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
      AppTopBar({ title: '我的钱包', pathStack: this.pathStack })

      Scroll() {
        Column() {
          this.BalanceCard()

          Column() {
            this.WalletRow($r('sys.symbol.doc_text'), '发票', '只限开电子发票', '', false, () => {
              this.go('Invoice');
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.app_card'))
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
    .backgroundColor($r('app.color.app_bg'))
  }
}
