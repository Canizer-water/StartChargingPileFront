/**
 * 注册页（Story 1）。
 * 字段：手机号 / 密码 / 确认密码 + 用户协议勾选。
 * 前端演示：注册成功后记录手机号到 AppStorage，供登录页回填。
 */

@Entry
@Component
struct RegisterPage {
  @State phone: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isPwdVisible: boolean = false;
  @State isConfirmPwdVisible: boolean = false;
  @State isAgreed: boolean = false;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`RegisterPage showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private goBack(): void {
    this.getUIContext().getRouter().back();
  }

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

  private handleRegister(): void {
    const err = this.validate();
    if (err !== '') {
      this.showToast(err);
      return;
    }
    // 前端演示：暂未对接后端，仅模拟注册
    AppStorage.setOrCreate('registeredPhone', this.phone);
    this.showToast('注册成功');
    setTimeout(() => {
      this.goBack();
    }, 800);
  }

  private togglePwdVisible(isConfirm: boolean): void {
    if (isConfirm) {
      this.isConfirmPwdVisible = !this.isConfirmPwdVisible;
    } else {
      this.isPwdVisible = !this.isPwdVisible;
    }
  }

  @Builder
  NavBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor($r('app.color.text_primary'))
        .width(48)
        .onClick(() => this.goBack())

      Text('注册')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Row().width(48)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16 })
    .backgroundColor($r('app.color.app_card'))
    .alignItems(VerticalAlign.Center)

    Divider().color($r('app.color.divider')).width('100%')
  }

  @Builder
  AgreementRow() {
    Row() {
      Stack() {
        if (this.isAgreed) {
          Text('✓')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
      }
      .width(16)
      .height(16)
      .borderRadius(8)
      .backgroundColor(this.isAgreed ? $r('app.color.btn_primary') : $r('app.color.app_card'))
      .border({ width: 1, color: this.isAgreed ? $r('app.color.btn_primary') : $r('app.color.border') })
      .clip(true)

      Row() {
        Text('我已阅读并同意')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        Text('《用户协议》')
          .fontSize(12)
          .fontColor($r('app.color.btn_primary'))
          .onClick(() => this.showToast('《用户协议》内容查看开发中'))
        Text('和')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        Text('《隐私政策》')
          .fontSize(12)
          .fontColor($r('app.color.btn_primary'))
          .onClick(() => this.showToast('《隐私政策》内容查看开发中'))
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

  /** 下划线输入行 */
  @Builder
  InputRow(icon: Resource, placeholder: string, text: string, isPassword: boolean, isConfirm: boolean) {
    Column() {
      Row() {
        SymbolGlyph(icon)
          .fontSize(20)
          .fontColor([$r('app.color.text_secondary')])
          .margin({ right: 12 })
        TextInput({ placeholder: placeholder, text: text })
          .type(isPassword ? (isConfirm ? (this.isConfirmPwdVisible ? InputType.Normal : InputType.Password) : (this.isPwdVisible ? InputType.Normal : InputType.Password)) : InputType.PhoneNumber)
          .maxLength(isPassword ? 20 : 11)
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
          .placeholderColor($r('app.color.text_muted'))
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onChange((value: string) => {
            if (isConfirm) {
              this.confirmPassword = value;
            } else if (isPassword) {
              this.password = value;
            } else {
              this.phone = value;
            }
          })

        if (isPassword) {
          if (isConfirm) {
            if (this.isConfirmPwdVisible) {
              SymbolGlyph($r('sys.symbol.eye')).fontSize(20).fontColor([$r('app.color.text_secondary')])
                .onClick(() => this.togglePwdVisible(true))
            } else {
              SymbolGlyph($r('sys.symbol.eye_slash')).fontSize(20).fontColor([$r('app.color.text_secondary')])
                .onClick(() => this.togglePwdVisible(true))
            }
          } else {
            if (this.isPwdVisible) {
              SymbolGlyph($r('sys.symbol.eye')).fontSize(20).fontColor([$r('app.color.text_secondary')])
                .onClick(() => this.togglePwdVisible(false))
            } else {
              SymbolGlyph($r('sys.symbol.eye_slash')).fontSize(20).fontColor([$r('app.color.text_secondary')])
                .onClick(() => this.togglePwdVisible(false))
            }
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)

      Divider().color($r('app.color.divider')).width('100%')
    }
    .width('100%')
    .height(58)
  }

  build() {
    Scroll() {
      Column() {
        this.NavBar()

        Column() {
          this.InputRow($r('sys.symbol.person'), '请输入手机号', this.phone, false, false)
          this.InputRow($r('sys.symbol.lock'), '请设置密码（6-20位）', this.password, true, false)
          this.InputRow($r('sys.symbol.lock'), '请再次输入密码', this.confirmPassword, true, true)
        }
        .padding({ left: 24, right: 24, top: 32 })

        Column() {
          this.AgreementRow()
        }
        .padding({ left: 24, right: 24 })
        .margin({ top: 20 })

        Column() {
          Button('注 册')
            .width('90%')
            .height(48)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.btn_primary'))
            .borderRadius(8)
            .onClick(() => this.handleRegister())
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 32 })

        Row() {
          Text('已有账号？')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
          Text('去登录')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.btn_primary'))
            .decoration({ type: TextDecorationType.Underline, color: $r('app.color.btn_primary') })
            .margin({ left: 2 })
            .onClick(() => this.goBack())
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 24, bottom: 24 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
    .scrollBar(BarState.Off)
  }
}
