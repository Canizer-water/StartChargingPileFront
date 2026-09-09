import { router } from '@kit.ArkUI';
import { ChatMessage, chatWithAssistant } from '../service/AiService';

@Entry
@Component
struct AiChatPage {
  @State input: string = '';
  @State loading: boolean = false;
  @State messages: ChatMessage[] = [
    { role: 'assistant', content: '你好，我是充电助手，请问有什么可以帮你？' },
  ];
  private scroller: Scroller = new Scroller();

  private scrollToBottom(): void {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 60);
  }

  private async send(): Promise<void> {
    const text = this.input.trim();
    if (text === '' || this.loading) {
      return;
    }
    this.input = '';
    this.messages.push({ role: 'user', content: text });
    this.scrollToBottom();
    this.loading = true;
    try {
      const reply = await chatWithAssistant(this.messages);
      this.messages.push({ role: 'assistant', content: reply });
    } catch (err) {
      console.error(`chat failed: ${JSON.stringify(err)}`);
      this.messages.push({ role: 'assistant', content: '抱歉，请求失败了，请稍后重试。' });
    } finally {
      this.loading = false;
      this.scrollToBottom();
    }
  }

  @Builder
  TitleBar() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor([$r('app.color.charge_secondary')])
        .onClick(() => {
          router.back();
        })
      Blank()
      Text('AI 助手')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.charge_title'))
      Blank()
      Row()
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  MessageBubble(msg: ChatMessage) {
    Row() {
      if (msg.role === 'user') {
        Blank()
        Text(msg.content)
          .fontSize(15)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.login_primary'))
          .borderRadius({ topLeft: 14, topRight: 14, bottomLeft: 14, bottomRight: 4 })
          .padding(12)
          .constraintSize({ maxWidth: '75%' })
      } else {
        Text(msg.content)
          .fontSize(15)
          .fontColor($r('app.color.charge_title'))
          .backgroundColor($r('app.color.charge_field_bg'))
          .borderRadius({ topLeft: 14, topRight: 14, bottomLeft: 4, bottomRight: 14 })
          .padding(12)
          .constraintSize({ maxWidth: '75%' })
        Blank()
      }
    }
    .width('100%')
  }

  @Builder
  InputBar() {
    Row({ space: 10 }) {
      TextInput({ placeholder: '输入你的问题…', text: this.input })
        .fontSize(15)
        .fontColor($r('app.color.charge_title'))
        .placeholderColor($r('app.color.login_placeholder'))
        .backgroundColor($r('app.color.charge_field_bg'))
        .borderRadius(22)
        .height(44)
        .layoutWeight(1)
        .onChange((value: string) => {
          this.input = value;
        })
        .onSubmit(() => {
          this.send();
        })
      Button('发送')
        .height(44)
        .padding({ left: 20, right: 20 })
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor(this.loading ? $r('app.color.charge_secondary') : $r('app.color.login_primary'))
        .borderRadius(22)
        .onClick(() => {
          this.send();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 14 })
    .backgroundColor($r('app.color.charge_card_bg'))
    .border({ width: { top: 1 }, color: $r('app.color.divider') })
  }

  build() {
    Column() {
      this.TitleBar()

      Scroll(this.scroller) {
        Column({ space: 12 }) {
          ForEach(this.messages, (msg: ChatMessage) => {
            this.MessageBubble(msg)
          }, (msg: ChatMessage, index: number) => `${index}-${msg.role}`)

          if (this.loading) {
            Row() {
              Text('正在思考…')
                .fontSize(14)
                .fontColor($r('app.color.charge_secondary'))
                .padding(12)
                .backgroundColor($r('app.color.charge_field_bg'))
                .borderRadius(14)
              Blank()
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)

      this.InputBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
