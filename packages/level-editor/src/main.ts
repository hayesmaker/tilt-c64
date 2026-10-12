// Tilt maze editor: edits a maze set (packages/tilt-mod/tools/mazes.py format),
// builds a tilt-mod cartridge through the server API and plays it in c64-ready.

import './style.css';
import { inEdit, kindOf, retile, WALL, FLOOR } from './model/autotile';
import { loadAssets, type Assets } from './model/assets';
import { cellToSprite, cloneMaze, COLS, EDIT, fromJson, MAX_GATES, MAX_MAZES, ROWS, toJson, type Maze, type MazeSet } from './model/maze';
import { checkSet, gateSize, type Problem } from './model/validate';
import { charImage, hexColour, renderMaze, type RenderOptions } from './editor/render';
import { PlayerOverlay } from './editor/player';

type Tool = 'wall' | 'floor' | 'char' | 'pick' | 'copy' | 'paste' | 'gate' | 'hole' | 'start';
const STORE = 'tilt-editor.project';
const COLOUR_NAMES = ['black', 'white', 'red', 'cyan', 'purple', 'green', 'blue', 'yellow'];

const $ = <T extends HTMLElement = HTMLElement>(s: string) => document.querySelector<T>(s)!;

let assets: Assets;
let original: MazeSet;
let set: MazeSet;
let cur = 0;
let tool: Tool = 'wall';
let charCode = 0x00;
let gateSel = 0;
let clip: number[][] | null = null;
let undoStack: string[] = [];
let redoStack: string[] = [];
let problems: Problem[] = [];
let drag: { c: number; r: number; c2: number; r2: number } | null = null;
let painting = false;
let hover: [number, number] | null = null;
const view: RenderOptions & { grid: boolean; zoom: number; fit: boolean } = { shiftX: 4, shiftY: 8, levelRow: 0, sprites: true, grid: true, zoom: 3, fit: true };

/** "fit" zoom: the largest zoom (1-4, in half steps) at which the board fits the centre column */
function fitZoom() {
  if (!view.fit) return;
  const w = document.querySelector<HTMLElement>('#centre')!.clientWidth - 4;
  view.zoom = Math.max(1, Math.min(4, Math.floor((w / (COLS * 8)) * 2) / 2));
}
const player = new PlayerOverlay(document.body);
let lastCrtUrl = '';

const maze = () => set.mazes[cur];

// ---------------------------------------------------------------- state
function snapshot() {
  undoStack.push(JSON.stringify(set));
  if (undoStack.length > 200) undoStack.shift();
  redoStack = [];
}
function restore(json: string) {
  set = JSON.parse(json);
  cur = Math.min(cur, set.mazes.length - 1);
  changed(false);
}
function changed(save = true) {
  problems = checkSet(set);
  if (save) {
    try {
      localStorage.setItem(STORE, JSON.stringify(toJson(set)));
    } catch { /* storage full or blocked: the project is still in memory */ }
  }
  refreshAll();
}

function setStatus(t: string) {
  $('#status').textContent = t;
}

// ---------------------------------------------------------------- drawing
const board = $<HTMLCanvasElement>('#board');
const overlay = $<HTMLCanvasElement>('#overlay');
const bctx = board.getContext('2d')!;
const octx = overlay.getContext('2d')!;

/** pixel offset of the board's characters (the game's fine scroll) */
const offset = () => [assets.scrollX[view.shiftX], assets.scrollY[view.shiftY] - 3];

function drawBoard() {
  renderMaze(bctx, assets, maze(), view);
  drawOverlay();
}

