import { common } from '@kit.AbilityKit';
import { LineIcon } from '../../component/LineIcon';
import { Theme } from '../../common/Theme';
import { AuthService } from '../../service/AuthService';
import { NoticeService } from '../../service/NoticeService';
import { OrderService } from '../../service/OrderService';
import { WalletService } from '../../service/WalletService';
import { ChargingOrder, NavParam, UserAccount } from '../../model/Types';

/**
 * 我的（Story 16）：头像 / 用户名 / 用户ID + 钱包域入口 + 退出登录。
 * 菜单三行（钱包/爱车/通知）为文档外增补，样式沿用 ProfileView 的图标块 + 红点徽标；
 * 「历史记录」不在此挂——底部 tab 的「订单」已是同一职责（且本页数据以服务端为准）。
 */

class MenuItem {
  key: string;
  title: string;
  iconKind: string;

  constructor(key: string, title: string, iconKind: string) {
    this.key = key;
    this.title = title;
    this.iconKind = iconKind;
  }
}

@Component
export struct MineView {
  pathStack: NavPathStack = new NavPathStack();

  @StorageProp('currentUser') user: UserAccount | null = null;
  @StorageLink('isDarkMode') isDark: boolean = false;
  @StorageProp('ordersVersion') @Watch('loadBadges') ordersVersion: number = 0;
  @StorageProp('noticeVersion') @Watch('loadBadges') noticeVersion: number = 0;
  @State loggingOut: boolean = false;
  /** 可开票订单数（已完成单）——挂钱包行红点 */
  @State invoiceableCount: number = 0;
  /** 未读通知数——挂通知行红点 */
  @State unreadCount: number = 0;

  private items: MenuItem[] = [
    new MenuItem('wallet', '我的钱包', 'wallet'),
    new MenuItem('car', '我的爱车', 'car'),
    new MenuItem('notify', '系统通知', 'envelope')
  ];

  aboutToAppear(): void {
    this.ensureStores();
    this.loadBadges();
  }

