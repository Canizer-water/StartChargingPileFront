import { ChargingOrder, RealTimeChargingData } from '../model/Types';
import { ApiError, Http, HttpResult } from './Http';
import { AuthService } from './AuthService';

/**
 * 订单服务（联调版，契约 §5.3/§5.4，orders 列表已按 v0.3 Envelope 分页）：全部端点走后端。
 *   listOrders()          ~ GET  /orders?page=1&size=50 → 解 Envelope<OrderPage>.data.items
 *   getOrderById(id)      ~ GET  /orders/{id}
 *   startOrder(req)       ~ POST /charging/start
 *   finishOrder(id)       ~ POST /charging/{id}/stop
 *   currentRealtime()     ~ GET  /charging/current（一期服务端模拟，二期换推送）
 * 方法签名与本地模拟时代一致；本地 preferences 订单存储已退役（数据以库为准）。
 * 注意：结算金额/时长由服务端裁决，finishOrder 的 data 参数仅为兼容旧签名保留。
 */

/** POST /charging/start 请求体 */
export interface StartOrderRequest {
  pileId: string;
}

/** 订单写操作统一响应体 */
export interface OrderResult {
  success: boolean;
  message: string;
  order?: ChargingOrder;
}

/** 后端 v0.3 Envelope 分页负载（契约 §5.6/§5.4，字段 camelCase） */
interface OrderPagePayload {
  items: ChargingOrder[];
  page: number;
  size: number;
  total: number;
}

/** 后端 v0.3 统一响应 Envelope<T>（success/errorCode/message/data） */
interface OrderEnvelope {
  success: boolean;
  errorCode: number;
  message: string;
  data: OrderPagePayload;
}

export class OrderService {
  private static instance: OrderService = new OrderService();

  static getInstance(): OrderService {
    return OrderService.instance;
  }

  private async token(): Promise<string> {
    return AuthService.getInstance().getToken();
  }

  /** 订单列表（新单在前）~ GET /orders?page=1&size=50；取近 50 条供当前单页列表 + 本地状态筛选 */
  async listOrders(): Promise<ChargingOrder[]> {
    const res: HttpResult = await Http.get('/orders?page=1&size=50', await this.token());
    const env = Http.parse<OrderEnvelope>(res);
    return env.data?.items ?? [];
  }

  /** 按订单号查询 ~ GET /orders/{id}；404 返回 undefined */
  async getOrderById(id: string): Promise<ChargingOrder | undefined> {
    try {
      const res: HttpResult = await Http.get(`/orders/${id}`, await this.token());
      return Http.parse<ChargingOrder>(res);
    } catch (err) {
      if (err instanceof ApiError && err.status === 404) {
        return undefined;
      }
      throw err instanceof ApiError ? err : new ApiError('订单查询失败');
    }
  }

  /** 当前用户进行中会话的实时数据 ~ GET /charging/current；404（无会话）返回 undefined */
  async currentRealtime(): Promise<RealTimeChargingData | undefined> {
    try {
      const res: HttpResult = await Http.get('/charging/current', await this.token());
      return Http.parse<RealTimeChargingData>(res);
    } catch (err) {
      if (err instanceof ApiError && err.status === 404) {
        return undefined;
      }
      throw err instanceof ApiError ? err : new ApiError('实时数据获取失败');
    }
  }

  /** 启动充电 ~ POST /charging/start（桩可用性/单会话不变式由服务端裁决） */
  async startOrder(req: StartOrderRequest): Promise<OrderResult> {
    try {
      const res: HttpResult = await Http.post('/charging/start', JSON.stringify(req), await this.token());
      const order = Http.parse<ChargingOrder>(res);
      this.bumpOrdersVersion();
      return { success: true, message: '充电已启动', order: order };
    } catch (err) {
      return { success: false, message: err instanceof ApiError ? err.message : '启动充电失败，请稍后重试' };
    }
  }

  /** 结束充电 ~ POST /charging/{id}/stop（服务端结算并释放桩） */
  async finishOrder(orderId: string, data: RealTimeChargingData | undefined): Promise<OrderResult> {
    try {
      const res: HttpResult = await Http.post(`/charging/${orderId}/stop`, '', await this.token());
      const order = Http.parse<ChargingOrder>(res);
      this.bumpOrdersVersion();
      return { success: true, message: '充电已结束', order: order };
    } catch (err) {
      return { success: false, message: err instanceof ApiError ? err.message : '结束充电失败，请稍后重试' };
    }
  }

  /** 订单数据版本号：任何写操作 +1，列表页 @Watch 后自动刷新 */
  private bumpOrdersVersion(): void {
    AppStorage.setOrCreate<number>('ordersVersion', (AppStorage.get<number>('ordersVersion') ?? 0) + 1);
  }
}
