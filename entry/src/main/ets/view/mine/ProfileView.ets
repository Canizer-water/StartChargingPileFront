import { LineIcon } from '../../component/LineIcon';
import { NavParam } from '../../model/Types';
import { Theme } from '../../common/Theme';

/**
 * 个人中心（"我的"入口）。
 * 顶部渐变 + 头像/用户名；下方功能列表跳转钱包/爱车/订单/通知/用户详情。
 */

class ProfileMenuItem {
  key: string;
  title: string;
  iconKind: string;
  badge: string;

  constructor(key: string, title: string, iconKind: string, badge: string) {
    this.key = key;
    this.title = title;
    this.iconKind = iconKind;
    this.badge = badge;
  }
}

@Component
export struct ProfileView {
  pathStack: NavPathStack = new NavPathStack();

  @StorageLink('isDarkMode') isDark: boolean = false;

  private menuItems: ProfileMenuItem[] = [
    new ProfileMenuItem('wallet', '我的钱包', 'wallet', '2'),
    new ProfileMenuItem('car', '我的爱车', 'car', ''),
    new ProfileMenuItem('history', '历史记录', 'history', ''),
    new ProfileMenuItem('notify', '系统通知', 'envelope', '')
  ];

  private decoSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private decoContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.decoSettings);

  private go(route: string): void {
    const param: NavParam = { id: '' };
    this.pathStack.pushPathByName(route, param);
  }

  private routeOf(key: string): string {
    if (key === 'wallet') {
      return 'Wallet';
    }
    if (key === 'car') {
      return 'MyVehicles';
    }
    if (key === 'history') {
      return 'OrderHistory';
    }
    if (key === 'notify') {
      return 'Notifications';
    }
    return '';
  }

  private openSubPage(key: string): void {
    const route: string = this.routeOf(key);
    if (route !== '') {
      this.go(route);
    }
  }

  private openUserDetail(): void {
    this.go('UserDetail');
  }

  private drawDot(ctx: CanvasRenderingContext2D, x: number, y: number, r: number): void {
    ctx.beginPath();
    ctx.arc(x, y, r, 0, Math.PI * 2);
    ctx.fill();
  }

  private drawHexagon(ctx: CanvasRenderingContext2D, cx: number, cy: number, radius: number, rotate: number): void {
    ctx.beginPath();
    for (let i: number = 0; i <= 6; i++) {
      const angle: number = rotate + i * Math.PI / 3;
      const px: number = cx + Math.cos(angle) * radius;
      const py: number = cy + Math.sin(angle) * radius;
      if (i === 0) {
        ctx.moveTo(px, py);
      } else {
        ctx.lineTo(px, py);
      }
    }
    ctx.stroke();
  }

  private drawHeaderDeco(): void {
    const ctx: CanvasRenderingContext2D = this.decoContext;
    const w: number = ctx.width;
    const h: number = ctx.height;
    if (w <= 0 || h <= 0) {
      return;
    }
    ctx.clearRect(0, 0, w, h);

    ctx.lineWidth = 1;
    ctx.strokeStyle = 0x0DFFFFFF;
    const gap: number = 26;
    for (let x: number = 0; x < w; x += gap) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, h);
      ctx.stroke();
    }
    for (let y: number = 0; y < h; y += gap) {
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(w, y);
      ctx.stroke();
    }

    ctx.lineWidth = 1.3;
    ctx.strokeStyle = 0x32BFF2FF;
    this.drawHexagon(ctx, w * 0.88, h * 0.22, Math.min(w, h) * 0.28, 0);
    this.drawHexagon(ctx, w * 0.10, h * 1.18, Math.min(w, h) * 0.32, Math.PI / 6);

    ctx.fillStyle = 0x66FFFFFF;
    this.drawDot(ctx, w * 0.94, h * 0.16, 2);
    this.drawDot(ctx, w * 0.78, h * 0.36, 1.2);
    this.drawDot(ctx, w * 0.06, h * 0.42, 1.6);
    this.drawDot(ctx, w * 0.24, h * 0.78, 1.2);
  }

  @Builder
  UserInfoHeader() {
    Row() {
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

      Column() {
        Text('智充车主')
          .fontSize(19)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.profile_header_text'))
        Row() {
          Row()
            .width(5)
            .height(5)
            .borderRadius(2.5)
            .backgroundColor(0x80FFFFFF)
            .margin({ right: 5 })
          Text('绿色出行 · 低碳生活')
            .fontSize(12)
            .fontColor($r('app.color.profile_header_sub'))
        }
        .alignItems(VerticalAlign.Center)
        .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })

      Row() {
        LineIcon({ kind: 'chevronRight', color: '#A6FFFFFF' })
      }
      .width(18)
      .height(18)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.openUserDetail();
    })
  }

  @Builder
  MenuRow(item: ProfileMenuItem) {
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

      if (item.badge.length > 0) {
        Row() {
          Text(item.badge)
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(20)
        .height(20)
        .borderRadius(10)
        .backgroundColor($r('app.color.profile_badge'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      } else {
        Row() {
          LineIcon({ kind: 'chevronRight', color: Theme.palette(this.isDark).textMuted })
        }
        .width(14)
        .height(14)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .height(68)
    .padding({ left: 20, right: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.openSubPage(item.key);
    })
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Canvas(this.decoContext)
          .width('100%')
          .height('100%')
          .hitTestBehavior(HitTestMode.Transparent)
          .onReady(() => {
            this.drawHeaderDeco();
          })

        Column() {
          this.UserInfoHeader()
        }
        .width('100%')
        .padding({ left: 22, right: 22 })
        .margin({ top: 56 })
      }
      .width('100%')
      .height(196)
      .linearGradient({
        angle: 135,
        colors: [[$r('app.color.brand_deep'), 0.0], [$r('app.color.login_primary'), 0.55], [$r('app.color.primary_light'), 1.0]]
      })

      Column() {
        ForEach(this.menuItems, (item: ProfileMenuItem, index: number) => {
          Column() {
            this.MenuRow(item)
            if (index < this.menuItems.length - 1) {
              Divider()
                .color($r('app.color.profile_divider'))
                .strokeWidth(1)
            }
          }
          .width('100%')
        }, (item: ProfileMenuItem) => item.key)
      }
      .width('100%')
      .padding({ bottom: 20 })
      .backgroundColor($r('app.color.app_card'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_card'))
  }
}
