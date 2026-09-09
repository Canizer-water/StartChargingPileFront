import { MapComponent, map, mapCommon } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { ChargingStation, NavParam } from '../../model/Types';
import { AppTopBar } from '../../component/AppTopBar';
import { GeoService } from '../../service/GeoService';
import { StationService } from '../../service/StationService';

/**
 * 真实地图（华为 Map Kit，@kit.MapKit）。
 * 前置：AGC 开通地图服务 + 调试证书/公钥指纹/Profile 顺序正确 + module.json5 已填 client_id；
 * 地图仅在真机渲染（模拟器/预览器不显示）。定位成功后走后端附近检索并把站点打点。
 */

@Component
export struct StationMapPage {
  pathStack: NavPathStack = new NavPathStack();
  @State stations: ChargingStation[] = [];
  @State statusText: string = '正在定位…';
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;

  aboutToAppear(): void {
    this.mapOptions = {
      position: {
        target: { latitude: 34.26, longitude: 108.952 }, // 默认西安市区；定位后以站点打点为主
        zoom: 11
      },
      mapType: mapCommon.MapType.STANDARD,
      myLocationControlsEnabled: true
    };
    this.callback = (err: BusinessError, controller: map.MapComponentController) => {
      if (err) {
        console.error(`map ready failed code=${err.code} msg=${err.message}`);
        this.statusText = '地图初始化失败：请检查 AGC/签名/client_id 配置';
        return;
      }
      this.mapController = controller;
      this.addStationMarkers();
    };
    this.initNearby();
  }

  onPageShow(): void {
    this.mapController?.show();
  }

  onPageHide(): void {
    this.mapController?.hide();
  }

  private initNearby(): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    GeoService.getInstance().currentPosition(ctx).then((pos) => {
      if (pos) {
        this.statusText = '正在加载附近充电站…';
        StationService.getInstance().nearby(pos.lat, pos.lng, 50).then((list) => {
          this.stations = list;
          this.statusText = list.length > 0 ? `附近 ${list.length} 个充电站` : '附近暂无充电站';
          this.addStationMarkers();
        }).catch(() => {
          this.statusText = '附近检索失败，展示全量站点';
          this.stations = StationService.getInstance().getStations();
          this.addStationMarkers();
        });
      } else {
        this.statusText = '未取得定位，展示全量站点';
        this.stations = StationService.getInstance().getStations();
        this.addStationMarkers();
      }
    });
  }

  private addStationMarkers(): void {
    const ctrl = this.mapController;
    if (!ctrl || this.stations.length === 0) {
      return;
    }
    for (const s of this.stations) {
      const markerOptions: mapCommon.MarkerOptions = {
        position: { latitude: s.latitude, longitude: s.longitude },
        title: s.name
      };
      try {
        ctrl.addMarker(markerOptions);
      } catch (e) {
        console.error(`addMarker failed ${s.id}: ${JSON.stringify(e)}`);
      }
    }
  }

  private goDetail(id: string): void {
    const param: NavParam = { id: id };
    this.pathStack.pushPathByName('StationDetail', param);
  }

  build() {
    Column() {
      AppTopBar({ title: '附近地图', pathStack: this.pathStack, showBack: true })

      Stack({ alignContent: Alignment.TopStart }) {
        MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
          .width('100%')
          .height('100%')

        Text(this.statusText)
          .fontSize(13)
          .fontColor($r('app.color.text_primary'))
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor($r('app.color.app_card'))
          .borderRadius(8)
          .margin({ left: 12, top: 10 })
      }
      .width('100%')
      .layoutWeight(1)

      if (this.stations.length > 0) {
        List() {
          ForEach(this.stations, (s: ChargingStation) => {
            ListItem() {
              Row() {
                Text(s.name)
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
                Text(`${s.distanceKm.toFixed(2)}Km`)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ left: 8 })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor($r('app.color.app_card'))
              .onClick(() => this.goDetail(s.id))
            }
          }, (s: ChargingStation) => s.id)
        }
        .width('100%')
        .height(180)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.app_bg'))
  }
}
