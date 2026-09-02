/**
 * LineIcon：使用 Canvas 自绘的轻量线性图标。
 * 不依赖系统符号资源，支持任意颜色，可随容器等比缩放。
 *
 * 可用 kind：
 * user / wallet / yuan / car / history / envelope /
 * chevronRight / back / exit / bolt
 */
@Component
export struct LineIcon {
  @Prop kind: string = 'user';
  @Prop color: string = '#1450B8';

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private drawUser(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.lineWidth = 1.7 * u;
    ctx.beginPath();
    ctx.arc(12 * u, 8.2 * u, 3.4 * u, 0, Math.PI * 2);
    ctx.stroke();
    ctx.beginPath();
    ctx.arc(12 * u, 13.6 * u, 6.1 * u, Math.PI * 0.16, Math.PI * 0.84);
    ctx.stroke();
  }

  private drawWallet(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.lineWidth = 1.7 * u;
    // 钱袋主体
    ctx.beginPath();
    ctx.moveTo(4.6 * u, 8.2 * u);
    ctx.quadraticCurveTo(4.2 * u, 18.5 * u, 12 * u, 18.5 * u);
    ctx.quadraticCurveTo(19.8 * u, 18.5 * u, 19.4 * u, 8.2 * u);
    ctx.stroke();
    // 袋口
    ctx.beginPath();
    ctx.moveTo(7.4 * u, 8.4 * u);
    ctx.lineTo(7.0 * u, 5.2 * u);
    ctx.lineTo(17.0 * u, 5.2 * u);
    ctx.lineTo(16.6 * u, 8.4 * u);
    ctx.stroke();
    // 货币符号
    ctx.fillStyle = this.color;
    ctx.font = `${10.5 * u}px sans-serif`;
    ctx.textAlign = 'center';
    ctx.fillText('¥', 12 * u, 15.4 * u);
  }

  private drawYuan(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.fillStyle = this.color;
    ctx.font = `${13 * u}px sans-serif`;
    ctx.textAlign = 'center';
    ctx.fillText('¥', 12 * u, 16.2 * u);
  }

