import { SubPage } from '../component/SubPage';

@Entry
@Component
struct HistoryPage {
  build() {
    Column() {
      SubPage({
        title: '历史记录',
        iconKind: 'history',
        desc: '充电记录与费用明细将在这里按时间查询。'
      })
    }
    .width('100%')
    .height('100%')
  }
}