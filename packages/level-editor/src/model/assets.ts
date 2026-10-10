// The game's graphics, captured from the running game by tools/editor_assets.py
// (public/tilt-assets.json): the character set for every perspective shift,
// the sprites, and the tables the game draws gates with.

export interface Assets {
  /** fonts[x][y]: 2K character set for perspective shift x, y (0-8; 4,4 = level) */
  fonts: Uint8Array[][];
  /** sprites $A0-$DF, 64 bytes each */
  sprites: Uint8Array;
  /** gate block cells: gateCells[orientation * 16 + k] = screen offset of cell k */
  gateCells: number[];
  /** gate characters: gateChars[orientation * 64 + frame * 10 + k] */
  gateChars: number[];
  /** gate bar cells: gateBarCells[orientation * 3 + k] = screen offset (colour 15, and tilt gate bars) */
  gateBarCells: number[];
  /** tilt gate bar characters: [0-2] orientation 0, [3-5] the others */
  tiltGateChars: number[];
  bg1: number;
  bg2: number;
  /** exit hole per perspective shift [x][y]: sprite 7's frame (hole_sprite) and
   *  sprite 6's data (that frame masked to the tilt, mask_hole_sprite) */
  holes: { ptr: number; masked: Uint8Array }[][];
  /** hardware fine scroll of the board per perspective shift ($D016 / $D011 bits 0-2) */
  scrollX: number[];
  scrollY: number[];
}

const b64 = (s: string) => Uint8Array.from(atob(s), (c) => c.charCodeAt(0));

export async function loadAssets(url = `${import.meta.env.BASE_URL}tilt-assets.json`): Promise<Assets> {
  const j = await (await fetch(url)).json();
  const fonts = Array.from({ length: 9 }, (_, x) => Array.from({ length: 9 }, (_, y) => b64(j.fonts[`${x},${y}`])));
  const holes = Array.from({ length: 9 }, (_, x) => Array.from({ length: 9 }, (_, y) => {
    const [ptr, masked] = j.holes[`${x},${y}`];
    return { ptr, masked: b64(masked) };
  }));
  return { fonts, holes, sprites: b64(j.sprites), gateCells: j.gate_cells, gateChars: j.gate_chars, gateBarCells: j.gate_bar_cells, tiltGateChars: j.tilt_gate_chars, bg1: j.vic.bg1, bg2: j.vic.bg2, scrollX: j.scroll_x, scrollY: j.scroll_y };
}

/** A tilt gate (mask bit 0): [col offset, row offset, character] of its 3-cell bar,
 *  as draw_tilt_gates draws it (orientation 0 uses bar 0, all others bar 1). */
export function tiltGateBar(a: Assets, orientation: number): [number, number, number][] {
  const i = orientation === 0 ? 0 : 3;
  return [0, 1, 2].map((k) => {
    const off = a.gateBarCells[i + k];
    return [off % 40, Math.floor(off / 40), a.tiltGateChars[i + k]];
  });
}

/** The 3 cells colour_gates paints colour 15 for a gate (every gate, both kinds). */
export function gateColourCells(a: Assets, orientation: number): [number, number][] {
  return [0, 1, 2].map((k) => {
    const off = a.gateBarCells[orientation * 3 + k];
    return [off % 40, Math.floor(off / 40)];
  });
}

/** Cells of a fire gate block: [col offset, row offset, character], closed. */
export function gateBlock(a: Assets, orientation: number, frame = 0): [number, number, number][] {
  const n = orientation < 2 ? 9 : 10;
  const out: [number, number, number][] = [];
  for (let k = 0; k < n; k++) {
    const off = a.gateCells[orientation * 16 + k];
    out.push([off % 40, Math.floor(off / 40), a.gateChars[orientation * 64 + frame * 10 + k]]);
  }
  return out;
}

export const SPRITE = { ball: 0xaa };