  private drawCar(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.lineWidth = 1.7 * u;
    // 车身
    ctx.beginPath();
    ctx.moveTo(3.8 * u, 10.8 * u);
    ctx.lineTo(5.2 * u, 7.2 * u);
    ctx.lineTo(9.0 * u, 5.8 * u);
    ctx.lineTo(14.8 * u, 5.8 * u);
    ctx.lineTo(18.2 * u, 8.0 * u);
    ctx.lineTo(20.2 * u, 10.8 * u);
    ctx.lineTo(20.2 * u, 15.4 * u);
    ctx.lineTo(3.8 * u, 15.4 * u);
    ctx.closePath();
    ctx.stroke();
    // 车窗
    ctx.beginPath();
    ctx.moveTo(9.8 * u, 6.4 * u);
    ctx.lineTo(10.5 * u, 8.8 * u);
    ctx.lineTo(15.6 * u, 8.8 * u);
    ctx.lineTo(15.0 * u, 6.4 * u);
    ctx.closePath();
    ctx.stroke();
    // 车轮
    ctx.fillStyle = this.color;
    ctx.beginPath();
    ctx.arc(8 * u, 15.4 * u, 2.1 * u, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(17 * u, 15.4 * u, 2.1 * u, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(8 * u, 15.4 * u, 0.8 * u, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(17 * u, 15.4 * u, 0.8 * u, 0, Math.PI * 2);
    ctx.fill();
  }

  private drawHistory(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.lineWidth = 1.7 * u;
    // 表盘
    ctx.beginPath();
    ctx.arc(12 * u, 12.5 * u, 7.0 * u, 0, Math.PI * 2);
    ctx.stroke();
    // 指针
    ctx.beginPath();
    ctx.moveTo(12 * u, 12.5 * u);
    ctx.lineTo(12 * u, 8.8 * u);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(12 * u, 12.5 * u);
    ctx.lineTo(15.0 * u, 14.0 * u);
    ctx.stroke();
    // 中心点
    ctx.fillStyle = this.color;
    ctx.beginPath();
    ctx.arc(12 * u, 12.5 * u, 0.9 * u, 0, Math.PI * 2);
    ctx.fill();
    // 顶部历史回环箭头
    ctx.lineWidth = 1.5 * u;
    ctx.beginPath();
    ctx.arc(12 * u, 12.5 * u, 8.8 * u, Math.PI * 1.15, Math.PI * 1.85);
    ctx.stroke();
  }

  private drawEnvelope(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.lineWidth = 1.7 * u;
    ctx.beginPath();
    ctx.moveTo(3.8 * u, 6.8 * u);
    ctx.lineTo(20.2 * u, 6.8 * u);
    ctx.lineTo(20.2 * u, 17.2 * u);
    ctx.lineTo(3.8 * u, 17.2 * u);
    ctx.closePath();
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(3.8 * u, 7.4 * u);
    ctx.lineTo(12 * u, 13.4 * u);
    ctx.lineTo(20.2 * u, 7.4 * u);
    ctx.stroke();
  }

  private drawChat(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.lineWidth = 1.7 * u;
    // 对话气泡主体
    ctx.beginPath();
    ctx.moveTo(4.2 * u, 5.6 * u);
    ctx.lineTo(19.8 * u, 5.6 * u);
    ctx.lineTo(19.8 * u, 14.8 * u);
    ctx.lineTo(13.2 * u, 14.8 * u);
    ctx.lineTo(10.6 * u, 18.2 * u);
    ctx.lineTo(8.0 * u, 14.8 * u);
    ctx.lineTo(4.2 * u, 14.8 * u);
    ctx.closePath();
    ctx.stroke();
    // 气泡内省略点
    ctx.fillStyle = this.color;
    ctx.beginPath();
    ctx.arc(8.4 * u, 10.2 * u, 1.0 * u, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(12 * u, 10.2 * u, 1.0 * u, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(15.6 * u, 10.2 * u, 1.0 * u, 0, Math.PI * 2);
    ctx.fill();
  }
  private drawSparkle(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.lineWidth = 1.6 * u;
    ctx.lineJoin = 'round';
    ctx.beginPath();
    ctx.moveTo(12 * u, 2.8 * u);
    ctx.lineTo(13.5 * u, 10.5 * u);
    ctx.lineTo(21.2 * u, 12 * u);
    ctx.lineTo(13.5 * u, 13.5 * u);
    ctx.lineTo(12 * u, 21.2 * u);
    ctx.lineTo(10.5 * u, 13.5 * u);
    ctx.lineTo(2.8 * u, 12 * u);
    ctx.lineTo(10.5 * u, 10.5 * u);
    ctx.closePath();
    ctx.stroke();
  }
  private drawChevronRight(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.lineWidth = 1.8 * u;
    ctx.beginPath();
    ctx.moveTo(9 * u, 5 * u);
    ctx.lineTo(16 * u, 12 * u);
    ctx.lineTo(9 * u, 19 * u);
    ctx.stroke();
  }

  private drawBack(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.lineWidth = 1.8 * u;
    ctx.beginPath();
    ctx.moveTo(15 * u, 5 * u);
    ctx.lineTo(8 * u, 12 * u);
    ctx.lineTo(15 * u, 19 * u);
    ctx.stroke();
  }

  private drawExit(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.lineWidth = 1.7 * u;
    // 门
    ctx.beginPath();
    ctx.moveTo(10.5 * u, 5.5 * u);
    ctx.lineTo(10.5 * u, 18.5 * u);
    ctx.stroke();
    // 箭头
    ctx.beginPath();
    ctx.moveTo(11 * u, 12 * u);
    ctx.lineTo(20 * u, 12 * u);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(16.3 * u, 7.6 * u);
    ctx.lineTo(20.6 * u, 12 * u);
    ctx.lineTo(16.3 * u, 16.4 * u);
    ctx.stroke();
  }

  private drawBolt(ctx: CanvasRenderingContext2D, u: number): void {
    ctx.fillStyle = this.color;
    ctx.beginPath();
    ctx.moveTo(13.6 * u, 3.6 * u);
    ctx.lineTo(8.0 * u, 13.4 * u);
    ctx.lineTo(11.6 * u, 13.4 * u);
    ctx.lineTo(10.4 * u, 20.4 * u);
    ctx.lineTo(16.4 * u, 10.2 * u);
    ctx.lineTo(12.8 * u, 10.2 * u);
    ctx.closePath();
    ctx.fill();
  }

  private drawIcon(): void {
    const ctx: CanvasRenderingContext2D = this.context;
    const w: number = ctx.width;
    const h: number = ctx.height;
    if (w <= 0 || h <= 0) {
      return;
    }
    const u: number = Math.min(w, h) / 24;
    ctx.clearRect(0, 0, w, h);
    ctx.strokeStyle = this.color;
    ctx.fillStyle = this.color;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    if (this.kind === 'user') {
      this.drawUser(ctx, u);
    } else if (this.kind === 'wallet') {
      this.drawWallet(ctx, u);
    } else if (this.kind === 'yuan') {
      this.drawYuan(ctx, u);
    } else if (this.kind === 'car') {
      this.drawCar(ctx, u);
    } else if (this.kind === 'history') {
      this.drawHistory(ctx, u);
    } else if (this.kind === 'envelope') {
      this.drawEnvelope(ctx, u);
    } else if (this.kind === 'chat') {
      this.drawChat(ctx, u);
    } else if (this.kind === 'sparkle') {
      this.drawSparkle(ctx, u);
    } else if (this.kind === 'chevronRight') {
      this.drawChevronRight(ctx, u);
    } else if (this.kind === 'back') {
      this.drawBack(ctx, u);
    } else if (this.kind === 'exit') {
      this.drawExit(ctx, u);
    } else if (this.kind === 'bolt') {
      this.drawBolt(ctx, u);
    }
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
      .onReady(() => {
        this.drawIcon();
      })
  }
}
