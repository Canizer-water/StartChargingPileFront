import { router } from '@kit.ArkUI';
import { LineIcon } from '../component/LineIcon';

class NotificationItem {
  id: number;
  title: string;
  content: string;
  iconKind: string;

  constructor(id: number, title: string, content: string, iconKind: string) {
    this.id = id;
    this.title = title;
    this.content = content;
    this.iconKind = iconKind;
  }
}

// ===== Mock 通知数据 =====
const NOTIFICATION_DATA: NotificationItem[] = [
  new NotificationItem(1, '系统升级通知', 'HarmonyOS NEXT 版本将于本周五凌晨 02:00 自动更新，请提前保存数据并保持充电桩在线。', 'bolt'),
  new NotificationItem(2, '账号安全提醒', '检测到您的账号在异地登录，请及时修改密码以确保账户安全。', 'user'),
  new NotificationItem(3, '新功能上线', 'AI 助手已支持多模态交互，欢迎体验智能充电服务。', 'sparkle')
];

@Entry
@Component
struct NotificationsPage {
  private notifications: NotificationItem[] = NOTIFICATION_DATA;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error('showToast failed: ' + JSON.stringify(err));
    }
  }

  @Builder
  NotificationCard(item: NotificationItem) {
    Row() {
      // 左侧圆形图标（与客服消息同款视觉）
      Row() {
        LineIcon({ kind: item.iconKind, color: '#26599A' })
      }
      .width(42)
      .height(42)
      .borderRadius(21)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(0x33FFFFFF)

      // 标题 + 内容：从上往下排列
      Column({ space: 6 }) {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#16385B')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.content)
          .fontSize(14)
          .fontColor('#3F6188')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12, right: 10 })

      Row() {
        LineIcon({ kind: 'chevronRight', color: '#6284AC' })
      }
      .width(20)
      .height(20)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(14)
    .borderRadius(12)
    .backgroundColor(0xE6FFFFFF)
    .border({ width: 1, color: '#D8E7F7' })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.showToast('查看通知详情：' + item.title);
    })
  }

  @Builder
  ServiceCard() {
    Row() {
      // 客服反馈图标（对话气泡）
      Row() {
        LineIcon({ kind: 'chat', color: '#26599A' })
      }
      .width(42)
      .height(42)
      .borderRadius(21)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(0x33FFFFFF)

      Text('客服反馈')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#16385B')
        .margin({ left: 12 })

      Blank()

      Row() {
        LineIcon({ kind: 'chevronRight', color: '#6284AC' })
      }
      .width(20)
      .height(20)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(14)
    .borderRadius(12)
    .backgroundColor(0xE6FFFFFF)
    .border({ width: 1, color: '#D8E7F7' })
    .alignItems(VerticalAlign.Center)
    .margin({ top: 24 })
    .onClick(() => {
      this.showToast('跳转客服反馈页面');
    })
  }

  build() {
    Column() {
      // 顶部标题栏：返回 + 系统通知
      Row() {
        Row() {
          LineIcon({ kind: 'back', color: '#FFFFFF' })
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .backgroundColor(0x26FFFFFF)
        .onClick(() => {
          router.back();
        })

        Text('系统通知')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ left: 6 })
      }
      .width('100%')
      .height(52)
      .padding({ left: 8, right: 16 })
      .alignItems(VerticalAlign.Center)

      // 可滚动内容区：通知列表 + 客服反馈
      Scroll() {
        Column() {
          Column({ space: 12 }) {
            ForEach(this.notifications, (item: NotificationItem) => {
              this.NotificationCard(item)
            }, (item: NotificationItem) => item.id.toString())
          }
          .width('100%')

          this.ServiceCard()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 24 })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 36 })
    .linearGradient({
      angle: 180,
      colors: [[0xFF0F3160, 0.0], [0xFF5A8DC0, 1.0]]
    })
  }
}