import { ChargingStation } from '../model/Types';

/**
 * 自绘风格地图（前端演示，无需地图 SDK / API Key）。
 * 使用 Canvas 绘制示意底图（道路、公园、水域），再用 Stack 叠加站点标记。
 */

@Component
export struct MapView {
  /** 需要在地图上展示的站点 */
  stations: ChargingStation[] = [];

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  /** 绘制示意底图 */
  private drawBase(): void {
    const ctx = this.context;
    const w = ctx.width;
    const h = ctx.height;
    if (w <= 0 || h <= 0) {
      return;
    }
    ctx.clearRect(0, 0, w, h);
    // 底色
    ctx.fillStyle = '#E8EDF3';
    ctx.fillRect(0, 0, w, h);
    // 楼宇色块
    ctx.fillStyle = '#DEE4EC';
    ctx.fillRect(w * 0.03, h * 0.10, w * 0.20, h * 0.20);
    ctx.fillRect(w * 0.72, h * 0.08, w * 0.18, h * 0.16);
    ctx.fillRect(w * 0.55, h * 0.70, w * 0.16, h * 0.20);
    // 公园
    ctx.fillStyle = '#CDE7D0';
    ctx.fillRect(w * 0.06, h * 0.52, w * 0.24, h * 0.30);
    // 水域
    ctx.fillStyle = '#C6E0F1';
    ctx.fillRect(w * 0.74, h * 0.58, w * 0.22, h * 0.28);
    // 道路（白底）
    ctx.fillStyle = '#FFFFFF';
    ctx.fillRect(0, h * 0.45, w, h * 0.075);     // 横向主干道
    ctx.fillRect(w * 0.47, 0, w * 0.055, h);     // 纵向主干道
    ctx.fillRect(0, h * 0.86, w, h * 0.045);     // 横向次干道
    ctx.fillRect(w * 0.12, 0, w * 0.03, h);      // 纵向次干道
    // 道路中线
    ctx.strokeStyle = '#D7DCE3';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(0, h * 0.4875);
    ctx.lineTo(w, h * 0.4875);
    ctx.moveTo(w * 0.4975, 0);
    ctx.lineTo(w * 0.4975, h);
    ctx.stroke();
  }

  /** 站点标记 */
  @Builder
  StationMarker(station: ChargingStation) {
    Column() {
      Stack() {
        Circle({ width: 16, height: 16 })
          .fill($r('app.color.map_marker'))
          .stroke(Color.White)
          .strokeWidth(3)
        Text('⚡')
          .fontSize(9)
          .fontColor(Color.White)
      }
      .width(16)
      .height(16)

      Text(station.name)
        .fontSize(9)
        .fontColor(Color.White)
        .backgroundColor('rgba(31,35,41,0.62)')
        .padding({ left: 4, right: 4, top: 1, bottom: 1 })
        .borderRadius(3)
        .margin({ top: 2 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: 72 })
    }
    .alignItems(HorizontalAlign.Center)
    .position({ x: `${station.mapX}%`, y: `${station.mapY}%` })
  }

  /** “我的位置”标记 */
  @Builder
  MyLocation() {
    Column() {
      Stack() {
        Circle({ width: 26, height: 26 })
          .fill('rgba(47,123,246,0.22)')
        Circle({ width: 14, height: 14 })
          .fill($r('app.color.map_marker_you'))
          .stroke(Color.White)
          .strokeWidth(3)
      }
      .width(26)
      .height(26)
    }
    .position({ x: '45%', y: '47%' })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.drawBase();
        })

      ForEach(this.stations, (station: ChargingStation) => {
        this.StationMarker(station)
      }, (station: ChargingStation) => station.id)

      this.MyLocation()
    }
    .width('100%')
    .height('100%')
    .clip(true)
  }
}
