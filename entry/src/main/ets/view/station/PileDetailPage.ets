import { ChargingPile, NavParam } from '../../model/Types';
import { StationService } from '../../service/StationService';
import { AppTopBar } from '../../component/AppTopBar';
import { PrimaryButton } from '../../component/PrimaryButton';

/**
 * 三级页面：电枪（充电桩）详情。
 * 对应 Story 8（查看充电桩详情）。
 */

@Component
export struct PileDetailPage {
  pathStack: NavPathStack = new NavPathStack();
  pileId: string = '';

  @State pile: ChargingPile | undefined = undefined;
  @State plate: string = '';

  aboutToAppear(): void {
    this.pile = StationService.getInstance().getPileById(this.pileId);
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private statusLabel(): string {
    if (this.pile && this.pile.status === 'IDLE') {
      return '空闲';
    }
    if (this.pile && this.pile.status === 'CHARGING') {
      return '充电中';
    }
    return '离线';
  }

  /** 车牌号 */
  @Builder
  PlateInput() {
    Column() {
      Row() {
        Text('*')
          .fontSize(16)
          .fontColor($r('app.color.price_orange'))
        Text('车牌号：')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        SymbolGlyph($r('sys.symbol.car'))
          .fontSize(24)
          .fontColor([$r('app.color.primary_blue')])
          .margin({ left: 8 })
          .onClick(() => this.showToast('选择车牌（演示）'))
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text('输入正确的车牌号可获取更多优惠')
        .fontSize(12)
        .fontColor($r('app.color.text_muted'))
        .width('100%')
        .margin({ top: 8 })

      TextInput({ placeholder: '请输入车牌号', text: this.plate })
        .width('100%')
        .height(44)
        .fontSize(15)
        .backgroundColor($r('app.color.chip_bg'))
        .borderRadius(8)
        .margin({ top: 12 })
        .onChange((v: string) => {
          this.plate = v;
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor($r('app.color.app_card'))
  }

  /** 充电信息栏（标签 + IP + 费用） */
  @Builder
  InfoBar(pile: ChargingPile) {
    Column() {
      Row() {
        Text('直流快充')
          .fontSize(12)
          .fontColor($r('app.color.tag_blue_text'))
          .backgroundColor($r('app.color.tag_blue_bg'))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(3)
        Text(this.statusLabel())
          .fontSize(12)
          .fontColor(this.pile?.status === 'CHARGING' ? $r('app.color.pile_charging')
            : (this.pile?.status === 'IDLE' ? $r('app.color.pile_idle') : $r('app.color.pile_offline')))
          .backgroundColor(this.pile?.status === 'CHARGING' ? $r('app.color.pile_charging_bg')
            : (this.pile?.status === 'IDLE' ? $r('app.color.tag_green_bg') : $r('app.color.chip_bg')))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(3)
          .margin({ left: 8 })
        Text(`充电桩IP：${pile.code}`)
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .margin({ left: 10 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        Text('¥')
          .fontSize(14)
          .fontColor($r('app.color.price_orange'))
        Text(`${pile.pricePerHour.toFixed(4)}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.price_orange'))
        Text('元/时')
          .fontSize(13)
          .fontColor($r('app.color.price_orange'))
          .margin({ left: 1, bottom: 2 })
        Text('包含服务费')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 10, bottom: 2 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: 12 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor($r('app.color.app_card'))
    .margin({ top: 8 })
  }

  /** 中间接线示意：中央桩体 + 左右信息 */
  @Builder
  Diagram(pile: ChargingPile) {
    Row() {
      // 左侧
      Column() {
        Text('停车位号：')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: 6 })
        Text(pile.slotCode)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Text('所属楼层')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 40 })
        Text(pile.floor)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 6 })
          .constraintSize({ maxWidth: 120 })
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      // 中央桩体
      Column() {
        Blank()
          .width(44)
          .height(14)
          .backgroundColor($r('app.color.border'))
          .borderRadius(3)
        Column() {
          SymbolGlyph($r('sys.symbol.bolt_fill'))
            .fontSize(26)
            .fontColor([$r('app.color.primary_light')])
          Circle({ width: 8, height: 8 })
            .fill($r('app.color.pile_idle'))
            .margin({ top: 6 })
        }
        .width(54)
        .height(150)
        .backgroundColor('#2B3138')
        .borderRadius({ topLeft: 8, topRight: 8, bottomLeft: 14, bottomRight: 14 })
        .justifyContent(FlexAlign.Center)
        Column()
          .width(72)
          .height(10)
          .backgroundColor('#1B2026')
          .borderRadius({ bottomLeft: 10, bottomRight: 10 })
      }
      .alignItems(HorizontalAlign.Center)
      .width(88)

      // 右侧
      Column() {
        Text('充电功率')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: 6 })
        Text(`${pile.powerKw}KW`)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('充电接口')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 40 })
        Text(pile.interfaceType)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 6 })
          .constraintSize({ maxWidth: 120 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding({ top: 24, bottom: 24 })
  }

  /** 底部操作栏 */
  @Builder
  BottomBar() {
    Row() {
      Text('提示：')
        .fontSize(13)
        .fontColor($r('app.color.price_orange'))
      Text('请先插枪后点击充电')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
      Blank()
      PrimaryButton({
        label: '立即充电',
        fullWidth: false,
        onTap: () => {
          const param: NavParam = { id: this.pileId };
          this.pathStack.pushPathByName('Charging', param);
        }
      })
    }
    .width('100%')
    .height(64)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.app_card'))
    .border({ width: { top: 1 }, color: $r('app.color.divider') })
  }

  build() {
    Column() {
      AppTopBar({ title: '电枪详情', pathStack: this.pathStack })

      Scroll() {
        Column() {
          if (this.pile) {
            this.PlateInput()
            this.InfoBar(this.pile)
            this.Diagram(this.pile)
          }
        }
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      if (this.pile) {
        this.BottomBar()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
