import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { ChargingOrder } from '../model/Types';

/**
 * 钱包余额（端侧模拟域，暂无后端接口，契约未收录）。
 *
 * 余额与「已扣款订单号」落 preferences，冷启动不丢（此前挂 AppStorage，重启即归零）。
 * 扣款口径：允许透支——结算只减余额，不拦充电启动，余额可为负（钱包页标红）。
 *
 * 【临时件】扣款发生在端侧，自动断电（B 域三路结算）、杀进程、换设备都可能漏扣，
 * 故只能在拉到订单列表时按 settleFinished 对账补扣。后端补 wallet 域后，
 * 这段逻辑要整体搬到 services/charging.py 的 _settle_order 里，本文件随之退役。
 */

const STORE_NAME = 'wallet_store';
const KEY_BALANCE = 'balance';
const KEY_PAID = 'paid_orders';
/** 已扣款订单号保留上限：超出后丢弃最旧，防 preferences 无限增长 */
const PAID_KEEP = 200;

function round2(v: number): number {
  return Math.round(v * 100) / 100;
}

export class WalletService {
  private static instance: WalletService = new WalletService();
  private store: preferences.Preferences | null = null;

  static getInstance(): WalletService {
    return WalletService.instance;
  }

  /** Ability 启动时初始化（页面兜底自初始化，与 AuthService 同构） */
  async init(ctx: common.Context): Promise<void> {
    if (this.store === null) {
      try {
        this.store = await preferences.getPreferences(ctx, STORE_NAME);
      } catch (err) {
        throw new Error('初始化钱包存储失败');
      }
    }
  }

  private async safeGet(key: string, def: string): Promise<string> {
    if (this.store === null) {
      return def;
    }
    try {
      return await this.store.get(key, def) as string;
    } catch (err) {
      return def;
    }
  }

  private async safePut(key: string, value: string): Promise<void> {
    if (this.store === null) {
      return;
    }
    try {
      await this.store.put(key, value);
      await this.store.flush();
    } catch (err) {
      // 端侧余额写失败不阻断主流程（演示数据）
    }
  }

  /** 余额数据版本号：任何写入 +1，钱包页/我的页 @Watch 后自动刷新（同 OrderService 口径） */
  private bumpWalletVersion(): void {
    AppStorage.setOrCreate<number>('walletVersion', (AppStorage.get<number>('walletVersion') ?? 0) + 1);
  }

  /** 当前余额（元）；未初始化或无记录为 0 */
  async getBalance(): Promise<number> {
    const raw = await this.safeGet(KEY_BALANCE, '0');
    const v = Number(raw);
    return Number.isFinite(v) ? round2(v) : 0;
  }

  /** 充值入账（模拟支付，不调任何真实支付渠道）；返回最新余额 */
  async recharge(amount: number): Promise<number> {
    const balance = round2(await this.getBalance() + amount);
    await this.safePut(KEY_BALANCE, balance.toString());
    this.bumpWalletVersion();
    return balance;
  }

  private async readPaid(): Promise<string[]> {
    const raw = await this.safeGet(KEY_PAID, '[]');
    try {
      return JSON.parse(raw) as string[];
    } catch (err) {
      return [];
    }
  }

  /**
   * 结算对账：把列表中「已完成且尚未扣过款」的订单逐笔扣掉，返回最新余额。
   * 按订单号幂等——同一单重复调用不会重复扣款（列表刷新、重进汇总页都安全）。
   */
  async settleFinished(orders: ChargingOrder[]): Promise<number> {
    const paid = await this.readPaid();
    let balance = await this.getBalance();
    let changed = false;
    for (const o of orders) {
      if (o.status !== 'FINISHED' || o.id === '') {
        continue;
      }
      if (paid.indexOf(o.id) >= 0) {
        continue;
      }
      paid.push(o.id);
      balance = round2(balance - o.amount);
      changed = true;
    }
    if (!changed) {
      return balance;
    }
    await this.safePut(KEY_PAID, JSON.stringify(paid.slice(-PAID_KEEP)));
    await this.safePut(KEY_BALANCE, balance.toString());
    this.bumpWalletVersion();
    return balance;
  }
}
