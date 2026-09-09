import { http } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { AiConfig } from './AiConfig';

export interface ChatMessage {
  role: string; // 'user' | 'assistant' | 'system'
  content: string;
}

interface LlmResponse {
  choices?: Array<LlmChoice>;
}
interface LlmChoice {
  message?: LlmMsg;
}
interface LlmMsg {
  content?: string;
}
interface OcrResponse {
  plateNo?: string;
  plate_no?: string;
  number?: string;
  result?: Array<OcrItem>;
}
interface OcrItem {
  number?: string;
  plateNo?: string;
}
interface OcrBody {
  image: string;
}
interface LlmBody {
  model: string;
  messages: ChatMessage[];
  stream: boolean;
}

function sleep(ms: number): Promise<void> {
  return new Promise<void>((resolve: () => void) => {
    setTimeout(resolve, ms);
  });
}

async function postJson(url: string, key: string, body: OcrBody | LlmBody): Promise<string> {
  const req = http.createHttp();
  try {
    const resp = await req.request(url, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${key}`,
      },
      expectDataType: http.HttpDataType.STRING,
      extraData: JSON.stringify(body),
      connectTimeout: 30000,
      readTimeout: 60000,
    });
    if (resp.responseCode !== 200) {
      throw new Error(`HTTP ${resp.responseCode}`);
    }
    return resp.result as string;
  } finally {
    req.destroy();
  }
}

function readImageAsBase64(uri: string): string {
  const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
  try {
    const stat = fs.statSync(file.fd);
    const buf = new ArrayBuffer(stat.size);
    fs.readSync(file.fd, buf);
    const helper = new util.Base64Helper();
    return helper.encodeToStringSync(new Uint8Array(buf));
  } finally {
    fs.closeSync(file);
  }
}

/**
 * 车牌识别：传入图片 uri，返回识别出的车牌号。
 * 演示模式直接返回示例结果；真实模式读取图片 → base64 → POST 到 OCR 接口。
 */
export async function recognizeLicensePlate(imageUri: string): Promise<string> {
  if (AiConfig.DEMO_MODE) {
    await sleep(600);
    return '陕A·D12345';
  }
  const imageBase64 = readImageAsBase64(imageUri);
  const ocrBody: OcrBody = { image: imageBase64 };
  const raw = await postJson(AiConfig.OCR_URL, AiConfig.OCR_KEY, ocrBody);
  const data = JSON.parse(raw) as OcrResponse;
  // 不同供应商返回结构不同，此处兼容几种常见字段，需按实际接口微调
  if (data.plateNo) {
    return data.plateNo;
  }
  if (data.plate_no) {
    return data.plate_no;
  }
  if (data.number) {
    return data.number;
  }
  if (data.result && data.result.length > 0) {
    return data.result[0].plateNo ?? data.result[0].number ?? '未识别到车牌';
  }
  return '未识别到车牌';
}

/**
 * AI 对话：把历史消息发给大模型，返回助手的回答。
 * 演示模式返回本地模拟回答；真实模式走 OpenAI 兼容 /chat/completions。
 */
export async function chatWithAssistant(messages: ChatMessage[]): Promise<string> {
  if (AiConfig.DEMO_MODE) {
    await sleep(800);
    const last = messages.length > 0 ? messages[messages.length - 1].content : '';
    return `（演示模式）已收到你的问题：「${last}」。填入真实模型 Key 后，我会在这里给出回答。`;
  }

  const payload: ChatMessage[] = [
    { role: 'system', content: AiConfig.SYSTEM_PROMPT },
    ...messages,
  ];
  const llmBody: LlmBody = { model: AiConfig.LLM_MODEL, messages: payload, stream: false };
  const raw = await postJson(AiConfig.LLM_URL, AiConfig.LLM_KEY, llmBody);
  const data = JSON.parse(raw) as LlmResponse;
  if (data.choices && data.choices.length > 0 && data.choices[0].message) {
    return data.choices[0].message.content ?? '';
  }
  return '（未获取到回答）';
}
