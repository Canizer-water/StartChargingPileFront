import { Theme } from '../common/Theme';

/**
 * 近7天充电量趋势图（ArkUI Canvas 自绘）
 * - 蓝色折线 + 蓝色渐变面积
 * - 点击/滑动显示悬浮提示：日期 + 充电量
 * - 颜色统一取自 common/Theme（随系统亮/暗切换）
 */
@Component
export struct TrendChart {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  @State selectedIndex: number = -1;
  @StorageLink('isDarkMode') @Watch('onDarkChange') isDark: boolean = false;

  onDarkChange(): void {
    if (this.context.width > 0) {
      this.draw();
    }
  }

  // Mock 数据：7 天累计 168.50 度
  private dates: string[] = ['2026-08-27', '2026-08-28', '2026-08-29', '2026-08-30', '2026-08-31', '2026-09-01', '2026-09-02'];
  private labels: string[] = ['8/27', '8/28', '8/29', '8/30', '8/31', '9/1', '9/2'];
  private values: number[] = [0, 12.5, 20, 33, 40, 29.67, 33.33];

  private padL: number = 34;
  private padR: number = 10;
  private padT: number = 12;
  private padB: number = 20;

  private plotLeft(): number {
    return this.padL;
  }

  private plotTop(): number {
    return this.padT;
  }

  private plotBottom(): number {
    return this.context.height - this.padB;
  }

  private plotRight(): number {
    return this.context.width - this.padR;
  }

  private yOf(value: number): number {
    const top = this.plotTop();
    const bottom = this.plotBottom();
    return top + (1 - value / 100) * (bottom - top);
  }

  private xOf(index: number): number {
    const left = this.plotLeft();
    const right = this.plotRight();
    const count = this.values.length;
    if (count <= 1) {
      return left;
    }
    return left + (right - left) * index / (count - 1);
  }

  private hitIndex(touchX: number): number {
    const left = this.plotLeft();
    const right = this.plotRight();
    const count = this.values.length;
    if (count <= 1 || touchX < left - 6 || touchX > right + 6) {
      return -1;
    }
    const step = (right - left) / (count - 1);
    let index = Math.round((touchX - left) / step);
    if (index < 0 || index > count - 1) {
      return -1;
    }
    return index;
  }

  private draw(): void {
    const ctx = this.context;
    const p = Theme.palette(this.isDark);
    const w = ctx.width;
    const h = ctx.height;
    ctx.clearRect(0, 0, w, h);
    if (this.values.length < 2) {
      return;
    }

    const left = this.plotLeft();
    const right = this.plotRight();
    const top = this.plotTop();
    const bottom = this.plotBottom();

    // 背景网格 + Y 轴刻度
    ctx.font = '10px sans-serif';
    ctx.textAlign = 'right';
    for (let i = 0; i <= 4; i++) {
      const value = i * 25;
      const y = this.yOf(value);
      ctx.strokeStyle = value === 0 ? p.grid : p.divider;
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(left, y);
      ctx.lineTo(right, y);
      ctx.stroke();
      ctx.fillStyle = p.textMuted;
      ctx.fillText(`${value}`, left - 7, y + 3);
    }

    // X 轴日期
    ctx.textAlign = 'center';
    ctx.fillStyle = p.textMuted;
    for (let i = 0; i < this.labels.length; i++) {
      const x = this.xOf(i);
      ctx.fillText(this.labels[i], x, bottom + 14);
    }

    // 数据点
    const points: ChartPoint[] = [];
    for (let i = 0; i < this.values.length; i++) {
      points.push(new ChartPoint(this.xOf(i), this.yOf(this.values[i])));
    }

    // 渐变面积填充
    const gradient = ctx.createLinearGradient(0, top, 0, bottom);
    gradient.addColorStop(0, '#4D' + p.brand.substring(1));
    gradient.addColorStop(1, '#06' + p.brand.substring(1));
    ctx.beginPath();
    ctx.moveTo(points[0].x, points[0].y);
    for (let i = 1; i < points.length; i++) {
      ctx.lineTo(points[i].x, points[i].y);
    }
    ctx.lineTo(points[points.length - 1].x, bottom);
    ctx.lineTo(points[0].x, bottom);
    ctx.closePath();
    ctx.fillStyle = gradient;
    ctx.fill();

    // 平滑折线
    ctx.beginPath();
    ctx.moveTo(points[0].x, points[0].y);
    if (points.length > 2) {
      for (let i = 1; i < points.length - 1; i++) {
        const midX = (points[i].x + points[i + 1].x) / 2;
        const midY = (points[i].y + points[i + 1].y) / 2;
        ctx.quadraticCurveTo(points[i].x, points[i].y, midX, midY);
      }
    }
    ctx.lineTo(points[points.length - 1].x, points[points.length - 1].y);
    ctx.strokeStyle = p.brand;
    ctx.lineWidth = 2;
    ctx.stroke();

    // 选中态：竖线 + 高亮点 + 悬浮提示
    if (this.selectedIndex >= 0 && this.selectedIndex < points.length) {
      const point = points[this.selectedIndex];
      ctx.strokeStyle = p.brandLight;
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(point.x, top);
      ctx.lineTo(point.x, bottom);
      ctx.stroke();

      ctx.beginPath();
      ctx.arc(point.x, point.y, 5, 0, Math.PI * 2);
      ctx.fillStyle = p.cardBg;
      ctx.fill();
      ctx.beginPath();
      ctx.arc(point.x, point.y, 3, 0, Math.PI * 2);
      ctx.fillStyle = p.brand;
      ctx.fill();

      const date = this.dates[this.selectedIndex];
      const valueText = `充电 ${this.values[this.selectedIndex].toFixed(2)} 度`;
      ctx.font = '10px sans-serif';
      ctx.textAlign = 'left';
      const width1 = ctx.measureText(date).width;
      const width2 = ctx.measureText(valueText).width;
      const boxW = Math.max(width1, width2) + 20;
      const boxH = 38;
      let boxX = point.x - boxW / 2;
      if (boxX < left - 6) {
        boxX = left - 6;
      }
      if (boxX + boxW > w - 4) {
        boxX = w - 4 - boxW;
      }
      let boxY = point.y - boxH - 14;
      if (boxY < top - 4) {
        boxY = point.y + 14;
      }
      if (boxY + boxH > h - 4) {
        boxY = h - boxH - 4;
      }
      ctx.fillStyle = p.brand;
      ctx.fillRect(boxX, boxY, boxW, boxH);
      ctx.fillStyle = '#FFFFFF';
      ctx.fillText(date, boxX + 10, boxY + 14);
      ctx.fillText(valueText, boxX + 10, boxY + 29);
    }
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height(190)
      .backgroundColor(Theme.palette(this.isDark).cardBg)
      .onReady(() => {
        this.draw();
      })
      .onTouch((event: TouchEvent) => {
        if (event.touches.length === 0) {
          return;
        }
        if (event.type === TouchType.Down || event.type === TouchType.Move) {
          this.selectedIndex = this.hitIndex(event.touches[0].x);
        } else {
          this.selectedIndex = -1;
        }
        this.draw();
      })
  }
}

class ChartPoint {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}
