import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { edgeProblems, retileRim } from '../src/model/autotile';
import { cloneMaze, fromJson, toJson } from '../src/model/maze';

const original = fromJson(JSON.parse(readFileSync(new URL('../../tilt-mod/mazes/original.json', import.meta.url), 'utf8')));

describe('auto edges', () => {
  it('reproduce every orthogonal floor cell of the original mazes', () => {
    for (const m of original.mazes) expect(edgeProblems(m)).toEqual([]);
  });
  it('leave the original rims alone', () => {
    for (const m of original.mazes) {
      const c = cloneMaze(m);
      retileRim(c);
      expect(c.screen).toEqual(m.screen);
    }
  });
});

describe('maze set JSON', () => {
  it('round-trips the original file', () => {
    const j = JSON.parse(readFileSync(new URL('../../tilt-mod/mazes/original.json', import.meta.url), 'utf8'));
    expect(toJson(fromJson(j))).toEqual(j);
  });
});

import { checkSet } from '../src/model/validate';
describe('validator', () => {
  it('finds no errors in the original set', () => {
    expect(checkSet(original).filter((p) => p.level === 'error')).toEqual([]);
  });
});
