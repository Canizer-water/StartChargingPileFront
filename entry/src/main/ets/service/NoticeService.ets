import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/**
 * 系统通知（端侧模拟域，无后端接口，契约未收录）。
 * 通知内容为静态演示数据，文案只描述已真实落地的功能；
 * 「已读」状态落 preferences，进过一次列表即清零红点。
 */

export class NoticeItem {
  id: number;
  title: string;
  content: string;
  iconKind: string;

  constructor(id: number, title: string, content: string, iconKind: string) {
    this.id = id;
    this.title = title;
    this.content = content;
    this.iconKind = iconKind;
  }
}

const STORE_NAME = 'notice_store';
const KEY_SEEN = 'seen_ids';

/** 静态演示通知（新增条目后，用户未点开过的会计入红点） */
const NOTICES: NoticeItem[] = [
  new NoticeItem(1, '系统升级通知', '平台服务将于近期升级，期间充电可能短暂中断，请提前结束充电并保存订单信息。', 'bolt'),
  new NoticeItem(2, '账号安全提醒', '检测到您的账号在异地登录，请及时修改密码以确保账户安全。', 'user'),
  new NoticeItem(3, '新功能上线', '我的钱包与电子发票已上线，支持余额查询与按订单开票。', 'sparkle')
];

export class NoticeService {
  private static instance: NoticeService = new NoticeService();
  private store: preferences.Preferences | null = null;

  static getInstance(): NoticeService {
    return NoticeService.instance;
  }

  /** Ability 启动时初始化（页面兜底自初始化，与 AuthService 同构） */
  async init(ctx: common.Context): Promise<void> {
    if (this.store === null) {
      try {
        this.store = await preferences.getPreferences(ctx, STORE_NAME);
      } catch (err) {
        throw new Error('初始化通知存储失败');
      }
    }
  }

  /** 通知列表（静态数据，同步取） */
  list(): NoticeItem[] {
    return NOTICES;
  }

  private async readSeen(): Promise<number[]> {
    if (this.store === null) {
      return [];
    }
    try {
      const raw = await this.store.get(KEY_SEEN, '[]') as string;
      return JSON.parse(raw) as number[];
    } catch (err) {
      return [];
    }
  }

  /** 未读条数（红点数字） */
  async unreadCount(): Promise<number> {
    const seen = await this.readSeen();
    return NOTICES.filter((n: NoticeItem) => seen.indexOf(n.id) < 0).length;
  }

  /** 标记全部已读 */
  async markAllSeen(): Promise<void> {
    if (this.store === null) {
      return;
    }
    const ids: number[] = NOTICES.map((n: NoticeItem) => n.id);
    try {
      await this.store.put(KEY_SEEN, JSON.stringify(ids));
      await this.store.flush();
      AppStorage.setOrCreate<number>('noticeVersion', (AppStorage.get<number>('noticeVersion') ?? 0) + 1);
    } catch (err) {
      // 红点写失败不影响阅读
    }
  }
}
