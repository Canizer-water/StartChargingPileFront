import { NavParam } from '../model/Types';
import { HomeView } from '../view/HomeView';
import { NearbyStationsPage } from '../view/NearbyStationsPage';
import { StationDetailPage } from '../view/station/StationDetailPage';
import { PileDetailPage } from '../view/station/PileDetailPage';
import { WalletView } from '../view/WalletView';
import { MyVehiclesView } from '../view/MyVehiclesView';
import { OrderHistoryView } from '../view/OrderHistoryView';
import { RechargeView } from '../view/RechargeView';
import { InvoiceView } from '../view/InvoiceView';
import { ProfileView } from '../view/mine/ProfileView';
import { UserDetailView } from '../view/mine/UserDetailView';
import { NotificationsView } from '../view/mine/NotificationsView';
import { ScanView } from '../view/charging/ScanView';
import { ChargingPage } from '../view/charging/ChargingPage';
import { ChargeCompletePage } from '../view/charging/ChargeCompletePage';
import { BillPage } from '../view/charging/BillPage';

/**
 * 主框架（Navigation 宿主）。
 * 根内容为首页 HomeView，全部二级页面统一在此注册（PageMap），经 NavPathStack 跳转。
 */

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();

  private idOf(param: object): string {
    if (!param) {
      return '';
    }
    return (param as NavParam).id;
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
    } else if (name === 'PileDetail') {
      NavDestination() {
        PileDetailPage({ pathStack: this.pathStack, pileId: this.idOf(param) })
      }.hideTitleBar(true)
    } else if (name === 'Wallet') {
      NavDestination() {
        WalletView({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'MyVehicles') {
      NavDestination() {
        MyVehiclesView({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'OrderHistory') {
      NavDestination() {
        OrderHistoryView({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'Recharge') {
      NavDestination() {
        RechargeView({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'Invoice') {
      NavDestination() {
        InvoiceView({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'Profile') {
      NavDestination() {
        ProfileView({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'UserDetail') {
      NavDestination() {
        UserDetailView({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'Notifications') {
      NavDestination() {
        NotificationsView({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'Scan') {
      NavDestination() {
        ScanView({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'Charging') {
      NavDestination() {
        ChargingPage({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'ChargeComplete') {
      NavDestination() {
        ChargeCompletePage({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    } else if (name === 'Bill') {
      NavDestination() {
        BillPage({ pathStack: this.pathStack })
      }.hideTitleBar(true)
    }
  }

  build() {
    Navigation(this.pathStack) {
      HomeView({ pathStack: this.pathStack })
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
