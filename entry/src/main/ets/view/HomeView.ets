import { NavParam } from '../model/Types';

/**
 * 首页（导航根）：功能宫格入口。
 * 汇聚「附近电站」充电主流程 + 钱包/爱车/订单等扩展功能。
 */

interface HomeItem {
  icon: Resource;
  title: string;
  desc: string;
  color: string;
  route: string;
}

@Component
export struct HomeView {
  pathStack: NavPathStack = new NavPathStack();

  private homeItems: HomeItem[] = [
    { icon: $r('sys.symbol.wallet'), title: '我的钱包', desc: '余额 · 红包 · 优惠券 · 发票', color: '#5B8CE7', route: 'Wallet' },
    { icon: $r('sys.symbol.car'), title: '我的爱车', desc: '车辆管理 · 自动支付', color: '#ED823E', route: 'MyVehicles' },
    { icon: $r('sys.symbol.doc_text'), title: '历史订单', desc: '全部 · 进行中 · 已完成', color: '#6B5CE7', route: 'OrderHistory' },
    { icon: $r('sys.symbol.person'), title: '个人中心', desc: '用户信息 · 车辆 · 钱包', color: '#3FC98A', route: 'Profile' }
  ];

  private go(route: string): void {
    const param: NavParam = { id: '' };
    this.pathStack.pushPathByName(route, param);
  }

  @Builder
  Header() {
    Column() {
      Text('智能充电桩')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
      Text('扫码充电 · 智慧出行')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ top: 8 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
  }

  /** 附近电站入口横幅 */
  @Builder
  NearbyBanner() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [[0x33A984, 0.0], [0x1FA869, 0.6], [0x0E6B44, 1.0]]
        })
      Row() {
        SymbolGlyph($r('sys.symbol.bolt_fill'))
          .fontSize(30)
          .fontColor(['rgba(255,255,255,0.9)'])
        Column() {
          Text('附近电站')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text('一键查找周边充电中心')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.86)')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(20)
          .fontColor([Color.White])
      }
      .padding({ left: 18, right: 18 })
      .width('100%')
    }
    .width('100%')
    .height(96)
    .borderRadius(14)
    .clip(true)
    .onClick(() => this.go('NearbyStations'))
  }

  @Builder
  MenuCard(item: HomeItem) {
    Row() {
      Stack() {
        SymbolGlyph(item.icon)
          .fontSize(24)
          .fontColor([Color.White])
      }
      .width(48)
      .height(48)
      .borderRadius(12)
      .backgroundColor(item.color)

      Column() {
        Text(item.title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text(item.desc)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(18)
        .fontColor([$r('app.color.text_muted')])
    }
    .width('100%')
    .height(76)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => this.go(item.route))
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(17)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.text_primary'))
      .width('100%')
      .margin({ top: 8, bottom: 12 })
  }

  build() {
    Column() {
      this.Header()

      Scroll() {
        Column() {
          this.NearbyBanner()

          this.SectionTitle('我的服务')
          ForEach(this.homeItems, (item: HomeItem) => {
            this.MenuCard(item)
          }, (item: HomeItem) => item.route)
        }
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
