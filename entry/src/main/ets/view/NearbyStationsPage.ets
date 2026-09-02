import { ChargingStation, NavParam } from '../model/Types';
import { StationService } from '../service/StationService';
import { MapView } from '../component/MapView';

/**
 * 一级页面：附近充电中心（含地图显示 + 最近大卡 + 推荐排行）。
 * 对应 Story 6（查看附近充电中心列表）。
 */

@Component
export struct NearbyStationsPage {
  pathStack: NavPathStack = new NavPathStack();

  @State stations: ChargingStation[] = [];
  @State nearest: ChargingStation | undefined = undefined;
  @State recommended: ChargingStation[] = [];

  aboutToAppear(): void {
    const svc = StationService.getInstance();
    this.stations = svc.getStations();
    this.nearest = svc.getNearest();
    this.recommended = svc.getRecommended();
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private goDetail(id: string): void {
    const param: NavParam = { id: id };
    this.pathStack.pushPathByName('StationDetail', param);
  }

  private onBack(): void {
    if (this.pathStack.size() > 0) {
      this.pathStack.pop();
    } else {
      this.showToast('已是附近电站首页');
    }
  }

  /** 顶部栏 */
  @Builder
  TopBar() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor([$r('app.color.text_primary')])
        .onClick(() => this.onBack())

      Text('附近电站')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .margin({ right: 24 })

      Blank().width(24)
    }
    .width('100%')
    .height(48)
    .padding({ left: 8, right: 8 })
    .backgroundColor($r('app.color.top_bar_bg'))
  }

  /** 标签 chip */
  @Builder
  TagChip(text: string, bg: ResourceColor, fg: ResourceColor) {
    Text(text)
      .fontSize(10)
      .fontColor(fg)
      .backgroundColor(bg)
      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      .borderRadius(3)
      .margin({ left: 4 })
  }

  /** 站点主图占位（无真实照片，用渐变 + 图标呈现） */
  @Builder
  StationBanner(station: ChargingStation, height: number) {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [[0x33A984, 0.0], [0x1FA869, 0.55], [0x0E6B44, 1.0]]
        })
      SymbolGlyph($r('sys.symbol.bolt_fill'))
        .fontSize(54)
        .fontColor(['rgba(255,255,255,0.82)'])
      Text(station.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .position({ x: 16, y: height - 46 })
    }
    .width('100%')
    .height(height)
    .borderRadius(12)
    .clip(true)
  }

  /** 「离我最近」大卡 */
  @Builder
  NearestCard(station: ChargingStation) {
    Column() {
      this.StationBanner(station, 180)

      Column() {
        Row() {
          Text(station.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          ForEach(station.tags, (tag: string) => {
            this.TagChip(tag,
              tag === '免停车费' ? $r('app.color.tag_green_bg') : $r('app.color.tag_blue_bg'),
              tag === '免停车费' ? $r('app.color.tag_green_text') : $r('app.color.tag_blue_text'))
          }, (tag: string) => tag)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text(station.address)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })
          .width('100%')

        Row() {
          Text(`${station.pricePerKwh.toFixed(2)}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.price_orange'))
          Text('元/度')
            .fontSize(12)
            .fontColor($r('app.color.price_orange'))
            .margin({ left: 1, bottom: 2 })
          Row() {
            SymbolGlyph($r('sys.symbol.clock'))
              .fontSize(12)
              .fontColor([$r('app.color.text_secondary')])
            Text('峰时')
              .fontSize(11)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 2 })
          }
          .padding({ left: 6, right: 6, top: 3, bottom: 3 })
          .backgroundColor($r('app.color.chip_bg'))
          .borderRadius(4)
          .margin({ left: 8 })

          Blank()

          Text(`空闲${station.freePiles}个`)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .margin({ top: 14 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({ top: 14, left: 14, right: 14, bottom: 16 })
    }
    .width('100%')
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .shadow({ radius: 10, color: 0x14000000, offsetY: 4 })
    .onClick(() => this.goDetail(station.id))
  }

  /** 推荐排行列表项 */
  @Builder
  RecommendedItem(station: ChargingStation) {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 135,
            colors: [[0x5AA8E0, 0.0], [0x2F7BF6, 0.6], [0x1B53BF, 1.0]]
          })
        SymbolGlyph($r('sys.symbol.bolt_fill'))
          .fontSize(28)
          .fontColor(['rgba(255,255,255,0.85)'])
      }
      .width(72)
      .height(72)
      .borderRadius(10)
      .clip(true)

      Column() {
        Row() {
          Text(station.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          ForEach(station.tags, (tag: string) => {
            this.TagChip(tag,
              tag === '免停车费' ? $r('app.color.tag_green_bg') : $r('app.color.tag_blue_bg'),
              tag === '免停车费' ? $r('app.color.tag_green_text') : $r('app.color.tag_blue_text'))
          }, (tag: string) => tag)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          Text(station.address)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          Text(`${station.distanceKm.toFixed(2)}Km`)
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 6 })
        }
        .width('100%')
        .margin({ top: 7 })

        Row() {
          Text(`${station.pricePerKwh.toFixed(2)}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.price_orange'))
          Text('元/度')
            .fontSize(11)
            .fontColor($r('app.color.price_orange'))
            .margin({ left: 1, bottom: 1 })
          Row() {
            SymbolGlyph($r('sys.symbol.clock'))
              .fontSize(11)
              .fontColor([$r('app.color.text_secondary')])
            Text('峰时')
              .fontSize(10)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 2 })
          }
          .padding({ left: 5, right: 5, top: 2, bottom: 2 })
          .backgroundColor($r('app.color.chip_bg'))
          .borderRadius(4)
          .margin({ left: 6 })

          Blank()

          Text(`空闲${station.freePiles}个`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .margin({ top: 8 })
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(10)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .onClick(() => this.goDetail(station.id))
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(19)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.text_primary'))
      .width('100%')
      .margin({ top: 16, bottom: 12 })
  }

  build() {
    Column() {
      this.TopBar()

      Scroll() {
        Column() {
          // 地图
          MapView({ stations: this.stations })
            .width('100%')
            .height(220)
            .borderRadius(12)
            .clip(true)
            .margin({ left: 14, right: 14, top: 6 })

          if (this.nearest) {
            this.SectionTitle('离我最近')
            this.NearestCard(this.nearest)
          }

          this.SectionTitle('推荐排行')
          ForEach(this.recommended, (st: ChargingStation) => {
            Column() {
              this.RecommendedItem(st)
            }
            .width('100%')
            .margin({ bottom: 10 })
          }, (st: ChargingStation) => st.id)
        }
        .padding({ left: 14, right: 14, bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
