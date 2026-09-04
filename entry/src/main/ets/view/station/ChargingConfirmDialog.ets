import { ChargingPile } from '../../model/Types';
import { InfoRow } from '../../component/InfoRow';
import { PrimaryButton } from '../../component/PrimaryButton';

/**
 * 启动充电确认弹窗（Story 10）：展示桩信息与预估费用 + 计费规则，
 * 确认后由调用方执行 OrderService.startOrder。
 * 预估口径：满功率 60% 时长系数（powerKw × 0.6h × pricePerKwh）。
 */

@CustomDialog
export struct ChargingConfirmDialog {
  controller: CustomDialogController;
  pile: ChargingPile | null = null;
  onConfirm?: () => void;

  private estimateCost(): string {
    if (!this.pile) {
      return '0.00';
    }
    return (this.pile.powerKw * 0.6 * this.pile.pricePerKwh).toFixed(2);
  }

  build() {
    Column({ space: 14 }) {
      Text('启动充电确认')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')

      if (this.pile) {
        Column({ space: 8 }) {
          InfoRow({ label: '充电桩', value: this.pile.code })
          Divider().color($r('app.color.divider'))
          InfoRow({ label: '额定功率', value: `${this.pile.powerKw} kW` })
          Divider().color($r('app.color.divider'))
          InfoRow({ label: '充电单价', value: `¥${this.pile.pricePerKwh.toFixed(2)}/度` })
          Divider().color($r('app.color.divider'))
          InfoRow({ label: '预估费用', value: `¥${this.estimateCost()}`, valueColor: $r('app.color.accent') })
        }
        .width('100%')
        .padding(14)
        .backgroundColor($r('app.color.app_bg'))
        .borderRadius(10)
      }

      Text('计费规则：电费按实际充电量 × 单价结算，结束充电后生成订单账单；请确认已插枪到位。')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')

      Row({ space: 14 }) {
        Column() {
          PrimaryButton({
            label: '取 消',
            isOutline: true,
            onTap: () => this.controller.close()
          })
        }
        .layoutWeight(1)

        Column() {
          PrimaryButton({
            label: '确认启动',
            onTap: () => {
              this.controller.close();
              if (this.onConfirm) {
                this.onConfirm();
              }
            }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Start)
    .width('85%')
    .padding(20)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(16)
    .shadow({ radius: 24, color: 0x33000000, offsetY: 8 })
  }
}
