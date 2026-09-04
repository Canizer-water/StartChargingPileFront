/**
 * 统一“标签 / 值”信息行（h48；14 副文 / 15 中粗）。
 * 值可传强调色（金额用 accent 等）。
 */
@Component
export struct InfoRow {
  @Prop label: string = '';
  @Prop value: string = '';
  valueColor: ResourceColor = $r('app.color.text_primary');

  build() {
    Row() {
      Text(this.label)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
      Blank()
      Text(this.value)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.valueColor)
    }
    .width('100%')
    .height(48)
  }
}
