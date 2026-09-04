import { common } from '@kit.AbilityKit';
import { ChargingOrder, NavParam } from '../../model/Types';
import { OrderService } from '../../service/OrderService';
import { AppTopBar } from '../../component/AppTopBar';
import { InfoRow } from '../../component/InfoRow';
import { PrimaryButton } from '../../component/PrimaryButton';

/**
 * 充电结束汇总（Story 13）：数据取自结算后的真实订单，
 * 查看账单进入 Bill，返回首页回到导航根。
 */

@Component
export struct ChargeCompletePage {
  pathStack: NavPathStack = new NavPathStack();
  /** 结算订单号（由路由参数注入） */
  orderId: string = '';

  @State order: ChargingOrder | null = null;

  aboutToAppear(): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    OrderService.getInstance().init(ctx).then(async () => {
      const order = await OrderService.getInstance().getOrderById(this.orderId);
      if (!order) {
        this.toast('未找到订单');
        this.pathStack.pop();
        return;
      }
      this.order = order;
    }).catch(() => {
      // 加载失败保持空态
    });
  }

  private toast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`ChargeCompletePage toast failed: ${JSON.stringify(err)}`);
    }
  }

  private goBill(): void {
    const param: NavParam = { id: this.orderId };
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
  SummaryCardContent(o: ChargingOrder) {
    Column({ space: 8 }) {
      InfoRow({ label: '充电桩', value: o.pileCode })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电时长', value: `${o.durationMin} min` })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电电量', value: `${o.energyKwh.toFixed(2)} kWh`, valueColor: $r('app.color.btn_primary') })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '订单号', value: o.id })
      Divider().color($r('app.color.divider'))
      InfoRow({ label: '充电费用', value: `¥${o.amount.toFixed(2)}`, valueColor: $r('app.color.accent') })
    }
    .width('100%')
  }

  build() {
    Column() {
      AppTopBar({ title: '充电完成', pathStack: this.pathStack })

      Scroll() {
        Column({ space: 16 }) {
          this.SuccessCard()

          if (this.order) {
            Column() {
              this.SummaryCardContent(this.order)
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