function drawOverlay() {
  fitZoom();
  const z = view.zoom;
  for (const c of [board, overlay]) {
    c.style.width = `${COLS * 8 * z}px`;
    c.style.height = `${ROWS * 8 * z}px`;
  }
  overlay.width = Math.round(COLS * 8 * z);
  overlay.height = Math.round(ROWS * 8 * z);
  const [fx, fy] = offset();
  const cellRect = (c: number, r: number, w = 1, h = 1): [number, number, number, number] =>
    [(c * 8 + fx) * z, (r * 8 + fy) * z, w * 8 * z, h * 8 * z];
  octx.clearRect(0, 0, overlay.width, overlay.height);
  if (view.grid) {
    octx.strokeStyle = 'rgba(255,255,255,0.12)';
    octx.lineWidth = 1;
    for (let c = EDIT.left; c <= EDIT.right + 1; c++) {
      const x = (c * 8 + fx) * z + 0.5;
      octx.beginPath(); octx.moveTo(x, (EDIT.top * 8 + fy) * z); octx.lineTo(x, ((EDIT.bottom + 1) * 8 + fy) * z); octx.stroke();
    }
    for (let r = EDIT.top; r <= EDIT.bottom + 1; r++) {
      const y = (r * 8 + fy) * z + 0.5;
      octx.beginPath(); octx.moveTo((EDIT.left * 8 + fx) * z, y); octx.lineTo(((EDIT.right + 1) * 8 + fx) * z, y); octx.stroke();
    }
  }
  const m = maze();
  // gates: fire gates yellow, tilt gates cyan (dashed); the selected one bold
  m.gates.forEach((g, k) => {
    const fire = (m.gate_masks[view.levelRow] >> k) & 1;
    const s = gateSize(g.orientation);
    octx.setLineDash(fire ? [] : [4, 3]);
    const rgb = fire ? '255,224,102' : '102,217,255';
    octx.strokeStyle = `rgba(${rgb},${k === gateSel ? 1 : 0.5})`;
    octx.lineWidth = k === gateSel ? 2 : 1;
    octx.strokeRect(...cellRect(g.col, g.row, s, s));
    octx.fillStyle = octx.strokeStyle;
    octx.font = `${4 * z}px sans-serif`;
    octx.fillText(String(k + 1), (g.col * 8 + fx) * z + 2, (g.row * 8 + fy) * z + 4 * z);
  });
  octx.setLineDash([]);
  // problems of this maze
  for (const p of problems)
    if (p.maze === cur && p.col !== undefined && p.row !== undefined) {
      octx.strokeStyle = p.level === 'error' ? '#ff4040' : '#ffc040';
      octx.lineWidth = 2;
      const [x, y, w, h] = cellRect(p.col, p.row);
      octx.beginPath(); octx.moveTo(x + 2, y + 2); octx.lineTo(x + w - 2, y + h - 2);
      octx.moveTo(x + w - 2, y + 2); octx.lineTo(x + 2, y + h - 2); octx.stroke();
    }
  if (drag) {
    const c0 = Math.min(drag.c, drag.c2), r0 = Math.min(drag.r, drag.r2);
    octx.strokeStyle = '#66d9ff';
    octx.lineWidth = 2;
    octx.strokeRect(...cellRect(c0, r0, Math.abs(drag.c2 - drag.c) + 1, Math.abs(drag.r2 - drag.r) + 1));
  }
  if (hover) {
    let [w, h] = [1, 1];
    if (tool === 'paste' && clip) [w, h] = [clip[0].length, clip.length];
    if (tool === 'gate' && m.gates[gateSel]) w = h = gateSize(m.gates[gateSel].orientation);
    octx.strokeStyle = 'rgba(102,217,255,0.8)';
    octx.lineWidth = 1;
    octx.strokeRect(...cellRect(hover[0], hover[1], w, h));
  }
}

// ---------------------------------------------------------------- editing
function cellAt(e: MouseEvent): [number, number] {
  const b = overlay.getBoundingClientRect();
  const [fx, fy] = offset();
  const x = (e.clientX - b.left) / view.zoom - fx, y = (e.clientY - b.top) / view.zoom - fy;
  return [Math.floor(x / 8), Math.floor(y / 8)];
}

function paint(c: number, r: number) {
  const m = maze();
  if (!inEdit(c, r)) return;
  const old = m.screen[r][c];
  if (tool === 'wall') m.screen[r][c] = WALL;
  else if (tool === 'floor') {
    if (kindOf(old) === 'floor') return;
    m.screen[r][c] = FLOOR;
  } else if (tool === 'char') m.screen[r][c] = charCode;
  if (m.screen[r][c] === old) return;
  retile(m, c, r, c, r);
}

