import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { carveDiagonal, cycleSlope, edgeProblems, FLOOR, retile, WALL } from '../src/model/autotile';
import { cloneMaze, EDIT, fromJson, type Maze } from '../src/model/maze';

const original = fromJson(JSON.parse(readFileSync(new URL('../../tilt-mod/mazes/original.json', import.meta.url), 'utf8')));

/** A board of solid wall with floor rectangles [c0, r0, c1, r1] (corridors). */
function board(...rects: [number, number, number, number][]): Maze {
  const m = cloneMaze(original.mazes[0]);
  for (let r = EDIT.top; r <= EDIT.bottom; r++) for (let c = EDIT.left; c <= EDIT.right; c++) m.screen[r][c] = WALL;
  for (const [c0, r0, c1, r1] of rects) for (let r = r0; r <= r1; r++) for (let c = c0; c <= c1; c++) m.screen[r][c] = FLOOR;
  retile(m);
  return m;
}
const hex = (m: Maze, r: number, c0: number, c1: number) => m.screen[r].slice(c0, c1 + 1).map((v) => v.toString(16).padStart(2, '0')).join(' ');

describe('automatic tiles', () => {
  it('leave the original mazes as they are, diagonals and all', () => {
    for (const m of original.mazes) {
      const c = cloneMaze(m);
      expect(retile(c)).toEqual([]);
      expect(c.screen).toEqual(m.screen);
    }
  });
});

describe('diagonal tool', () => {
  // corridors 3 cells wide, joined by a diagonal dragged from one to the other
  const cases: [string, [number, number, number, number][], [number, number, number, number]][] = [
    ['horizontal \\ horizontal', [[4, 6, 30, 8], [17, 18, 34, 20]], [6, 7, 18, 19]],
    ['horizontal / horizontal', [[4, 6, 30, 8], [4, 18, 17, 20]], [28, 7, 16, 19]],
    ['vertical \\ vertical', [[4, 5, 6, 12], [10, 16, 12, 21]], [5, 11, 11, 17]],
    ['vertical / vertical', [[28, 5, 30, 12], [22, 16, 24, 21]], [29, 11, 23, 17]],
    ['horizontal \\ vertical', [[4, 6, 30, 8], [17, 14, 19, 21]], [10, 7, 18, 15]],
    ['vertical \\ horizontal', [[4, 5, 6, 12], [4, 18, 34, 20]], [5, 11, 13, 19]],
    ['into a room', [[4, 5, 34, 9], [4, 15, 34, 21]], [10, 7, 20, 17]],
    ['dragged bottom to top', [[4, 6, 30, 8], [17, 18, 34, 20]], [18, 19, 6, 7]],
  ];
  for (const [name, rects, [c0, r0, c1, r1]] of cases)
    it(`joins ${name} with characters the game has`, () => {
      const m = board(...rects);
      carveDiagonal(m, c0, r0, c1, r1);
      expect(edgeProblems(m)).toEqual([]);
    });

  it('makes the corridor of the original mazes', () => {
    const m = board([4, 6, 30, 8], [17, 18, 34, 20]);
    carveDiagonal(m, 6, 7, 18, 19);
    expect(hex(m, 12, 8, 14)).toBe('00 23 24 20 26 25 00');
    expect(hex(m, 9, 5, 11)).toBe('00 23 24 20 4c 25 00');       // the join of original maze 3, row 8
  });

  it('cycles the slope of a cell on a click', () => {
    const m = board([4, 6, 30, 8]);
    cycleSlope(m, 10, 9);
    expect(m.screen[9][10]).not.toBe(WALL);
    for (let k = 0; k < 4; k++) cycleSlope(m, 10, 9);
    expect(m.screen[9][10]).toBe(WALL);
  });
});
