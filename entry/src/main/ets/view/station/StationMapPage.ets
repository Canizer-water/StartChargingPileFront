import { MapComponent, map, mapCommon } from '@kit.MapKit';
import { AsyncCallback, BusinessError, Callback } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { ChargingStation, NavParam } from '../../model/Types';
import { AppTopBar } from '../../component/AppTopBar';
import { GeoService } from '../../service/GeoService';
import { StationService } from '../../service/StationService';

/**
 * 真实地图（华为 Map Kit，@kit.MapKit）。
 * 前置：AGC 开通地图服务 + 调试证书/公钥指纹/Profile 顺序正确 + module.json5 已填 client_id
 * + build-profile.json5 声明 Map Kit capability；DevEco 模拟器与真机均可渲染（需联网取瓦片）。
 *
 * 定位要点：Map Kit 不自行取位——蓝点须由 App 调 setMyLocationEnabled(true) 开图层、
 * 再用 setMyLocation(Location) 把 LocationKit 的结果喂进去；定位按钮也只抛
 * myLocationButtonClick 事件，移动镜头得 App 自己处理。
 */

/** 定位成功后的缩放级别（覆盖 50km 附近检索结果）。 */
const NEARBY_ZOOM: number = 13;
/** 附近检索半径，单位 km，与后端 /stations?radius 口径一致。 */
const NEARBY_RADIUS_KM: number = 50;

@Component
export struct StationMapPage {
  pathStack: NavPathStack = new NavPathStack();
  @State stations: ChargingStation[] = [];
  @State statusText: string = '正在定位…';
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  /** 定位结果缓存：定位与地图就绪无固定先后，谁后到谁负责落到地图上。 */
  private location?: geoLocationManager.Location;
  /** 首次同时具备「地图就绪 + 有定位」时自动居中一次。 */
  private centered: boolean = false;

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
      this.enableMyLocationLayer(controller);
      // 定位可能已先于地图就绪返回，此处补画并首次居中
      this.syncMarkers();
    };
    this.locate(false);
  }

  aboutToDisappear(): void {
    const ctrl = this.mapController;
    if (ctrl) {
      ctrl.off('myLocationButtonClick', this.onLocateButtonClick);
    }
  }

  onPageShow(): void {
    this.mapController?.show();
  }

  onPageHide(): void {
    this.mapController?.hide();
  }

  /** 打开「我的位置」图层并接管右下角定位按钮。 */
  private enableMyLocationLayer(ctrl: map.MapComponentController): void {
    ctrl.setMyLocationEnabled(true);
    ctrl.setMyLocationControlsEnabled(true);
    ctrl.on('myLocationButtonClick', this.onLocateButtonClick);
  }

  private onLocateButtonClick: Callback<void> = (): void => {
    this.locate(true);
  };

  /** 定位一次并刷新站点列表；recenter 为真时把镜头移到当前位置。 */
  private locate(recenter: boolean): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.statusText = '正在定位…';
    GeoService.getInstance().currentLocation(ctx).then((loc) => {
      if (!loc) {
        this.location = undefined;
        this.statusText = '未取得定位，展示全量站点';
        this.stations = StationService.getInstance().getStations();
        this.syncMarkers();
        return;
      }
      this.location = loc;
      this.statusText = '正在加载附近充电站…';
      StationService.getInstance().nearby(loc.latitude, loc.longitude, NEARBY_RADIUS_KM).then((list) => {
        this.stations = list;
        this.statusText = list.length > 0 ? `附近 ${list.length} 个充电站` : '附近暂无充电站';
        this.syncMarkers(recenter);
      }).catch(() => {
        this.statusText = '附近检索失败，展示全量站点';
        this.stations = StationService.getInstance().getStations();
        this.syncMarkers(recenter);
      });
    });
  }

  /** 站点打点：先清后画，避免定位回调与地图就绪回调重复叠加 marker。 */
  private syncMarkers(recenter: boolean = false): void {
    const ctrl = this.mapController;
    if (!ctrl) {
      return;
    }
    ctrl.clear();
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
    this.applyMyLocation(recenter);
  }

  /** 把定位结果喂给地图图层；地图未就绪时静默跳过，就绪回调会再调一次。 */
  private applyMyLocation(recenter: boolean): void {
    const ctrl = this.mapController;
    const loc = this.location;
    if (!ctrl || !loc) {
      return;
    }
    const target: mapCommon.LatLng = { latitude: loc.latitude, longitude: loc.longitude };
    const shouldCenter = recenter || !this.centered;
    try {
      ctrl.setMyLocation(loc);
      if (shouldCenter) {
        this.centered = true;
        ctrl.animateCamera(map.newLatLng(target, NEARBY_ZOOM));
      }
    } catch (e) {
      console.error(`setMyLocation failed: ${JSON.stringify(e)}`);
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
              .onClick(() => {
                this.goDetail(s.id);
              })
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
