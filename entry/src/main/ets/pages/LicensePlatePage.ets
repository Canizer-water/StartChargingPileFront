import { router } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { recognizeLicensePlate } from '../service/AiService';

@Entry
@Component
struct LicensePlatePage {
  @State pickedImage: string = '';
  @State result: string = '';
  @State recognizing: boolean = false;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private pickImage(): void {
    const options = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 1;
    const picker = new photoAccessHelper.PhotoViewPicker();
    picker.select(options).then((res: photoAccessHelper.PhotoSelectResult) => {
      if (res.photoUris.length > 0) {
        this.pickedImage = res.photoUris[0];
        this.result = '';
      }
    }).catch((err: BusinessError) => {
      console.error(`pick image failed: code=${err.code} msg=${err.message}`);
      this.showToast(`选择图片失败(${err.code})`);
    });
  }

  private async recognize(): Promise<void> {
    if (this.pickedImage === '') {
      this.showToast('请先选择一张车牌照片');
      return;
    }
    this.recognizing = true;
    this.result = '';
    try {
      const plate = await recognizeLicensePlate(this.pickedImage);
      this.result = plate;
    } catch (err) {
      console.error(`recognize failed: ${JSON.stringify(err)}`);
      const msg = (err as Error)?.message || '识别失败，请重试';
      this.showToast(msg);
    } finally {
      this.recognizing = false;
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
      Text('AI 车牌识别')
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
  ImagePreview() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height(260)
        .borderRadius(16)
        .backgroundColor($r('app.color.chip_bg'))
      if (this.pickedImage === '') {
        Column({ space: 12 }) {
          SymbolGlyph($r('sys.symbol.car'))
            .fontSize(52)
            .fontColor([$r('app.color.charge_secondary')])
          Text('点击下方按钮选择车牌照片')
            .fontSize(14)
            .fontColor($r('app.color.charge_secondary'))
        }
      } else {
        Image(this.pickedImage)
          .width('100%')
          .height(260)
          .borderRadius(16)
          .objectFit(ImageFit.Contain)
      }
    }
    .width('100%')
    .height(260)
  }

  @Builder
  ResultCard() {
    Column({ space: 10 }) {
      Text('识别结果')
        .fontSize(13)
        .fontColor($r('app.color.charge_secondary'))
      if (this.recognizing) {
        LoadingProgress()
          .width(36)
          .height(36)
          .color($r('app.color.login_primary'))
        Text('识别中…')
          .fontSize(14)
          .fontColor($r('app.color.charge_secondary'))
      } else if (this.result !== '') {
        Text(this.result)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.login_primary'))
        Text('请核对车牌号是否准确')
          .fontSize(12)
          .fontColor($r('app.color.charge_secondary'))
      } else {
        Text('尚未识别')
          .fontSize(15)
          .fontColor($r('app.color.charge_secondary'))
      }
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(16)
    .border({ width: 1, color: $r('app.color.divider') })
  }

  build() {
    Column() {
      this.TitleBar()

      Scroll() {
        Column({ space: 20 }) {
          this.ImagePreview()
          this.ResultCard()

          Row({ space: 14 }) {
            Button('选择照片')
              .layoutWeight(1)
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.login_primary'))
              .backgroundColor(Color.White)
              .border({ width: 1, color: $r('app.color.login_primary'), radius: 8 })
              .onClick(() => {
                this.pickImage();
              })
            Button('开始识别')
              .layoutWeight(1)
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.login_primary'))
              .borderRadius(8)
              .onClick(() => {
                this.recognize();
              })
          }
          .width('100%')
          .margin({ top: 4, bottom: 24 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 8 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
