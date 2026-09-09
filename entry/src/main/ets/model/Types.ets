/**
 * 业务数据类型定义（对齐《开发设计文档》§5，即未来后端接口的响应形状）。
 * 纯展示字段（停车位号/楼层/收费方式/地图坐标/标签等）不属于领域模型，
 * 定义在 model/MockData.ets 的 *DisplayMeta 中。
 */

/** 导航路由参数（NavPathStack 传参统一用对象包装，避免 object→string 转换） */
export interface NavParam {
  id: string;
}

/** 用户账号 —— 对齐后端 GET /auth/me 的 UserOut；密码不再经端侧存储（联调后收紧，契约 §5.1） */
export interface UserAccount {
  id: string;
  username: string;      // 手机号
  avatar: string;        // 头像资源名
  createdAt: string;     // 注册时间 'YYYY-MM-DD HH:MM:SS'
}

/** 车辆信息 —— 对齐后端 GET /vehicle/current 的 VehicleOut（契约 §5.7） */
export interface Vehicle {
  plateNo: string;       // 车牌号（无记录默认 ''）
  battery: number;       // 电量 %（默认 75）
  rangeKm: number;       // 续航 km（默认 260）
}

/** 充电桩状态（后端 PileOut.status；FAULT 桩不可启动/预估，仅展示） */
export type PileStatus = 'IDLE' | 'CHARGING' | 'OFFLINE' | 'FAULT';

/** 充电桩 */
export interface ChargingPile {
  id: string;
  stationId: string;
  code: string;          // 桩编号，同时作为二维码内容
  latitude: number;      // 纬度（后端 PileOut.latitude）
  longitude: number;     // 经度
  powerKw: number;       // 额定功率 kW
  pricePerKwh: number;   // 单价 元/度
  interfaceType: string; // 接口类型，如 国标2015
  status: PileStatus;
}

/** 充电站 */
export interface ChargingStation {
  id: string;
  name: string;
  address: string;
  latitude: number;      // 纬度（后端 StationOut.latitude）
  longitude: number;     // 经度
  distanceKm: number;     // 距离 km
  freePiles: number;      // 空闲桩数（= piles 中 IDLE 数）
  pricePerKwh: number;    // 对外展示单价 元/度
  businessHours: string;  // 营业时间，如 00:00-22:22
  piles: ChargingPile[];
}

/** 订单状态 */
export type OrderStatus = 'CHARGING' | 'FINISHED';

/** 充电订单 */
export interface ChargingOrder {
  id: string;            // 订单号，如 CO20260904...
  stationId: string;
  stationName: string;
  pileCode: string;      // 桩编号
  startTime: string;     // 如 2026-09-04 12:30:00
  endTime: string;       // 进行中为 ''
  energyKwh: number;     // 充电量 度
  unitPrice: number;     // 单价 元/度
  durationMin: number;   // 时长 分钟
  amount: number;        // 总价 元（= energyKwh × unitPrice）
  status: OrderStatus;
}

/** 充电实时状态 */
export interface RealTimeChargingData {
  voltage: number;       // 电压 V
  current: number;       // 电流 A
  powerKw: number;       // 功率 kW
  durationSec: number;   // 已充时长 s
  energyKwh: number;     // 已充电量 度
  estimatedCost: number; // 预估费用 元
}
