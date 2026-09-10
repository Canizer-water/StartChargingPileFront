import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ApiConfig } from '../common/Config';

/**
 * 统一 HTTP 通道（@kit.NetworkKit）。
 * 契约映射规则（后端设计文档 §5 通用节）：
 * - 2xx → resolve HttpResult（body 为 JSON 字符串，由调用方按声明接口 parse）；
 * - 非 2xx → reject ApiError，message 取后端 {"detail"}，保证各 service 的
 *   {success:false, message} 形状与本地实现时代完全一致（调用方零改动）。
 */

export class ApiError extends Error {
  /** 后端 HTTP 状态码；0 = 网络层失败（未连通） */
  status: number;

  constructor(message: string, status: number = 0) {
    super(message);
    this.status = status;
  }
}

export interface HttpResult {
  status: number;
  body: string;
}

/** 后端错误体 */
interface ErrorBody {
  detail?: string;
}

function parseDetail(body: string, fallback: string): string {
  if (body === '') {
    return fallback;
  }
  try {
    const parsed = JSON.parse(body) as ErrorBody;
    return parsed.detail ?? fallback;
  } catch (err) {
    return fallback;
  }
}

export class Http {
  /** GET；token 为空则不带鉴权头 */
  static get(path: string, token: string = ''): Promise<HttpResult> {
    return Http.request(http.RequestMethod.GET, path, '', token);
  }

  /** POST；bodyJson 为已序列化的请求体（'' 表示无体） */
  static post(path: string, bodyJson: string = '', token: string = ''): Promise<HttpResult> {
    return Http.request(http.RequestMethod.POST, path, bodyJson, token);
  }

  /** PUT；用于整资源更新端点（如 PUT /vehicle/current） */
  static put(path: string, bodyJson: string = '', token: string = ''): Promise<HttpResult> {
    return Http.request(http.RequestMethod.PUT, path, bodyJson, token);
  }

  private static request(method: http.RequestMethod, path: string, bodyJson: string,
                         token: string): Promise<HttpResult> {
    const req = http.createHttp();
    const header: Record<string, string> = { 'Content-Type': 'application/json' };
    if (token !== '') {
      header['Authorization'] = `Bearer ${token}`;
    }
    const options: http.HttpRequestOptions = {
      method: method,
      header: header,
      expectDataType: http.HttpDataType.STRING,
      connectTimeout: ApiConfig.CONNECT_TIMEOUT_MS,
      readTimeout: ApiConfig.READ_TIMEOUT_MS
    };
    if (bodyJson !== '') {
      options.extraData = bodyJson;
    }
    return new Promise<HttpResult>((resolve, reject) => {
      req.request(`${ApiConfig.BASE_URL}${path}`, options).then((res) => {
        req.destroy();
        const status = res.responseCode as number;
        const body = typeof res.result === 'string' ? res.result as string : '';
        if (status >= 200 && status < 300) {
          resolve({ status: status, body: body });
          return;
        }
        reject(new ApiError(parseDetail(body, `请求失败(${status})`), status));
      }).catch((err: BusinessError) => {
        req.destroy();
        console.error(`HTTP ${method} ${path} failed: code=${err.code} msg=${err.message}`);
        reject(new ApiError('无法连接后端服务，请确认服务已启动'));
      });
    });
  }

  /** 2xx 响应体反序列化辅助 */
  static parse<T>(result: HttpResult): T {
    return JSON.parse(result.body) as T;
  }
}
