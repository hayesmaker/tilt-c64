# Tilt maze editor

A browser editor for Tilt maze sets. It edits the maze set format of
[`../tilt-mod`](../tilt-mod/README.md), builds a tilt-mod cartridge (up to 40
mazes) through a small Node API that runs KickAssembler, and plays it in
c64-ready inside the page.

```
npm install
npm run dev          # http://localhost:5181 (Vite + build API)
npm test             # auto-edge rules and validator against the original mazes
npm run serve        # production build + standalone server
```

Needs Java + KickAssembler (`KICKASS=/path/to/KickAss.jar`, default
`/opt/KickAss.jar`) and Python 3 for builds.

## Using it

* **Mazes** (left): a level plays them in order, then the next level repeats
  them with a faster, bigger ball and the next row of gate ticks. Add a copy of
  an original maze or an empty board, duplicate, delete, reorder. The demo maze
  should stay original maze 3: the demo's recorded moves were made for it.
* **Board** (centre), drawn with the game's own characters:
  * **Wall** / **Floor** (W / F): paint wall tops or floor. The wall edge
    characters around them are placed automatically.
  * **Diagonal** (D): drag at 45 degrees from one corridor to another to carve
    a sloping corridor like the original mazes': one cell of floor plus a
    shaded cell on each side, with half-wall cells along both walls. The part
    of the drag inside open floor carves nothing, and the sloping walls run on
    into the corners of the corridors they join, so the joins get the game's
    own junction characters and shade correctly at every tilt. A click (no
    drag) cycles one cell through wall and the four half walls, to touch up.
    Two diagonals that meet in a point (a V or an X) have no characters in the
    game's font yet and show red crosses.
  * **Char** (C) paints any character as it is (pick one in the palette, or
    with **Pick**, I). Use it for special pieces; auto edges leave them alone.
  * **Copy** / **Paste** (X / V): drag a block, then stamp it.
  * **Gate** (G): pick a gate in the inspector (or 1-9), click to move it,
    R or right-click to rotate. **Hole** (H) and **Start** (S) place the exit
    hole and the ball.
  * Tilt X / Y shows the board at another tilt; "Level" shows the gates as
    they are on that level (and is where Play this maze starts).
* **Inspector** (right): name, colours, gates and the problem list. Every gate
  is always there; per level it is a **fire gate** (ticked, drawn yellow: fire
  flips it open for a moment) or a **tilt gate** (unticked, cyan: a bar that
  only opens while the board is tilting against it, so passing it needs a
  little wobble). **Add gate** / **Remove gate** change the number of gates:
  0-16 per maze (the original mazes have 8). Red crosses on the board mark cells
  the game has no character for, most often a corridor one cell wide between
  two walls: make corridors at least two cells wide.
* **Build & play** (Ctrl+Enter) builds the cartridge and runs it: arrow keys
  and Z / left Ctrl are the joystick in port 2, F7 demo, F1 restart, M music.
  **Play this maze** (Ctrl+Shift+Enter) builds a cartridge with only the
  current maze, starting on the level chosen under "Level", to test
  it quickly (Rebuild in the player repeats the last kind of build).
  **Download .crt** saves the cartridge for VICE or real hardware.
* The set is kept in the browser (local storage); **Save** downloads it as
  JSON, **Open** loads one. `../tilt-mod/build.sh myset.json` builds the
  same cartridge from the command line.

## How it works

| Path | |
|------|-|
| `src/model/maze.ts` | maze set types, JSON in/out |
| `src/model/autotile.ts` | automatic tiles: cell shapes (wall, floor, four half walls) -> character, the diagonal tool |
| `src/model/tile-rules.json` | the rules: every neighbourhood of the original mazes, mirrored; made by `../../tools/editor_tile_rules.py` |
| `src/model/validate.ts` | problems shown in the editor |
| `src/editor/render.ts` | draws a maze like the VIC: multicolour characters, colour RAM, fine scroll, gates, sprites |
| `src/editor/player.ts` | c64-ready player overlay |
| `server/api.ts` | `/api/original`, `/api/build` (runs `tilt-mod/build.sh` in a temporary copy), `/api/builds/<id>/<file>` |
| `public/tilt-assets.json` | the game's run-time fonts for every tilt, sprites, gate tables: made by `../../tools/editor_assets.py` |