function onDown(e: MouseEvent) {
  if (e.button !== 0) return;
  const [c, r] = cellAt(e);
  const m = maze();
  if (tool === 'pick') {
    if (r >= 0 && r < ROWS && c >= 0 && c < COLS) {
      charCode = m.screen[r][c];
      setTool('char');
    }
    return;
  }
  if (tool === 'copy') {
    drag = { c, r, c2: c, r2: r };
    drawOverlay();
    return;
  }
  snapshot();
  if (tool === 'paste') {
    if (!clip) return;
    clip.forEach((row, dr) => row.forEach((v, dc) => {
      if (inEdit(c + dc, r + dr)) m.screen[r + dr][c + dc] = v;
    }));
    retile(m, c, r, c + clip[0].length - 1, r + clip.length - 1);
  } else if (tool === 'gate') {
    if (!m.gates[gateSel]) return;
    m.gates[gateSel] = { ...m.gates[gateSel], col: c, row: r };
  } else if (tool === 'hole' || tool === 'start') {
    const [x, y] = cellToSprite(c, r);
    // centre the 24 x 21 sprite on the cell
    m[tool] = [Math.max(0, x - 8), Math.max(0, y - 6)];
  } else {
    painting = true;
    paint(c, r);
  }
  changed();
}

function onMove(e: MouseEvent) {
  const [c, r] = cellAt(e);
  hover = [c, r];
  const inside = r >= 0 && r < ROWS && c >= 0 && c < COLS;
  $('#cell-info').textContent = inside
    ? `cell ${c}, ${r}  char $${maze().screen[r][c].toString(16).padStart(2, '0')}  ${inEdit(c, r) ? '' : '(frame)'}`
    : '';
  if (drag) {
    drag.c2 = c;
    drag.r2 = r;
  } else if (painting) {
    paint(c, r);
    problems = checkSet(set);
    drawBoard();
    return;
  }
  drawOverlay();
}

function onUp() {
  if (drag) {
    const c0 = Math.max(0, Math.min(drag.c, drag.c2)), c1 = Math.min(COLS - 1, Math.max(drag.c, drag.c2));
    const r0 = Math.max(0, Math.min(drag.r, drag.r2)), r1 = Math.min(ROWS - 1, Math.max(drag.r, drag.r2));
    clip = maze().screen.slice(r0, r1 + 1).map((row) => row.slice(c0, c1 + 1));
    drag = null;
    setStatus(`copied ${c1 - c0 + 1} x ${r1 - r0 + 1} cells: use Paste (V)`);
    setTool('paste');
  }
  if (painting) {
    painting = false;
    changed();
  }
}

function rotateGate() {
  const g = maze().gates[gateSel];
  if (!g) return;
  snapshot();
  g.orientation = (g.orientation + 1) & 3;
  changed();
}

/** New gate: a fire gate on every level, on the first 3x3 patch of floor that
 *  no other gate covers (else the top left of the board). */
function addGate() {
  const m = maze();
  if (m.gates.length >= MAX_GATES) return setStatus(`a maze has at most ${MAX_GATES} gates`);
  const covered = (c: number, r: number) => m.gates.some((g) => {
    const s = gateSize(g.orientation);
    return c >= g.col && c < g.col + s && r >= g.row && r < g.row + s;
  });
  let at = { col: EDIT.left, row: EDIT.top };
  search: for (let r = EDIT.top; r <= EDIT.bottom - 2; r++)
    for (let c = EDIT.left; c <= EDIT.right - 2; c++) {
      let ok = true;
      for (let dr = 0; dr < 3 && ok; dr++)
        for (let dc = 0; dc < 3 && ok; dc++)
          ok = kindOf(m.screen[r + dr][c + dc]) === 'floor' && !covered(c + dc, r + dr);
      if (ok) { at = { col: c, row: r }; break search; }
    }
  snapshot();
  const k = m.gates.length;
  m.gates.push({ ...at, orientation: 0 });
  m.gate_masks = m.gate_masks.map((mask) => mask | (1 << k));
  gateSel = k;
  setTool('gate');
  changed();
}

