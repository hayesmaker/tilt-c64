import { describe, expect, it } from 'vitest';
import { fromJson, toJson } from '../src/model/maze';

const row = '20'.repeat(40);
const set = (gates: number, masks: string[]) => ({
  format: 'tilt-mazes', version: 1, demo_maze: 0,
  mazes: [{ name: 't', screen: Array(25).fill(row), hole: [100, 100], start: [100, 100], floor_colour: 8, frame_colour: 8,
    gates: Array.from({ length: gates }, (_, k) => ({ col: 3 + k, row: 5, orientation: 0 })), gate_masks: masks }],
});

describe('gate masks', () => {
  it('keeps 8-gate mazes as 8 digits', () => {
    const j = toJson(fromJson(set(8, ['11111111', '11111110', '00000000', '10101010', '01010101']))) as any;
    expect(j.mazes[0].gate_masks).toEqual(['11111111', '11111110', '00000000', '10101010', '01010101']);
  });
  it('writes one digit per gate above 8, and drops bits of gates that do not exist', () => {
    const j = toJson(fromJson(set(12, ['1111111111111111', '100000000001', '0', '1', '110000000000']))) as any;
    expect(j.mazes[0].gate_masks).toEqual(['111111111111', '100000000001', '000000000000', '000000000001', '110000000000']);
  });
  it('pads short mazes to 8 digits', () => {
    const j = toJson(fromJson(set(3, ['111', '11111111', '0', '1', '10']))) as any;
    expect(j.mazes[0].gate_masks).toEqual(['00000111', '00000111', '00000000', '00000001', '00000010']);
  });
});
