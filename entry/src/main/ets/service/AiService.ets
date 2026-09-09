import { fileIo as fs } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { AuthService } from './AuthService';
import { Http, HttpResult } from './Http';

/**
 * AI 助手（联调版）：车牌识别 / 多轮问答统一走后端 `/api/v1/ai/*`（Envelope 解包）。
 * 密钥/模型在后端 .env，前端永不接触；系统提示与实时充电状态由后端注入。
 */

export interface ChatMessage {
  role: string; // 'user' | 'assistant' | 'system'
  content: string;
}

/** 后端 Envelope<T>（契约 §5.6）：success/errorCode/message/data */
interface Envelope<T> {
  success: boolean;
  errorCode: number;
  message: string;
  data: T;
}

interface ChatUsageData {
  promptTokens: number;
  completionTokens: number;
  totalTokens: number;
}

interface ChatData {
  reply: string;
  model: string;
  usage?: ChatUsageData | null;
}

interface PlateData {
  plateNumber: string;
  confidence: number;
  rawText: string;
  model: string;
}

interface PlateBody {
  imageDataUrl: string;
}

interface ChatBody {
  messages: ChatMessage[];
}

function mimeOf(uri: string): string {
  const idx = uri.lastIndexOf('.');
  const ext = idx >= 0 ? uri.substring(idx + 1).toLowerCase() : 'png';
  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'bmp':
      return 'image/bmp';
    default:
      return 'image/png';
  }
}

function readImageAsDataUrl(uri: string): string {
  const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
  try {
    const stat = fs.statSync(file.fd);
    const buf = new ArrayBuffer(stat.size);
    fs.readSync(file.fd, buf);
    const helper = new util.Base64Helper();
    const b64 = helper.encodeToStringSync(new Uint8Array(buf));
    return `data:${mimeOf(uri)};base64,${b64}`;
  } finally {
    fs.closeSync(file);
  }
}

/** 车牌识别 ~ POST /ai/plate（后端经火山方舟视觉模型）；未识别到返回空串 */
export async function recognizeLicensePlate(imageUri: string): Promise<string> {
  const token = await AuthService.getInstance().getToken();
  const body: PlateBody = { imageDataUrl: readImageAsDataUrl(imageUri) };
  const res: HttpResult = await Http.post('/ai/plate', JSON.stringify(body), token);
  const env = Http.parse<Envelope<PlateData>>(res);
  return env.data ? env.data.plateNumber : '';
}

/** AI 对话 ~ POST /ai/chat（多轮上下文；后端注入 system 与实时充电状态） */
export async function chatWithAssistant(messages: ChatMessage[]): Promise<string> {
  const token = await AuthService.getInstance().getToken();
  const body: ChatBody = { messages: messages };
  const res: HttpResult = await Http.post('/ai/chat', JSON.stringify(body), token);
  const env = Http.parse<Envelope<ChatData>>(res);
  return env.data ? env.data.reply : '';
}
