import { router } from '@kit.ArkUI';
import { LineIcon } from './LineIcon';

/**
 * 个人中心列表子页通用外壳（占位页）：
 * 我的钱包 / 我的爱车 / 历史记录 / 系统通知
 * 后续可替换为各功能的真实业务页面。
 */
@Component
export struct SubPage {
  @Prop title: string = '';
  @Prop iconKind: string = 'wallet';
  @Prop desc: string = '';

  build() {
    Column() {
      // 顶部深蓝渐变导航栏
      Column() {
        Row() {
          Row() {
            LineIcon({ kind: 'back', color: '#FFFFFF' })
          }
          .width(36)
          .height(36)
          .borderRadius(18)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .backgroundColor(0x14FFFFFF)
          .onClick(() => {
            router.back();
          })

          Text(this.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .margin({ left: 8 })
        }
        .width('100%')
        .height(52)
        .padding({ left: 10, right: 18 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({ top: 40 })
      .linearGradient({
        angle: 90,
        colors: [[0xFF0A1F44, 0.0], [0xFF0E7490, 1.0]]
      })

      // 占位内容
      Column() {
        Row() {
          LineIcon({ kind: this.iconKind, color: '#1450B8' })
        }
        .width(76)
        .height(76)
        .borderRadius(22)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .linearGradient({
          angle: 135,
          colors: [[0xFFEAF2FF, 0.0], [0xFFD8E7FF, 1.0]]
        })

        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.profile_text_primary'))
          .margin({ top: 18 })

        Text(this.desc)
          .fontSize(13)
          .fontColor($r('app.color.profile_text_secondary'))
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 8 })

        Text('页面建设中，敬请期待')
          .fontSize(12)
          .fontColor($r('app.color.profile_text_secondary'))
          .margin({ top: 18 })

        // 内容骨架占位
        Column() {
          Row()
            .width('72%')
            .height(12)
            .borderRadius(6)
            .backgroundColor($r('app.color.profile_skeleton'))
          Row()
            .width('52%')
            .height(12)
            .borderRadius(6)
            .backgroundColor($r('app.color.profile_skeleton'))
            .margin({ top: 12 })
          Row()
            .width('64%')
            .height(12)
            .borderRadius(6)
            .backgroundColor($r('app.color.profile_skeleton'))
            .margin({ top: 12 })
        }
        .width('100%')
        .padding(18)
        .borderRadius(16)
        .backgroundColor($r('app.color.profile_placeholder_bg'))
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 28 })
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 28, right: 28, top: 46 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.profile_sub_bg'))
  }
}
