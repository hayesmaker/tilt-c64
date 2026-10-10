// Draws a maze the way the game shows it: multicolour characters from the
// run-time font for a perspective shift, the colours the game puts in colour
// RAM, closed gates, the exit hole and the ball.

import { gateBlock, gateColourCells, SPRITE, tiltGateBar, type Assets } from '../model/assets';
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
  /** gate mask row (level 1-5+): which gates are fire gates and which tilt gates */
  levelRow: number;
  /** draw the exit hole and the ball */
  sprites: boolean;
}

/** Colour RAM as the game fills it: floor colour, and frame colour on the frame
 *  (gates: see renderMaze). */
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
  // gates of this level, as the game draws them: mask bit 1 = fire gate (draw_gates,
  // closed), bit 0 = tilt gate (a 3-cell bar, draw_tilt_gates); colour_gates paints
  // the 3 bar cells of every gate colour 15
  const set = (r: number, c: number, ch: number) => {
    if (r >= 0 && r < ROWS && c >= 0 && c < COLS) screen[r][c] = ch;
  };
  m.gates.forEach((g, k) => {
    const fire = (m.gate_masks[o.levelRow] >> k) & 1;
    for (const [dc, dr, ch] of fire ? gateBlock(a, g.orientation) : tiltGateBar(a, g.orientation)) set(g.row + dr, g.col + dc, ch);
    for (const [dc, dr] of gateColourCells(a, g.orientation)) {
      const r = g.row + dr, c = g.col + dc;
      if (r >= 0 && r < ROWS && c >= 0 && c < COLS) colour[r][c] = GATE_COLOUR;
    }
  });
  // the board is fine scrolled like the game does it ($D016 / $D011); rows 0-1 (status) are not
  const fx = a.scrollX[o.shiftX], fy = a.scrollY[o.shiftY] - 3;
  for (let i = 0; i < px.length; i += 4) {
    const p = PALETTE[BOARD_BG];
    px[i] = p[0]; px[i + 1] = p[1]; px[i + 2] = p[2]; px[i + 3] = 255;
  }
  // foreground pixels of the characters (multicolour %10 / %11, hires 1): sprites
  // with background priority (the exit hole) are hidden behind them
  const fg = new Uint8Array(COLS * 8 * ROWS * 8);
  const put = (x: number, y: number, c: number, front = false) => {
    if (y >= STATUS_ROWS * 8) {
      x += fx;
      y += fy;
      if (x < 0 || x >= COLS * 8 || y < STATUS_ROWS * 8 || y >= ROWS * 8) return;
    }
    if (front) fg[y * COLS * 8 + x] = 1;
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
            const bits = (b >> (6 - 2 * x)) & 3;
            put(c * 8 + 2 * x, r * 8 + y, cols[bits], bits >= 2);
            put(c * 8 + 2 * x + 1, r * 8 + y, cols[bits], bits >= 2);
          }
        } else
          for (let x = 0; x < 8; x++) {
            const on = (b >> (7 - x)) & 1;
            put(c * 8 + x, r * 8 + y, on ? cr : BOARD_BG, !!on);
          }
      }
    }
  if (o.sprites) {
    // exit hole as place_hole_sprites puts it: at hole + tilt level - 4, sprite 7 =
    // the frame for this tilt (colour 0), sprite 6 = its masked copy (colour 15,
    // in front of 7); both behind the walls ($D01B = $C0)
    const hole = a.holes[o.shiftX][o.shiftY];
    const hx = m.hole[0] + o.shiftX - 4, hy = m.hole[1] + o.shiftY - 4;
    const frame = a.sprites.subarray((hole.ptr - 0xa0) * 64, (hole.ptr - 0xa0) * 64 + 64);
    drawSprite(px, frame, hx, hy, 0, fg);
    drawSprite(px, hole.masked, hx, hy, 15, fg);
    const ball = a.sprites.subarray((SPRITE.ball - 0xa0) * 64, (SPRITE.ball - 0xa0) * 64 + 64);
    drawSprite(px, ball, m.start[0], m.start[1], 1);
  }
  ctx.putImageData(img, 0, 0);
}

/** A hires sprite (64 bytes) at sprite coordinates x, y; with `behind`, it is
 *  hidden where the characters have foreground pixels. */
function drawSprite(px: Uint8ClampedArray, data: Uint8Array, x: number, y: number, colour: number, behind?: Uint8Array) {
  const p = PALETTE[colour];
  for (let row = 0; row < 21; row++)
    for (let byte = 0; byte < 3; byte++) {
      const b = data[row * 3 + byte];
      for (let bit = 0; bit < 8; bit++) {
        if (!((b >> (7 - bit)) & 1)) continue;
        const X = x - 24 + byte * 8 + bit, Y = y - 50 + row;
        if (X < 0 || Y < STATUS_ROWS * 8 || X >= COLS * 8 || Y >= ROWS * 8) continue;
        if (behind?.[Y * COLS * 8 + X]) continue;
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
