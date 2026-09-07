import { ChargingPile, ChargingStation } from '../model/Types';
import { Http, HttpResult } from './Http';
import { AuthService } from './AuthService';

/**
 * 充电站/充电桩数据服务（联调版，契约 §5.2）。
 * 数据源已从 MockData 切换为 GET /stations（后端设计文档 §5.2），
 * 内存缓存供原有同步查询 API 使用；页面进页时调用 refresh() 拉最新桩状态。
 * 展示元数据（停车位号/地图坐标等）仍在前端 MockData，不来自后端（契约 §10 决策 1）。
 */

export class StationService {
  private static instance: StationService = new StationService();
  private cache: ChargingStation[] = [];

  static getInstance(): StationService {
    return StationService.instance;
  }

  /** 从后端拉取全量站点并更新缓存；失败时保留旧缓存并抛出（调用方可 catch 走缓存兜底） */
  async refresh(): Promise<void> {
    const token = await AuthService.getInstance().getToken();
    const res: HttpResult = await Http.get('/stations', token);
    this.cache = Http.parse<ChargingStation[]>(res);
  }

  /** 附近充电中心列表（按距离升序；排序口径归前端，§5.2） */
  getStations(): ChargingStation[] {
    return this.cache.slice().sort((a, b) => a.distanceKm - b.distanceKm);
  }

  /** 最近的一个充电中心（缓存为空时 undefined，页面需判空） */
  getNearest(): ChargingStation | undefined {
    const list = this.getStations();
    return list.length > 0 ? list[0] : undefined;
  }

  /** 推荐排行（去掉最近的那个） */
  getRecommended(): ChargingStation[] {
    return this.getStations().slice(1);
  }

  getStationById(id: string): ChargingStation | undefined {
    return this.cache.find((s) => s.id === id);
  }

  getPileById(pileId: string): ChargingPile | undefined {
    for (const s of this.cache) {
      const p = s.piles.find((x) => x.id === pileId);
      if (p) {
        return p;
      }
    }
    return undefined;
  }

  /** 按桩编号（二维码内容）查询 */
  getPileByCode(code: string): ChargingPile | undefined {
    for (const s of this.cache) {
      const p = s.piles.find((x) => x.code === code);
      if (p) {
        return p;
      }
    }
    return undefined;
  }

  /** 占用桩数（状态为 CHARGING 的桩数量，派生值） */
  occupiedCount(stationId: string): number {
    const s = this.getStationById(stationId);
    if (!s) {
      return 0;
    }
    return s.piles.filter((p) => p.status === 'CHARGING').length;
  }

  /** 随机挑一个空闲桩（扫码演示模式用；先 refresh 再调用可保证状态新鲜） */
  pickIdlePile(): ChargingPile | undefined {
    const idle: ChargingPile[] = [];
    for (const s of this.cache) {
      for (const p of s.piles) {
        if (p.status === 'IDLE') {
          idle.push(p);
        }
      }
    }
    if (idle.length === 0) {
      return undefined;
    }
    return idle[Math.floor(Math.random() * idle.length)];
  }
}
