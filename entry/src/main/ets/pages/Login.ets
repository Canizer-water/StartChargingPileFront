import { router } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State showPassword: boolean = false;
  @State rememberPassword: boolean = false;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private handleLogin(): void {
    if (this.username.trim() === '') {
      this.showToast('请输入手机号 / 用户名');
      return;
    }
    if (this.password.trim() === '') {
      this.showToast('请输入密码');
      return;
    }
    // 演示登录：暂无后端，登录成功后进入个人中心
    router.pushUrl({ url: 'pages/Profile' }, (err) => {
      if (err) {
        console.error('push pages/Profile failed: ' + JSON.stringify(err));
      }
    });
  }

  @Builder
  TopArea() {
    Column() {
      Stack() {
        Column()
          .width(80)
          .height(80)
          .borderRadius(40)
          .backgroundColor(Color.White)
          .opacity(0.92)
        Image($r('app.media.battery_charging'))
          .width(50)
          .height(50)
      }
      .width(80)
      .height(80)

      Text('智能充电桩')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.login_title'))
        .margin({ top: 14 })

      Text('扫码充电 · 智慧出行')
        .fontSize(14)
        .fontColor($r('app.color.login_slogan'))
        .margin({ top: 8 })
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .margin({ top: 72 })
  }

  @Builder
  LoginCard() {
    Column() {
      Text('欢迎回来')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.login_card_title'))
        .width('100%')

      Text('登录后开始管理您的充电桩')
        .fontSize(13)
        .fontColor($r('app.color.login_text_secondary'))
        .margin({ top: 8 })
        .width('100%')

      // 用户名输入框
      Row() {
        SymbolGlyph($r('sys.symbol.person'))
          .fontSize(20)
          .fontColor([$r('app.color.login_icon')])
          .margin({ right: 12 })
        TextInput({ placeholder: '请输入手机号 / 用户名', text: this.username })
          .type(InputType.Normal)
          .fontSize(15)
          .fontColor($r('app.color.login_card_title'))
          .placeholderColor($r('app.color.login_placeholder'))
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .height(52)
          .onChange((value: string) => {
            this.username = value;
          })
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.login_input_bg'))
      .borderRadius(12)
      .margin({ top: 28 })

      // 密码输入框
      Row() {
        SymbolGlyph($r('sys.symbol.lock'))
          .fontSize(20)
          .fontColor([$r('app.color.login_icon')])
          .margin({ right: 12 })
        TextInput({ placeholder: '请输入密码', text: this.password })
          .type(this.showPassword ? InputType.Normal : InputType.Password)
          .fontSize(15)
          .fontColor($r('app.color.login_card_title'))
          .placeholderColor($r('app.color.login_placeholder'))
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .height(52)
          .enterKeyType(EnterKeyType.Done)
          .onChange((value: string) => {
            this.password = value;
          })
          .onSubmit(() => {
            this.handleLogin();
          })
        if (this.showPassword) {
          SymbolGlyph($r('sys.symbol.eye'))
            .fontSize(20)
            .fontColor([$r('app.color.login_icon')])
            .onClick(() => {
              this.showPassword = false;
            })
        } else {
          SymbolGlyph($r('sys.symbol.eye_slash'))
            .fontSize(20)
            .fontColor([$r('app.color.login_icon')])
            .onClick(() => {
              this.showPassword = true;
            })
        }
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.login_input_bg'))
      .borderRadius(12)
      .margin({ top: 16 })

      // 记住密码 & 忘记密码
      Row() {
        Checkbox()
          .shape(CheckBoxShape.ROUNDED_SQUARE)
          .select(this.rememberPassword)
          .selectedColor($r('app.color.login_primary'))
          .width(18)
          .height(18)
          .onChange((value: boolean) => {
            this.rememberPassword = value;
          })
        Text('记住密码')
          .fontSize(13)
          .fontColor($r('app.color.login_text_secondary'))
          .margin({ left: 6 })
          .onClick(() => {
            this.rememberPassword = !this.rememberPassword;
          })

        Blank()

        Text('忘记密码？')
          .fontSize(13)
          .fontColor($r('app.color.login_primary'))
          .onClick(() => {
            this.showToast('请联系管理员重置密码');
          })
      }
      .width('100%')
      .margin({ top: 16 })

      // 登录按钮
      Button('登 录')
        .width('100%')
        .height(50)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.login_primary'))
        .borderRadius(25)
        .margin({ top: 28 })
        .onClick(() => {
          this.handleLogin();
        })

      // 注册引导
      Row() {
        Text('还没有账号？')
          .fontSize(13)
          .fontColor($r('app.color.login_text_secondary'))
        Text('立即注册')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.login_primary'))
          .margin({ left: 4 })
          .onClick(() => {
            this.showToast('注册功能开发中');
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20 })
    }
    .width('100%')
    .padding(24)
    .backgroundColor($r('app.color.login_card_bg'))
    .borderRadius(20)
    .shadow({ radius: 24, color: 0x22000000, offsetY: 8 })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 背景图
      Image($r('app.media.background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 底部压暗渐变，提升文字可读性
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [[0x00000000, 0.0], [0x00000000, 0.5], [0xBF000000, 1.0]]
        })

      Column() {
        this.TopArea()

        Blank()

        this.LoginCard()

        Text('v1.0.0')
          .fontSize(12)
          .fontColor($r('app.color.login_slogan'))
          .opacity(0.6)
          .margin({ top: 20, bottom: 24 })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.start_window_background'))
  }
}
