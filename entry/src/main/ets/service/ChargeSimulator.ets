import { ChargingPile, RealTimeChargingData } from '../model/Types';

/**
 * 充电实时数据模拟器（doc §6）：setInterval 定时产出 RealTimeChargingData。
 * 模型：功率随已充电量缓慢回落（0.8→0.5 倍额定），电流 = 功率 / 电压，
 *      电量按功率积分累计，费用 = 电量 × 桩单价。
 * 未来后端就绪后，以 WebSocket/轮询推送替换本类的 tick 数据源。
 */

export class ChargeSimulator {
  private timerId: number = -1;

  /** 是否正在模拟 */
  isRunning(): boolean {
    return this.timerId !== -1;
  }

  /**
   * 启动模拟。
   * @param pile 充电桩（取额定功率与单价）
   * @param intervalMs 刷新间隔
   * @param onUpdate 每次 tick 的实时数据回调
   */
  start(pile: ChargingPile, intervalMs: number, onUpdate: (d: RealTimeChargingData) => void): void {
    if (this.timerId !== -1) {
      return;
    }
    let durationSec = 0;
    let energyKwh = 0;
    this.timerId = setInterval(() => {
      const dt = intervalMs / 1000;
      durationSec += dt;
      // 电压 720V ± 30V 随机抖动
      const voltage = 720 + (Math.random() * 60 - 30);
      // 功率因子从 0.8 随电量渐降至 0.5
      const factor = Math.max(0.5, 0.8 - energyKwh / 400);
      const powerKw = pile.powerKw * factor;
      energyKwh += powerKw * dt / 3600;
      const current = powerKw * 1000 / voltage;
      const data: RealTimeChargingData = {
        voltage: Math.round(voltage),
        current: Math.round(current),
        powerKw: Math.round(powerKw * 10) / 10,
        durationSec: Math.round(durationSec),
        energyKwh: Math.round(energyKwh * 100) / 100,
        estimatedCost: Math.round(energyKwh * pile.pricePerKwh * 100) / 100
      };
      onUpdate(data);
    }, intervalMs);
  }

  /** 停止模拟（幂等） */
  stop(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }
}
