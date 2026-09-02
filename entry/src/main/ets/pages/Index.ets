import { NavParam } from '../model/Types';
import { NearbyStationsPage } from '../view/NearbyStationsPage';
import { StationDetailPage } from '../view/station/StationDetailPage';
import { PileDetailPage } from '../view/station/PileDetailPage';

/**
 * 主框架（Navigation 宿主）。
 * 以「附近电站」为根内容，通过 NavPathStack 跳转二级、三级页面。
 */

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string, param: object) {
    if (name === 'StationDetail') {
      StationDetailPage({ pathStack: this.pathStack, stationId: (param as NavParam).id })
    } else if (name === 'PileDetail') {
      PileDetailPage({ pathStack: this.pathStack, pileId: (param as NavParam).id })
    }
  }

  build() {
    Navigation(this.pathStack) {
      NearbyStationsPage({ pathStack: this.pathStack })
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
