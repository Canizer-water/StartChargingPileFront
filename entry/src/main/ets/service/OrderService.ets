import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { ChargingOrder, ChargingPile, RealTimeChargingData } from '../model/Types';
import { StationService } from './StationService';

/**
 * 订单服务：本地 preferences 持久化，接口形状与未来后端对齐——
 *   listOrders()                    ~ GET  /orders
 *   getOrderById(id)                ~ GET  /orders/{id}
 *   startOrder(req)                 ~ POST /charging/start
 *   finishOrder(id, data)           ~ POST /charging/{id}/stop
 * 启动/结束会同步翻转 MockData 中桩的 status（IDLE<->CHARGING），
 * 保证扫码/列表看到的可充状态与订单一致。
 * preferences API 可能抛异常，统一经 safe* 包裹转为 Promise 拒绝，由调用方 .catch 消费。
 */

const STORE_NAME = 'order_store';
const KEY_ORDERS = 'orders';

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

function round2(n: number): number {
  return Math.round(n * 100) / 100;
}

function pad2(n: number): string {
  return n < 10 ? `0${n}` : `${n}`;
}

/** 本地时间格式：2026-09-04 12:30:00 */
function formatTime(d: Date): string {
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())} ` +
    `${pad2(d.getHours())}:${pad2(d.getMinutes())}:${pad2(d.getSeconds())}`;
}

/** 首装种子订单（与 MockData 站点/桩自洽的已完成历史单） */
function seedOrders(): ChargingOrder[] {
  return [
    {
      id: 'CO202608291015301234', stationId: 's1', stationName: '诺得充电中心', pileCode: 'p000000002',
      startTime: '2026-08-29 10:15:30', endTime: '2026-08-29 11:02:30',
      energyKwh: 11.62, unitPrice: 1.35, durationMin: 47, amount: 15.69, status: 'FINISHED'
    },
    {
      id: 'CO202608311845004321', stationId: 's2', stationName: '智慧e充·天辰店', pileCode: 'p100000002',
      startTime: '2026-08-31 18:45:00', endTime: '2026-08-31 19:41:00',
      energyKwh: 18.20, unitPrice: 1.20, durationMin: 56, amount: 21.84, status: 'FINISHED'
    },
    {
      id: 'CO202609020830159876', stationId: 's3', stationName: '星充能源大厦站', pileCode: 'p300000002',
      startTime: '2026-09-02 08:30:15', endTime: '2026-09-02 09:45:15',
      energyKwh: 41.00, unitPrice: 1.05, durationMin: 75, amount: 43.05, status: 'FINISHED'
    }
  ];
}

export class OrderService {
  private static instance: OrderService = new OrderService();
  private store: preferences.Preferences | null = null;

  static getInstance(): OrderService {
    return OrderService.instance;
  }

  /** Ability 启动时初始化（页面兜底自初始化，首次写入种子订单） */
  async init(ctx: common.Context): Promise<void> {
    if (this.store === null) {
      try {
        this.store = await preferences.getPreferences(ctx, STORE_NAME);
        const raw = await this.store.get(KEY_ORDERS, '') as string;
        if (raw === '') {
          await this.store.put(KEY_ORDERS, JSON.stringify(seedOrders()));
          await this.store.flush();
        }
      } catch (err) {
        throw new Error('初始化订单存储失败');
      }
    }
  }

  private async requireStore(): Promise<preferences.Preferences> {
    if (this.store === null) {
      throw new Error('OrderService not initialized');
    }
    return this.store;
  }

  private async safeGet(key: string, def: string): Promise<string> {
    const store = await this.requireStore();
    try {
      return await store.get(key, def) as string;
    } catch (err) {
      throw new Error(`读取订单存储失败(${key})`);
    }
  }

  private async safePut(key: string, value: string): Promise<void> {
    const store = await this.requireStore();
    try {
      await store.put(key, value);
      await store.flush();
    } catch (err) {
      throw new Error(`写入订单存储失败(${key})`);
    }
  }

  private async loadOrders(): Promise<ChargingOrder[]> {
    const raw = await this.safeGet(KEY_ORDERS, '');
    if (raw === '') {
      return [];
    }
    try {
      return JSON.parse(raw) as ChargingOrder[];
    } catch (err) {
      return [];
    }
  }

  /** 订单列表（新单在前）~ GET /orders */
  async listOrders(): Promise<ChargingOrder[]> {
    const orders = await this.loadOrders();
    return orders.sort((a, b) => a.startTime < b.startTime ? 1 : -1);
  }

  /** 按订单号查询 ~ GET /orders/{id} */
  async getOrderById(id: string): Promise<ChargingOrder | undefined> {
    const orders = await this.loadOrders();
    return orders.find((o) => o.id === id);
  }

  /** 启动充电：生成 CHARGING 订单并占用桩 ~ POST /charging/start */
  async startOrder(req: StartOrderRequest): Promise<OrderResult> {
    const svc = StationService.getInstance();
    const pile: ChargingPile | undefined = svc.getPileById(req.pileId);
    if (!pile) {
      return { success: false, message: '充电桩不存在' };
    }
    if (pile.status !== 'IDLE') {
      return { success: false, message: '该充电桩当前不可用' };
    }
    const orders = await this.loadOrders();
    if (orders.some((o) => o.status === 'CHARGING')) {
      return { success: false, message: '已有进行中的充电订单，请先结束' };
    }
    const now = new Date();
    const station = svc.getStationById(pile.stationId);
    const order: ChargingOrder = {
      id: `CO${formatTime(now).replace(/[-: ]/g, '')}${Math.floor(1000 + Math.random() * 9000)}`,
      stationId: pile.stationId,
      stationName: station ? station.name : '',
      pileCode: pile.code,
      startTime: formatTime(now),
      endTime: '',
      energyKwh: 0,
      unitPrice: pile.pricePerKwh,
      durationMin: 0,
      amount: 0,
      status: 'CHARGING'
    };
    orders.push(order);
    await this.safePut(KEY_ORDERS, JSON.stringify(orders));
    pile.status = 'CHARGING';
    this.bumpOrdersVersion();
    return { success: true, message: '充电已启动', order: order };
  }

  /** 结束充电：按实时数据结算订单并释放桩 ~ POST /charging/{id}/stop */
  async finishOrder(orderId: string, data: RealTimeChargingData): Promise<OrderResult> {
    const orders = await this.loadOrders();
    const order = orders.find((o) => o.id === orderId);
    if (!order) {
      return { success: false, message: '订单不存在' };
    }
    if (order.status === 'FINISHED') {
      return { success: true, message: '订单已完成', order: order };
    }
    const now = new Date();
    const energy = round2(data.energyKwh);
    order.endTime = formatTime(now);
    order.durationMin = Math.max(1, Math.round(data.durationSec / 60));
    order.energyKwh = energy;
    order.amount = round2(energy * order.unitPrice);
    order.status = 'FINISHED';
    await this.safePut(KEY_ORDERS, JSON.stringify(orders));
    const pile = StationService.getInstance().getPileByCode(order.pileCode);
    if (pile) {
      pile.status = 'IDLE';
    }
    this.bumpOrdersVersion();
    return { success: true, message: '充电已结束', order: order };
  }

  /** 订单数据版本号：任何写操作 +1，列表页 @Watch 后自动刷新 */
  private bumpOrdersVersion(): void {
    AppStorage.setOrCreate<number>('ordersVersion', (AppStorage.get<number>('ordersVersion') ?? 0) + 1);
  }
}
