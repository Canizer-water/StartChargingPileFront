import { router } from '@kit.ArkUI';

// ============================================================
// Login.ets - 登录页（Story 2，深色沉浸式）
// 视觉基调：深蓝灰底 #1e2330 + 地图背景 + 白字 + 亮蓝按钮
// 返回箭头置于内容层顶部（保证最左上方）；无"第三方注册"区
// ============================================================

// ---- 颜色规范 ----
const COLOR_BG: string = '#1e2330';          // 页面背景（深蓝灰）
const COLOR_TEXT_MAIN: string = '#ffffff';    // 主文字
const COLOR_PLACEHOLDER: string = '#888888';  // 占位符
const COLOR_ICON_DEFAULT: string = '#aaaaaa'; // 图标/次要色
const COLOR_INPUT_LINE: string = '#333333';   // 输入框下划线
const COLOR_BTN_PRIMARY: string = '#4a90e2';  // 登录按钮

@Entry
@Component
struct LoginPage {
  // ---- 表单状态 ----
  @State phoneNumber: string = '';
  @State password: string = '';
  @State isPasswordVisible: boolean = false;
  @State isLoginPressed: boolean = false;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`LoginPage showToast failed: ${JSON.stringify(err)}`);
    }
  }

  /** 页面显示时：若从注册页返回，自动回填刚注册的手机号 */
  onPageShow(): void {
    const p = AppStorage.get<string>('registeredPhone');
    if (p !== undefined && p !== '') {
      this.phoneNumber = p;
      // 消费一次后清除，避免下次进入残留
      AppStorage.setOrCreate('registeredPhone', '');
    }
  }

  /** 登录校验与跳转 */
  private handleLogin(): void {
    if (this.phoneNumber.trim() === '') {
      this.showToast('请输入手机号');
      return;
    }
    if (this.password.trim() === '') {
      this.showToast('请输入密码');
      return;
    }
    // 前端演示：暂未对接后端，校验通过进入首页
    console.info(`LoginPage: login with phone=${this.phoneNumber}`);
    router.replaceUrl({ url: 'pages/Index' });
  }

  // ============================================================
  // 品牌 Logo 区
  // ============================================================
  @Builder
  BrandArea() {
    Column() {
      Text('TOWATT')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLOR_TEXT_MAIN)
        .letterSpacing(2)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // ============================================================
  // 下划线式输入行
  // ============================================================
  @Builder
  InputRow(placeholder: string, bindText: string, withEye: boolean) {
    Column() {
      Row() {
        if (withEye) {
          // 密码输入：文字 + 眼睛切换
          TextInput({ placeholder: placeholder, text: bindText })
            .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
            .fontSize(16)
            .fontColor(COLOR_TEXT_MAIN)
            .placeholderColor(COLOR_PLACEHOLDER)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .enterKeyType(EnterKeyType.Done)
            .onChange((value: string) => {
              this.password = value;
            })
            .onSubmit(() => {
              this.handleLogin();
            })
          if (this.isPasswordVisible) {
            SymbolGlyph($r('sys.symbol.eye'))
              .fontSize(20)
              .fontColor([COLOR_ICON_DEFAULT])
              .onClick(() => {
                this.isPasswordVisible = false;
              })
          } else {
            SymbolGlyph($r('sys.symbol.eye_slash'))
              .fontSize(20)
              .fontColor([COLOR_ICON_DEFAULT])
              .onClick(() => {
                this.isPasswordVisible = true;
              })
          }
        } else {
          // 手机号输入
          TextInput({ placeholder: placeholder, text: bindText })
            .type(InputType.PhoneNumber)
            .maxLength(11)
            .fontSize(16)
            .fontColor(COLOR_TEXT_MAIN)
            .placeholderColor(COLOR_PLACEHOLDER)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.phoneNumber = value;
            })
        }
      }
      .width('100%')
      .height(54)
      .alignItems(VerticalAlign.Center)

      Divider()
        .color(COLOR_INPUT_LINE)
        .width('100%')
    }
    .width('100%')
  }

  // ============================================================
  // 登录按钮
  // ============================================================
  @Builder
  LoginButton() {
    Button('登 录')
      .width('100%')
      .height(48)
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .fontColor(COLOR_TEXT_MAIN)
      .backgroundColor(COLOR_BTN_PRIMARY)
      .borderRadius(8)
      .opacity(this.isLoginPressed ? 0.9 : 1)
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isLoginPressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.isLoginPressed = false;
        }
      })
      .onClick(() => {
        this.handleLogin();
      })
  }

  // ============================================================
  // 底部操作区（忘记密码 / 注册账号）
  // ============================================================
  @Builder
  BottomActions() {
    Row() {
      Text('忘记密码')
        .fontSize(14)
        .fontColor(COLOR_TEXT_MAIN)
        .onClick(() => {
          this.showToast('请联系管理员重置密码');
        })
      Text('注册账号')
        .fontSize(14)
        .fontColor(COLOR_TEXT_MAIN)
        .onClick(() => {
          router.pushUrl({ url: 'pages/Register' });
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 24 })
  }

  build() {
    Stack() {
      // ---- 背景层：纯色 + 地图素材（60%）----
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(COLOR_BG)

      Image($r('app.media.login_map_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.6)

      // ---- 内容层（最上层）----
      Column() {
        // 顶部返回箭头（最左上方）
        Row() {
          Text('←')
            .fontSize(24)
            .fontColor(COLOR_TEXT_MAIN)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .padding({ left: 16, top: 16 })

        // 主内容组（品牌 + 表单 + 按钮）整体垂直居中
        Blank()

        Column() {
          // 品牌 Logo 区
          this.BrandArea()

          // 输入表单区（TOWATT 下约 64vp）
          Column() {
            this.InputRow('请输入手机号', this.phoneNumber, false)
            // 两输入框之间间距约 18vp
            Column() {
              this.InputRow('请输入密码', this.password, true)
            }
            .margin({ top: 18 })
          }
          .width('100%')
          .margin({ top: 64 })

          // 登录按钮（距密码框 40vp）
          Column() {
            this.LoginButton()
          }
          .width('100%')
          .margin({ top: 40 })
        }
        .width('100%')
        .padding({ left: 32, right: 32 })

        Blank()

        // 底部操作区
        Column() {
          this.BottomActions()
        }
        .width('100%')
        .padding({ left: 32, right: 32 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG)
  }
}
