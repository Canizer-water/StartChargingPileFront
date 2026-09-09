import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';

/**
 * 定位服务：动态申请定位权限 → 取当前经纬度（地图就近检索用）。
 */

export interface LatLng {
  lat: number;
  lng: number;
}

export class GeoService {
  private static instance: GeoService = new GeoService();

  static getInstance(): GeoService {
    return GeoService.instance;
  }

  private async ensurePermission(ctx: common.UIAbilityContext): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const res = await atManager.requestPermissionsFromUser(ctx, [
        'ohos.permission.APPROXIMATELY_LOCATION',
        'ohos.permission.LOCATION'
      ]);
      return res.authResults.every((r: number) => r === 0);
    } catch (err) {
      console.error(`request location permission failed: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /** 取当前定位；未授权或失败返回 null（调用方走全量列表兜底）。 */
  async currentPosition(ctx: common.UIAbilityContext): Promise<LatLng | null> {
    const granted = await this.ensurePermission(ctx);
    if (!granted) {
      return null;
    }
    const request: geoLocationManager.CurrentLocationRequest = {
      'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
      'scenario': geoLocationManager.LocationRequestScenario.UNSET,
      'maxAccuracy': 0
    };
    return new Promise<LatLng | null>((resolve) => {
      try {
        geoLocationManager.getCurrentLocation(request, (err: BusinessError, loc) => {
          if (err || !loc) {
            resolve(null);
            return;
          }
          resolve({ lat: loc.latitude, lng: loc.longitude });
        });
      } catch (err) {
        resolve(null);
      }
    });
  }
}
