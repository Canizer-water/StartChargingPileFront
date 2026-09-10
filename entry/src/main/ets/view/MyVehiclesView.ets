import { AppTopBar } from '../component/AppTopBar';
import { VehicleService } from '../service/VehicleService';
import { Vehicle } from '../model/Types';

/**
 * 我的爱车：当前用户的默认车辆，数据来自后端 GET/PUT /vehicle/current（契约 §5.7）。
 * 后端为「一行一用户」，故本页是单卡而非车列表；可录入字段仅车牌一项，
 * 电量/续航由后端给默认值，端侧不可改。
 * 车牌可手输，也可走 AI 识别（LicensePlatePage，target='vehicle'）回填；
 * 归一化与格式校验在服务端，422 的 detail 文案直接透传给用户。
 */

/** 识别页路由入参 */
interface PlateRouteParams {
  target: string;
}

@Component
export struct MyVehiclesView {
  pathStack: NavPathStack = new NavPathStack();

  @State vehicle: Vehicle | null = null;
  @State loading: boolean = true;
  @State errorText: string = '';
  /** 车牌输入框草稿 */
  @State plateDraft: string = '';
  @State saving: boolean = false;
  /** AI 识别页回传的车牌号（一次性，读完即清空） */
  @StorageProp('vehiclePlatePick') @Watch('onPlatePick') vehiclePlatePick: string = '';

  aboutToAppear(): void {
    this.load();
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1800 });
    } catch (err) {
      console.error(`showToast failed: ${JSON.stringify(err)}`);
    }
  }

  private onPlatePick(): void {
    if (this.vehiclePlatePick === '') {
      return;
    }
    this.plateDraft = this.vehiclePlatePick;
    AppStorage.setOrCreate('vehiclePlatePick', '');
    this.showToast('识别结果已填入，请核对后保存');
  }

  private load(): void {
    this.loading = true;
    VehicleService.getInstance().getCurrent().then((v: Vehicle) => {
      this.applyVehicle(v);
      this.errorText = '';
      this.loading = false;
    }).catch((err: Error) => {
      this.errorText = err.message === '' ? '车辆信息获取失败' : err.message;
      this.loading = false;
    });
  }

  private applyVehicle(v: Vehicle): void {
    this.vehicle = v;
    // 仅在无未保存草稿时用服务端值回填，避免覆盖用户正在输入的内容
    if (this.plateDraft === '') {
      this.plateDraft = v.plateNo;
    }
  }

  private openRecognizer(): void {
    const params: PlateRouteParams = { target: 'vehicle' };
    try {
      this.getUIContext().getRouter().pushUrl({ url: 'pages/LicensePlatePage', params: params });
    } catch (err) {
      console.error(`open LicensePlatePage failed: ${JSON.stringify(err)}`);
      this.showToast('打开车牌识别失败');
    }
  }

  /** 保存车牌（空串=清除）；成功后以服务端归一化值刷新输入框 */
  private save(): void {
    if (this.saving) {
      return;
    }
    this.saving = true;
    const draft: string = this.plateDraft;
    VehicleService.getInstance().updatePlate(draft).then((v: Vehicle) => {
      this.vehicle = v;
      this.plateDraft = v.plateNo;
      this.showToast(v.plateNo === '' ? '车牌已清除' : `已保存 ${v.plateNo}`);
    }).catch((err: Error) => {
      // 校验失败时保留草稿，让用户能直接改
      this.showToast(err.message === '' ? '保存失败，请重试' : err.message);
    }).finally(() => {
      this.saving = false;
    });
  }

  /** 与后端 §5.7 口径一致的轻量提示（不做拦截，最终以服务端判定为准） */
  private draftLooksInvalid(): boolean {
    return this.plateDraft.replace(/\s/g, '') !== '' && this.plateDraft.replace(/\s/g, '').length < 5;
  }

  @Builder
  StatCell(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  VehicleCard(v: Vehicle) {
    Column() {
      Row() {
        Stack() {
          SymbolGlyph($r('sys.symbol.car'))
            .fontSize(26)
            .fontColor([$r('app.color.btn_primary')])
        }
        .width(52)
        .height(52)
        .borderRadius(26)
        .backgroundColor($r('app.color.tint_blue'))

        Column() {
          Text(v.plateNo === '' ? '未录入车牌' : v.plateNo)
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor(v.plateNo === '' ? $r('app.color.text_secondary') : $r('app.color.text_primary'))
          Text('当前账号默认车辆')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 14 })
      }
      .width('100%')

      Divider()
        .color($r('app.color.divider'))
        .strokeWidth(1)
        .margin({ top: 16, bottom: 16 })

      Row() {
        this.StatCell('电量', `${v.battery}%`)
        this.StatCell('续航', `${v.rangeKm} km`)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
  }

  @Builder
  EditSection() {
    Column() {
      Text('录入车牌号')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      TextInput({ placeholder: '如 陕A12345', text: this.plateDraft })
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .placeholderColor($r('app.color.text_muted'))
        .backgroundColor($r('app.color.chip_bg'))
        .borderRadius(10)
        .height(50)
        .width('100%')
        .maxLength(16)
        .onChange((value: string) => {
          this.plateDraft = value;
        })

      if (this.draftLooksInvalid()) {
        Text('车牌号偏短，正常为 7–8 位')
          .fontSize(12)
          .fontColor($r('app.color.red'))
          .width('100%')
          .margin({ top: 6 })
      }

      Row({ space: 12 }) {
        Button('拍照识别')
          .layoutWeight(1)
          .height(46)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.btn_primary'))
          .backgroundColor($r('app.color.app_card'))
          .border({ width: 1, color: $r('app.color.btn_primary'), radius: 10 })
          .onClick(() => {
            this.openRecognizer();
          })

        Button(this.saving ? '保存中…' : '保存')
          .layoutWeight(1)
          .height(46)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.btn_primary'))
          .borderRadius(10)
          .enabled(!this.saving)
          .onClick(() => {
            this.save();
          })
      }
      .width('100%')
      .margin({ top: 14 })

      Text('保存后车牌仅用于展示与充电准备，空格与「·」等符号由服务端统一清洗；清空车牌再保存即可移除。')
        .fontSize(12)
        .fontColor($r('app.color.text_muted'))
        .width('100%')
        .lineHeight(18)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 14 })
  }

  @Builder
  ErrorCard() {
    Column() {
      Text(this.errorText === '' ? '暂无车辆信息' : this.errorText)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .textAlign(TextAlign.Center)
      Button('重试')
        .height(40)
        .fontSize(14)
        .fontColor($r('app.color.btn_primary'))
        .backgroundColor($r('app.color.app_card'))
        .border({ width: 1, color: $r('app.color.btn_primary'), radius: 8 })
        .margin({ top: 14 })
        .onClick(() => {
          this.load();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.app_card'))
    .borderRadius(12)
  }

  build() {
    Column() {
      AppTopBar({
        title: '我的爱车',
        pathStack: this.pathStack,
        trailingText: '刷新',
        onTrailing: () => {
          this.load();
        }
      })

      Scroll() {
        Column() {
          if (this.loading) {
            Text('正在加载车辆信息…')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .padding({ top: 40, bottom: 40 })
              .textAlign(TextAlign.Center)
          } else if (this.vehicle) {
            this.VehicleCard(this.vehicle)
            this.EditSection()
          } else {
            this.ErrorCard()
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