/** Remove the selected gate; the gates after it move down one number. */
function removeGate() {
  const m = maze();
  const k = gateSel;
  if (!m.gates[k]) return;
  snapshot();
  m.gates.splice(k, 1);
  m.gate_masks = m.gate_masks.map((mask) => (mask & ((1 << k) - 1)) | ((mask >> (k + 1)) << k));
  gateSel = Math.max(0, Math.min(k, m.gates.length - 1));
  changed();
}

// ---------------------------------------------------------------- panels
function colourOptions(sel: HTMLSelectElement, value: number) {
  sel.innerHTML = '';
  for (let v = 8; v <= 15; v++) {
    const o = document.createElement('option');
    o.value = String(v);
    o.textContent = `${COLOUR_NAMES[v & 7]} (${v})`;
    o.style.background = hexColour(v & 7);
    sel.appendChild(o);
  }
  sel.value = String(value);
}

function refreshMazes() {
  const list = $('#maze-list');
  list.innerHTML = '';
  set.mazes.forEach((m, i) => {
    const li = document.createElement('li');
    const errs = problems.filter((p) => p.maze === i && p.level === 'error').length;
    li.innerHTML = `<span class="n">${i + 1}</span><span></span>${errs ? `<span class="bad" title="${errs} errors">!</span>` : ''}`;
    li.children[1].textContent = m.name || '(no name)';
    if (i === cur) li.className = 'sel';
    li.onclick = () => {
      cur = i;
      gateSel = 0;
      refreshAll();
    };
    list.appendChild(li);
  });
  $('#maze-count').textContent = `${set.mazes.length} / ${MAX_MAZES}`;
  const demo = $<HTMLSelectElement>('#m-demo');
  demo.innerHTML = set.mazes.map((m, i) => `<option value="${i}">${i + 1}. ${escapeHtml(m.name)}</option>`).join('');
  demo.value = String(set.demo_maze);
}

function refreshInspector() {
  const m = maze();
  $<HTMLInputElement>('#i-name').value = m.name;
  colourOptions($<HTMLSelectElement>('#i-floor'), m.floor_colour);
  colourOptions($<HTMLSelectElement>('#i-frame'), m.frame_colour);
  gateSel = Math.max(0, Math.min(gateSel, m.gates.length - 1));
  $('#g-count').textContent = `${m.gates.length} / ${MAX_GATES}`;
  $<HTMLButtonElement>('#g-add').disabled = m.gates.length >= MAX_GATES;
  $<HTMLButtonElement>('#g-del').disabled = !m.gates.length;
  const tb = $('#gates tbody');
  tb.innerHTML = '';
  m.gates.forEach((g, k) => {
    const tr = document.createElement('tr');
    if (k === gateSel) tr.className = 'sel';
    const masks = m.gate_masks.map((mask, row) =>
      `<td><input type="checkbox" data-row="${row}" ${(mask >> k) & 1 ? 'checked' : ''} title="gate ${k + 1} on level ${row === 4 ? '5+' : row + 1}: ticked = fire gate, unticked = tilt gate"></td>`).join('');
    tr.innerHTML = `<td><input type="radio" name="gsel" ${k === gateSel ? 'checked' : ''}></td><td>${k + 1}</td>
      <td>${g.col},${g.row}</td>
      <td><select>${['vertical', 'horizontal', 'diagonal A', 'diagonal B'].map((n, o) => `<option value="${o}" ${o === g.orientation ? 'selected' : ''}>${n}</option>`).join('')}</select></td>${masks}`;
    tr.querySelector<HTMLInputElement>('input[type=radio]')!.onchange = () => {
      gateSel = k;
      setTool('gate');
      refreshAll();
    };
    tr.querySelector('select')!.onchange = (e) => {
      snapshot();
      g.orientation = Number((e.target as HTMLSelectElement).value);
      changed();
    };
    tr.querySelectorAll<HTMLInputElement>('input[type=checkbox]').forEach((cb) => (cb.onchange = () => {
      snapshot();
      const row = Number(cb.dataset.row);
      m.gate_masks[row] = cb.checked ? m.gate_masks[row] | (1 << k) : m.gate_masks[row] & ~(1 << k);
      changed();
    }));
    tb.appendChild(tr);
  });
  const ul = $('#problems');
  ul.innerHTML = '';
  const shown = problems.filter((p) => p.maze === cur || p.maze === -1);
  for (const p of shown.slice(0, 100)) {
    const li = document.createElement('li');
    li.className = p.level;
    li.textContent = p.col !== undefined ? `${p.text} (cell ${p.col}, ${p.row})` : p.text;
    ul.appendChild(li);
  }
  const all = problems.filter((p) => p.level === 'error').length;
  $('#p-count').textContent = `${shown.length} here, ${all} errors in the set`;
}

