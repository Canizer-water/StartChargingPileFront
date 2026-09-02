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
      NearbyStationsPage({ pathStack: this.pathStack })
    } else if (name === 'Wallet') {
      WalletView({ pathStack: this.pathStack })
    } else if (name === 'MyVehicles') {
      MyVehiclesView({ pathStack: this.pathStack })
    } else if (name === 'OrderHistory') {
      OrderHistoryView({ pathStack: this.pathStack })
    } else if (name === 'Recharge') {
      RechargeView({ pathStack: this.pathStack })
    } else if (name === 'Invoice') {
      InvoiceView({ pathStack: this.pathStack })
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
