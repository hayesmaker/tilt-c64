// Emulator overlay: runs a built tilt-mod cartridge in c64-ready's C64Player.
//
// Tilt reads joystick port 2 and a few keys, so the player runs in "mixed"
// input mode: arrow keys + Z / left Ctrl are the joystick in port 2, all other
// keys go to the C64 keyboard (F1 restart, F7 demo, M music, SPACE fire).
// Each run uses a fresh player: the reliable way to start a new cartridge.

import { C64Player, CanvasRenderer } from 'c64-ready';

const BASE = import.meta.env.BASE_URL;
const WASM_URL = `${BASE}c64/c64.wasm`;
const WORKLET_URL = `${BASE}c64/audio-worklet-processor.js`;

export class PlayerOverlay {
  isOpen = false;
  onRebuild: () => void = () => {};
  private root: HTMLElement;
  private canvas: HTMLCanvasElement;
  private status: HTMLElement;
  private player: C64Player | null = null;
  private last: { crt: Uint8Array; title: string } | null = null;
  private generation = 0;
  private muted = false;

  constructor(host: HTMLElement) {
    this.root = document.createElement('div');
    this.root.id = 'play';
    this.root.hidden = true;
    this.root.innerHTML = `
      <div class="play-box">
        <div class="play-top">
          <b id="play-title"></b>
          <span id="play-status" class="muted"></span>
          <span class="spacer"></span>
          <button id="play-rebuild" title="build the current edits and restart">Rebuild</button>
          <button id="play-restart" title="run this build again">Restart</button>
          <button id="play-mute">Sound off</button>
          <button id="play-close" title="back to the editor (Esc)">Close</button>
        </div>
        <canvas id="play-canvas" width="384" height="272"></canvas>
        <div class="play-keys muted">Joystick: arrow keys + Z or left Ctrl (fire) &middot; keyboard keys: F7 demo, F1 restart, M music, SPACE fire</div>
      </div>`;
    host.appendChild(this.root);
    this.canvas = this.root.querySelector('#play-canvas')!;
    this.status = this.root.querySelector('#play-status')!;
    this.root.querySelector('#play-close')!.addEventListener('click', () => this.close());
    this.root.querySelector('#play-restart')!.addEventListener('click', () => this.last && this.run(this.last.crt, this.last.title));
    this.root.querySelector('#play-rebuild')!.addEventListener('click', () => this.onRebuild());
    const mute = this.root.querySelector<HTMLButtonElement>('#play-mute')!;
    mute.addEventListener('click', () => {
      this.muted = !this.muted;
      mute.textContent = this.muted ? 'Sound on' : 'Sound off';
      this.player?.audio.setMuted(this.muted);
    });
    window.addEventListener('keydown', (e) => {
      if (this.isOpen && e.key === 'Escape') this.close();
    });
  }

  setStatus(text: string) {
    this.status.textContent = text;
  }

  async run(crt: Uint8Array, title: string) {
    this.last = { crt, title };
    this.root.querySelector('#play-title')!.textContent = title;
    this.root.hidden = false;
    this.isOpen = true;
    const gen = ++this.generation;
    await this.stop();
    if (gen !== this.generation) return;
    // a fresh canvas each run: the renderer keeps its own drawing loop
    const fresh = this.canvas.cloneNode() as HTMLCanvasElement;
    this.canvas.replaceWith(fresh);
    this.canvas = fresh;
    const renderer = new CanvasRenderer(fresh);
    const player = new C64Player({
      wasmUrl: WASM_URL,
      gameUrl: 'null',
      gameData: crt,
      gameType: 'crt',
      gameSource: title,
      renderer,
      audio: { workletUrl: WORKLET_URL },
    });
    this.player = player;
    try {
      await player.start();
      player.setInputMode('mixed');
      player.setKeyboardJoystickPort(2);
      player.audio.setMuted(this.muted);
      this.setStatus('running');
    } catch (e) {
      this.setStatus(`emulator error: ${(e as Error).message}`);
    }
  }

  private async stop() {
    const p = this.player;
    this.player = null;
    if (p) await p.destroy().catch(() => undefined);
  }

  close() {
    this.generation++;
    this.isOpen = false;
    this.root.hidden = true;
    void this.stop();
  }
}
