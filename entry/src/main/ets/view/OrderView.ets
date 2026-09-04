import { common } from '@kit.AbilityKit';
import { ChargingOrder, NavParam } from '../model/Types';
import { OrderService } from '../service/OrderService';
import { AppTopBar } from '../component/AppTopBar';

/**
 * 订单列表（Story 14）：状态筛选 + 订单卡，数据来自 OrderService。
 * 「查看详情」进入账单页（Story 15），「再来一单」回到附近电站。
 */

@Component
export struct OrderView {
  pathStack: NavPathStack = new NavPathStack();
  /** tab 模式（主框架内嵌）时隐藏返回键 */
  embedded: boolean = false;

  @State currentTab: number = 0;
  @State orders: ChargingOrder[] = [];
  @StorageProp('ordersVersion') @Watch('reload') ordersVersion: number = 0;

  private tabs: string[] = ['全部', '充电中', '已完成'];

  aboutToAppear(): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    OrderService.getInstance().init(ctx).then(() => this.reload());
  }

  private reload(): void {
    OrderService.getInstance().listOrders().then((list: ChargingOrder[]) => {
      this.orders = list;
    }).catch(() => {
      // 存储异常时保持旧数据
    });
  }

  private statusLabel(o: ChargingOrder): string {
    return o.status === 'CHARGING' ? '充电中' : '已完成';
  }

  /** 订单状态胶囊底色：充电中橙、已完成品牌蓝 */
  private statusBg(o: ChargingOrder): ResourceColor {
    return o.status === 'CHARGING' ? $r('app.color.accent') : $r('app.color.btn_primary');
  }

  private getVisibleOrders(): ChargingOrder[] {
    if (this.currentTab === 0) {
      return this.orders;
    }
    const status: string = this.currentTab === 1 ? 'CHARGING' : 'FINISHED';
    return this.orders.filter((o: ChargingOrder) => o.status === status);
  }

  private goOrderDetail(orderId: string): void {
    const param: NavParam = { id: orderId };
    this.pathStack.pushPathByName('Bill', param);
  }

  private goCharging(orderId: string): void {
    const param: NavParam = { id: orderId };
    this.pathStack.pushPathByName('Charging', param);
  }

  private goNearby(): void {
    const param: NavParam = { id: '' };
    this.pathStack.pushPathByName('NearbyStations', param);
  }

  @Builder
  FilterBar() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Text(tab)
          .fontSize(14)
          .fontColor(this.currentTab === index ? Color.White : $r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.currentTab === index ? $r('app.color.btn_primary') : $r('app.color.app_card'))
          .borderRadius(16)
          .margin({ right: 10 })
          .onClick(() => {
            this.currentTab = index;
          })
      }, (tab: string) => tab)
    }
    .width('100%')
    .margin({ top: 14, bottom: 12 })
  }

  @Builder
  OrderCard(o: ChargingOrder) {
    Column() {
      Row() {
        Text(`${o.stationName} · ${o.pileCode}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          .margin({ right: 8 })
        Text(this.statusLabel(o))
          .fontSize(13)
          .fontColor(Color.White)
          .backgroundColor(this.statusBg(o))
          .borderRadius(10)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      }
      .width('100%')
      .margin({ bottom: 14 })

      Divider().color($r('app.color.divider')).strokeWidth(1)

      Row() {
        Column() {
          Text('充电时间')
            .fontSize(12)
            .fontColor($r('app.color.text_muted'))
          Text(o.startTime)
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text('充电量(度)')
            .fontSize(12)
            .fontColor($r('app.color.text_muted'))
          Text(o.energyKwh.toFixed(2))
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)

        Column() {
          Text('实付金额(元)')
            .fontSize(12)
            .fontColor($r('app.color.text_muted'))
          Text(o.amount.toFixed(2))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.End)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 14 })

      Row() {
        Blank()
        if (o.status === 'CHARGING') {
          Text('去充电')
            .fontSize(13)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.btn_primary'))
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .borderRadius(16)
            .onClick(() => this.goCharging(o.id))
        } else {
          Text('查看详情')
            .fontSize(13)
            .fontColor($r('app.color.btn_primary'))
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .borderRadius(16)
            .border({ width: 1, color: $r('app.color.btn_primary') })
            .margin({ right: 12 })
            .onClick(() => this.goOrderDetail(o.id))
          Text('再来一单')
            .fontSize(13)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.btn_primary'))
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .borderRadius(16)
            .onClick(() => this.goNearby())
        }
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
    .margin({ bottom: 12 })
  }

  @Builder
  EmptyTip() {
    Column({ space: 10 }) {
      SymbolGlyph($r('sys.symbol.doc_text'))
        .fontSize(44)
        .fontColor([$r('app.color.text_muted')])
      Text('暂无订单，去启动一次充电吧')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .padding({ top: 80 })
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      AppTopBar({ title: '充电订单', pathStack: this.pathStack, showBack: !this.embedded })
      this.FilterBar()

      Scroll() {
        Column() {
          if (this.getVisibleOrders().length === 0) {
            this.EmptyTip()
          }
          ForEach(this.getVisibleOrders(), (o: ChargingOrder) => {
            this.OrderCard(o)
          }, (o: ChargingOrder) => o.id)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
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
