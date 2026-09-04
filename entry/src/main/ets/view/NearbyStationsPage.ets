import { ChargingStation, NavParam } from '../model/Types';
import { StationService } from '../service/StationService';
import { MapView } from '../component/MapView';
import { AppTopBar } from '../component/AppTopBar';

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

  private goDetail(id: string): void {
    const param: NavParam = { id: id };
    this.pathStack.pushPathByName('StationDetail', param);
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
          colors: [[$r('app.color.primary_light'), 0.0], [$r('app.color.btn_primary'), 0.55], [$r('app.color.brand_deep'), 1.0]]
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
    .border({ width: 1, color: $r('app.color.divider') })
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
            colors: [[$r('app.color.primary_light'), 0.0], [$r('app.color.btn_primary'), 0.6], [$r('app.color.brand_deep'), 1.0]]
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
      .fontSize(17)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.text_primary'))
      .width('100%')
      .margin({ top: 16, bottom: 12 })
  }

  build() {
    Column() {
      AppTopBar({ title: '附近电站', pathStack: this.pathStack })

      Scroll() {
        Column() {
          // 地图
          MapView({ stations: this.stations })
            .width('100%')
            .height(220)
            .borderRadius(12)
            .clip(true)
            .margin({ top: 8 })

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
        .padding({ left: 16, right: 16, bottom: 20 })
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
