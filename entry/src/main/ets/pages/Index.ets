// ============================================================
// Index.ets - 首页（白底浅色版）
// 结构：上部浅蓝渐变区（导航+仪表盘+透明车图+站名）
//       下部白色数据卡 + 设备信息
//       底部白色 TabBar（黑色线稿图标素材）
// 双状态：isCharging=true 充电中 / false 未充电引导
// 车图：car_suv_cutout.png（背景已抠除的透明版）
// ============================================================

import { router } from '@kit.ArkUI';

// ---- 配色（白底浅色）----
const COLOR_PAGE_BG: string = '#ffffff';        // 页面背景
const COLOR_GRAD_TOP: string = '#7fb0e6';       // 渐变起点（科技蓝）
const COLOR_GRAD_BOTTOM: string = '#3271cf';    // 渐变终点（科技深蓝）
const COLOR_PRIMARY: string = '#4a90e2';        // 主题蓝
const COLOR_ENERGY: string = '#52c41a';         // 电量强调绿
const COLOR_TEXT_MAIN: string = '#333333';      // 主文字
const COLOR_TEXT_SUB: string = '#999999';       // 次级文字
const COLOR_TEXT_GRAY: string = '#666666';      // 说明文字
const COLOR_CARD_BG: string = '#ffffff';        // 卡片背景
const COLOR_CARD_SHADOW: string = '#0f000000';  // 卡片阴影 rgba(0,0,0,0.06)
const COLOR_DIVIDER: string = '#f0f0f0';        // TabBar 分隔线
const COLOR_INFO_LINE: string = '#f5f5f5';      // 信息分隔线
const COLOR_GREEN_BG: string = '#e6f7e6';       // 电量卡圆底起点
const COLOR_GREEN_BG2: string = '#f6ffed';      // 电量卡圆底终点
const COLOR_BLUE_BG: string = '#e6f4ff';        // 蓝卡圆底起点
const COLOR_BLUE_BG2: string = '#f0f7ff';       // 蓝卡圆底终点

const GRADIENT_HEIGHT: number = 400;

