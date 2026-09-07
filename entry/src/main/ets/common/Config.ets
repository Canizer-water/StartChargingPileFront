/**
 * 后端服务地址配置 —— 唯一允许出现服务地址的地方，页面/服务禁止硬编码 URL。
 * 契约：后端仓库 ChargingPile/doc/后端设计文档.md（v0.2）。
 *
 * 环境对照：
 * - DevEco 模拟器：10.0.2.2 = 模拟器视角下的宿主机回环地址（后端 uvicorn 默认 127.0.0.1:8000 即可连通）
 * - 真机联调：改为宿主机局域网 IP（如 192.168.x.x），后端需以 --host 0.0.0.0 启动并放行防火墙
 * 局域网地址属于开发环境配置，不入库生产仓库；发布前替换为正式网关域名。
 */
export class ApiConfig {
  static readonly BASE_URL: string = 'http://10.0.2.2:8000/api/v1';
  static readonly CONNECT_TIMEOUT_MS: number = 8000;
  static readonly READ_TIMEOUT_MS: number = 8000;
}
