// Automatic wall edges, including 45 degree walls.
//
// Tilt's walls are raised blocks. The wall tops are character $00; the floor
// cells next to a wall hold "edge" characters, which the game redraws for
// every tilt so that the wall's side faces appear. Diagonal walls are half
// wall cells cut along a diagonal ($23 $25 $27 $29 and variants), and where two
// diagonals meet a wall cell gets a small notch ($7C $7E $80 $82).
//
// Every cell has a shape (tile-rules.json, from the character's wall pixels):
//   W wall, F floor, LL / UR / LR / UL half wall (the wall half is in that
//   corner), NB / NT / NL / NR wall with a notch at the bottom / top / ...
// The character a cell needs follows from its shape and its 8 neighbours'
// shapes: tile-rules.json holds every such neighbourhood of the four original
// mazes (no conflicts), mirrored left-right and top-bottom like the game's
// font (made by tools/editor_tile_rules.py). Floor cells next to plain walls
// fall back on EDGE_RULES (the same measurements, plus the wall end pieces
// the originals never use). Other neighbourhoods have no character in the
// game's font (e.g. a corridor one cell wide with walls above and below):
// such cells are "unsupported" and shown as errors.
//
// The editor works with the user's shapes (W, F and the four diagonals);
// notches are worked out from the diagonals around a wall cell.

import { COLS, EDIT, RIM, ROWS, type Maze } from './maze';
import TILES from './tile-rules.json';

export const WALL = 0x00;
export const FLOOR = 0x20;

export type Diagonal = 'LL' | 'UR' | 'LR' | 'UL';
/** shapes the user draws */
export type Shape = 'W' | 'F' | Diagonal;
type Notch = 'NB' | 'NT' | 'NL' | 'NR';
type FullShape = Shape | Notch;

export const DIAGONALS: Diagonal[] = ['LL', 'UR', 'LR', 'UL'];
/** a diagonal's plain character (retile picks the variant its neighbours need) */
const DIAGONAL_CHAR: Record<Diagonal, number> = { LL: 0x23, UR: 0x25, LR: 0x27, UL: 0x29 };
const NOTCH_CHAR: Record<Notch, number> = { NB: 0x7c, NT: 0x7e, NL: 0x80, NR: 0x82 };

const SHAPE = new Map<number, FullShape>(Object.entries(TILES.shapes).map(([k, v]) => [parseInt(k, 16), v as FullShape]));
const RULES = new Map<string, number>(Object.entries(TILES.rules));

// neighbour bits
const U = 1, D = 2, L = 4, R = 8, UL = 16, UR = 32, DL = 64, DR = 128;
const NB: [number, number, number][] = [
  [UL, -1, -1], [U, -1, 0], [UR, -1, 1], [L, 0, -1], [R, 0, 1], [DL, 1, -1], [D, 1, 0], [DR, 1, 1],
];

/** neighbour walls -> floor character (floor cells with only plain walls around) */
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
for (const ch of EDGE_RULES.values()) if (!SHAPE.has(ch)) SHAPE.set(ch, 'F');

/** Rim characters per side: [wall touches the rim, floor variants (first = default)].
 *  The two floor variants only differ while the frame flashes. */
export const RIM_CHARS = {
  top: [0x8d, [0x8e, 0x8c]],
  bottom: [0x93, [0x92, 0x94]],
  left: [0x96, [0x95, 0x97]],
  right: [0x90, [0x8f, 0x91]],
} as const;
const RIM_CODES = new Set<number>([0x6c, ...Object.values(RIM_CHARS).flatMap(([w, f]) => [w, ...f])]);
/** sides of the cell a diagonal's wall half touches */
const WALL_SIDES: Record<Diagonal, (keyof typeof RIM_CHARS)[]> = {
  LL: ['left', 'bottom'], UR: ['right', 'top'], LR: ['right', 'bottom'], UL: ['left', 'top'],
};

export type CellKind = 'wall' | 'floor' | 'diagonal' | 'raw';

/** raw = a character the rules don't know (floor marks, special pieces): kept as it is */
export function kindOf(code: number): CellKind {
  const s = SHAPE.get(code);
  if (s === undefined) return 'raw';
  if (s === 'F') return 'floor';
  return s in DIAGONAL_CHAR ? 'diagonal' : 'wall';
}

