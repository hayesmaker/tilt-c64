// Tilt maze sets: the JSON format read by packages/tilt-mod/tools/mazes.py.

export const COLS = 40;
export const ROWS = 25;
/** Cells the player edits: rows 5-21, columns 3-35. Around them is the board
 *  rim (row 4, row 22, column 2, column 36), worked out from the cells inside,
 *  and the fixed frame. Rows 0-1 are under the status line. */
export const EDIT = { top: 5, bottom: 21, left: 3, right: 35 };
export const RIM = { top: 4, bottom: 22, left: 2, right: 36 };
export const MAX_MAZES = 40;
export const GATES = 8;
/** gate mask rows: levels 1, 2, 3, 4, 5+ */
export const MASK_ROWS = 5;

export interface Gate {
  col: number;
  row: number;
  /** 0-3: picture and size of the gate block (see gateCells) */
  orientation: number;
}

export interface Maze {
  name: string;
  /** 25 rows of 40 screen codes */
  screen: number[][];
  /** exit hole, sprite coordinates */
  hole: [number, number];
  /** ball start, sprite coordinates */
  start: [number, number];
  /** 8-15 (multicolour), shown as value & 7 */
  floor_colour: number;
  frame_colour: number;
  gates: Gate[];
  /** 5 rows x 8 bits: gate k is there on that level row if bit k is set */
  gate_masks: number[];
}

export interface MazeSet {
  format: 'tilt-mazes';
  version: 1;
  demo_maze: number;
  mazes: Maze[];
}

/** File JSON (screen rows as hex strings, masks as bit strings) -> model. */
export function fromJson(j: any): MazeSet {
  if (j?.format !== 'tilt-mazes') throw new Error('not a Tilt maze set (format "tilt-mazes")');
  const mazes: Maze[] = j.mazes.map((z: any) => ({
    name: String(z.name ?? ''),
    screen: z.screen.map((r: string) => Array.from({ length: COLS }, (_, i) => parseInt(r.slice(i * 2, i * 2 + 2), 16))),
    hole: [z.hole[0], z.hole[1]],
    start: [z.start[0], z.start[1]],
    floor_colour: z.floor_colour,
    frame_colour: z.frame_colour,
    gates: z.gates.map((g: any) => ({ col: g.col, row: g.row, orientation: g.orientation })),
    gate_masks: z.gate_masks.map((m: string) => parseInt(m, 2)),
  }));
  return { format: 'tilt-mazes', version: 1, demo_maze: j.demo_maze ?? 0, mazes };
}

export function toJson(s: MazeSet): object {
  return {
    format: 'tilt-mazes',
    version: 1,
    demo_maze: s.demo_maze,
    mazes: s.mazes.map((z) => ({
      name: z.name,
      screen: z.screen.map((r) => r.map((v) => v.toString(16).padStart(2, '0')).join('')),
      hole: z.hole,
      start: z.start,
      floor_colour: z.floor_colour,
      frame_colour: z.frame_colour,
      gates: z.gates,
      gate_masks: z.gate_masks.map((m) => m.toString(2).padStart(8, '0')),
    })),
  };
}

export function cloneMaze(z: Maze): Maze {
  return JSON.parse(JSON.stringify(z));
}

/** Sprite coordinates of the top left of a cell (the game's sprites are
 *  placed 24 pixels left and 50 lines above the screen origin). */
export const cellToSprite = (col: number, row: number): [number, number] => [col * 8 + 24, row * 8 + 50];
export const spriteToCell = (x: number, y: number): [number, number] => [Math.floor((x - 24) / 8), Math.floor((y - 50) / 8)];
