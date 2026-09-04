import { NavParam } from '../../model/Types';
import { AppTopBar } from '../../component/AppTopBar';
import { InfoRow } from '../../component/InfoRow';
import { PrimaryButton } from '../../component/PrimaryButton';

/**
 * 充电结束汇总（Story 13）：电量/时长/费用总结，进入账单或返回首页。
 */
@Component
export struct ChargeCompletePage {
  pathStack: NavPathStack = new NavPathStack();

  @State duration: string = '31';
  @State kwh: string = '23.12';
  @State cost: string = '27.74';

  private goBill(): void {
    const param: NavParam = { id: 'CP2026090212345678' };
    this.pathStack.pushPathByName('Bill', param);
  }

  private backHome(): void {
    this.pathStack.popToIndex(0);
  }

  @Builder
  SuccessCard() {
    Column({ space: 16 }) {
      SymbolGlyph($r('sys.symbol.checkmark_circle'))
        .fontSize(72)
        .fontColor([$r('app.color.btn_primary')])

      Text('充电已完成')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Text('请及时取走充电枪，注意行车安全')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .padding(28)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
  }

  @Builder
  SummaryCardContent() {
    Column({ space: 8 }) {
      InfoRow({ label: '充电桩', value: 'P-005' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电时长', value: `${this.duration} min` })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电电量', value: `${this.kwh} kWh`, valueColor: $r('app.color.btn_primary') })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '订单号', value: 'CP2026090212345678' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电费用', value: `¥${this.cost}`, valueColor: $r('app.color.accent') })
    }
    .width('100%')
  }

  build() {
    Column() {
      AppTopBar({ title: '充电完成', pathStack: this.pathStack })

      Scroll() {
        Column({ space: 16 }) {
          this.SuccessCard()

          Column() {
            this.SummaryCardContent()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.app_card'))
          .borderRadius(12)
          .border({ width: 1, color: $r('app.color.divider') })

          Row({ space: 14 }) {
            Column() {
              PrimaryButton({
                label: '返回首页',
                isOutline: true,
                onTap: () => this.backHome()
              })
            }
            .layoutWeight(1)

            Column() {
              PrimaryButton({
                label: '查看账单',
                onTap: () => this.goBill()
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
