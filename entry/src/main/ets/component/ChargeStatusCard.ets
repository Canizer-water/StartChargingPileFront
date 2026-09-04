import { ChargingOrder, NavParam } from '../model/Types';

/**
 * 首页充电状态卡片（Story 4）：
 * 未充电 → 引导找桩；充电中 → 展示站点/桩号并可点回充电中页面。
 * 数据源为 AppStorage 'currentOrder'（会话内共享）。
 */

@Component
export struct ChargeStatusCard {
  pathStack: NavPathStack = new NavPathStack();
  /** 未充电态 CTA：切换到底部「充电」tab */
  onFindPile?: () => void;

  @StorageProp('currentOrder') order: ChargingOrder | null = null;

  private goCharging(): void {
    if (!this.order) {
      return;
    }
    const param: NavParam = { id: this.order.id };
    this.pathStack.pushPathByName('Charging', param);
  }

  @Builder
  ChargingContent(o: ChargingOrder) {
    Row() {
      Stack() {
        Column()
          .width(48)
          .height(48)
          .borderRadius(12)
          .backgroundColor($r('app.color.charge_tint_bg'))
        SymbolGlyph($r('sys.symbol.bolt_fill'))
          .fontSize(26)
          .fontColor([$r('app.color.btn_primary')])
      }
      .width(48)
      .height(48)

      Column({ space: 4 }) {
        Text(`${o.stationName} · ${o.pileCode}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(`已充 ${o.energyKwh.toFixed(2)} 度 · ¥${o.unitPrice.toFixed(2)}/度`)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      Row({ space: 6 }) {
        Circle({ width: 8, height: 8 }).fill($r('app.color.accent'))
        Text('充电中')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.accent'))
      }
    }
    .width('100%')
    .onClick(() => this.goCharging())
  }

  @Builder
  IdleContent() {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
        SymbolGlyph($r('sys.symbol.bolt_fill'))
          .fontSize(22)
          .fontColor([$r('app.color.text_secondary')])
        Text('当前未在充电')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
      }
      .width('100%')

      Text('扫码或浏览附近电站，即可启动充电')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')

      Button('找桩充电')
        .height(36)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.btn_primary'))
        .backgroundColor($r('app.color.charge_tint_bg'))
        .borderRadius(18)
        .padding({ left: 20, right: 20 })
        .onClick(() => {
          if (this.onFindPile) {
            this.onFindPile();
          }
        })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  build() {
    Column() {
      if (this.order) {
        this.ChargingContent(this.order)
      } else {
        this.IdleContent()
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
  }
}
