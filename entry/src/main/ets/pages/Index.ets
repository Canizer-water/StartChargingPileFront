import { HomeView } from '../view/HomeView';
import { NearbyStationsPage } from '../view/NearbyStationsPage';
import { WalletView } from '../view/WalletView';
import { MyVehiclesView } from '../view/MyVehiclesView';
import { OrderHistoryView } from '../view/OrderHistoryView';
import { RechargeView } from '../view/RechargeView';
import { InvoiceView } from '../view/InvoiceView';

/**
 * 主框架（Navigation 宿主）。
 * 根内容为首页 HomeView，各二级页通过 NavPathStack 跳转。
 */

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string, param: object) {
    if (name === 'NearbyStations') {
      NavDestination() {
        NearbyStationsPage({ pathStack: this.pathStack })
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
    }
  }

  build() {
    Navigation(this.pathStack) {
      HomeView({ pathStack: this.pathStack })
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
