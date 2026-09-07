import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { UserAccount } from '../model/Types';
import { ApiError, Http, HttpResult } from './Http';

/**
 * 账号服务（Story 1/2）——联调后：认证走后端 /auth/*（设计文档 §5.1），
 * 本地 preferences 仅存两样：会话 JWT（session_token）与「记住密码」（纯端侧体验）。
 * 方法签名与本地模拟时代完全一致，页面零改动。
 * 后端 JWT 无状态，logout 仅清除端侧 token（服务端不保留会话表）。
 */

const STORE_NAME = 'auth_store';
const KEY_TOKEN = 'session_token';
const KEY_REMEMBER = 'remember'; // { username, password } JSON

/** POST /auth/register 请求体 */
export interface RegisterRequest {
  username: string;
  password: string;
}

/** POST /auth/login 请求体 */
export interface LoginRequest {
  username: string;
  password: string;
  remember: boolean;
}

/** 认证接口统一响应体 */
export interface AuthResult {
  success: boolean;
  message: string;
  user?: UserAccount;
}

/** 记住密码（本地回显用） */
export interface RememberedAccount {
  username: string;
  password: string;
}

/** 后端 TokenResult 响应 */
interface TokenPayload {
  token: string;
  user: UserAccount;
}

function errorMessage(err: Object, fallback: string): string {
  return err instanceof ApiError && err.message !== '' ? err.message : fallback;
}

export class AuthService {
  private static instance: AuthService = new AuthService();
  private store: preferences.Preferences | null = null;

  static getInstance(): AuthService {
    return AuthService.instance;
  }

  /** Ability 启动时初始化（Login/Register 页兜底自初始化） */
  async init(ctx: common.Context): Promise<void> {
    if (this.store === null) {
      try {
        this.store = await preferences.getPreferences(ctx, STORE_NAME);
      } catch (err) {
        throw new Error('初始化本地存储失败');
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
      // 本地回显数据写失败不阻断主流程
    }
  }

  private async safeDelete(key: string): Promise<void> {
    if (this.store === null) {
      return;
    }
    try {
      await this.store.delete(key);
      await this.store.flush();
    } catch (err) {
      // 同上
    }
  }

  /** 注册 ~ POST /auth/register（唯一性校验由后端裁决，409） */
  async register(req: RegisterRequest): Promise<AuthResult> {
    const body: RegisterRequest = { username: req.username, password: req.password };
    try {
      const res: HttpResult = await Http.post('/auth/register', JSON.stringify(body));
      const payload = Http.parse<TokenPayload>(res);
      await this.safePut(KEY_TOKEN, payload.token);
      return { success: true, message: '注册成功', user: payload.user };
    } catch (err) {
      return { success: false, message: errorMessage(err, '注册失败，请稍后重试') };
    }
  }

  /** 登录 ~ POST /auth/login（401=账号或密码错误；remember 纯端侧） */
  async login(req: LoginRequest): Promise<AuthResult> {
    const body: LoginRequest = { username: req.username, password: req.password, remember: false };
    try {
      const res: HttpResult = await Http.post('/auth/login', JSON.stringify(body));
      const payload = Http.parse<TokenPayload>(res);
      await this.safePut(KEY_TOKEN, payload.token);
      if (req.remember) {
        const remembered: RememberedAccount = { username: req.username, password: req.password };
        await this.safePut(KEY_REMEMBER, JSON.stringify(remembered));
      } else {
        await this.safeDelete(KEY_REMEMBER);
      }
      return { success: true, message: '登录成功', user: payload.user };
    } catch (err) {
      if (err instanceof ApiError && err.status === 401) {
        return { success: false, message: '账号或密码错误' };
      }
      return { success: false, message: errorMessage(err, '登录失败，请稍后重试') };
    }
  }

  /** 退出登录：清除端侧会话 token（保留记住密码） */
  async logout(): Promise<void> {
    await this.safeDelete(KEY_TOKEN);
  }

  /** 冷启动恢复会话 ~ GET /auth/me；token 失效自动清理 */
  async restoreSession(): Promise<UserAccount | null> {
    const token = await this.safeGet(KEY_TOKEN, '');
    if (token === '') {
      return null;
    }
    try {
      const res: HttpResult = await Http.get('/auth/me', token);
      return Http.parse<UserAccount>(res);
    } catch (err) {
      if (err instanceof ApiError && err.status === 401) {
        await this.safeDelete(KEY_TOKEN);
      }
      return null;
    }
  }

  /** 当前会话 token（供业务服务带鉴权头；空串=未登录） */
  async getToken(): Promise<string> {
    return this.safeGet(KEY_TOKEN, '');
  }

  /** 读取记住的账号密码（登录页回填用，本地行为） */
  async getRemembered(): Promise<RememberedAccount | null> {
    const raw = await this.safeGet(KEY_REMEMBER, '');
    if (raw === '') {
      return null;
    }
    try {
      return JSON.parse(raw) as RememberedAccount;
    } catch (err) {
      return null;
    }
  }
}
