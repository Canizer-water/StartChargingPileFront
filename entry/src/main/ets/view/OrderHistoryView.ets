import { NavParam } from '../model/Types';
import { AppTopBar } from '../component/AppTopBar';

/**
 * 历史订单：状态筛选 tab + 订单卡。
 */

interface OrderItem {
  station: string;
  time: string;
  amount: string;
  status: string;
}

@Component
export struct OrderHistoryView {
  pathStack: NavPathStack = new NavPathStack();

  @State currentTab: number = 0;
  private tabs: string[] = ['全部', '进行中', '已完成', '已取消'];

  @State orders: OrderItem[] = [
    { station: '东方明珠充电站 · 02号桩', time: '09-18 14:30', amount: '36.50', status: '已完成' },
    { station: '世纪公园快充站 · 05号桩', time: '09-18 10:12', amount: '28.00', status: '进行中' },
    { station: '虹桥枢纽充电站 · 01号桩', time: '09-17 20:45', amount: '52.80', status: '已完成' },
    { station: '陆家嘴慢充站 · 03号桩', time: '09-17 08:05', amount: '15.20', status: '已取消' }
  ];

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  /** 订单状态胶囊底色：进行中橙、已取消灰、其余品牌蓝 */
  private statusBg(status: string): ResourceColor {
    if (status === '进行中') {
      return $r('app.color.accent');
    }
    if (status === '已取消') {
      return $r('app.color.pile_offline');
    }
    return $r('app.color.btn_primary');
  }

  private getVisibleOrders(): OrderItem[] {
    if (this.currentTab === 0) {
      return this.orders;
    }
    const status: string = this.tabs[this.currentTab];
    return this.orders.filter((item: OrderItem) => item.status === status);
  }

  private go(route: string): void {
    const param: NavParam = { id: '' };
    this.pathStack.pushPathByName(route, param);
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
  OrderCard(item: OrderItem) {
    Column() {
      Row() {
        Text(item.station)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
        Text(item.status)
          .fontSize(13)
          .fontColor(Color.White)
          .backgroundColor(this.statusBg(item.status))
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
          Text(item.time)
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text('实付金额(元)')
            .fontSize(12)
            .fontColor($r('app.color.text_muted'))
          Text(item.amount)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .margin({ top: 14 })

      Row() {
        Blank()
        Text('查看详情')
          .fontSize(13)
          .fontColor($r('app.color.btn_primary'))
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .borderRadius(16)
          .border({ width: 1, color: $r('app.color.btn_primary') })
          .margin({ right: 12 })
          .onClick(() => this.showToast('订单详情开发中'))
        Text('再来一单')
          .fontSize(13)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.btn_primary'))
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .borderRadius(16)
          .onClick(() => this.go('NearbyStations'))
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      AppTopBar({ title: '历史订单', pathStack: this.pathStack })
      this.FilterBar()

      Scroll() {
        Column() {
          ForEach(this.getVisibleOrders(), (item: OrderItem) => {
            this.OrderCard(item)
          }, (item: OrderItem) => item.station + item.time)
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
