# tilt-mod — Tilt with more mazes

A modded Tilt cartridge that plays a **maze set** of 1 to 40 mazes instead of
the original four. The mazes live in extra cartridge banks and are copied into
RAM when they are needed, so the number of mazes is not limited by the C64's
memory.

```
./build.sh                         # original 4 mazes -> build/tilt-mod.crt
./build.sh mymazes.json            # your maze set
./build.sh mymazes.json run        # ... and start it in VICE (flatpak x64sc)
python3 tools/test_mod.py mymazes.json 8    # emulator test: plays 8 mazes by cheating the ball into the hole
```

`src/` is a hand-edited copy of the disassembly (`../../src`); the main
`tools/regen.sh` never touches it.

## How it works

A level is maze 0 .. N-1 of the set; then the level goes up and the mazes
repeat with a faster, bigger ball and the next row of gate masks, like the
original. The demo plays `demo_maze` (its recording was made for original
maze 2, so keep that maze there).

The game's per-maze tables have four entries, indexed by `maze`. The mod keeps
that code and uses the four entries as a ring of slots: maze n is played in
slot n & 3. `src/maze_loader.asm` (at `$C000`, free RAM) loads a maze when it is
due: it switches the cartridge on for a moment, copies the 1K screen to
`$A000 + slot * $400` and the maze's record into the slot's table entries,
and switches the cartridge off again.

Changes to the original code (all the same size, marked `tilt-mod:` in
`src/tilt.asm`, so no other address moves):

| Address | Was | Now |
|---------|-----|-----|
| `$0822` | `lda #$01` (assume tampered) | `lda #$00`: the code checksum no longer matters |
| `$421F` | `dex / sec / sbc hole_x_by_maze,x` | `jsr prev_slot_sbc`: previous maze is slot (maze-1)&3 |
| `$4537` | `sty maze` | `jsr mod_init_mazes`: first maze (or the demo maze) |
| `$46A5` | `inc maze` | `jsr mod_next_maze`: next maze, or end of the level |
| `$46AE`, `$653B` | `lda maze / cmp #4` | `lda level_end / cmp #1` |
| `$4850` | `inc level` | `jsr mod_restart_mazes`: level + 1, maze 0 |

The loader must not live at `$A000-$BFFF`: while a cartridge bank is read
(`$01 = $37`) the BASIC ROM covers that area. `$B000-$BFFF` is still free for
data that is not needed while loading; `$8F00-$9FFF` is free but also hidden
while the cartridge is on.

## Cartridge layout

| Bank | Contents |
|------|----------|
| 0-9 | the original cartridge (loader, game, loading picture) with the modded game |
| 10 | maze directory: `$8000` maze count, `$8001` demo maze, `$8002` "TILTMAZE", `$800A` start level, `$8040 + n*64` record n |
| 11-15 | maze screens, 8 per bank (1K each) |

Record (64 bytes): hole X, hole Y, ball start X (low, high), ball start Y,
floor colour, frame colour, 5 gate masks, 8 gates (screen address low/high,
orientation), screen bank, screen page.

At most 16 banks (128K): 40 mazes.

## Maze set files

`mazes/original.json` holds the four original mazes (`python3 tools/mazes.py
export` writes it from the game image). The format is described at the top of
`tools/mazes.py`. In short, per maze:

* `screen`: 25 rows of 40 screen codes (hex). Rows 0-1 are under the status
  line. The wall edge / corner characters are part of the screen data (the
  editor places them automatically).
* `hole`, `start`: exit hole and ball start in sprite coordinates.
* `floor_colour`, `frame_colour`: 8-15 (multicolour; shown as value AND 7).
* `gates`: 8 gates, each at a cell (`col`, `row`, top left of its 3x3 block)
  with an orientation 0-3.
* `gate_masks`: 5 rows (levels 1, 2, 3, 4, 5+), each 8 bits for gates 8..1:
  which gates are there on that level.