export function inEdit(col: number, row: number): boolean {
  return row >= EDIT.top && row <= EDIT.bottom && col >= EDIT.left && col <= EDIT.right;
}

/** The user's shape of a cell: notches count as wall, raw cells and the
 *  frame count as floor / wall. */
function userShape(code: number): Shape {
  const s = SHAPE.get(code);
  if (s === undefined || s === 'F') return 'F';
  return s in DIAGONAL_CHAR ? (s as Diagonal) : 'W';
}

/** shapes of the whole screen (outside the edit area: wall) */
type Grid = Shape[][];
function shapes(m: Maze): Grid {
  return m.screen.map((row, r) => row.map((code, c) => (inEdit(c, r) ? userShape(code) : 'W')));
}
const at = <T extends string>(g: T[][], c: number, r: number, outside: T): T => (inEdit(c, r) ? g[r][c] : outside);

// A diagonal fits a cell when its wall half meets walls and its floor half floor:
// [sides that must be wall, sides that must be floor] as [dcol, drow]
const FIT: Record<Diagonal, [[number, number][], [number, number][]]> = {
  LL: [[[-1, 0], [0, 1]], [[0, -1], [1, 0]]],
  UR: [[[0, -1], [1, 0]], [[-1, 0], [0, 1]]],
  UL: [[[0, -1], [-1, 0]], [[0, 1], [1, 0]]],
  LR: [[[0, 1], [1, 0]], [[0, -1], [-1, 0]]],
};
function fits(g: Grid, c: number, r: number, d: Diagonal): boolean {
  const [wall, floor] = FIT[d];
  return wall.every(([dc, dr]) => at(g, c + dc, r + dr, 'W') !== 'F') && floor.every(([dc, dr]) => at(g, c + dc, r + dr, 'W') === 'F');
}
/** direction of a diagonal's wall line: LL / UR run down-right, UL / LR down-left */
const LINE: Record<Diagonal, number> = { LL: 1, UR: 1, UL: -1, LR: -1 };

/** A diagonal wall ends where it meets the walls: a floor cell next to the end
 *  of a diagonal line that the diagonal fits (a corner of a corridor the line
 *  runs into) becomes part of it, as in the original mazes. Returns the cells
 *  it changed. */
function continueLines(m: Maze, g: Grid): [number, number][] {
  const out: [number, number][] = [];
  for (let again = true; again;) {
    again = false;
    for (let r = EDIT.top; r <= EDIT.bottom; r++)
      for (let c = EDIT.left; c <= EDIT.right; c++) {
        if (g[r][c] !== 'F' || kindOf(m.screen[r][c]) === 'raw') continue;
        const d = DIAGONALS.find((d) => (at(g, c - LINE[d], r - 1, 'W') === d || at(g, c + LINE[d], r + 1, 'W') === d) && fits(g, c, r, d));
        if (!d) continue;
        g[r][c] = d;
        out.push([c, r]);
        again = true;
      }
  }
  return out;
}

/** Wall cells where two diagonals meet get a notch. */
function withNotches(g: Grid): FullShape[][] {
  const s = (c: number, r: number) => at(g, c, r, 'W');
  return g.map((row, r) => row.map((v, c): FullShape => {
    if (v !== 'W' || !inEdit(c, r)) return v;
    if (s(c - 1, r + 1) === 'UL' && s(c + 1, r + 1) === 'UR') return 'NB';
    if (s(c - 1, r - 1) === 'LL' && s(c + 1, r - 1) === 'LR') return 'NT';
    if (s(c + 1, r - 1) === 'UL' && s(c + 1, r + 1) === 'LL') return 'NR';
    if (s(c - 1, r - 1) === 'UR' && s(c - 1, r + 1) === 'LR') return 'NL';
    return v;
  }));
}

