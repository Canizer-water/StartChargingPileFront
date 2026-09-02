import { router } from '@kit.ArkUI';

interface HomeItem {
  icon: Resource;
  title: string;
  desc: string;
  color: string;
  url: string;
}

@Entry
@Component
struct Index {
  private homeItems: HomeItem[] = [
    { icon: $r('sys.symbol.wallet'), title: '我的钱包', desc: '余额 · 红包 · 优惠券 · 发票', color: '#5B8CE7', url: 'pages/Wallet' },
    { icon: $r('sys.symbol.car'), title: '我的爱车', desc: '车辆管理 · 自动支付', color: '#ED823E', url: 'pages/MyVehicles' },
    { icon: $r('sys.symbol.doc_text'), title: '历史订单', desc: '全部 · 进行中 · 已完成', color: '#6B5CE7', url: 'pages/OrderHistory' }
  ];

  private navigate(url: string): void {
    router.pushUrl({ url: url }).catch((err: Error) => {
      console.error(`navigate failed: ${JSON.stringify(err)}`);
    });
  }

  @Builder
  Header() {
    Column() {
      Text('智能充电桩')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.common_text_primary'))
        .width('100%')
      Text('扫码充电 · 智慧出行')
        .fontSize(14)
        .fontColor($r('app.color.common_text_secondary'))
        .width('100%')
        .margin({ top: 8 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
  }

  @Builder
  MenuCard(item: HomeItem) {
    Row() {
      Stack() {
        SymbolGlyph(item.icon)
          .fontSize(24)
          .fontColor([Color.White])
      }
      .width(48)
      .height(48)
      .borderRadius(12)
      .backgroundColor(item.color)

      Column() {
        Text(item.title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.common_text_primary'))
        Text(item.desc)
          .fontSize(13)
          .fontColor($r('app.color.common_text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(18)
        .fontColor([$r('app.color.common_text_secondary')])
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => {
      this.navigate(item.url);
    })
  }

  build() {
    Column() {
      this.Header()
      Scroll() {
        Column() {
          ForEach(this.homeItems, (item: HomeItem) => {
            this.MenuCard(item)
          }, (item: HomeItem) => item.title)
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
