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
| `$38CF` | `draw_gates` | `jmp mod_draw_gates`: up to 16 gates |
| `$419D` | `colour_gates` | `jmp mod_colour_gates` (back into its loop) |
| `$67E1` | `draw_tilt_gates` | `jmp mod_draw_tilt_gates` |
| `$6B17` | `find_gate` | `jmp mod_find_gate` |
| `$6B5B` | clear the hit gate's mask bit | `jsr mod_clear_gate_bit` (16 bit mask) |
| `$3B62`, `$3B89` | `ldx gate_mask` | `jsr gate_mask_any` |
| `gate_table,x` (14 places) | 8 gates per slot at `$3991` | `gate_table16,x`: 16 per slot at `$C000+` |
| `$46A5` (again) | `jsr mod_next_maze` | `jsr skip_arm`: fire skips the interstitial |
| `$4667` | `lda wait_counter` (`wait_frames`) | `jsr skip_poll_wait` |
| `$4309` | `lda slide_state` (`slide_tick`) | `jsr skip_poll_slide` |
| `$46E8` | `jsr level_sign_slide_out` | `jsr skip_sign_out` |
| `$6013` | `jmp KERNAL_IRQ_EXIT` (after a colour split) | `jmp ingame_music_irq`: in-game music |
| `$562A` | `jsr title_music_key` | `jsr mod_title_keys`: + F2/F3/F4 sound mode, mode sprite |
| `$566D` | `jsr sid_off` (title ends) | `jsr mod_title_exit`: sprite 7 back as the title had it |
| `$0340-$03FF` | zero (cassette buffer) | the mode sprite's three frames |
| 44 SID stores in the sound effects | `sta/stx/sty SID_...` | `jsr sfx_<op>_<register>`: skipped while MUSIC plays (`src/sfx_mute.asm`) |

### Sound modes and in-game music

On the title screen F2 / F3 / F4 pick the sound during play (F2 and F4 are
SHIFT+F1 and SHIFT+F3 on a C64). A sprite under the logo, on the left, shows
the current mode: its key and a glyph (speaker / note and speaker / notes).
It is sprite 7, which the title doesn't use; its frames are in the cassette
buffer (`$0340-$03FF`), and sprite 7's registers are given back when the title
ends. The mode stays set from game to game.

| Key | Mode | While the ball rolls |
|-----|------|----------------------|
| F2 | SFX ONLY | sound effects only, as in the original |
| F3 | MUSIC + SFX (default) | tune 5 on SID voice 1, the effects on voices 2 and 3 |
| F4 | MUSIC | tune 2 on all three voices; no sound effects while it plays |

M still switches the title music and the level jingle on and off, as in the
original; the sound mode doesn't depend on it.

Tunes 2 and 5 are never played by the original (see `../../docs/music.md`):
tune 2 is a full three-voice tune, tune 5 its melody alone on voice 1, the
voice the sound effects leave free. The music (`src/ingame_music.asm`) runs in
the raster IRQ after the line-105 colour split (done by line ~144; the next
split is at 199) and only while the ball rolls.

* **MUSIC + SFX:** the driver's voice loop is limited to voice 1, so the
  rolling, clunk and gate sounds are untouched. It pauses while voice 1 is
  needed elsewhere: the BACKUP alarm, the power refill tone, the level jingle.
* **MUSIC:** tune 2 starts like the title music (SID cleared, volume 7, no
  filter). While it plays the 44 SID stores of the sound effect routines
  (`src/sfx_mute.asm`) do nothing; the routines still run, so the game plays
  exactly the same (checked in the emulator). When the ball stops rolling the
  voices are silenced and the game's filter and volume set again, so the
  effects between mazes and when a ball is lost sound as usual.

Between mazes the tune carries on where it was; after the level jingle it
starts again.

### Fire skips the interstitial

After the bonus count, the level sign, the maze slide (or the roll back through
the mazes at the end of a level) and the sign slide-out take about 14 seconds
(19 at the end of a level). A new fire press (or SPACE) during that time jumps
straight to the next maze, ready for the ball (`src/skip.asm`). Fire held from
before does not count: it has to be released first. After a skip the game
waits for fire to be released, so the held button doesn't release the ball at
once. The power refill on a new level still plays (about a second). In the
emulator the skipped and unskipped runs end with the same screen, colours,
score, power, level and maze.

### Up to 16 gates

The original has exactly 8 gates per maze: one mask byte per level row and
loops of 8 in every gate routine. `src/gates16.asm` keeps up to 16 gates per
slot, a gate count per slot and 16 bit masks, and replaces those routines (the
table above). With 8 gates it behaves exactly like the original (checked in
the emulator: same screens before and during a gate flip, same `find_gate` /
`gate_hit` results). Redrawing 16 fire gates during a flip ends at raster line
~91 instead of ~52, well inside the frame.

The loader must not live at `$A000-$BFFF`: while a cartridge bank is read
(`$01 = $37`) the BASIC ROM covers that area. `$B000-$BFFF` is still free for
data that is not needed while loading; `$8F00-$9FFF` is free but also hidden
while the cartridge is on.

## Cartridge layout

| Bank | Contents |
|------|----------|
| 0-9 | the original cartridge (loader, game, loading picture) with the modded game |
| 10 | maze directory: `$8000` maze count, `$8001` demo maze, `$8002` "TILTMAZE", `$800A` start level, `$8040 + n*128` record n |
| 11-15 | maze screens, 8 per bank (1K each) |

Record (128 bytes): hole X, hole Y, ball start X (low, high), ball start Y,
floor colour, frame colour, 5 gate masks for gates 1-8, gates 1-8 (screen
address low/high, orientation), screen bank, screen page, 5 gate masks for
gates 9-16, gate count, gates 9-16 (see `src/maze_loader.asm`).

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
* `gates`: 0-16 gates, each at a cell (`col`, `row`, top left of its 3x3 block)
  with an orientation 0-3. The original mazes have 8.
* `gate_masks`: 5 rows (levels 1, 2, 3, 4, 5+), one bit per gate, last gate
  first (8 digits for up to 8 gates, else one per gate):
  the kind of each gate on that level. 1 = fire gate (a bar that fire flips
  open for a moment), 0 = tilt gate (a bar that only opens while the board is
  tilting against it). Every gate is always there, as one kind or the other.
