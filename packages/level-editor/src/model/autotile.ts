// Automatic wall edges.
//
// Tilt's walls are raised blocks. The wall tops are character $00; the floor
// cells next to a wall hold "edge" characters, which the game redraws for
// every tilt so that the wall's side faces appear. Which edge character a
// floor cell needs depends only on which of its 8 neighbours are walls. The
// table below was measured on the four original mazes (every orthogonal floor
// cell, ~1000 cells, no conflicts), plus four the game builds but never uses. Other neighbourhoods have no character in
// the game's font (e.g. a corridor one cell wide with walls above and below):
// such cells are "unsupported" and shown as errors.

import { COLS, EDIT, RIM, ROWS, type Maze } from './maze';

export const WALL = 0x00;
export const FLOOR = 0x20;

// neighbour bits
const U = 1, D = 2, L = 4, R = 8, UL = 16, UR = 32, DL = 64, DR = 128;
const NB: [number, number, number][] = [
  [U, -1, 0], [D, 1, 0], [L, 0, -1], [R, 0, 1], [UL, -1, -1], [UR, -1, 1], [DL, 1, -1], [DR, 1, 1],
];

/** neighbour walls -> floor character */
export const EDGE_RULES = new Map<number, number>([
  [0, 0x20],
  [DL, 0x04], [DR, 0x10], [UL, 0x08], [UR, 0x0c],
  [D | DL, 0x03], [D | DR, 0x01], [L | DL, 0x05], [L | UL, 0x07],
  [R | DR, 0x0f], [R | UR, 0x0d], [U | UL, 0x09], [U | UR, 0x0b],
  [D | DL | DR, 0x02], [L | UL | DL, 0x06], [R | UR | DR, 0x0e], [U | UL | UR, 0x0a],
  [D | L | UL | DL | DR, 0x14], [D | R | UR | DL | DR, 0x13],
  [U | L | UL | UR | DL, 0x11], [U | R | UL | UR | DR, 0x12],
  // the end of a wall one cell thick: the game builds these (both end pieces
  // ANDed, $20A8-$20C7 in build_wall_chars) but the original mazes never use them
  [D, 0x15], [L, 0x16], [U, 0x17], [R, 0x18],
]);
/** floor characters the auto-edge rules make (and may replace) */
export const AUTO_FLOOR = new Set(EDGE_RULES.values());

/** Rim characters per side: [wall touches the rim, floor variants (first = default)].
 *  The two floor variants only differ while the frame flashes. */
export const RIM_CHARS = {
  top: [0x8d, [0x8e, 0x8c]],
  bottom: [0x93, [0x92, 0x94]],
  left: [0x96, [0x95, 0x97]],
  right: [0x90, [0x8f, 0x91]],
} as const;
const RIM_CODES = new Set<number>([0x6c, ...Object.values(RIM_CHARS).flatMap(([w, f]) => [w, ...f])]);

/** Other characters of the original mazes that count as walls for the edge
 *  rules (diagonal wall pieces etc. are kept as they are, see isWallCode). */
export const RAW_WALLS = new Set<number>([0x00]);

export type CellKind = 'wall' | 'floor' | 'raw';

export function kindOf(code: number): CellKind {
  if (code === WALL) return 'wall';
  if (AUTO_FLOOR.has(code)) return 'floor';
  return 'raw';
}

export function inEdit(col: number, row: number): boolean {
  return row >= EDIT.top && row <= EDIT.bottom && col >= EDIT.left && col <= EDIT.right;
}

/** Wall for the edge rules: wall tops, and the rim / frame around the edit area. */
export function isWallAt(m: Maze, col: number, row: number): boolean {
  if (!inEdit(col, row)) return true;
  return RAW_WALLS.has(m.screen[row][col]);
}

export function neighbourBits(m: Maze, col: number, row: number): number {
  let bits = 0;
  for (const [b, dr, dc] of NB) if (isWallAt(m, col + dc, row + dr)) bits |= b;
  return bits;
}

/** The edge character for a floor cell, or null if the font has none. */
export function edgeFor(m: Maze, col: number, row: number): number | null {
  return EDGE_RULES.get(neighbourBits(m, col, row)) ?? null;
}

/** Recompute the floor cells in a rectangle (plus one cell around it) and the
 *  rim next to it. Returns the cells that have no edge character. */
export function retile(m: Maze, c0 = EDIT.left, r0 = EDIT.top, c1 = EDIT.right, r1 = EDIT.bottom): [number, number][] {
  const bad: [number, number][] = [];
  for (let r = Math.max(EDIT.top, r0 - 1); r <= Math.min(EDIT.bottom, r1 + 1); r++)
    for (let c = Math.max(EDIT.left, c0 - 1); c <= Math.min(EDIT.right, c1 + 1); c++) {
      if (kindOf(m.screen[r][c]) !== 'floor') continue;
      const e = edgeFor(m, c, r);
      if (e === null) bad.push([c, r]);
      else m.screen[r][c] = e;
    }
  retileRim(m);
  return bad;
}

/** Board rim: wall-contact character where a wall touches it, otherwise keep the
 *  current floor variant (or use the default one). */
export function retileRim(m: Maze) {
  const set = (c: number, r: number, inside: number, [w, floors]: readonly [number, readonly number[]]) => {
    const cur = m.screen[r][c];
    if (kindOf(inside) === 'raw') return;           // special piece inside: keep the rim as it is
    if (RAW_WALLS.has(inside)) m.screen[r][c] = w;
    else if (!floors.includes(cur)) m.screen[r][c] = floors[0];
  };
  for (let c = EDIT.left; c <= EDIT.right; c++) {
    set(c, RIM.top, m.screen[EDIT.top][c], RIM_CHARS.top);
    set(c, RIM.bottom, m.screen[EDIT.bottom][c], RIM_CHARS.bottom);
  }
  for (let r = EDIT.top; r <= EDIT.bottom; r++) {
    set(RIM.left, r, m.screen[r][EDIT.left], RIM_CHARS.left);
    set(RIM.right, r, m.screen[r][EDIT.right], RIM_CHARS.right);
  }
}

/** Floor cells whose code differs from what the rules give (or that have no
 *  edge character): for the validator. Raw cells and cells next to raw cells
 *  are not checked. */
export function edgeProblems(m: Maze): { col: number; row: number; want: number | null }[] {
  const out: { col: number; row: number; want: number | null }[] = [];
  for (let r = EDIT.top; r <= EDIT.bottom; r++)
    for (let c = EDIT.left; c <= EDIT.right; c++) {
      if (kindOf(m.screen[r][c]) !== 'floor') continue;
      let nearRaw = false;
      for (let dr = -1; dr <= 1; dr++)
        for (let dc = -1; dc <= 1; dc++)
          if (inEdit(c + dc, r + dr) && kindOf(m.screen[r + dr][c + dc]) === 'raw') nearRaw = true;
      if (nearRaw) continue;
      const want = edgeFor(m, c, r);
      if (want !== m.screen[r][c]) out.push({ col: c, row: r, want });
    }
  return out;
}

export { COLS, ROWS, RIM_CODES };
