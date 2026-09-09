import { common } from '@kit.AbilityKit';
import { LineIcon } from '../../component/LineIcon';
import { AuthService } from '../../service/AuthService';
import { UserAccount } from '../../model/Types';

/**
 * 我的（Story 16）：头像 / 用户名 / 用户ID + 退出登录。
 * 超纲功能页（钱包/爱车/通知等）暂不挂入口，本视图仅保留文档范围内内容。
 */

@Component
export struct MineView {
  @StorageProp('currentUser') user: UserAccount | null = null;
  @State loggingOut: boolean = false;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private maskedName(): string {
    const name = this.user ? this.user.username : '';
    if (name.length !== 11) {
      return name === '' ? '未登录' : name;
    }
    return `${name.substring(0, 3)}****${name.substring(7)}`;
  }

  private handleLogout(): void {
    if (this.loggingOut) {
      return;
    }
    this.loggingOut = true;
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    AuthService.getInstance().init(ctx)
      .then(() => AuthService.getInstance().logout())
      .then(() => {
        AppStorage.setOrCreate<UserAccount | null>('currentUser', null);
        AppStorage.setOrCreate('isLoggedIn', false);
        try {
          this.getUIContext().getRouter().replaceUrl({ url: 'pages/Login' });
        } catch (err) {
          this.showToast('退出失败，请重试');
        }
      })
      .catch(() => {
        this.showToast('退出失败，请重试');
      })
      .finally(() => {
        this.loggingOut = false;
      });
  }

  @Builder
  GradientHeader() {
    Column() {
      Row() {
        LineIcon({ kind: 'user', color: '#FFFFFF' })
      }
      .width(64)
      .height(64)
      .borderRadius(32)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .linearGradient({
        angle: 135,
        colors: [[$r('app.color.primary_light'), 0.0], [$r('app.color.brand_deep'), 1.0]]
      })
      .border({ width: 2, color: 0xCCFFFFFF })
      .shadow({ radius: 12, color: 0x30000000, offsetY: 4 })

      Text(this.maskedName())
        .fontSize(19)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.profile_header_text'))
        .margin({ top: 12 })

      Text(this.user ? `用户ID：${this.user.id}` : '绿色出行 · 低碳生活')
        .fontSize(12)
        .fontColor($r('app.color.profile_header_sub'))
        .margin({ top: 8 })

      if (this.user) {
        Text(`注册时间：${this.user.createdAt.substring(0, 10)}`)
          .fontSize(11)
          .fontColor($r('app.color.profile_header_sub'))
          .opacity(0.8)
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .padding({ top: 56, bottom: 36 })
    .alignItems(HorizontalAlign.Center)
    .linearGradient({
      angle: 135,
      colors: [[$r('app.color.brand_deep'), 0.0], [$r('app.color.login_primary'), 0.55], [$r('app.color.primary_light'), 1.0]]
    })
  }

  @Builder
  LogoutRow() {
    Row() {
      Row() {
        LineIcon({ kind: 'exit', color: '#ED823E' })
      }
      .width(44)
      .height(44)
      .borderRadius(13)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.chip_bg'))

      Text('退出登录')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.profile_text_primary'))
        .margin({ left: 14 })
        .layoutWeight(1)
    }
    .width('100%')
    .height(68)
    .padding({ left: 20, right: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.handleLogout())
  }

  build() {
    Column() {
      this.GradientHeader()

      Column() {
        this.LogoutRow()
      }
      .width('100%')
      .padding({ bottom: 20 })
      .backgroundColor($r('app.color.app_card'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
