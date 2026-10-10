// Paths shared by the dev server (vite.config.ts) and server/index.ts.

import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';

const HERE = import.meta.dirname;
export const PACKAGE_DIR = join(HERE, '..');
/** The tilt-mod package: its source and tools build every cartridge (override: TILT_MOD_DIR). */
export const MOD_DIR = process.env.TILT_MOD_DIR ?? join(PACKAGE_DIR, '../tilt-mod');
/** The maze set new projects start from: the four original mazes. */
export const ORIGINAL = join(MOD_DIR, 'mazes/original.json');
export const DIST_DIR = join(PACKAGE_DIR, 'dist');

/** c64-ready's runtime assets, served by the editor under /c64/. */
const c64public = dirname(createRequire(import.meta.url).resolve('c64-ready/wasm')); // .../public/c64.wasm
export const C64_ASSETS: Record<string, { path: string; type: string }> = {
  'c64.wasm': { path: join(c64public, 'c64.wasm'), type: 'application/wasm' },
  'audio-worklet-processor.js': { path: join(c64public, 'audio-worklet-processor.js'), type: 'text/javascript' },
};
