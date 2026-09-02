import { ChargingPile, ChargingStation } from '../model/Types';
import { MOCK_STATIONS } from '../model/MockData';

/**
 * 充电站/充电桩数据服务（本地模拟）。
 */

export class StationService {
  private static instance: StationService = new StationService();

  static getInstance(): StationService {
    return StationService.instance;
  }

  /** 附近充电中心列表（按距离升序） */
  getStations(): ChargingStation[] {
    return MOCK_STATIONS.slice().sort((a, b) => a.distanceKm - b.distanceKm);
  }

  /** 最近的一个充电中心（用于「离我最近」大卡） */
  getNearest(): ChargingStation {
    return this.getStations()[0];
  }

  /** 推荐排行（去掉最近的那个） */
  getRecommended(): ChargingStation[] {
    return this.getStations().slice(1);
  }

  getStationById(id: string): ChargingStation | undefined {
    return MOCK_STATIONS.find((s) => s.id === id);
  }

  getPileById(pileId: string): ChargingPile | undefined {
    for (const s of MOCK_STATIONS) {
      const p = s.piles.find((x) => x.id === pileId);
      if (p) {
        return p;
      }
    }
    return undefined;
  }
}
