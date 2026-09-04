import { AppTopBar } from '../../component/AppTopBar';
import { InfoRow } from '../../component/InfoRow';
import { PrimaryButton } from '../../component/PrimaryButton';

/**
 * 账单详情（Story 15）：费用明细 + 订单信息。
 */
@Component
export struct BillPage {
  pathStack: NavPathStack = new NavPathStack();

  @State orderNo: string = 'CP2026090212345678';
  @State paid: boolean = true;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private backHome(): void {
    this.pathStack.popToIndex(0);
  }

  @Builder
  AmountCard() {
    Column({ space: 10 }) {
      Text('应付金额')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
      Text('¥27.74')
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.accent'))
      Text(this.paid ? '已支付' : '待支付')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.btn_primary'))
        .padding({ left: 14, right: 14, top: 5, bottom: 5 })
        .backgroundColor($r('app.color.charge_tint_bg'))
        .borderRadius(12)
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .padding(24)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .border({ width: 1, color: $r('app.color.divider') })
  }

  @Builder
  FeeCardContent() {
    Column({ space: 8 }) {
      InfoRow({ label: '充电电费（23.12 度 × ¥1.2/度）', value: '¥27.74' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电服务费', value: '¥3.00' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '停车费', value: '¥0.00' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '优惠', value: '-¥3.00' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '应付合计', value: '¥27.74', valueColor: $r('app.color.accent') })
    }
    .width('100%')
  }

  @Builder
  InfoCardContent() {
    Column({ space: 8 }) {
      InfoRow({ label: '订单号', value: this.orderNo })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电桩', value: 'P-005 · 直流快充' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电时长', value: '31 min' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电电量', value: '23.12 kWh' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '支付方式', value: '微信支付' })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '支付时间', value: '2026-09-02 12:34' })
    }
    .width('100%')
  }

  build() {
    Column() {
      AppTopBar({ title: '账单详情', pathStack: this.pathStack })

      Scroll() {
        Column({ space: 16 }) {
          this.AmountCard()

          Column() {
            this.FeeCardContent()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.app_card'))
          .borderRadius(12)
          .border({ width: 1, color: $r('app.color.divider') })

          Column() {
            this.InfoCardContent()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.app_card'))
          .borderRadius(12)
          .border({ width: 1, color: $r('app.color.divider') })

          PrimaryButton({
            label: this.paid ? '返回首页' : '立即支付',
            onTap: () => {
              if (this.paid) {
                this.backHome();
              } else {
                this.showToast('支付功能开发中');
              }
            }
          })
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
