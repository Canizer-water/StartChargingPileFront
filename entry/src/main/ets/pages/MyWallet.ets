import { SubPage } from '../component/SubPage';

@Entry
@Component
struct MyWalletPage {
  build() {
    Column() {
      SubPage({
        title: '我的钱包',
        iconKind: 'wallet',
        desc: '钱包余额、充值记录与消费账单将在这里展示。'
      })
    }
    .width('100%')
    .height('100%')
  }
}