import { Vehicle } from '../model/Types';
import { ApiError, Http, HttpResult } from './Http';
import { AuthService } from './AuthService';

/**
 * 车辆服务（契约 §5.7）：查询 / 录入当前登录用户的默认车辆。
 * 后端无记录时懒建并返回默认值，故正常登录下总有响应、不会 404。
 *
 * 车牌归一化（去空白与 `·`、字母转大写）和格式校验均由服务端裁决：422 时 detail 为
 * 「车牌号格式不正确」，端侧只透传展示，不重复实现一套校验口径（防两端漂移）。
 */

/** PUT /vehicle/current 请求体（契约 §5.7 VehicleUpdate） */
interface VehicleUpdateRequest {
  plateNo: string;
}

export class VehicleService {
  private static instance: VehicleService = new VehicleService();

  static getInstance(): VehicleService {
    return VehicleService.instance;
  }

  private async token(): Promise<string> {
    return AuthService.getInstance().getToken();
  }

  /** 当前用户车辆 ~ GET /vehicle/current；未登录/网络异常抛出，由页面兜底 */
  async getCurrent(): Promise<Vehicle> {
    try {
      const res: HttpResult = await Http.get('/vehicle/current', await this.token());
      return Http.parse<Vehicle>(res);
    } catch (err) {
      throw err instanceof ApiError ? err : new ApiError('车辆信息获取失败');
    }
  }

  /** 写入车牌 ~ PUT /vehicle/current；plateNo 传空串表示清除。返回后端归一化后的车辆 */
  async updatePlate(plateNo: string): Promise<Vehicle> {
    const body: VehicleUpdateRequest = { plateNo: plateNo };
    try {
      const res: HttpResult = await Http.put('/vehicle/current', JSON.stringify(body), await this.token());
      return Http.parse<Vehicle>(res);
    } catch (err) {
      throw err instanceof ApiError ? err : new ApiError('车牌保存失败');
    }
  }
}
