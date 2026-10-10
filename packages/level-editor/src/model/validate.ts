// Problems in a maze set, shown in the editor. "error": tools/mazes.py would
// refuse it or the game would break; "warning": playable but probably not
// what was meant.

import { edgeProblems, inEdit, WALL } from './autotile';
import { GATES, MASK_ROWS, MAX_MAZES, spriteToCell, type Maze, type MazeSet } from './maze';

export interface Problem {
  level: 'error' | 'warning';
  maze: number;
  text: string;
  col?: number;
  row?: number;
}

/** Gate blocks: orientations 0-1 are straight (3x3 cells), 2-3 diagonal (4x4). */
export const gateSize = (orientation: number) => (orientation < 2 ? 3 : 4);

/** The cell under the middle of a sprite at sprite coordinates x, y. */
export const spriteCell = (x: number, y: number) => spriteToCell(x + 12, y + 10);

export function checkMaze(m: Maze, i: number): Problem[] {
  const p: Problem[] = [];
  const add = (level: Problem['level'], text: string, col?: number, row?: number) => p.push({ level, maze: i, text, col, row });
  for (const e of edgeProblems(m))
    add('error', e.want === null
      ? 'floor cell has no edge character for its walls (e.g. a 1-cell corridor between two walls)'
      : 'floor edge does not match its walls', e.col, e.row);
  if (m.gates.length !== GATES) add('error', `needs exactly ${GATES} gates`);
  if (m.gate_masks.length !== MASK_ROWS) add('error', `needs ${MASK_ROWS} gate mask rows`);
  m.gates.forEach((g, k) => {
    const size = gateSize(g.orientation);
    if (!inEdit(g.col, g.row) || !inEdit(g.col + size - 1, g.row + size - 1)) add('error', `gate ${k + 1} is not inside the board`, g.col, g.row);
  });
  for (const k of ['floor_colour', 'frame_colour'] as const)
    if (m[k] < 8 || m[k] > 15) add('error', `${k.replace('_', ' ')} must be 8-15`);
  const [hc, hr] = spriteCell(...m.hole);
  if (!inEdit(hc, hr)) add('error', 'exit hole is not on the board', hc, hr);
  else if (m.screen[hr][hc] === WALL) add('warning', 'exit hole is on a wall', hc, hr);
  const [sc, sr] = spriteCell(...m.start);
  if (!inEdit(sc, sr)) add('error', 'ball start is not on the board', sc, sr);
  else if (m.screen[sr][sc] === WALL) add('warning', 'ball starts on a wall: it is lost at once', sc, sr);
  if (m.start[0] < 0 || m.start[0] > 511 || m.start[1] < 0 || m.start[1] > 255 || m.hole.some((v) => v < 0 || v > 255))
    add('error', 'hole / start position out of range');
  return p;
}

export function checkSet(s: MazeSet): Problem[] {
  const p: Problem[] = [];
  if (s.mazes.length < 1 || s.mazes.length > MAX_MAZES)
    p.push({ level: 'error', maze: -1, text: `a set needs 1-${MAX_MAZES} mazes (has ${s.mazes.length})` });
  if (s.demo_maze < 0 || s.demo_maze >= s.mazes.length)
    p.push({ level: 'error', maze: -1, text: 'the demo maze is not in the set' });
  s.mazes.forEach((m, i) => p.push(...checkMaze(m, i)));
  return p;
}
