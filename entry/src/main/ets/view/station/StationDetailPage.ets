import { ChargingPile, ChargingStation, NavParam } from '../../model/Types';
import { StationService } from '../../service/StationService';

/**
 * 二级页面：充电中心详情。
 * 对应 Story 7（查看充电中心详情）。
 */

@Component
export struct StationDetailPage {
  pathStack: NavPathStack = new NavPathStack();
  stationId: string = '';

  @State station: ChargingStation | undefined = undefined;

  aboutToAppear(): void {
    this.station = StationService.getInstance().getStationById(this.stationId);
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private goPile(pileId: string): void {
    const param: NavParam = { id: pileId };
    this.pathStack.pushPathByName('PileDetail', param);
  }

  /** 顶部大图 + 信息覆盖 */
  @Builder
  Hero(station: ChargingStation) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 160,
          colors: [[$r('app.color.primary_light'), 0.0], [$r('app.color.btn_primary'), 0.6], [$r('app.color.brand_deep'), 1.0]]
        })

      // 返回按钮
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor([Color.White])
        .position({ x: 10, y: 10 })
        .onClick(() => this.pathStack.pop())

      // 右下两个圆形按钮
      Row({ space: 12 }) {
        Stack() {
          Circle({ width: 40, height: 40 }).fill('rgba(255,255,255,0.92)')
          SymbolGlyph($r('sys.symbol.navigation'))
            .fontSize(20)
            .fontColor([$r('app.color.primary_blue')])
        }
        .width(40)
        .height(40)
        .onClick(() => this.showToast('发起导航（演示）'))

        Stack() {
          Circle({ width: 40, height: 40 }).fill('rgba(255,255,255,0.92)')
          SymbolGlyph($r('sys.symbol.share'))
            .fontSize(20)
            .fontColor([$r('app.color.primary_blue')])
        }
        .width(40)
        .height(40)
        .onClick(() => this.showToast('分享（演示）'))
      }
      .position({ x: '68%', y: '62%' })

      // 左下方信息
      Column() {
        Text(station.name)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        Text(station.address)
          .fontSize(13)
          .fontColor('rgba(255,255,255,0.86)')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 6 })
          .constraintSize({ maxWidth: '76%' })
        Text(`${station.distanceKm.toFixed(1)}km`)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16, bottom: 16 })
    }
    .width('100%')
    .height(250)
    .clip(true)
  }

  /** 占用 / 空闲 */
  @Builder
  Counts(station: ChargingStation) {
    Row() {
      Stack() {
        Circle({ width: 10, height: 10 }).fill($r('app.color.price_orange'))
      }
      Text(`${station.occupied}个`)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ left: 6 })
      Text('占用')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ left: 4 })

      Stack() {
        Circle({ width: 10, height: 10 }).fill($r('app.color.pile_idle'))
      }
      .margin({ left: 24 })
      Text(`${station.freePiles}个`)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ left: 6 })
      Text('空闲')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ left: 4 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor($r('app.color.app_card'))
  }

  /** 收费与营业信息 */
  @Builder
  InfoGrid(station: ChargingStation) {
    Column() {
      Row() {
        Column() {
          Text('收费方式')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
          Text(station.feeMode)
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text('实时电价')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
          Row() {
            Text(`${station.pricePerKwh.toFixed(2)}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.price_orange'))
            Text('元/度')
              .fontSize(12)
              .fontColor($r('app.color.price_orange'))
              .margin({ left: 1, bottom: 1 })
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 16 })

      Row() {
        Column() {
          Text('停车费')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
          Text(station.parkingFee)
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text('营业时间')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
          Row() {
            Text(station.businessHours)
              .fontSize(15)
              .fontColor($r('app.color.text_primary'))
            SymbolGlyph($r('sys.symbol.phone'))
              .fontSize(18)
              .fontColor([$r('app.color.primary_blue')])
              .margin({ left: 8 })
              .onClick(() => this.showToast(`拨打 ${station.phone}`))
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor($r('app.color.app_card'))
    .margin({ top: 8 })
  }

  /** 单个充电桩卡片 */
  @Builder
  PileCard(pile: ChargingPile) {
    Column() {
      Row() {
        Text('充电桩：')
          .fontSize(15)
          .fontColor($r('app.color.text_secondary'))
        Text(pile.code)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Row() {
          SymbolGlyph($r('sys.symbol.bolt_fill'))
            .fontSize(14)
            .fontColor([$r('app.color.btn_primary')])
          Text('充电')
            .fontSize(14)
            .fontColor($r('app.color.btn_primary'))
            .margin({ left: 3 })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .border({ width: 1, color: $r('app.color.btn_primary') })
        .borderRadius(18)
        .onClick(() => this.goPile(pile.id))
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(`停车位号：${pile.slotCode}`)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ top: 8 })

      Row() {
        Text('类型：')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
        Text('直流快充')
          .fontSize(11)
          .fontColor($r('app.color.tag_blue_text'))
          .backgroundColor($r('app.color.tag_blue_bg'))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(3)
          .margin({ left: 4 })
        Text(pile.ground)
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor($r('app.color.chip_bg'))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(3)
          .margin({ left: 6 })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .margin({ top: 10, bottom: 4 })
  }

  build() {
    NavDestination() {
      Column() {
        if (this.station) {
          this.Hero(this.station)
          this.Counts(this.station)
          this.InfoGrid(this.station)

          Text('推荐充电桩')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .padding({ left: 16, top: 18, bottom: 8 })

          Scroll() {
            Column() {
              ForEach(this.station.piles, (pile: ChargingPile) => {
                this.PileCard(pile)
              }, (pile: ChargingPile) => pile.id)
            }
            .padding({ left: 16, right: 16, bottom: 20 })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.app_bg'))
    }
    .hideTitleBar(true)
  }
}
