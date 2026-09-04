/**
 * Canvas 自绘组件（地图、趋势图、头像渐变等）使用的调色板。
 * 与 resources/{base,dark}/element/color.json 保持同步——
 * Canvas 绘制上下文拿不到 ArkUI 资源，色值在这里集中维护。
 * 亮/暗通过 AppStorage['isDarkMode']（EntryAbility 同步）选择 Theme.LIGHT / Theme.DARK。
 */
export class Palette {
  brand: string = '#5B8CE7';
  brandLight: string = '#7FA8F0';
  brandDeep: string = '#1B53BF';
  brandSoft: string = '#E7F0FF';
  accent: string = '#ED823E';
  textPrimary: string = '#1F2329';
  textSecondary: string = '#6B737C';
  textMuted: string = '#A8B0B8';
  cardBg: string = '#FFFFFF';
  pageBg: string = '#F5F6F8';
  divider: string = '#EEF0F3';
  grid: string = '#F2F6FB';
  success: string = '#1FA869';
  warn: string = '#F5A623';
  offline: string = '#B4BAC2';
  mapBg: string = '#E8EDF3';
  mapRoad: string = '#FFFFFF';
  mapPark: string = '#CDE7D0';
  mapWater: string = '#C6E0F1';
}

export class Theme {
  static readonly LIGHT: Palette = new Palette();
  static readonly DARK: Palette = Theme.buildDark();

  private static buildDark(): Palette {
    const p: Palette = new Palette();
    p.brand = '#6E9BE8';
    p.brandLight = '#8FB3F5';
    p.brandDeep = '#2E5EAA';
    p.brandSoft = '#16304F';
    p.accent = '#F09663';
    p.textPrimary = '#F2F3F5';
    p.textSecondary = '#AEB4BC';
    p.textMuted = '#6E747A';
    p.cardBg = '#1E2025';
    p.pageBg = '#121418';
    p.divider = '#2A2D33';
    p.grid = '#22252B';
    p.success = '#2EC480';
    p.offline = '#6E747A';
    p.mapBg = '#1A1D22';
    p.mapRoad = '#2A2D33';
    p.mapPark = '#1F3A2A';
    p.mapWater = '#193041';
    return p;
  }

  static palette(isDark: boolean): Palette {
    return isDark ? Theme.DARK : Theme.LIGHT;
  }
}