/** The character for a cell, or null if the font has none. */
function tileFor(full: FullShape[][], c: number, r: number): number | null {
  const s = (c: number, r: number) => at(full, c, r, 'W');
  const self = s(c, r);
  const around = NB.map(([, dr, dc]) => s(c + dc, r + dr));
  const hit = RULES.get([self, ...around].join(','));
  if (hit !== undefined) return hit;
  if (self === 'W') return WALL;
  if (self === 'F' && around.every((v) => v === 'W' || v === 'F')) {
    const bits = NB.reduce((b, [bit], k) => (around[k] === 'W' ? b | bit : b), 0);
    return EDGE_RULES.get(bits) ?? null;
  }
  return null;
}

/** Characters for the cells (all of them, or those near the rectangle), worked
 *  out from the shapes. want = null: the font has no character for the cell. */
function solve(m: Maze, c0 = EDIT.left, r0 = EDIT.top, c1 = EDIT.right, r1 = EDIT.bottom) {
  const g = shapes(m);
  const moved = continueLines(m, g);
  for (const [c, r] of moved) {
    c0 = Math.min(c0, c); r0 = Math.min(r0, r); c1 = Math.max(c1, c); r1 = Math.max(r1, r);
  }
  const full = withNotches(g);
  const out: { col: number; row: number; want: number | null; shape: FullShape }[] = [];
  // a cell depends on its neighbours' shapes, and a notch on the cells around it
  for (let r = Math.max(EDIT.top, r0 - 2); r <= Math.min(EDIT.bottom, r1 + 2); r++)
    for (let c = Math.max(EDIT.left, c0 - 2); c <= Math.min(EDIT.right, c1 + 2); c++) {
      if (kindOf(m.screen[r][c]) === 'raw') continue;
      out.push({ col: c, row: r, want: tileFor(full, c, r), shape: full[r][c] });
    }
  return out;
}

const plainChar = (s: FullShape) => (s === 'W' ? WALL : s === 'F' ? FLOOR : s in NOTCH_CHAR ? NOTCH_CHAR[s as Notch] : DIAGONAL_CHAR[s as Diagonal]);

/** Recompute the cells in a rectangle (plus two cells around it) and the rim.
 *  Returns the cells that have no character. */
export function retile(m: Maze, c0 = EDIT.left, r0 = EDIT.top, c1 = EDIT.right, r1 = EDIT.bottom): [number, number][] {
  const bad: [number, number][] = [];
  for (const { col, row, want, shape } of solve(m, c0, r0, c1, r1)) {
    if (want !== null) m.screen[row][col] = want;
    else {
      bad.push([col, row]);
      if (userShape(m.screen[row][col]) !== shape && shape !== 'F') m.screen[row][col] = plainChar(shape);
    }
  }
  retileRim(m);
  return bad;
}

/** Board rim: wall-contact character where a wall (or the wall half of a
 *  diagonal) touches it, otherwise keep the current floor variant (or use the
 *  default one). */
export function retileRim(m: Maze) {
  const set = (c: number, r: number, inside: number, side: keyof typeof RIM_CHARS) => {
    const [w, floors] = RIM_CHARS[side];
    const cur = m.screen[r][c];
    const kind = kindOf(inside);
    if (kind === 'raw') return;                     // special piece inside: keep the rim as it is
    const touches = kind === 'wall' || (kind === 'diagonal' && WALL_SIDES[userShape(inside) as Diagonal].includes(side));
    if (touches) m.screen[r][c] = w;
    else if (!(floors as readonly number[]).includes(cur)) m.screen[r][c] = floors[0];
  };
  for (let c = EDIT.left; c <= EDIT.right; c++) {
    set(c, RIM.top, m.screen[EDIT.top][c], 'top');
    set(c, RIM.bottom, m.screen[EDIT.bottom][c], 'bottom');
  }
  for (let r = EDIT.top; r <= EDIT.bottom; r++) {
    set(RIM.left, r, m.screen[r][EDIT.left], 'left');
    set(RIM.right, r, m.screen[r][EDIT.right], 'right');
  }
}

/** Cells whose code differs from what the rules give (or that have no
 *  character): for the validator. Cells next to raw cells are not checked. */
