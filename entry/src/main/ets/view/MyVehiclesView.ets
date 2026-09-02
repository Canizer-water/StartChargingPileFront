/**
 * 我的爱车：车辆卡列表 + 自动支付开关。
 */

interface VehicleItem {
  plate: string;
  model: string;
  deposit: string;
  autoPay: boolean;
  enterprise: boolean;
}

@Component
export struct MyVehiclesView {
  pathStack: NavPathStack = new NavPathStack();

  @State vehicles: VehicleItem[] = [
    { plate: '京A 15H00', model: '特斯拉MODEL S', deposit: '20元', autoPay: true, enterprise: false },
    { plate: '浙B 2K109', model: '比亚迪汉EV', deposit: '20元', autoPay: false, enterprise: true }
  ];

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  @Builder
  NavBar(title: string) {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor([$r('app.color.text_primary')])
        .margin({ left: 4 })
        .onClick(() => this.pathStack.pop())
      Blank()
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
      Blank()
      // 占位保证标题居中
      Row().width(24)
    }
    .width('100%')
    .height(44)
    .padding({ left: 12, right: 12 })
  }

  @Builder
  VehicleCard(item: VehicleItem) {
    Row() {
      Stack() {
        SymbolGlyph($r('sys.symbol.car'))
          .fontSize(26)
          .fontColor([$r('app.color.btn_primary')])
      }
      .width(52)
      .height(52)
      .borderRadius(26)
      .backgroundColor(Color.White)
      .border({ width: 1, color: $r('app.color.border') })

      Column() {
        Row() {
          Text(item.plate)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          if (item.enterprise) {
            Text('企')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.btn_primary'))
              .borderRadius(4)
              .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              .margin({ left: 6 })
          }
        }
        Text(item.model)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 6 })
        Text('预付金额：' + item.deposit)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      Column() {
        Row() {
          Text('自动支付')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
          Toggle({ type: ToggleType.Switch, isOn: item.autoPay })
            .selectedColor($r('app.color.btn_primary'))
            .width(42)
            .height(24)
            .margin({ left: 8 })
        }
        if (item.enterprise) {
          Text('支付账户：企业')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 10 })
        }
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => this.showToast('车辆详情开发中'))
  }

  build() {
    Column() {
      this.NavBar('我的爱车')

      Scroll() {
        Column() {
          ForEach(this.vehicles, (item: VehicleItem) => {
            this.VehicleCard(item)
          }, (item: VehicleItem) => item.plate + item.enterprise.toString())
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
