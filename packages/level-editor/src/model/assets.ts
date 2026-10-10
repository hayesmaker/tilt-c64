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
  bg1: number;
  bg2: number;
  /** hardware fine scroll of the board per perspective shift ($D016 / $D011 bits 0-2) */
  scrollX: number[];
  scrollY: number[];
}

const b64 = (s: string) => Uint8Array.from(atob(s), (c) => c.charCodeAt(0));

export async function loadAssets(url = `${import.meta.env.BASE_URL}tilt-assets.json`): Promise<Assets> {
  const j = await (await fetch(url)).json();
  const fonts = Array.from({ length: 9 }, (_, x) => Array.from({ length: 9 }, (_, y) => b64(j.fonts[`${x},${y}`])));
  return { fonts, sprites: b64(j.sprites), gateCells: j.gate_cells, gateChars: j.gate_chars, bg1: j.vic.bg1, bg2: j.vic.bg2, scrollX: j.scroll_x, scrollY: j.scroll_y };
}

/** Cells of a gate block: [col offset, row offset, character] for the closed gate. */
export function gateBlock(a: Assets, orientation: number, frame = 0): [number, number, number][] {
  const n = orientation < 2 ? 9 : 10;
  const out: [number, number, number][] = [];
  for (let k = 0; k < n; k++) {
    const off = a.gateCells[orientation * 16 + k];
    out.push([off % 40, Math.floor(off / 40), a.gateChars[orientation * 64 + frame * 10 + k]]);
  }
  return out;
}

export const SPRITE = { ball: 0xaa, holeTop: 0xde, holeBottom: 0xbc };
