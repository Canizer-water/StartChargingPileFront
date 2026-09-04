/**
 * 统一顶栏：左返回 + 居中标题（h48，17 Medium，底部 1vp 分割线可选）。
 * NavDestination 页面传 pathStack；@Entry 页面（如注册）传 onBack。
 */
@Component
export struct AppTopBar {
  @Prop title: string = '';
  @Prop showBack: boolean = true;
  @Prop bordered: boolean = true;
  pathStack?: NavPathStack;
  onBack?: () => void;

  build() {
    Column() {
      Row() {
        if (this.showBack) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor([$r('app.color.text_primary')])
            .onClick(() => {
              if (this.onBack) {
                this.onBack();
              } else if (this.pathStack) {
                this.pathStack.pop();
              }
            })
        } else {
          Row().width(24).height(24)
        }
        Blank()
        Text(this.title)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
        Row().width(24).height(24)
      }
      .width('100%')
      .height(47)
      .padding({ left: 16, right: 16 })

      if (this.bordered) {
        Divider()
          .strokeWidth(1)
          .color($r('app.color.divider'))
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.top_bar_bg'))
  }
}
