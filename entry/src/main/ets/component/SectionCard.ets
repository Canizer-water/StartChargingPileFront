/**
 * 统一分区卡片容器：app_card 底、radius 12、1vp divider 描边、默认 16 内边距。
 * 用法：SectionCard({ content: this.SomeBuilder, pad: 16 })。
 */
@Component
export struct SectionCard {
  @BuilderParam content: () => void = this.emptyContent;
  pad: Length | Padding = 16;
  withBorder: boolean = true;

  @Builder
  emptyContent() {
  }

  build() {
    Column() {
      this.content();
    }
    .width('100%')
    .padding(this.pad)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .border(this.withBorder ? { width: 1, color: $r('app.color.divider') } : { width: 0 })
  }
}
