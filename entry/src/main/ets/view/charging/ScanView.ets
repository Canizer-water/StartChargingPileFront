import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ChargingPile, NavParam } from '../../model/Types';
import { StationService } from '../../service/StationService';

/**
 * 扫一扫（Story 9）：取景框 + 模拟识别。
 * 识别结果从 StationService 解析真实空闲桩（替代原硬编码 P-005），
 * 成功后按文档路由跳「充电桩详情」，由详情页确认后启动充电。
 * 相机页保持深底风格，与其他页面区分是刻意设计。
 */
@Component
export struct ScanView {
  pathStack: NavPathStack = new NavPathStack();
  /** tab 模式（主框架内嵌）时隐藏返回键 */
  embedded: boolean = false;

  @State scanOffset: number = 208;
  @State scanDone: boolean = false;
  @State pickedImage: string = '';
  @State foundPile: ChargingPile | null = null;
  private readonly viewSize: number = 260;

  aboutToAppear(): void {
    this.scanOffset = 0;
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  /** 模拟识别：解析一个真实空闲桩 */
  private recognize(): boolean {
    const pile = StationService.getInstance().pickIdlePile();
    if (!pile) {
      this.showToast('暂无空闲充电桩，请稍后再试');
      return false;
    }
    this.foundPile = pile;
    this.scanDone = true;
    this.showToast(`识别成功：${pile.code} ${pile.interfaceType}`);
    return true;
  }

  private startScan(): void {
    if (this.scanDone) {
      return;
    }
    this.recognize();
  }

  private manualInput(): void {
    this.showToast('演示模式：自动识别桩编号');
    this.recognize();
  }

  private pickFromAlbum(): void {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;
      const picker = new photoAccessHelper.PhotoViewPicker();
      picker.select(options).then((result: photoAccessHelper.PhotoSelectResult) => {
        if (result.photoUris.length > 0) {
          this.pickedImage = result.photoUris[0];
          this.recognize();
        }
      }).catch((err: BusinessError) => {
        console.error(`pick image failed: code=${err.code} msg=${err.message}`);
        this.showToast(`相册选择失败(${err.code})`);
      });
    } catch (err) {
      console.error(`pick image sync error: ${JSON.stringify(err)}`);
      this.showToast('相册选择失败');
    }
  }

  /** 识别成功 → 充电桩详情（文档路由：扫码后进入桩详情，再确认启动） */
  private goPileDetail(): void {
    const pile = this.foundPile;
    if (!pile) {
      this.showToast('未识别到充电桩');
      return;
    }
    const param: NavParam = { id: pile.id };
    this.pathStack.pushPathByName('PileDetail', param);
  }

