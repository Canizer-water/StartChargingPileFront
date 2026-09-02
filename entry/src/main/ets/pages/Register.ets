import { router } from '@kit.ArkUI';

// ============================================================
// Register.ets - 注册页（Story 1）
// 视觉基调：白色背景 + 蓝色主题 + iOS 简洁风格
// 字段：手机号 / 密码 / 确认密码（不含验证码）
// ============================================================

// ---- 颜色规范 ----
const COLOR_BG: string = '#ffffff';
const COLOR_NAV_BAR: string = '#ffffff';
const COLOR_NAV_DIVIDER: string = '#f0f0f0';
const COLOR_TITLE: string = '#333333';
const COLOR_PLACEHOLDER: string = '#cccccc';
const COLOR_SECONDARY: string = '#999999';
const COLOR_LINE: string = '#eeeeee';
const COLOR_PRIMARY: string = '#4a90e2';
const COLOR_PROTOCOL_TEXT: string = '#666666';
const COLOR_BUTTON_TEXT: string = '#ffffff';
const COLOR_CHECK_BORDER: string = '#cccccc';

// 输入行高度（下划线式，行间无间距）
const INPUT_ROW_HEIGHT: number = 58;

@Entry
@Component
struct RegisterPage {
  // ---- 表单状态 ----
  @State phone: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isPwdVisible: boolean = false;
  @State isConfirmPwdVisible: boolean = false;
  @State isAgreed: boolean = false;
  // ---- 按钮按压效果 ----
  @State isRegisterPressed: boolean = false;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`RegisterPage showToast failed: ${JSON.stringify(err)}`);
    }
  }

  /** 返回上一页 */
  private goBack(): void {
    router.back();
  }

  /** 表单校验，返回错误提示；通过返回空串 */
  private validate(): string {
    if (!/^\d{11}$/.test(this.phone)) {
      return '请输入正确的手机号';
    }
    if (this.password.length < 6 || this.password.length > 20) {
      return '密码长度需为6-20位';
    }
    if (this.password !== this.confirmPassword) {
      return '两次输入的密码不一致';
    }
    if (!this.isAgreed) {
      return '请先阅读并同意用户协议与隐私政策';
    }
    return '';
  }

  /** 执行注册 */
  private handleRegister(): void {
    const err = this.validate();
    if (err !== '') {
      this.showToast(err);
      return;
    }
    // 前端演示：暂未对接后端，仅模拟注册
    console.info(`RegisterPage: register success, phone=${this.phone}`);
    // 记录注册账号，供登录页回填（Story 1）
    AppStorage.setOrCreate('registeredPhone', this.phone);
    this.showToast('注册成功');
    setTimeout(() => {
      this.goBack();
    }, 800);
  }

  /** 切换密码可见性 */
  private togglePwdVisible(isConfirm: boolean): void {
    if (isConfirm) {
      this.isConfirmPwdVisible = !this.isConfirmPwdVisible;
    } else {
      this.isPwdVisible = !this.isPwdVisible;
    }
  }

  // ============================================================
  // 顶部导航栏：Row 三栏布局（左返回 / 中标题 / 右占位对称），
  // 保证标题绝对居中且返回键可点击、互不重叠
  // ============================================================
  @Builder
  NavBar() {
    Row() {
      // 左侧：返回箭头（固定宽度区域，左对齐）
      Text('←')
        .fontSize(24)
        .fontColor(COLOR_TITLE)
        .width(48)
        .onClick(() => {
          this.goBack();
        })

      // 中间：标题（占满并居中）
      Text('注册')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLOR_TITLE)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 右侧：与左侧等宽的空占位，保证标题居中
      Row()
        .width(48)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16 })
    .backgroundColor(COLOR_NAV_BAR)
    .alignItems(VerticalAlign.Center)

    Divider()
      .color(COLOR_NAV_DIVIDER)
      .width('100%')
  }

  // ============================================================
  // 用户协议区：圆形勾选框 + 分段文字
  // ============================================================
  @Builder
  AgreementRow() {
    Row() {
      // 圆形勾选框
      Stack() {
        if (this.isAgreed) {
          Text('✓')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLOR_BUTTON_TEXT)
        }
      }
      .width(16)
      .height(16)
      .borderRadius(8)
      .backgroundColor(this.isAgreed ? COLOR_PRIMARY : COLOR_BG)
      .border({
        width: 1,
        color: this.isAgreed ? COLOR_PRIMARY : COLOR_CHECK_BORDER
      })
      .clip(true)

      // 协议文字（分段）
      Row() {
        Text('我已阅读并同意')
          .fontSize(12)
          .fontColor(COLOR_PROTOCOL_TEXT)
        Text('《用户协议》')
          .fontSize(12)
          .fontColor(COLOR_PRIMARY)
          .onClick(() => {
            this.showToast('《用户协议》内容查看开发中');
          })
        Text('和')
          .fontSize(12)
          .fontColor(COLOR_PROTOCOL_TEXT)
        Text('《隐私政策》')
          .fontSize(12)
          .fontColor(COLOR_PRIMARY)
          .onClick(() => {
            this.showToast('《隐私政策》内容查看开发中');
          })
      }
      .margin({ left: 8 })

      Blank()
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.isAgreed = !this.isAgreed;
    })
  }

  build() {
    Scroll() {
      Column() {
        // ---- 顶部导航栏 ----
        this.NavBar()

        // ---- 表单区 ----
        Column() {
          // 1. 手机号输入框
          Column() {
            Row() {
              SymbolGlyph($r('sys.symbol.person'))
                .fontSize(20)
                .fontColor([COLOR_SECONDARY])
                .margin({ right: 12 })
              TextInput({ placeholder: '请输入手机号', text: this.phone })
                .type(InputType.PhoneNumber)
                .maxLength(11)
                .fontSize(15)
                .fontColor(COLOR_TITLE)
                .placeholderColor(COLOR_PLACEHOLDER)
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.phone = value;
                })
            }
            .width('100%')
            .layoutWeight(1)
            .alignItems(VerticalAlign.Center)

            Divider()
              .color(COLOR_LINE)
              .width('100%')
          }
          .width('100%')
          .height(INPUT_ROW_HEIGHT)

          // 2. 密码输入框
          Column() {
            Row() {
              SymbolGlyph($r('sys.symbol.lock'))
                .fontSize(20)
                .fontColor([COLOR_SECONDARY])
                .margin({ right: 12 })
              TextInput({ placeholder: '请设置密码（6-20位）', text: this.password })
                .type(this.isPwdVisible ? InputType.Normal : InputType.Password)
                .fontSize(15)
                .fontColor(COLOR_TITLE)
                .placeholderColor(COLOR_PLACEHOLDER)
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.password = value;
                })

              if (this.isPwdVisible) {
                SymbolGlyph($r('sys.symbol.eye'))
                  .fontSize(20)
                  .fontColor([COLOR_SECONDARY])
                  .onClick(() => {
                    this.togglePwdVisible(false);
                  })
              } else {
                SymbolGlyph($r('sys.symbol.eye_slash'))
                  .fontSize(20)
                  .fontColor([COLOR_SECONDARY])
                  .onClick(() => {
                    this.togglePwdVisible(false);
                  })
              }
            }
            .width('100%')
            .layoutWeight(1)
            .alignItems(VerticalAlign.Center)

            Divider()
              .color(COLOR_LINE)
              .width('100%')
          }
          .width('100%')
          .height(INPUT_ROW_HEIGHT)

          // 3. 确认密码输入框
          Column() {
            Row() {
              SymbolGlyph($r('sys.symbol.lock'))
                .fontSize(20)
                .fontColor([COLOR_SECONDARY])
                .margin({ right: 12 })
              TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
                .type(this.isConfirmPwdVisible ? InputType.Normal : InputType.Password)
                .fontSize(15)
                .fontColor(COLOR_TITLE)
                .placeholderColor(COLOR_PLACEHOLDER)
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.confirmPassword = value;
                })

              if (this.isConfirmPwdVisible) {
                SymbolGlyph($r('sys.symbol.eye'))
                  .fontSize(20)
                  .fontColor([COLOR_SECONDARY])
                  .onClick(() => {
                    this.togglePwdVisible(true);
                  })
              } else {
                SymbolGlyph($r('sys.symbol.eye_slash'))
                  .fontSize(20)
                  .fontColor([COLOR_SECONDARY])
                  .onClick(() => {
                    this.togglePwdVisible(true);
                  })
              }
            }
            .width('100%')
            .layoutWeight(1)
            .alignItems(VerticalAlign.Center)

            Divider()
              .color(COLOR_LINE)
              .width('100%')
          }
          .width('100%')
          .height(INPUT_ROW_HEIGHT)
        }
        .padding({ left: 24, right: 24, top: 32 })

        // ---- 用户协议区 ----
        Column() {
          this.AgreementRow()
        }
        .padding({ left: 24, right: 24 })
        .margin({ top: 20 })

        // ---- 注册按钮（非满宽，水平收缩并居中）----
        Column() {
          Button('注 册')
            .width('90%')
            .height(48)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLOR_BUTTON_TEXT)
            .backgroundColor(COLOR_PRIMARY)
            .borderRadius(8)
            .opacity(this.isRegisterPressed ? 0.9 : 1)
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.isRegisterPressed = true;
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.isRegisterPressed = false;
              }
            })
            .onClick(() => {
              this.handleRegister();
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 32 })

        // ---- 底部引导区 ----
        Row() {
          Text('已有账号？')
            .fontSize(13)
            .fontColor(COLOR_SECONDARY)
          Text('去登录')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLOR_PRIMARY)
            .decoration({ type: TextDecorationType.Underline, color: COLOR_PRIMARY })
            .margin({ left: 2 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/Login' });
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 24, bottom: 24 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG)
    .scrollBar(BarState.Off)
  }
}
