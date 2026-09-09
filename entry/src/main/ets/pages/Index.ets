import { NavParam } from '../model/Types';
import { HomeView } from '../view/HomeView';
import { NearbyStationsPage } from '../view/NearbyStationsPage';
import { StationDetailPage } from '../view/station/StationDetailPage';
import { PileDetailPage } from '../view/station/PileDetailPage';
import { StationMapPage } from '../view/station/StationMapPage';
import { OrderView } from '../view/OrderView';
import { MineView } from '../view/mine/MineView';
import { ScanView } from '../view/charging/ScanView';
import { ChargingPage } from '../view/charging/ChargingPage';
import { ChargeCompletePage } from '../view/charging/ChargeCompletePage';
import { BillPage } from '../view/charging/BillPage';

/**
 * 主框架（Story 3）：Navigation 宿主，NavBar 内容为底部 5 个 tab
 * （首页/充电/扫一扫/订单/我的），二级页面统一 NavDestination 注册。
 * 超纲页面（钱包/爱车/通知等）已从路由表撤下，文件保留待后续迭代。
 */

@Component
@Entry
struct Index {
  pathStack: NavPathStack = new NavPathStack();
  private tabsController: TabsController = new TabsController();
  @State activeTab: number = 0;

  private idOf(param: object): string {
    if (!param) {
      return '';
    }
    return (param as NavParam).id;
  }

  private goTab(index: number): void {
    this.activeTab = index;
    this.tabsController.changeIndex(index);
  }

  @Builder
  PageMap(name: string, param: object) {
    if (name === 'NearbyStations') {
      NavDestination() {
        NearbyStationsPage({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'StationDetail') {
      NavDestination() {
        StationDetailPage({ pathStack: this.pathStack, stationId: this.idOf(param) })
      }.hideTitleBar(true)
    } else if (name === 'StationMap') {
      NavDestination() {
        StationMapPage({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'PileDetail') {
      NavDestination() {
        PileDetailPage({ pathStack: this.pathStack, pileId: this.idOf(param) })
      }.hideTitleBar(true)
    } else if (name === 'Charging') {
      NavDestination() {
        ChargingPage({ pathStack: this.pathStack, orderId: this.idOf(param) })
      }.hideTitleBar(true)
    } else if (name === 'ChargeComplete') {
      NavDestination() {
        ChargeCompletePage({ pathStack: this.pathStack, orderId: this.idOf(param) })
      }.hideTitleBar(true)
    } else if (name === 'Bill') {
      NavDestination() {
        BillPage({ pathStack: this.pathStack, orderId: this.idOf(param) })
      }.hideTitleBar(true)
    }
  }

  @Builder
  TabItem(index: number, title: string, icon: Resource) {
    Column({ space: 3 }) {
      SymbolGlyph(icon)
        .fontSize(24)
        .fontColor([this.activeTab === index ? $r('app.color.btn_primary') : $r('app.color.text_secondary')])
      Text(title)
        .fontSize(11)
        .fontColor(this.activeTab === index ? $r('app.color.btn_primary') : $r('app.color.text_secondary'))
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Navigation(this.pathStack) {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController, index: this.activeTab }) {
        TabContent() {
          HomeView({ pathStack: this.pathStack, onGoTab: (index: number) => this.goTab(index) })
        }
        .tabBar(this.TabItem(0, '首页', $r('sys.symbol.house')))

        TabContent() {
          NearbyStationsPage({ pathStack: this.pathStack, embedded: true })
        }
        .tabBar(this.TabItem(1, '充电', $r('sys.symbol.bolt_fill')))

        TabContent() {
          ScanView({ pathStack: this.pathStack, embedded: true })
        }
        .tabBar(this.TabItem(2, '扫一扫', $r('sys.symbol.qrcode')))

        TabContent() {
          OrderView({ pathStack: this.pathStack, embedded: true })
        }
        .tabBar(this.TabItem(3, '订单', $r('sys.symbol.doc_text')))

        TabContent() {
          MineView()
        }
        .tabBar(this.TabItem(4, '我的', $r('sys.symbol.person')))
      }
      .scrollable(false)
      .barHeight(56)
      .onChange((index: number) => {
        this.activeTab = index;
      })
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
