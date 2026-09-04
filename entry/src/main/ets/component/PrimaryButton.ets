/**
 * 统一主操作按钮：h48、圆角 24 pill。solid = 品牌底白字；outline = 描边品牌字。
 * 语义强调（如“结束充电”）通过 color 传入 accent。
 */
@Component
export struct PrimaryButton {
  @Prop label: string = '';
  @Prop outline: boolean = false;
  @Prop disabled: boolean = false;
  @Prop fullWidth: boolean = true;
  color: ResourceColor = $r('app.color.btn_primary');
  radius: number = 24;
  onTap?: () => void;

  build() {
    Button(this.label)
      .width(this.fullWidth ? '100%' : undefined)
      .height(48)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.outline ? this.color : Color.White)
      .backgroundColor(this.outline ? $r('app.color.app_card') : this.color)
      .border({ width: 1.5, color: this.outline ? this.color : Color.Transparent })
      .borderRadius(this.radius)
      .padding({ left: 24, right: 24 })
      .enabled(!this.disabled)
      .onClick(() => {
        if (this.onTap) {
          this.onTap();
        }
      })
  }
}
