import { common } from '@kit.AbilityKit';
import { LineIcon } from '../../component/LineIcon';
import { Theme } from '../../common/Theme';
import { AppTopBar } from '../../component/AppTopBar';
import { NoticeItem, NoticeService } from '../../service/NoticeService';

/**
 * 系统通知：通知列表 + 客服反馈入口。
 * 标准浅底页面 + 白色卡片，与全局蓝色设计系统一致。
 * 内容为端侧静态演示数据（无后端接口，契约未收录），进页即标记已读、「我的」页红点清零。
 */

@Component
export struct NotificationsView {
  pathStack: NavPathStack = new NavPathStack();

  @StorageLink('isDarkMode') isDark: boolean = false;

  private notifications: NoticeItem[] = [];

  aboutToAppear(): void {
    this.notifications = NoticeService.getInstance().list();
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    NoticeService.getInstance().init(ctx)
      .then(() => NoticeService.getInstance().markAllSeen())
      .catch(() => {
      });
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error('Notifications showToast failed: ' + JSON.stringify(err));
    }
  }

  @Builder
  IconTile(kind: string) {
    Row() {
      LineIcon({ kind: kind, color: Theme.palette(this.isDark).brand })
    }
    .width(42)
    .height(42)
    .borderRadius(21)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.tint_blue'))
  }

  @Builder
  NotificationCard(item: NoticeItem) {
    Row() {
      this.IconTile(item.iconKind)

      Column({ space: 6 }) {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.content)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12, right: 10 })

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(16)
        .fontColor([$r('app.color.text_muted')])
    }
    .width('100%')
    .padding(14)
    .borderRadius(12)
    .backgroundColor($r('app.color.app_card'))
    .border({ width: 1, color: $r('app.color.divider') })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.showToast('查看通知详情：' + item.title);
    })
  }

  @Builder
  ServiceCard() {
    Row() {
      this.IconTile('chat')

      Text('客服反馈')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ left: 12 })

      Blank()

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(16)
        .fontColor([$r('app.color.text_muted')])
    }
    .width('100%')
    .padding(14)
    .borderRadius(12)
    .backgroundColor($r('app.color.app_card'))
    .border({ width: 1, color: $r('app.color.divider') })
    .alignItems(VerticalAlign.Center)
    .margin({ top: 24 })
    .onClick(() => {
      this.showToast('跳转客服反馈页面');
    })
  }

  build() {
    Column() {
      AppTopBar({ title: '系统通知', pathStack: this.pathStack })

      Scroll() {
        Column() {
          Column({ space: 12 }) {
            ForEach(this.notifications, (item: NoticeItem) => {
              this.NotificationCard(item)
            }, (item: NoticeItem) => item.id.toString())
          }
          .width('100%')

          this.ServiceCard()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
