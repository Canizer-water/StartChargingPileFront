import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';

/**
 * 定位服务：动态申请定位权限 → 取当前定位。
 * 返回 LocationKit 原始 Location（Map Kit 的 setMyLocation 需要整包，不能只给经纬度）。
 */

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
      return res.authResults.some((r: number) => r === 0);
    } catch (err) {
      const e = err as BusinessError;
      console.error(`request location permission failed code=${e.code} msg=${e.message}`);
      return false;
    }
  }

  /** 取当前定位；未授权或定位失败返回 null（调用方走全量列表兜底）。 */
  async currentLocation(ctx: common.UIAbilityContext): Promise<geoLocationManager.Location | null> {
    const granted = await this.ensurePermission(ctx);
    if (!granted) {
      console.warn('location permission denied');
      return null;
    }
    const request: geoLocationManager.CurrentLocationRequest = {
      'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
      'scenario': geoLocationManager.LocationRequestScenario.UNSET,
      'maxAccuracy': 0,
      'timeoutMs': 10000
    };
    try {
      return await geoLocationManager.getCurrentLocation(request);
    } catch (err) {
      const e = err as BusinessError;
      // 3301100 定位服务未开启 / 3301200 获取位置信息超时
      console.error(`getCurrentLocation failed code=${e.code} msg=${e.message}`);
      return null;
    }
  }
}