@Entry
@Component
struct Index {
  // ---- 充电状态数据（本地演示）----
  @State isCharging: boolean = true;
  @State chargePower: string = '2.1';
  @State chargeDuration: string = '58:08';
  @State currentAmp: string = '2.10';
  @State voltage: string = '400.50';
  @State deviceNo: string = '3201000668A451';
  @State orderNo: string = 'DT20021045004006';
  @State selectedTab: number = 0;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`Index showToast failed: ${JSON.stringify(err)}`);
    }
  }

  /** 未充电引导卡 */
  @Builder
  IdleGuide() {
    Column() {
      Image($r('app.media.battery_charging'))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Contain)
        .opacity(0.9)
      Text('当前未在充电')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLOR_TEXT_MAIN)
        .margin({ top: 16 })
      Text('扫码或查找附近充电站，开始充电')
        .fontSize(13)
        .fontColor(COLOR_TEXT_GRAY)
        .margin({ top: 8 })
      Button('去充电')
        .width(180)
        .height(44)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#ffffff')
        .backgroundColor(COLOR_PRIMARY)
        .borderRadius(22)
        .margin({ top: 24 })
        .onClick(() => {
          this.showToast('充电功能开发中');
        })
    }
    .width(300)
    .padding({ top: 28, bottom: 28, left: 20, right: 20 })
    .backgroundColor(COLOR_CARD_BG)
    .borderRadius(20)
    .shadow({ radius: 16, color: COLOR_CARD_SHADOW, offsetY: 4 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /** 数据卡片（白底） */
  @Builder
  DataCard(iconText: string, bgFrom: string, bgTo: string, iconColor: string,
    value: string, unit: string, label: string) {
    Row() {
      // 浅色渐变方形图标（小圆角）
      Stack() {
        Text(iconText)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(iconColor)
      }
      .width(36)
      .height(36)
      .borderRadius(8)
      .linearGradient({
        angle: 135,
        colors: [[bgFrom, 0.0], [bgTo, 1.0]]
      })

      Column() {
        Row() {
          Text(value)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLOR_TEXT_MAIN)
          Text(unit)
            .fontSize(12)
            .fontColor(COLOR_TEXT_SUB)
            .margin({ left: 2 })
        }
        .alignItems(VerticalAlign.Bottom)

        Text(label)
          .fontSize(12)
          .fontColor(COLOR_TEXT_SUB)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .height(80)
    .padding(16)
    .backgroundColor(COLOR_CARD_BG)
    .borderRadius(12)
    .shadow({ radius: 8, color: COLOR_CARD_SHADOW, offsetY: 2 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  InfoRow(label: string, value: string, showLine: boolean) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(COLOR_TEXT_SUB)
      Blank()
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLOR_TEXT_MAIN)
    }
    .width('100%')
    .height(48)
    .alignItems(VerticalAlign.Center)

    if (showLine) {
      Divider()
        .color(COLOR_INFO_LINE)
        .width('100%')
    }
  }

  // ============================================================
  // TabBar（白底，黑色线稿图标素材）
  // ============================================================
  @Builder
  TabItem(index: number, iconRes: Resource, label: string) {
    Column() {
      Column() {
        Image(iconRes)
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
        Text(label)
          .fontSize(10)
          .fontColor(this.selectedTab === index ? COLOR_PRIMARY : COLOR_TEXT_SUB)
          .margin({ top: 2 })
      }
      .padding({ left: 14, right: 14, top: 4, bottom: 4 })
      .borderRadius(14)
      .backgroundColor(this.selectedTab === index ? '#204a90e2' : Color.Transparent)
    }
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onTabClick(index);
    })
  }

  @Builder
  ScanTab() {
    // 蓝色拉长条：图标 + "扫一扫"整体居中
    Row() {
      Image($r('app.media.sao'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text('扫一扫')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#ffffff')
        .margin({ left: 6 })
    }
    .width(132)
    .height(52)
    .borderRadius(26)
    .backgroundColor(COLOR_PRIMARY)
    .shadow({ radius: 14, color: '#664a90e2', offsetY: -4 })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .margin({ top: -26 })
    .onClick(() => {
      this.showToast('打开扫一扫');
    })
  }

  private onTabClick(index: number): void {
    this.selectedTab = index;
    if (index === 0) {
      return;
    }
    if (index === 2) {
      this.showToast('打开扫一扫');
      return;
    }
    const names: string[] = ['首页', '充电', '扫一扫', '订单', '我的'];
    this.showToast(`${names[index]}功能开发中`);
  }

  build() {
    Column() {
      // ================= 可滚动主体 =================
      Scroll() {
        Column() {
          // ---------- 上部：浅蓝渐变区 ----------
          Column() {
            // 顶部：左侧返回箭头 + 右侧 ⋯/↻ 图标（白色）
            Row() {
              // 返回箭头（首页可返回登录页）
              Text('←')
                .fontSize(24)
                .fontColor('#ffffff')
                .margin({ left: 16 })
                .onClick(() => {
                  router.back();
                })
              Blank()
              Row() {
                Text('⋯')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff')
                  .onClick(() => {
                    console.info('Index: 点击分享/更多');
                  })
                Text('↻')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff')
                  .margin({ left: 16 })
                  .onClick(() => {
                    console.info('Index: 点击刷新/设置');
                  })
              }
              .padding({ right: 20 })
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .height(56)
            .alignItems(VerticalAlign.Center)

            // 内容组（标题 + 状态内容）整体在渐变区中垂直居中
            Column() {
              // 状态标题（充电中"充电详情"/未充电"首页"），白色
              Text(this.isCharging ? '充电详情' : '首页')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#ffffff')

              if (this.isCharging) {
                // ---- 充电中：放大车图（无多余装饰/标签）----
                Column() {
                  // 放大后的透明车图（背景已抠除，无文字）
                  Image($r('app.media.car_suv_cutout'))
                    .width(330)
                    .objectFit(ImageFit.Contain)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Center)
                .margin({ top: 16 })
              } else {
                // ---- 未充电引导 ----
                Column() {
                  this.IdleGuide()
                }
                .width('100%')
                .margin({ top: 20 })
              }
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height(GRADIENT_HEIGHT)
          .linearGradient({
            angle: 180,
            colors: [[COLOR_GRAD_TOP, 0.0], [COLOR_GRAD_BOTTOM, 1.0]]
          })

          // ---------- 下部：数据卡片 + 设备信息 ----------
          Column() {
            if (this.isCharging) {
              Grid() {
                GridItem() {
                  this.DataCard('电', COLOR_GREEN_BG, COLOR_GREEN_BG2, COLOR_ENERGY,
                    this.chargePower, '度', '当前充电电量')
                }
                GridItem() {
                  this.DataCard('时', COLOR_BLUE_BG, COLOR_BLUE_BG2, COLOR_PRIMARY,
                    this.chargeDuration, '', '已充电时长')
                }
                GridItem() {
                  this.DataCard('A', COLOR_BLUE_BG, COLOR_BLUE_BG2, COLOR_PRIMARY,
                    this.currentAmp, 'A', '实时电流')
                }
                GridItem() {
                  this.DataCard('V', COLOR_BLUE_BG, COLOR_BLUE_BG2, COLOR_PRIMARY,
                    this.voltage, 'V', '实际电压')
                }
              }
              .columnsTemplate('1fr 1fr')
              .rowsTemplate('1fr 1fr')
              .columnsGap(12)
              .rowsGap(12)
              .width('100%')
              .height(172)
              .padding({ left: 16, right: 16 })

              Column() {
                this.InfoRow('充电设备编号', this.deviceNo, true)
                this.InfoRow('订单编编号', this.orderNo, false)
              }
              .padding({ left: 16, right: 16 })
              .margin({ top: 20 })
            } else {
              Column() {
                Text('暂无充电数据')
                  .fontSize(14)
                  .fontColor(COLOR_TEXT_SUB)
                  .margin({ top: 24, bottom: 24 })
              }
              .width('100%')
            }
          }
          .width('100%')
          .backgroundColor(COLOR_PAGE_BG)
          .padding({ top: 16, bottom: 24 })
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // ================= 底部 TabBar =================
      Column() {
        Row() {
          this.TabItem(0, $r('app.media.tab_home'), '首页')
          this.TabItem(1, $r('app.media.tab_charge'), '充电')
          this.ScanTab()
          this.TabItem(3, $r('app.media.tab_order'), '订单')
          this.TabItem(4, $r('app.media.tab_mine'), '我的')
        }
        .width('100%')
        .height(60)
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 4, right: 4 })
        .backgroundColor(COLOR_PAGE_BG)
      }
      .width('100%')
      .backgroundColor(COLOR_PAGE_BG)
      .padding({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_PAGE_BG)
  }
}
