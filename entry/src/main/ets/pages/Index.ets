import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @Builder
  EntryItem(title: string, subtitle: string, symbol: Resource, target: string) {
    Row({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(46)
          .height(46)
          .borderRadius(23)
          .backgroundColor($r('app.color.charge_tint_bg'))
        SymbolGlyph(symbol)
          .fontSize(24)
          .fontColor([$r('app.color.login_primary')])
      }
      Column({ space: 3 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.charge_title'))
        Text(subtitle)
          .fontSize(13)
          .fontColor($r('app.color.charge_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(20)
        .fontColor([$r('app.color.charge_secondary')])
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.charge_card_bg'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
    .onClick(() => {
      router.pushUrl({ url: target });
    })
  }

  build() {
    Column({ space: 16 }) {
      Text('AI 功能')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.charge_title'))
        .width('100%')
        .margin({ top: 24 })

      this.EntryItem('AI 车牌识别', '拍照 / 选图识别车牌号', $r('sys.symbol.car'), 'pages/LicensePlatePage')
      this.EntryItem('AI 助手', '大模型智能问答对话', $r('sys.symbol.ellipsis_message'), 'pages/AiChatPage')

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
    .backgroundColor($r('app.color.charge_field_bg'))
  }
}
