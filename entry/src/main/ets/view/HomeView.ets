import { ChargeStatusCard } from '../component/ChargeStatusCard';

/**
 * 首页 tab（Story 4/5）：充电状态卡片 + 附近充电站快捷入口。
 * 原「我的服务」宫格为超纲功能入口，本轮按 doc 功能点范围撤下。
 */

@Component
export struct HomeView {
  pathStack: NavPathStack = new NavPathStack();
  /** 切换主框架底部 tab（附近电站入口 / 找桩 CTA 用） */
  onGoTab?: (index: number) => void;

  @Builder
  Header() {
    Column() {
      Text('智能充电桩')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
      Text('扫码充电 · 智慧出行')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ top: 8 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
  }

  /** 附近电站入口横幅（Story 5：点击切到充电 tab） */
  @Builder
  NearbyBanner() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [[$r('app.color.primary_light'), 0.0], [$r('app.color.btn_primary'), 0.6], [$r('app.color.brand_deep'), 1.0]]
        })
      Row() {
        SymbolGlyph($r('sys.symbol.bolt_fill'))
          .fontSize(30)
          .fontColor(['rgba(255,255,255,0.9)'])
        Column() {
          Text('附近电站')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text('一键查找周边充电中心')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.86)')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(20)
          .fontColor([Color.White])
      }
      .padding({ left: 18, right: 18 })
      .width('100%')
    }
    .width('100%')
    .height(96)
    .borderRadius(14)
    .clip(true)
    .onClick(() => {
      if (this.onGoTab) {
        this.onGoTab(1);
      }
    })
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(17)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.text_primary'))
      .width('100%')
      .margin({ top: 8, bottom: 12 })
  }

  build() {
    Column() {
      this.Header()

      Scroll() {
        Column() {
          this.SectionTitle('充电状态')
          ChargeStatusCard({
            pathStack: this.pathStack,
            onFindPile: () => {
              if (this.onGoTab) {
                this.onGoTab(1);
              }
            }
          })

          this.SectionTitle('快捷入口')
          this.NearbyBanner()
        }
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