  @Builder
  TitleBar() {
    Row() {
      if (this.embedded) {
        Row().width(24).height(24)
      } else {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .fontColor([$r('app.color.scan_hint')])
          .onClick(() => {
            this.pathStack.pop();
          })
      }
      Blank()
      Text('扫一扫')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.scan_hint'))
      Blank()
      Row()
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  CornerBrackets() {
    Column()
      .width(38)
      .height(38)
      .border({
        width: { top: 4, left: 4 },
        color: $r('app.color.scan_corner'),
        radius: 4,
        style: BorderStyle.Solid
      })
      .position({ x: 0, y: 0 })
    Column()
      .width(38)
      .height(38)
      .border({
        width: { top: 4, right: 4 },
        color: $r('app.color.scan_corner'),
        radius: 4,
        style: BorderStyle.Solid
      })
      .position({ x: this.viewSize - 38, y: 0 })
    Column()
      .width(38)
      .height(38)
      .border({
        width: { bottom: 4, left: 4 },
        color: $r('app.color.scan_corner'),
        radius: 4,
        style: BorderStyle.Solid
      })
      .position({ x: 0, y: this.viewSize - 38 })
    Column()
      .width(38)
      .height(38)
      .border({
        width: { bottom: 4, right: 4 },
        color: $r('app.color.scan_corner'),
        radius: 4,
        style: BorderStyle.Solid
      })
      .position({ x: this.viewSize - 38, y: this.viewSize - 38 })
  }

  @Builder
  Viewfinder() {
    Column({ space: 20 }) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .borderRadius(12)
          .backgroundColor(0x14FFFFFF)
        this.CornerBrackets()
        Column({ space: 10 }) {
          SymbolGlyph($r('sys.symbol.qrcode'))
            .fontSize(46)
            .fontColor([$r('app.color.scan_hint')])
          Text('对准二维码')
            .fontSize(14)
            .fontColor($r('app.color.scan_hint'))
        }
        Row()
          .width(200)
          .height(3)
          .borderRadius(1.5)
          .linearGradient({
            angle: 90,
            colors: [[0x005B8CE7, 0.0], [$r('app.color.scan_corner'), 0.5], [0x005B8CE7, 1.0]]
          })
          .position({ x: 30, y: 16 })
          .translate({ y: this.scanOffset })
          .animation({
            duration: 1800,
            curve: Curve.EaseInOut,
            iterations: -1,
            playMode: PlayMode.Alternate
          })
      }
      .width(this.viewSize)
      .height(this.viewSize)
      .onClick(() => {
        this.startScan();
      })

      Text('将二维码放入框内，即可自动扫描')
        .fontSize(14)
        .fontColor($r('app.color.scan_hint'))
        .opacity(0.9)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
  }

  @Builder
  ResultCard() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        Stack() {
          Column()
            .width(44)
            .height(44)
            .borderRadius(22)
            .backgroundColor($r('app.color.charge_tint_bg'))
          if (this.pickedImage !== '') {
            Image(this.pickedImage)
              .width(44)
              .height(44)
              .borderRadius(22)
              .objectFit(ImageFit.Cover)
          } else {
            SymbolGlyph($r('sys.symbol.bolt_fill'))
              .fontSize(26)
              .fontColor([$r('app.color.btn_primary')])
          }
        }
        Column({ space: 4 }) {
          Text(this.foundPile ? `${this.foundPile.code} · ${this.foundPile.interfaceType}` : '识别失败')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.charge_title'))
          Text(this.foundPile ?
            `额定 ${this.foundPile.powerKw}kW · ¥${this.foundPile.pricePerKwh.toFixed(2)}/度 · 空闲中` :
            '未找到空闲充电桩，请重试')
            .fontSize(13)
            .fontColor($r('app.color.charge_secondary'))
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Row({ space: 16 }) {
        Text('重新扫码')
          .fontSize(15)
          .fontColor($r('app.color.charge_secondary'))
          .onClick(() => {
            this.scanDone = false;
            this.pickedImage = '';
            this.foundPile = null;
          })
        Blank()
        Button('查看桩详情')
          .width(124)
          .height(44)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.btn_primary'))
          .borderRadius(22)
          .onClick(() => {
            this.goPileDetail();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .backgroundColor($r('app.color.scan_result_bg'))
    .borderRadius(12)
  }

  @Builder
  BottomBar() {
    Column() {
      if (this.scanDone) {
        this.ResultCard()
      }

      Row({ space: 12 }) {
        Button('输入桩编号')
          .fontSize(15)
          .fontColor($r('app.color.scan_hint'))
          .backgroundColor(0x26FFFFFF)
          .borderRadius(24)
          .height(48)
          .padding({ left: 30, right: 30 })
          .onClick(() => {
            this.manualInput();
          })
        Button('使用相册')
          .fontSize(15)
          .fontColor($r('app.color.scan_hint'))
          .backgroundColor(0x26FFFFFF)
          .borderRadius(24)
          .height(48)
          .padding({ left: 30, right: 30 })
          .onClick(() => {
            this.pickFromAlbum();
          })
      }
      .margin({ top: 16 })

      Text('演示模式：点击取景框即可模拟扫码')
        .fontSize(12)
        .fontColor($r('app.color.scan_hint'))
        .opacity(0.6)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 12, bottom: 28 })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.scan_bar_bg'))
        .opacity(0.72)

      Column() {
        this.TitleBar()

        Column() {
          Blank()
          this.Viewfinder()
          Blank()
          this.BottomBar()
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.scan_bar_bg'))
  }
}
