import { router } from '@kit.ArkUI';
import { LineIcon } from '../component/LineIcon';

/**
 * 个人中心页（移动端）
 * - 顶部：深蓝/青色科技渐变 + 抽象网格/多边形装饰，头像 + 用户名
 * - 底部：白色功能列表（我的钱包 / 我的爱车 / 历史记录 / 系统通知）
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

@Entry
@Component
struct ProfilePage {
  private menuItems: ProfileMenuItem[] = [
    new ProfileMenuItem('wallet', '我的钱包', 'wallet', '2'),
    new ProfileMenuItem('car', '我的爱车', 'car', ''),
    new ProfileMenuItem('history', '历史记录', 'history', ''),
    new ProfileMenuItem('notify', '系统通知', 'envelope', '')
  ];

  private decoSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private decoContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.decoSettings);

  private routeOf(key: string): string {
    if (key === 'wallet') {
      return 'pages/MyWallet';
    }
    if (key === 'car') {
      return 'pages/MyCar';
    }
    if (key === 'history') {
      return 'pages/History';
    }
    if (key === 'notify') {
      return 'pages/Notifications';
    }
    return '';
  }

  private openSubPage(key: string): void {
    const url: string = this.routeOf(key);
    if (url === '') {
      return;
    }
    router.pushUrl({ url: url }, (err) => {
      if (err) {
        console.error('push sub page failed: ' + JSON.stringify(err));
      }
    });
  }

  private openUserDetail(): void {
    router.pushUrl({ url: 'pages/UserDetail' }, (err) => {
      if (err) {
        console.error('push UserDetail failed: ' + JSON.stringify(err));
      }
    });
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

  /** 顶部科技感装饰：细网格 + 抽象多边形 + 光点 */
  private drawHeaderDeco(): void {
    const ctx: CanvasRenderingContext2D = this.decoContext;
    const w: number = ctx.width;
    const h: number = ctx.height;
    if (w <= 0 || h <= 0) {
      return;
    }
    ctx.clearRect(0, 0, w, h);

    // 细网格
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

    // 抽象多边形
    ctx.lineWidth = 1.3;
    ctx.strokeStyle = 0x32BFF2FF;
    this.drawHexagon(ctx, w * 0.88, h * 0.22, Math.min(w, h) * 0.28, 0);
    this.drawHexagon(ctx, w * 0.10, h * 1.18, Math.min(w, h) * 0.32, Math.PI / 6);

    // 光点
    ctx.fillStyle = 0x66FFFFFF;
    this.drawDot(ctx, w * 0.94, h * 0.16, 2);
    this.drawDot(ctx, w * 0.78, h * 0.36, 1.2);
    this.drawDot(ctx, w * 0.06, h * 0.42, 1.6);
    this.drawDot(ctx, w * 0.24, h * 0.78, 1.2);
  }

  @Builder
  UserInfoHeader() {
    Row() {
      // 圆形头像占位：渐变圆 + 人形
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
        colors: [[0xFF52C8FF, 0.0], [0xFF1E5FD9, 1.0]]
      })
      .border({ width: 2, color: 0xCCFFFFFF })
      .shadow({ radius: 12, color: 0x30000000, offsetY: 4 })

      // 用户名 + 标语
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

      // 可点击引导箭头
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
      // 左侧图标
      Row() {
        LineIcon({ kind: item.iconKind, color: '#1450B8' })
      }
      .width(44)
      .height(44)
      .borderRadius(13)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .linearGradient({
        angle: 135,
        colors: [[0xFFEAF2FF, 0.0], [0xFFD8E7FF, 1.0]]
      })

      // 中间文字
      Text(item.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.profile_text_primary'))
        .margin({ left: 14 })
        .layoutWeight(1)

      // 右侧元素
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
          LineIcon({ kind: 'chevronRight', color: '#C3CAD4' })
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
      // ===== 顶部信息区 =====
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
        colors: [[0xFF081C45, 0.0], [0xFF0E3E8C, 0.55], [0xFF0C86A8, 1.0]]
      })

      // ===== 底部功能列表区（纯白背景） =====
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
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
