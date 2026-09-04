import { ChargingPile, ChargingStation } from './Types';

/**
 * 本地模拟数据（前端演示用，无后端依赖）。
 * 领域数据（站点/桩）严格使用 Types.ets 的规范模型；
 * 纯展示信息（停车位号/楼层/收费方式/地图坐标等）单独放 DisplayMeta 表，
 * 页面经 stationMeta()/pileMeta() 查询，不与后端接口字段混淆。
 */

const PILES_S1: ChargingPile[] = [
  { id: 'p000000002', stationId: 's1', code: 'p000000002', powerKw: 150, pricePerKwh: 1.35, interfaceType: '国标2015 国标2011', status: 'IDLE' },
  { id: 'p000000003', stationId: 's1', code: 'p000000003', powerKw: 120, pricePerKwh: 1.25, interfaceType: '国标2015', status: 'CHARGING' },
  { id: 'p000000004', stationId: 's1', code: 'p000000004', powerKw: 60, pricePerKwh: 1.15, interfaceType: '国标2011', status: 'IDLE' }
];

const PILES_S2: ChargingPile[] = [
  { id: 'p100000001', stationId: 's2', code: 'p100000001', powerKw: 180, pricePerKwh: 1.45, interfaceType: '国标2015 国标2011', status: 'IDLE' },
  { id: 'p100000002', stationId: 's2', code: 'p100000002', powerKw: 90, pricePerKwh: 1.20, interfaceType: '国标2015', status: 'IDLE' }
];

const PILES_S3: ChargingPile[] = [
  { id: 'p300000001', stationId: 's3', code: 'p300000001', powerKw: 120, pricePerKwh: 1.10, interfaceType: '国标2015 国标2011', status: 'OFFLINE' },
  { id: 'p300000002', stationId: 's3', code: 'p300000002', powerKw: 60, pricePerKwh: 1.05, interfaceType: '国标2011', status: 'IDLE' }
];

const PILES_S4: ChargingPile[] = [
  { id: 'p400000001', stationId: 's4', code: 'p400000001', powerKw: 7, pricePerKwh: 1.02, interfaceType: '国标交流', status: 'IDLE' }
];

export const MOCK_STATIONS: ChargingStation[] = [
  {
    id: 's1', name: '诺得充电中心', address: '「地上」五圆路东街159号诺得大厦',
    distanceKm: 0.03, pricePerKwh: 1.15, businessHours: '00:00-22:22',
    freePiles: 2, piles: PILES_S1
  },
  {
    id: 's2', name: '智慧e充·天辰店', address: '「地上」天辰大厦西路88号',
    distanceKm: 0.8, pricePerKwh: 1.20, businessHours: '00:00-24:00',
    freePiles: 2, piles: PILES_S2
  },
  {
    id: 's3', name: '星充能源大厦站', address: '「地下」会展大道199号能源大厦B2',
    distanceKm: 1.6, pricePerKwh: 1.05, businessHours: '08:00-22:00',
    freePiles: 1, piles: PILES_S3
  },
  {
    id: 's4', name: '绿色出行会展中心站', address: '「地上」会展大道100号',
    distanceKm: 2.4, pricePerKwh: 1.02, businessHours: '00:00-24:00',
    freePiles: 1, piles: PILES_S4
  }
];

/** 充电站展示元数据（不属于领域模型，仅本页式渲染用） */
export interface StationDisplayMeta {
  feeMode: string;      // 收费方式，如 峰谷电价
  parkingFee: string;   // 停车费说明
  phone: string;        // 联系电话
  tags: string[];       // 标签胶囊
  mapX: number;         // 自绘地图标记横坐标（%）
  mapY: number;         // 自绘地图标记纵坐标（%）
}

/** 充电桩展示元数据（不属于领域模型） */
export interface PileDisplayMeta {
  slotCode: string;   // 停车位号
  floor: string;      // 所属楼层
  ground: string;     // 地上/地下充电
}

const STATION_META: Record<string, StationDisplayMeta> = {
  's1': { feeMode: '峰谷电价', parkingFee: '免停车费', phone: '0571-88886666', tags: ['直流快充', '免停车费'], mapX: 30, mapY: 42 },
  's2': { feeMode: '峰谷电价', parkingFee: '收费2元/时', phone: '0571-66667777', tags: ['直流快充'], mapX: 62, mapY: 26 },
  's3': { feeMode: '平段电价', parkingFee: '免停车费', phone: '0571-55556666', tags: ['直流快充', '夜间优惠'], mapX: 78, mapY: 62 },
  's4': { feeMode: '峰谷电价', parkingFee: '收费1元/时', phone: '0571-44443333', tags: ['交流慢充'], mapX: 18, mapY: 76 }
};

const PILE_META: Record<string, PileDisplayMeta> = {
  'p000000002': { slotCode: 'C000000001', floor: '诺得充电中心1号一层', ground: '地上充电' },
  'p000000003': { slotCode: 'C000000002', floor: '诺得充电中心1号一层', ground: '地上充电' },
  'p000000004': { slotCode: 'C000000003', floor: '诺得充电中心1号一层', ground: '地上充电' },
  'p100000001': { slotCode: 'C200000001', floor: '天辰大厦一层', ground: '地上充电' },
  'p100000002': { slotCode: 'C200000002', floor: '天辰大厦一层', ground: '地上充电' },
  'p300000001': { slotCode: 'C300000001', floor: '能源大厦B2层', ground: '地下充电' },
  'p300000002': { slotCode: 'C300000002', floor: '能源大厦B2层', ground: '地下充电' },
  'p400000001': { slotCode: 'C400000001', floor: '会展中心1号广场', ground: '地上充电' }
};

const EMPTY_STATION_META: StationDisplayMeta = { feeMode: '', parkingFee: '', phone: '', tags: [], mapX: 50, mapY: 50 };
const EMPTY_PILE_META: PileDisplayMeta = { slotCode: '', floor: '', ground: '' };

/** 按站点 id 取展示元数据（查不到返回空值，页面按缺省渲染） */
export function stationMeta(id: string): StationDisplayMeta {
  return STATION_META[id] ?? EMPTY_STATION_META;
}

/** 按桩 id 取展示元数据 */
export function pileMeta(id: string): PileDisplayMeta {
  return PILE_META[id] ?? EMPTY_PILE_META;
}
