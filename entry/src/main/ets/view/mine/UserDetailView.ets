import { LineIcon } from '../../component/LineIcon';
import { TrendChart } from '../../component/TrendChart';
import { NavParam } from '../../model/Types';

/**
 * 用户详情（从个人中心头像进入）。
 * 头部返回/头像/昵称，数据卡 + 近7天充电趋势(TrendChart) + 设置项。
 */

@Component
export struct UserDetailView {
  pathStack: NavPathStack = new NavPathStack();

  private userName: string = 'XX智能充电';
  private plateNo: string = '车牌号：京A·88888';
  private balanceYuan: string = '23.00';
  private monthKwh: string = '168.50';
  @State autoPowerOff: boolean = true;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`UserDetail showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private go(route: string): void {
    const param: NavParam = { id: '' };
    this.pathStack.pushPathByName(route, param);
  }

  private openHistory(): void {
    this.go('OrderHistory');
  }

  private exitAccount(): void {
    // 演示：退出/切换账号，回到登录页
    try {
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/Login' });
    } catch (err) {
      this.showToast('退出失败，请重试');
    }
  }

  @Builder
  StatCell(iconKind: string, value: string, label: string, iconBg: string, iconColor: string) {
    Column() {
      Row() {
        LineIcon({ kind: iconKind, color: iconColor })
      }
      .width(42)
      .height(42)
      .borderRadius(21)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(iconBg)

      Text(value)
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.uc_text_primary'))
        .margin({ top: 10 })

      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.uc_text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  HeaderArea() {
    Row() {
      Row() {
        LineIcon({ kind: 'back', color: '#1F2937' })
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#F4F7FB')
      .onClick(() => {
        this.pathStack.pop();
      })

      Row() {
        Row() {
          LineIcon({ kind: 'user', color: '#FFFFFF' })
        }
        .width(54)
        .height(54)
        .borderRadius(27)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .linearGradient({
          angle: 135,
          colors: [[0xFF52C8FF, 0.0], [0xFF1E5FD9, 1.0]]
        })
        .border({ width: 2, color: 0x1A2196F3 })

        Column() {
          Row() {
            Text(this.userName)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.uc_text_primary'))
            Row() {
              Text('月卡用户')
                .fontSize(10)
                .fontColor($r('app.color.uc_blue'))
            }
            .height(18)
            .padding({ left: 7, right: 7 })
            .borderRadius(9)
            .backgroundColor($r('app.color.uc_light_bg'))
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .margin({ left: 8 })
          }
          .alignItems(VerticalAlign.Center)

          Text(this.plateNo)
            .fontSize(12)
            .fontColor($r('app.color.uc_text_secondary'))
            .margin({ top: 5 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 12 })

      Row() {
        LineIcon({ kind: 'exit', color: '#1F2937' })
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#F4F7FB')
      .onClick(() => {
        this.exitAccount();
      })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  StatsCard() {
    Row() {
      this.StatCell('yuan', this.balanceYuan, '充电余额（元）', '#E8F3FF', '#2196F3')
      Column()
        .width(1)
        .height(62)
        .backgroundColor($r('app.color.uc_divider'))
      this.StatCell('bolt', this.monthKwh, '本月充电量（度）', '#E0F7FA', '#00838F')
    }
    .width('100%')
    .padding({ top: 20, bottom: 20 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(16)
    .shadow({ radius: 12, color: 0x08000000, offsetY: 2 })
  }

  @Builder
  TrendCard() {
    Column() {
      Row() {
        Column() {
          Text('近7天充电量（度）')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.uc_text_primary'))
          Text('8/27 - 9/2 · 本地模拟数据')
            .fontSize(11)
            .fontColor($r('app.color.uc_text_secondary'))
            .margin({ top: 3 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Row() {
          Text('充电记录')
            .fontSize(12)
            .fontColor($r('app.color.uc_blue'))
          Row() {
            LineIcon({ kind: 'chevronRight', color: '#2196F3' })
          }
          .width(10)
          .height(10)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({ left: 1 })
        }
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.openHistory();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 4 })

      TrendChart()
    }
    .width('100%')
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(16)
    .shadow({ radius: 12, color: 0x08000000, offsetY: 2 })
  }

  @Builder
  SettingCard() {
    Row() {
      Row() {
        LineIcon({ kind: 'bolt', color: '#2196F3' })
      }
      .width(42)
      .height(42)
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.uc_light_bg'))

      Column() {
        Text('充电完成自动断电')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.uc_text_primary'))
        Text('充电结束后自动断开电源，避免产生占位费用')
          .fontSize(11)
          .fontColor($r('app.color.uc_text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Toggle({ type: ToggleType.Switch, isOn: this.autoPowerOff })
        .selectedColor($r('app.color.uc_blue'))
        .onChange((isOn: boolean) => {
          this.autoPowerOff = isOn;
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(16)
    .shadow({ radius: 12, color: 0x08000000, offsetY: 2 })
  }

  build() {
    Column() {
      Column() {
        this.HeaderArea()
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 44, bottom: 14 })
      .backgroundColor($r('app.color.app_card'))

      Scroll() {
        Column({ space: 14 }) {
          this.StatsCard()
          this.TrendCard()
          this.SettingCard()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.uc_page_bg'))
  }
}