export function edgeProblems(m: Maze): { col: number; row: number; want: number | null }[] {
  const nearRaw = (c: number, r: number) => {
    for (let dr = -1; dr <= 1; dr++)
      for (let dc = -1; dc <= 1; dc++)
        if (inEdit(c + dc, r + dr) && kindOf(m.screen[r + dr][c + dc]) === 'raw') return true;
    return false;
  };
  return solve(m)
    .filter(({ col, row, want }) => want !== m.screen[row][col] && !nearRaw(col, row))
    .map(({ col, row, want }) => ({ col, row, want }));
}

// ---------------------------------------------------------------- diagonal tool

/** Write shapes back as plain characters (retile then picks the variants). */
function store(m: Maze, g: Grid) {
  for (let r = EDIT.top; r <= EDIT.bottom; r++)
    for (let c = EDIT.left; c <= EDIT.right; c++) {
      const code = m.screen[r][c];
      if (kindOf(code) === 'raw' || userShape(code) === g[r][c]) continue;
      m.screen[r][c] = plainChar(g[r][c]);
    }
}

/** The cells of a 45 degree corridor from (c0, r0) towards (c1, r1): the
 *  middle line, snapped to the diagonal. */
export function diagonalPath(c0: number, r0: number, c1: number, r1: number): [number, number][] {
  const n = Math.round((Math.abs(c1 - c0) + Math.abs(r1 - r0)) / 2);
  const dc = c1 >= c0 ? 1 : -1, dr = r1 >= r0 ? 1 : -1;
  return Array.from({ length: n + 1 }, (_, i) => [c0 + i * dc, r0 + i * dr] as [number, number]);
}

/** Carve a diagonal corridor like the original mazes': along the path, the
 *  cell and one on each side become floor, and the cell beyond on each side a
 *  half wall (in walls; in floor only where it fits a corner). Where the path
 *  runs through open floor (inside the corridors it joins) it carves nothing.
 *  The side walls carry on past the ends into corners they fit, so they meet
 *  the walls of the corridors joined. */
export function carveDiagonal(m: Maze, c0: number, r0: number, c1: number, r1: number) {
  let path = diagonalPath(c0, r0, c1, r1);
  if (path.length < 2) return;
  if (path[0][1] > path[path.length - 1][1]) path.reverse();      // top to bottom
  const g = shapes(m);
  const fixed = (c: number, r: number) => !inEdit(c, r) || kindOf(m.screen[r][c]) === 'raw';
  const open = ([c, r]: [number, number]) => [-1, 0, 1].every((k) => at(g, c + k, r, 'W') === 'F');
  while (path.length && open(path[0])) path.shift();
  while (path.length && open(path[path.length - 1])) path.pop();
  if (!path.length) return;
  for (const [c, r] of path)
    for (const k of [-1, 0, 1]) if (!fixed(c + k, r)) g[r][c + k] = 'F';
  const dc = Math.sign(path[path.length - 1][0] - path[0][0]) || 1;
  const sides: [Diagonal, number][] = dc > 0 ? [['LL', -2], ['UR', 2]] : [['UL', -2], ['LR', 2]];
  for (const [d, off] of sides) {
    const line = path.map(([c, r]) => [c + off, r] as [number, number]);
    for (const [c, r] of line)
      if (!fixed(c, r) && (g[r][c] !== 'F' || fits(g, c, r, d))) g[r][c] = d;
    for (const [[c, r], step] of [[line[0], -1], [line[line.length - 1], 1]] as const)
      for (let cc = c + step * dc, rr = r + step; !fixed(cc, rr) && fits(g, cc, rr, d); cc += step * dc, rr += step) g[rr][cc] = d;
  }
  store(m, g);
  retile(m);
}

/** Click with the diagonal tool: wall -> LL -> UR -> LR -> UL -> wall. */
export function cycleSlope(m: Maze, c: number, r: number) {
  if (!inEdit(c, r) || kindOf(m.screen[r][c]) === 'raw') return;
  const order: Shape[] = ['W', 'LL', 'UR', 'LR', 'UL'];
  const s = userShape(m.screen[r][c]);
  m.screen[r][c] = plainChar(order[(order.indexOf(s) + 1) % order.length]);
  retile(m, c, r, c, r);
}

export { COLS, ROWS, RIM_CODES };
