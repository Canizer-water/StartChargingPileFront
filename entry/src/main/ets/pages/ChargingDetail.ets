import { router } from '@kit.ArkUI';

interface RouteParams {
  station?: string;
}

@Entry
@Component
struct ChargingDetail {
  @State station: string = '东方明珠充电站 · 02号桩';
  @State pileNo: string = '02 号桩';
  @State status: string = '空闲';
  @State power: string = '120kW';
  @State pricePeak: string = '1.50';
  @State priceValley: string = '0.80';

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  aboutToAppear(): void {
    const params = router.getParams() as RouteParams;
    if (params && params.station) {
      this.station = params.station;
    }
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
  HeaderCard() {
    Column() {
      Row() {
        Column() {
          Text(this.station)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.common_text_primary'))
          Text('上海市浦东新区 · 距您 0.5km')
            .fontSize(12)
            .fontColor($r('app.color.common_text_secondary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.status)
          .fontSize(13)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.common_primary'))
          .borderRadius(10)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      }
      .width('100%')

      Divider().color($r('app.color.common_divider')).strokeWidth(1).margin({ top: 14, bottom: 14 })

      Row() {
        Column() {
          Text(this.power)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.common_text_primary'))
          Text('最大功率')
            .fontSize(12)
            .fontColor($r('app.color.common_text_secondary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.pricePeak)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.common_text_primary'))
          Text('高峰电价(元/度)')
            .fontSize(12)
            .fontColor($r('app.color.common_text_secondary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.priceValley)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.common_text_primary'))
          Text('低谷电价(元/度)')
            .fontSize(12)
            .fontColor($r('app.color.common_text_secondary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(12)
    .margin({ top: 14 })
  }

  @Builder
  TipsCard() {
    Column() {
      Text('充电须知')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.common_text_primary'))
        .width('100%')
        .margin({ bottom: 10 })

      ForEach([
        '· 兼容特斯拉 / 蔚来 / 小鹏等主流车型',
        '· 支持扫码启动，充满自动断电',
        '· 请确认车辆电池接口与桩型匹配',
        '· 环境异常时请勿充电，及时联系客服'
      ], (tip: string) => {
        Text(tip)
          .fontSize(13)
          .fontColor($r('app.color.common_text_secondary'))
          .width('100%')
          .margin({ bottom: 6 })
      }, (tip: string) => tip)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(12)
    .margin({ top: 14 })
  }

  build() {
    Column() {
      this.NavBar('充电桩详情')

      Scroll() {
        Column() {
          this.HeaderCard()
          this.TipsCard()
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)

      Button('开始充电')
        .width('100%')
        .height(50)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.common_primary'))
        .borderRadius(25)
        .margin({ left: 16, right: 16, bottom: 20 })
        .onClick(() => {
          this.showToast('已确认开始充电');
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_bg'))
  }
}
