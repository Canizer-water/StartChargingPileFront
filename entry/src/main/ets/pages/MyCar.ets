import { SubPage } from '../component/SubPage';

@Entry
@Component
struct MyCarPage {
  build() {
    Column() {
      SubPage({
        title: '我的爱车',
        iconKind: 'car',
        desc: '车辆信息、车牌绑定与充电偏好将在这里管理。'
      })
    }
    .width('100%')
    .height('100%')
  }
}