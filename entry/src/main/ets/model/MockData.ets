import { ChargingPile, ChargingStation } from './Types';

/**
 * 本地模拟数据（前端演示用，无后端依赖）。
 * 描述：充电站 / 充电桩静态数据，用于列表、详情页面。
 */

const PILES_S1: ChargingPile[] = [
  {
    id: 'p000000002', stationId: 's1', code: 'p000000002', slotCode: 'C000000001',
    powerKw: 150, pricePerHour: 3.0, interfaceType: '国标2015 国标2011',
    floor: '诺得充电中心1号一层', ground: '地上充电', status: 'IDLE'
  },
  {
    id: 'p000000003', stationId: 's1', code: 'p000000003', slotCode: 'C000000002',
    powerKw: 120, pricePerHour: 2.8, interfaceType: '国标2015',
    floor: '诺得充电中心1号一层', ground: '地上充电', status: 'CHARGING'
  },
  {
    id: 'p000000004', stationId: 's1', code: 'p000000004', slotCode: 'C000000003',
    powerKw: 60, pricePerHour: 2.2, interfaceType: '国标2011',
    floor: '诺得充电中心1号一层', ground: '地上充电', status: 'IDLE'
  }
];

const PILES_S2: ChargingPile[] = [
  {
    id: 'p100000001', stationId: 's2', code: 'p100000001', slotCode: 'C200000001',
    powerKw: 180, pricePerHour: 3.4, interfaceType: '国标2015 国标2011',
    floor: '天辰大厦一层', ground: '地上充电', status: 'IDLE'
  },
  {
    id: 'p100000002', stationId: 's2', code: 'p100000002', slotCode: 'C200000002',
    powerKw: 90, pricePerHour: 2.6, interfaceType: '国标2015',
    floor: '天辰大厦一层', ground: '地上充电', status: 'IDLE'
  }
];

const PILES_S3: ChargingPile[] = [
  {
    id: 'p300000001', stationId: 's3', code: 'p300000001', slotCode: 'C300000001',
    powerKw: 120, pricePerHour: 2.9, interfaceType: '国标2015 国标2011',
    floor: '能源大厦B2层', ground: '地下充电', status: 'OFFLINE'
  },
  {
    id: 'p300000002', stationId: 's3', code: 'p300000002', slotCode: 'C300000002',
    powerKw: 60, pricePerHour: 2.0, interfaceType: '国标2011',
    floor: '能源大厦B2层', ground: '地下充电', status: 'IDLE'
  }
];

const PILES_S4: ChargingPile[] = [
  {
    id: 'p400000001', stationId: 's4', code: 'p400000001', slotCode: 'C400000001',
    powerKw: 7, pricePerHour: 1.2, interfaceType: '国标交流',
    floor: '会展中心1号广场', ground: '地上充电', status: 'IDLE'
  }
];

export const MOCK_STATIONS: ChargingStation[] = [
  {
    id: 's1', name: '诺得充电中心', address: '「地上」五圆路东街159号诺得大厦',
    distanceKm: 0.03, pricePerKwh: 3.12, feeMode: '峰谷电价', parkingFee: '免停车费',
    businessHours: '00:00-22:22', phone: '0571-88886666',
    freePiles: 101, occupied: 101, tags: ['直流快充', '免停车费'], mapX: 30, mapY: 42,
    piles: PILES_S1
  },
  {
    id: 's2', name: '智慧e充·天辰店', address: '「地上」天辰大厦西路88号',
    distanceKm: 0.8, pricePerKwh: 3.32, feeMode: '峰谷电价', parkingFee: '收费2元/时',
    businessHours: '00:00-24:00', phone: '0571-66667777',
    freePiles: 23, occupied: 8, tags: ['直流快充'], mapX: 62, mapY: 26,
    piles: PILES_S2
  },
  {
    id: 's3', name: '星充能源大厦站', address: '「地下」会展大道199号能源大厦B2',
    distanceKm: 1.6, pricePerKwh: 3.58, feeMode: '平段电价', parkingFee: '免停车费',
    businessHours: '08:00-22:00', phone: '0571-55556666',
    freePiles: 12, occupied: 15, tags: ['直流快充', '夜间优惠'], mapX: 78, mapY: 62,
    piles: PILES_S3
  },
  {
    id: 's4', name: '绿色出行会展中心站', address: '「地上」会展大道100号',
    distanceKm: 2.4, pricePerKwh: 3.0, feeMode: '峰谷电价', parkingFee: '收费1元/时',
    businessHours: '00:00-24:00', phone: '0571-44443333',
    freePiles: 5, occupied: 3, tags: ['交流慢充'], mapX: 18, mapY: 76,
    piles: PILES_S4
  }
];
