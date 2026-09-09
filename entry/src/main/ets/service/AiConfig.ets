/**
 * AI 接口配置（集中管理，方便你后续替换成真实接口）。
 * 把下面的占位符换成你自己的接口地址和 Key 即可。
 */
export class AiConfig {
  // ===== 车牌识别 OCR =====
  // 默认示例为通用 OCR 占位，请按供应商格式调整（如百度/阿里/腾讯 OCR）
  static readonly OCR_URL: string = 'https://your-ocr-api.example.com/v1/recognize';
  static readonly OCR_KEY: string = 'YOUR_OCR_API_KEY';

  // ===== AI 对话大模型（OpenAI 兼容格式）=====
  // 默认示例为 DeepSeek，换成通义/讯飞/Moonshot 等 OpenAI 兼容接口时改 URL 和 model 即可
  static readonly LLM_URL: string = 'https://api.deepseek.com/v1/chat/completions';
  static readonly LLM_KEY: string = 'YOUR_LLM_API_KEY';
  static readonly LLM_MODEL: string = 'deepseek-chat';

  // ===== 演示模式 =====
  // true：不发真实请求，返回本地模拟结果（先看 UI 用）；
  // false：走真实 HTTP 调用（需填好上面的 URL/Key）
  static readonly DEMO_MODE: boolean = true;

  // 系统提示词（AI 助手的角色设定，可自行调整）
  static readonly SYSTEM_PROMPT: string =
    '你是智能充电桩的 AI 助手，请用简洁友好的中文回答用户关于充电、车辆、账单等问题。';
}