function refreshAll() {
  refreshMazes();
  refreshInspector();
  drawBoard();
  $<HTMLButtonElement>('#undo').disabled = !undoStack.length;
  $<HTMLButtonElement>('#redo').disabled = !redoStack.length;
}

function setTool(t: Tool) {
  tool = t;
  document.querySelectorAll<HTMLButtonElement>('#tools [data-tool]').forEach((b) => b.classList.toggle('active', b.dataset.tool === t));
  $('#palette').hidden = !(t === 'char' || t === 'pick');
  $('#char-code').textContent = `$${charCode.toString(16).padStart(2, '0')}`;
  drawPalette();
  drawOverlay();
}

function drawPalette() {
  const c = $<HTMLCanvasElement>('#palette-canvas');
  const ctx = c.getContext('2d')!;
  for (let code = 0; code < 256; code++) ctx.putImageData(charImage(assets, code, maze().floor_colour), (code % 32) * 8, Math.floor(code / 32) * 8);
  ctx.strokeStyle = '#66d9ff';
  ctx.strokeRect((charCode % 32) * 8 + 0.5, Math.floor(charCode / 32) * 8 + 0.5, 7, 7);
}

const escapeHtml = (s: string) => s.replace(/[&<>"]/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[ch]!);

// ---------------------------------------------------------------- mazes
function emptyMaze(): Maze {
  const m = cloneMaze(original.mazes[0]);
  m.name = 'Empty board';
  for (let r = EDIT.top; r <= EDIT.bottom; r++) for (let c = EDIT.left; c <= EDIT.right; c++) m.screen[r][c] = FLOOR;
  m.gate_masks = m.gate_masks.map(() => 0);
  retile(m);
  return m;
}

function addMaze(m: Maze) {
  if (set.mazes.length >= MAX_MAZES) return setStatus(`a set holds at most ${MAX_MAZES} mazes`);
  snapshot();
  set.mazes.push(m);
  cur = set.mazes.length - 1;
  changed();
}

// ---------------------------------------------------------------- files, build
function download(name: string, data: BlobPart, type: string) {
  const a = document.createElement('a');
  a.href = URL.createObjectURL(new Blob([data], { type }));
  a.download = name;
  a.click();
  setTimeout(() => URL.revokeObjectURL(a.href), 1000);
}

/** Build and play: the whole set, or only the current maze (a one-maze set that
 *  starts on the level shown under "Level"). */
let lastPlay: 'set' | 'maze' = 'set';
async function buildAndPlay(what: 'set' | 'maze' = lastPlay) {
  lastPlay = what;
  const one = what === 'maze';
  const errs = problems.filter((p) => p.level === 'error' && (!one || p.maze === cur));
  if (errs.length && !confirm(`${errs.length} errors in ${one ? 'this maze' : 'the set'} (see Problems). Build anyway?`)) return;
  const body = one
    ? { ...toJson({ ...set, demo_maze: 0, mazes: [maze()] }), start_level: view.levelRow }
    : toJson(set);
  const title = one ? `${maze().name}, level ${view.levelRow === 4 ? 5 : view.levelRow + 1}` : `Tilt: ${set.mazes.length} mazes`;
  setStatus('building…');
  for (const b of ['#b-play', '#b-play-one']) $<HTMLButtonElement>(b).disabled = true;
  try {
    const res = await fetch('/api/build', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
    const r = await res.json();
    if (!res.ok || !r.ok) {
      setStatus(`build failed: ${r.error ?? res.statusText}`);
      $('#log').textContent = r.log ?? r.error ?? '';
      $('#log-box').hidden = false;
      return;
    }
    const crt = new Uint8Array(await (await fetch(`/api/builds/${r.id}/tilt-mod.crt`)).arrayBuffer());
    if (lastCrtUrl) URL.revokeObjectURL(lastCrtUrl);
    lastCrtUrl = URL.createObjectURL(new Blob([crt], { type: 'application/octet-stream' }));
    const a = $<HTMLAnchorElement>('#b-crt');
    a.href = lastCrtUrl;
    a.hidden = false;
    setStatus(`built in ${(r.ms / 1000).toFixed(1)} s: ${one ? '1 maze' : `${set.mazes.length} mazes`}, ${(crt.length / 1024).toFixed(0)}K cartridge`);
    void player.run(crt, title);
  } catch (e) {
    setStatus(`build failed: ${(e as Error).message}`);
  } finally {
    for (const b of ['#b-play', '#b-play-one']) $<HTMLButtonElement>(b).disabled = false;
  }
}

// ---------------------------------------------------------------- events
function wire() {
  overlay.addEventListener('mousedown', onDown);
  overlay.addEventListener('mousemove', onMove);
  overlay.addEventListener('mouseleave', () => { hover = null; drawOverlay(); });
  window.addEventListener('mouseup', onUp);
  overlay.addEventListener('contextmenu', (e) => {
    e.preventDefault();
    if (tool === 'gate') rotateGate();
  });
  document.querySelectorAll<HTMLButtonElement>('#tools [data-tool]').forEach((b) => (b.onclick = () => setTool(b.dataset.tool as Tool)));
  $('#g-add').onclick = addGate;
  $('#g-del').onclick = removeGate;
  $('#undo').onclick = () => { if (undoStack.length) { redoStack.push(JSON.stringify(set)); restore(undoStack.pop()!); } };
  $('#redo').onclick = () => { if (redoStack.length) { undoStack.push(JSON.stringify(set)); restore(redoStack.pop()!); } };
  $<HTMLCanvasElement>('#palette-canvas').onclick = (e) => {
    const c = e.target as HTMLCanvasElement; // offsetX/Y and clientWidth/Height: inside the border
    const col = Math.floor((e.offsetX * 32) / c.clientWidth), row = Math.floor((e.offsetY * 8) / c.clientHeight);
    if (col < 0 || col > 31 || row < 0 || row > 7) return;
    charCode = row * 32 + col;
    setTool('char');
  };
  const viewInput = (id: string, f: (v: string, el: HTMLInputElement) => void) =>
    $<HTMLInputElement>(id).addEventListener('input', (e) => { const el = e.target as HTMLInputElement; f(el.value, el); drawBoard(); });
  viewInput('#v-tx', (v) => (view.shiftX = Number(v)));
  viewInput('#v-ty', (v) => (view.shiftY = Number(v)));
  viewInput('#v-level', (v) => (view.levelRow = Number(v)));
  viewInput('#v-grid', (_, el) => (view.grid = el.checked));
  viewInput('#v-sprites', (_, el) => (view.sprites = el.checked));
  $<HTMLSelectElement>('#v-zoom').addEventListener('change', (e) => {
    const v = (e.target as HTMLSelectElement).value;
    view.fit = v === 'fit';
    if (!view.fit) view.zoom = Number(v);
    drawBoard();
  });
  window.addEventListener('resize', () => drawOverlay());
  $('#i-name').onchange = (e) => { snapshot(); maze().name = (e.target as HTMLInputElement).value; changed(); };
  $('#i-floor').onchange = (e) => { snapshot(); maze().floor_colour = Number((e.target as HTMLSelectElement).value); changed(); };
  $('#i-frame').onchange = (e) => { snapshot(); maze().frame_colour = Number((e.target as HTMLSelectElement).value); changed(); };
  $('#m-add').onclick = () => {
    const t = $<HTMLSelectElement>('#m-template').value;
    addMaze(t === 'empty' ? emptyMaze() : { ...cloneMaze(original.mazes[Number(t)]), name: `Copy of original ${Number(t) + 1}` });
  };
  $('#m-dup').onclick = () => addMaze({ ...cloneMaze(maze()), name: `${maze().name} (copy)` });
  $('#m-del').onclick = () => {
    if (set.mazes.length <= 1) return setStatus('a set needs at least one maze');
    if (!confirm(`Delete "${maze().name}"?`)) return;
    snapshot();
    set.mazes.splice(cur, 1);
    if (set.demo_maze >= set.mazes.length) set.demo_maze = set.mazes.length - 1;
    else if (set.demo_maze > cur) set.demo_maze--;
    cur = Math.min(cur, set.mazes.length - 1);
    changed();
  };
  const move = (d: number) => {
    const j = cur + d;
    if (j < 0 || j >= set.mazes.length) return;
    snapshot();
    [set.mazes[cur], set.mazes[j]] = [set.mazes[j], set.mazes[cur]];
    if (set.demo_maze === cur) set.demo_maze = j;
    else if (set.demo_maze === j) set.demo_maze = cur;
    cur = j;
    changed();
  };
  $('#m-up').onclick = () => move(-1);
  $('#m-down').onclick = () => move(1);
  $('#m-demo').onchange = (e) => { snapshot(); set.demo_maze = Number((e.target as HTMLSelectElement).value); changed(); };
  $('#f-new').onclick = () => {
    if (!confirm('Start a new set from the four original mazes? (Save first if you want to keep this one.)')) return;
    snapshot();
    set = JSON.parse(JSON.stringify(original));
    cur = 0;
    changed();
  };
  $('#f-save').onclick = () => download('tilt-mazes.json', JSON.stringify(toJson(set), null, 1) + '\n', 'application/json');
  $('#f-open').onclick = () => $<HTMLInputElement>('#f-file').click();
  $<HTMLInputElement>('#f-file').onchange = async (e) => {
    const f = (e.target as HTMLInputElement).files?.[0];
    if (!f) return;
    try {
      const s = fromJson(JSON.parse(await f.text()));
      snapshot();
      set = s;
      cur = 0;
      changed();
      setStatus(`opened ${f.name}`);
    } catch (err) {
      setStatus(`cannot open ${f.name}: ${(err as Error).message}`);
    }
    (e.target as HTMLInputElement).value = '';
  };
  $('#b-play').onclick = () => void buildAndPlay('set');
  $('#b-play-one').onclick = () => void buildAndPlay('maze');
  player.onRebuild = () => void buildAndPlay();
  $('#log-close').onclick = () => ($('#log-box').hidden = true);
  window.addEventListener('keydown', (e) => {
    if (player.isOpen || (e.target as HTMLElement).matches('input[type=text], select')) return;
    const k = e.key.toLowerCase();
    if ((e.ctrlKey || e.metaKey) && k === 'z') { e.preventDefault(); $('#undo').click(); return; }
    if ((e.ctrlKey || e.metaKey) && k === 'y') { e.preventDefault(); $('#redo').click(); return; }
    if ((e.ctrlKey || e.metaKey) && k === 'enter') { e.preventDefault(); void buildAndPlay(e.shiftKey ? 'maze' : 'set'); return; }
    if (e.ctrlKey || e.metaKey || e.altKey) return;
    const keys: Record<string, Tool> = { w: 'wall', f: 'floor', c: 'char', i: 'pick', x: 'copy', v: 'paste', g: 'gate', h: 'hole', s: 'start' };
    if (keys[k]) setTool(keys[k]);
    else if (k === 'r') rotateGate();
    else if (k >= '1' && k <= '9' && tool === 'gate' && Number(k) <= maze().gates.length) { gateSel = Number(k) - 1; refreshAll(); }
  });
}

// ---------------------------------------------------------------- start
async function start() {
  assets = await loadAssets();
  original = fromJson(await (await fetch('/api/original')).json());
  set = JSON.parse(JSON.stringify(original));
  try {
    const saved = localStorage.getItem(STORE);
    if (saved) set = fromJson(JSON.parse(saved));
  } catch { /* no saved project */ }
  wire();
  setTool('wall');
  changed(false);
  setStatus(`${set.mazes.length} mazes`);
}

void start();
