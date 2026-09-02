import { router } from '@kit.ArkUI';

interface InvoiceOrder {
  station: string;
  time: string;
  amount: number;
  selected: boolean;
}

@Entry
@Component
struct Invoice {
  @State headType: number = 0;
  @State titleInput: string = '';
  @State taxNoInput: string = '';
  @State emailInput: string = '';
  @State orders: InvoiceOrder[] = [
    { station: '东方明珠充电站 · 02号桩', time: '09-18 14:30', amount: 36.50, selected: true },
    { station: '虹桥枢纽充电站 · 01号桩', time: '09-17 20:45', amount: 52.80, selected: false }
  ];

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private selectedTotal(): number {
    let total = 0;
    this.orders.forEach((item: InvoiceOrder) => {
      if (item.selected) {
        total += item.amount;
      }
    });
    return total;
  }

  private submit(): void {
    if (this.selectedTotal() <= 0) {
      this.showToast('请先选择要开票的订单');
      return;
    }
    if (this.titleInput.trim() === '') {
      this.showToast('请填写发票抬头');
      return;
    }
    if (this.emailInput.trim() === '') {
      this.showToast('请填写接收邮箱');
      return;
    }
    this.showToast('开票申请已提交，电子发票将发送至邮箱');
    this.getUIContext().getRouter().back();
  }

  @Builder
  NavBar(title: string) {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor([$r('app.color.common_text_primary')])
        .margin({ left: 4 })
        .onClick(() => {
          router.back();
        })
      Blank()
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.common_text_primary'))
      Blank()
      Row().width(24)
    }
    .width('100%')
    .height(44)
    .padding({ left: 12, right: 12 })
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.common_text_primary'))
      .width('100%')
      .margin({ bottom: 12 })
  }

  @Builder
  OrderSection() {
    Column() {
      this.SectionTitle('选择要开票的订单')

      ForEach(this.orders, (item: InvoiceOrder, index: number) => {
        Row() {
          Stack() {
            Circle()
              .width(20)
              .height(20)
              .fill(item.selected ? $r('app.color.common_primary') : $r('app.color.common_border'))
            if (item.selected) {
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontSize(12)
                .fontColor([Color.White])
            }
          }
          .width(20)
          .height(20)

          Column() {
            Text(item.station)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.common_text_primary'))
            Text(item.time)
              .fontSize(12)
              .fontColor($r('app.color.common_text_secondary'))
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })

          Text(item.amount.toFixed(2) + ' 元')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.common_text_primary'))
        }
        .width('100%')
        .height(64)
        .onClick(() => {
          this.orders[index].selected = !this.orders[index].selected;
        })
      }, (item: InvoiceOrder) => item.station)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(12)
    .margin({ top: 14 })
  }

  @Builder
  HeadTypeSection() {
    Column() {
      this.SectionTitle('发票抬头类型')

      Row() {
        Row() {
          Text('个人')
            .fontSize(15)
            .fontColor(this.headType === 0 ? Color.White : $r('app.color.common_text_secondary'))
        }
        .height(36)
        .layoutWeight(1)
        .borderRadius(10)
        .backgroundColor(this.headType === 0 ? $r('app.color.common_primary') : $r('app.color.common_bg'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.headType = 0;
        })
        Row() {
          Text('企业')
            .fontSize(15)
            .fontColor(this.headType === 1 ? Color.White : $r('app.color.common_text_secondary'))
        }
        .height(36)
        .layoutWeight(1)
        .borderRadius(10)
        .backgroundColor(this.headType === 1 ? $r('app.color.common_primary') : $r('app.color.common_bg'))
        .justifyContent(FlexAlign.Center)
        .margin({ left: 12 })
        .onClick(() => {
          this.headType = 1;
        })
      }
      .width('100%')
      .margin({ bottom: 14 })

      Text(this.headType === 0 ? '姓名 / 个人抬头' : '企业名称')
        .fontSize(13)
        .fontColor($r('app.color.common_text_secondary'))
        .width('100%')
        .margin({ bottom: 6 })

      TextInput({ placeholder: this.headType === 0 ? '请输入姓名' : '请输入企业名称', text: this.titleInput })
        .fontSize(15)
        .fontColor($r('app.color.common_text_primary'))
        .placeholderColor($r('app.color.common_text_tertiary'))
        .backgroundColor($r('app.color.common_bg'))
        .borderRadius(10)
        .height(50)
        .width('100%')
        .onChange((value: string) => {
          this.titleInput = value;
        })

      if (this.headType === 1) {
        Text('税号')
          .fontSize(13)
          .fontColor($r('app.color.common_text_secondary'))
          .width('100%')
          .margin({ top: 14, bottom: 6 })

        TextInput({ placeholder: '请输入纳税人识别号', text: this.taxNoInput })
          .fontSize(15)
          .fontColor($r('app.color.common_text_primary'))
          .placeholderColor($r('app.color.common_text_tertiary'))
          .backgroundColor($r('app.color.common_bg'))
          .borderRadius(10)
          .height(50)
          .width('100%')
          .onChange((value: string) => {
            this.taxNoInput = value;
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(12)
    .margin({ top: 14 })
  }

  @Builder
  EmailSection() {
    Column() {
      this.SectionTitle('接收邮箱')

      TextInput({ placeholder: '电子发票将发送至该邮箱', text: this.emailInput })
        .fontSize(15)
        .fontColor($r('app.color.common_text_primary'))
        .placeholderColor($r('app.color.common_text_tertiary'))
        .backgroundColor($r('app.color.common_bg'))
        .borderRadius(10)
        .height(50)
        .width('100%')
        .type(InputType.Email)
        .onChange((value: string) => {
          this.emailInput = value;
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(12)
    .margin({ top: 14 })
  }

  build() {
    Column() {
      this.NavBar('开电子发票')

      Scroll() {
        Column() {
          this.OrderSection()
          this.HeadTypeSection()
          this.EmailSection()

          Text('本次开票合计：' + this.selectedTotal().toFixed(2) + ' 元')
            .fontSize(14)
            .fontColor($r('app.color.common_text_primary'))
            .width('100%')
            .margin({ top: 4, bottom: 8 })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)

      Button('提交开票申请')
        .width('100%')
        .height(50)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.common_primary'))
        .borderRadius(25)
        .margin({ left: 16, right: 16, bottom: 20 })
        .onClick(() => {
          this.submit();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_bg'))
  }
}