  /** preferences 存储兜底自初始化（Ability 已初始化时为空操作） */
  private ensureStores(): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    WalletService.getInstance().init(ctx).catch(() => {
    });
    NoticeService.getInstance().init(ctx).catch(() => {
    });
  }

  private routeOf(key: string): string {
    if (key === 'wallet') {
      return 'Wallet';
    }
    if (key === 'car') {
      return 'MyVehicles';
    }
    if (key === 'notify') {
      return 'Notifications';
    }
    return '';
  }

  private go(key: string): void {
    const route: string = this.routeOf(key);
    if (route === '') {
      return;
    }
    const param: NavParam = { id: '' };
    this.pathStack.pushPathByName(route, param);
  }

  /** 红点数据：可开票单数 + 未读通知数；后端不可达时保持旧值不报错 */
  private loadBadges(): void {
    NoticeService.getInstance().unreadCount().then((n: number) => {
      this.unreadCount = n;
    }).catch(() => {
    });
    OrderService.getInstance().listOrders().then((list: ChargingOrder[]) => {
      // 顺带对账：本页已有订单列表，不结算的话「可开票 2 单」会与余额 0.00 并存
      WalletService.getInstance().settleFinished(list).catch(() => {
      });
      this.invoiceableCount = list.filter((o: ChargingOrder) => o.status === 'FINISHED').length;
    }).catch(() => {
    });
  }

  private badgeOf(key: string): string {
    if (key === 'wallet') {
      return this.invoiceableCount > 0 ? this.invoiceableCount.toString() : '';
    }
    if (key === 'notify') {
      return this.unreadCount > 0 ? this.unreadCount.toString() : '';
    }
    return '';
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private maskedName(): string {
    const name = this.user ? this.user.username : '';
    if (name.length !== 11) {
      return name === '' ? '未登录' : name;
    }
    return `${name.substring(0, 3)}****${name.substring(7)}`;
  }

  private handleLogout(): void {
    if (this.loggingOut) {
      return;
    }
    this.loggingOut = true;
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    AuthService.getInstance().init(ctx)
      .then(() => AuthService.getInstance().logout())
      .then(() => {
        AppStorage.setOrCreate<UserAccount | null>('currentUser', null);
        AppStorage.setOrCreate('isLoggedIn', false);
        try {
          this.getUIContext().getRouter().replaceUrl({ url: 'pages/Login' });
        } catch (err) {
          this.showToast('退出失败，请重试');
        }
      })
      .catch(() => {
        this.showToast('退出失败，请重试');
      })
      .finally(() => {
        this.loggingOut = false;
      });
  }

  @Builder
  GradientHeader() {
    Column() {
      Row() {
        LineIcon({ kind: 'user', color: '#FFFFFF' })
      }
      .width(64)
      .height(64)
      .borderRadius(32)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .linearGradient({
        angle: 135,
        colors: [[$r('app.color.primary_light'), 0.0], [$r('app.color.brand_deep'), 1.0]]
      })
      .border({ width: 2, color: 0xCCFFFFFF })
      .shadow({ radius: 12, color: 0x30000000, offsetY: 4 })

      Text(this.maskedName())
        .fontSize(19)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.profile_header_text'))
        .margin({ top: 12 })

      Text(this.user ? `用户ID：${this.user.id}` : '绿色出行 · 低碳生活')
        .fontSize(12)
        .fontColor($r('app.color.profile_header_sub'))
        .margin({ top: 8 })

      if (this.user) {
        Text(`注册时间：${this.user.createdAt.substring(0, 10)}`)
          .fontSize(11)
          .fontColor($r('app.color.profile_header_sub'))
          .opacity(0.8)
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .padding({ top: 56, bottom: 36 })
    .alignItems(HorizontalAlign.Center)
    .linearGradient({
      angle: 135,
      colors: [[$r('app.color.brand_deep'), 0.0], [$r('app.color.login_primary'), 0.55], [$r('app.color.primary_light'), 1.0]]
    })
  }

  @Builder
  MenuRow(item: MenuItem) {
    Row() {
      Row() {
        LineIcon({ kind: item.iconKind, color: Theme.palette(this.isDark).brand })
      }
      .width(44)
      .height(44)
      .borderRadius(13)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.tint_blue'))

      Text(item.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.profile_text_primary'))
        .margin({ left: 14 })
        .layoutWeight(1)

      if (this.badgeOf(item.key).length > 0) {
        Row() {
          Text(this.badgeOf(item.key))
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .height(20)
        .constraintSize({ minWidth: 20 })
        .padding({ left: 6, right: 6 })
        .borderRadius(10)
        .backgroundColor($r('app.color.profile_badge'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({ right: 10 })
      }

      // LineIcon 是 100%×100% 的 Canvas，必须包固定尺寸容器，
      // 否则会索要整行宽度、把 layoutWeight(1) 的标题挤没
      Row() {
        LineIcon({ kind: 'chevronRight', color: Theme.palette(this.isDark).textMuted })
      }
      .width(16)
      .height(16)
      .margin({ left: 6 })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(68)
    .padding({ left: 20, right: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.go(item.key))
  }

  @Builder
  LogoutRow() {
    Row() {
      Row() {
        LineIcon({ kind: 'exit', color: '#ED823E' })
      }
      .width(44)
      .height(44)
      .borderRadius(13)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.chip_bg'))

      Text('退出登录')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.profile_text_primary'))
        .margin({ left: 14 })
        .layoutWeight(1)
    }
    .width('100%')
    .height(68)
    .padding({ left: 20, right: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.handleLogout())
  }

  build() {
    Column() {
      this.GradientHeader()

      // 头图满宽，卡片层单独留 16 边距（与全站 app_bg + 圆角卡片一致）
      Column() {
        Column() {
          ForEach(this.items, (item: MenuItem, index: number) => {
            Column() {
              this.MenuRow(item)
              if (index < this.items.length - 1) {
                Divider()
                  .color($r('app.color.profile_divider'))
                  .strokeWidth(1)
              }
            }
            .width('100%')
          }, (item: MenuItem) => item.key)
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })
        .backgroundColor($r('app.color.app_card'))
        .borderRadius(12)

        Column() {
          this.LogoutRow()
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })
        .margin({ top: 12 })
        .backgroundColor($r('app.color.app_card'))
        .borderRadius(12)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
