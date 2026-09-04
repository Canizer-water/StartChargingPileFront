import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { UserAccount } from '../model/Types';

/**
 * 账号服务（Story 1/2）：本地 preferences 持久化，接口形状与未来后端对齐——
 *   register(req)  ~ POST /auth/register
 *   login(req)     ~ POST /auth/login
 *   logout()       ~ POST /auth/logout
 *   restoreSession() ~ GET /auth/session
 * 联调后端时仅需将本类的存储实现替换为 HTTP 调用，调用方零改动。
 * 注意：密码明文存储仅限前端演示（见《开发设计文档》§11），后端接入后废弃。
 */

const STORE_NAME = 'auth_store';
const KEY_USERS = 'users';       // UserAccount[] JSON
const KEY_SESSION = 'session';   // 已登录用户 id
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

export class AuthService {
  private static instance: AuthService = new AuthService();
  private store: preferences.Preferences | null = null;

  static getInstance(): AuthService {
    return AuthService.instance;
  }

  /** Ability 启动时初始化（Login/Register 页兜底自初始化） */
  async init(ctx: common.Context): Promise<void> {
    if (this.store === null) {
      this.store = await preferences.getPreferences(ctx, STORE_NAME);
    }
  }

  private async requireStore(): Promise<preferences.Preferences> {
    if (this.store === null) {
      throw new Error('AuthService not initialized');
    }
    return this.store;
  }

  private async loadUsers(store: preferences.Preferences): Promise<UserAccount[]> {
    const raw = await store.get(KEY_USERS, '') as string;
    if (raw === '') {
      return [];
    }
    try {
      return JSON.parse(raw) as UserAccount[];
    } catch (err) {
      return [];
    }
  }

  /** 注册（含账号唯一性校验）~ POST /auth/register */
  async register(req: RegisterRequest): Promise<AuthResult> {
    const store = await this.requireStore();
    const users = await this.loadUsers(store);
    if (users.some((u) => u.username === req.username)) {
      return { success: false, message: '该手机号已注册' };
    }
    const user: UserAccount = {
      id: `U${Date.now()}`,
      username: req.username,
      password: req.password,
      avatar: '',
      createdAt: new Date().toISOString()
    };
    users.push(user);
    await store.put(KEY_USERS, JSON.stringify(users));
    await store.flush();
    return { success: true, message: '注册成功', user: user };
  }

  /** 登录（账号存在 + 密码匹配 + 记住密码）~ POST /auth/login */
  async login(req: LoginRequest): Promise<AuthResult> {
    const store = await this.requireStore();
    const users = await this.loadUsers(store);
    const user = users.find((u) => u.username === req.username);
    if (!user) {
      return { success: false, message: '账号不存在，请先注册' };
    }
    if (user.password !== req.password) {
      return { success: false, message: '密码不一致，请重新输入' };
    }
    await store.put(KEY_SESSION, user.id);
    if (req.remember) {
      const remembered: RememberedAccount = { username: user.username, password: user.password };
      await store.put(KEY_REMEMBER, JSON.stringify(remembered));
    } else {
      await store.delete(KEY_REMEMBER);
    }
    await store.flush();
    return { success: true, message: '登录成功', user: user };
  }

  /** 退出登录：清除会话（保留账号与记住密码）~ POST /auth/logout */
  async logout(): Promise<void> {
    const store = await this.requireStore();
    await store.delete(KEY_SESSION);
    await store.flush();
  }

  /** 冷启动恢复会话，无有效会话返回 null ~ GET /auth/session */
  async restoreSession(): Promise<UserAccount | null> {
    const store = await this.requireStore();
    const sessionId = await store.get(KEY_SESSION, '') as string;
    if (sessionId === '') {
      return null;
    }
    const users = await this.loadUsers(store);
    return users.find((u) => u.id === sessionId) ?? null;
  }

  /** 读取记住的账号密码（登录页回填用） */
  async getRemembered(): Promise<RememberedAccount | null> {
    const store = await this.requireStore();
    const raw = await store.get(KEY_REMEMBER, '') as string;
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
