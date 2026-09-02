/**
 * 业务数据类型定义（ArkTS interface，仅供类型标注，不提供运行时值）
 */

/** 导航路由参数（NavPathStack 传参统一用对象包装，避免 object→string 转换） */
export interface NavParam {
  id: string;
}

/** 充电桩状态 */
export type PileStatus = 'IDLE' | 'CHARGING' | 'OFFLINE';

/** 电压/电流模拟数据 */
export interface RealTimeChargingData {
  voltage: number;       // 电压 V
  current: number;       // 电流 A
  powerKw: number;       // 功率 kW
  durationSec: number;   // 已充时长 s
  energyKwh: number;     // 已充电量 kWh
  estimatedCost: number; // 预估费用 元
}

/** 充电桩 */
export interface ChargingPile {
  id: string;
  stationId: string;
  code: string;          // 桩编号，如 p000000002（同时作为扫码内容）
  slotCode: string;      // 停车位号，如 C000000001
  powerKw: number;       // 充电功率，如 150（KW）
  pricePerHour: number;  // 单价 元/时
  interfaceType: string; // 充电接口，如 国标2015 国标2011
  floor: string;         // 所属楼层，如 诺德充电中心1号一层
  ground: string;        // 地上/地下充电
  status: PileStatus;
}

/** 充电站 */
export interface ChargingStation {
  id: string;
  name: string;
  address: string;
  distanceKm: number;     // 距离 km
  pricePerKwh: number;    // 实时电价 元/度
  feeMode: string;        // 收费方式，如 峰谷电价
  parkingFee: string;     // 停车费，如 免停车费
  businessHours: string;  // 营业时间，如 00:00-22:22
  phone: string;          // 联系电话
  freePiles: number;      // 空闲桩数
  occupied: number;       // 占用桩数
  tags: string[];         // 标签，如 ['直流快充', '免停车费']
  mapX: number;           // 地图标记横坐标（%）
  mapY: number;           // 地图标记纵坐标（%）
  piles: ChargingPile[];
}
