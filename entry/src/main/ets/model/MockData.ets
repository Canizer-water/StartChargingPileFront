/**
 * 展示元数据表（联调后：域数据——站点/桩/订单——一律来自后端，本文件不再承载）。
 * 这里只保留纯 UI 字段（停车位号/楼层/收费方式/电话/标签/自绘地图坐标），
 * 契约 §10 决策 1：展示元数据后端不建模，页面经 stationMeta()/pileMeta() 查询。
 * 桩档案与业务规则以服务端为准；本表按后端种子数据（seed.py）的 id/code 对齐。
 */

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
  'p100000003': { slotCode: 'C200000003', floor: '天辰大厦一层', ground: '地上充电' },
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
