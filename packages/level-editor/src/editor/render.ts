// Draws a maze the way the game shows it: multicolour characters from the
// run-time font for a perspective shift, the colours the game puts in colour
// RAM, closed gates, the exit hole and the ball.

import { gateBlock, SPRITE, type Assets } from '../model/assets';
import { COLS, ROWS, type Maze } from '../model/maze';

export const PALETTE: [number, number, number][] = [
  [0, 0, 0], [255, 255, 255], [136, 57, 50], [103, 182, 189], [139, 63, 150], [85, 160, 73], [64, 49, 141], [191, 206, 114],
  [139, 84, 41], [87, 66, 0], [184, 105, 98], [80, 80, 80], [120, 120, 120], [148, 224, 137], [120, 105, 196], [159, 159, 159],
];
export const hexColour = (c: number) => '#' + PALETTE[c & 15].map((v) => v.toString(16).padStart(2, '0')).join('');

/** $D021 behind the board (the raster IRQ sets it per band; the board is brown) */
const BOARD_BG = 9;
const STATUS_ROWS = 2;
const GATE_COLOUR = 15;

export interface RenderOptions {
  shiftX: number;
  shiftY: number;
  /** gate mask row (level 1-5+) whose gates are drawn */
  levelRow: number;
  /** draw gates that are off on this level as an outline (overlay) */
  sprites: boolean;
}

/** Colour RAM as the game fills it: floor colour, frame colour on the frame,
 *  colour 15 on gates. */
export function colourMap(m: Maze): number[][] {
  const col = Array.from({ length: ROWS }, () => new Array(COLS).fill(m.floor_colour));
  for (let r = 2; r < ROWS; r++) col[r][0] = col[r][38] = m.frame_colour;
  for (let c = 0; c <= 38; c++) col[2][c] = col[24][c] = m.frame_colour;
  return col;
}

export function renderMaze(ctx: CanvasRenderingContext2D, a: Assets, m: Maze, o: RenderOptions) {
  const img = ctx.createImageData(COLS * 8, ROWS * 8);
  const px = img.data;
  const font = a.fonts[o.shiftX][o.shiftY];
  const screen = m.screen.map((r) => r.slice());
  const colour = colourMap(m);
  // closed gates of this level, drawn over the screen like draw_gates does
  m.gates.forEach((g, k) => {
    if (!((m.gate_masks[o.levelRow] >> k) & 1)) return;
    for (const [dc, dr, ch] of gateBlock(a, g.orientation)) {
      const r = g.row + dr, c = g.col + dc;
      if (r >= 0 && r < ROWS && c >= 0 && c < COLS) {
        screen[r][c] = ch;
        colour[r][c] = GATE_COLOUR;
      }
    }
  });
  // the board is fine scrolled like the game does it ($D016 / $D011); rows 0-1 (status) are not
  const fx = a.scrollX[o.shiftX], fy = a.scrollY[o.shiftY] - 3;
  for (let i = 0; i < px.length; i += 4) {
    const p = PALETTE[BOARD_BG];
    px[i] = p[0]; px[i + 1] = p[1]; px[i + 2] = p[2]; px[i + 3] = 255;
  }
  const put = (x: number, y: number, c: number) => {
    if (y >= STATUS_ROWS * 8) {
      x += fx;
      y += fy;
      if (x < 0 || x >= COLS * 8 || y < STATUS_ROWS * 8 || y >= ROWS * 8) return;
    }
    const i = (y * COLS * 8 + x) * 4;
    const p = PALETTE[c & 15];
    px[i] = p[0]; px[i + 1] = p[1]; px[i + 2] = p[2]; px[i + 3] = 255;
  };
  for (let r = 0; r < ROWS; r++)
    for (let c = 0; c < COLS; c++) {
      const ch = screen[r][c];
      const cr = colour[r][c];
      for (let y = 0; y < 8; y++) {
        const b = font[ch * 8 + y];
        if (r < STATUS_ROWS) {                       // under the status line: not part of the maze
          for (let x = 0; x < 8; x++) put(c * 8 + x, r * 8 + y, 0);
          continue;
        }
        if (cr & 8) {                                // multicolour
          const cols = [BOARD_BG, a.bg1, 15, cr & 7];
          for (let x = 0; x < 4; x++) {
            const v = cols[(b >> (6 - 2 * x)) & 3];
            put(c * 8 + 2 * x, r * 8 + y, v);
            put(c * 8 + 2 * x + 1, r * 8 + y, v);
          }
        } else
          for (let x = 0; x < 8; x++) put(c * 8 + x, r * 8 + y, (b >> (7 - x)) & 1 ? cr : BOARD_BG);
      }
    }
  if (o.sprites) {
    const sx = o.shiftX - 4, sy = o.shiftY - 4;
    drawSprite(px, a, SPRITE.holeBottom, m.hole[0] + sx, m.hole[1] + sy, 0);
    drawSprite(px, a, SPRITE.holeTop, m.hole[0] + sx, m.hole[1] + sy, 15);
    drawSprite(px, a, SPRITE.ball, m.start[0], m.start[1], 1);
  }
  ctx.putImageData(img, 0, 0);
}

/** A hires sprite at sprite coordinates x, y. */
function drawSprite(px: Uint8ClampedArray, a: Assets, ptr: number, x: number, y: number, colour: number) {
  const base = (ptr - 0xa0) * 64;
  const p = PALETTE[colour];
  for (let row = 0; row < 21; row++)
    for (let byte = 0; byte < 3; byte++) {
      const b = a.sprites[base + row * 3 + byte];
      for (let bit = 0; bit < 8; bit++) {
        if (!((b >> (7 - bit)) & 1)) continue;
        const X = x - 24 + byte * 8 + bit, Y = y - 50 + row;
        if (X < 0 || Y < STATUS_ROWS * 8 || X >= COLS * 8 || Y >= ROWS * 8) continue;
        const i = (Y * COLS * 8 + X) * 4;
        px[i] = p[0]; px[i + 1] = p[1]; px[i + 2] = p[2]; px[i + 3] = 255;
      }
    }
}

/** One character as a small canvas image (for the character palette). */
export function charImage(a: Assets, code: number, colour: number, shiftX = 4, shiftY = 8): ImageData {
  const img = new ImageData(8, 8);
  const font = a.fonts[shiftX][shiftY];
  const cols = [BOARD_BG, a.bg1, 15, colour & 7];
  for (let y = 0; y < 8; y++) {
    const b = font[code * 8 + y];
    for (let x = 0; x < 4; x++) {
      const p = PALETTE[cols[(b >> (6 - 2 * x)) & 3]];
      for (const xx of [2 * x, 2 * x + 1]) {
        const i = (y * 8 + xx) * 4;
        img.data[i] = p[0]; img.data[i + 1] = p[1]; img.data[i + 2] = p[2]; img.data[i + 3] = 255;
      }
    }
  }
  return img;
}
