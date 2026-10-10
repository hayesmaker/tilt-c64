# Tilt (C64) — commented disassembly for KickAssembler

Tilt, Codemasters 1990. Program by Steve Walters.

This folder holds a complete, re-assemblable disassembly of the C64 game, made
from the STATMAT 2023 cartridge conversion (`bin/Tilt.crt`, Magic Desk format).
`./build.sh` assembles it with KickAssembler and checks that the results are
**byte-identical** to the originals: the 63K game image and the whole `.crt`.

```
./build.sh          # assemble -> build/tilt.prg (game image) and build/tilt.crt, and verify
./build.sh run      # same, then start the cartridge in x64sc (VICE flatpak) with the labels loaded
```

`KICKASS=/path/to/KickAss.jar ./build.sh` overrides the default `/opt/KickAss.jar`.

## Files

| Path | Contents |
|------|----------|
| `src/tilt.asm` | The game: memory layout, all code, tables, sprites, music (generated, see below) |
| `src/cart.asm` | The cartridge: CRT header, STATMAT loader (bank 0), picture viewer (bank 9), packing of the game image into banks 0-7 (hand-written) |
| `src/bin/pic_*.bin` | The original Tilt loading picture (hires bitmap + screen RAM) |
| `src/bin/*.bin` | Leftover RAM contents the game never uses, kept for the byte-identical build |
| `bin/Tilt.crt` | The original cartridge |
| `docs/memory_map.md` | Run-time memory map, free RAM, raster IRQ, sprite use, the checksum |
| `docs/mazes/` | The four mazes, rendered from the source data (`tools/mazeview.py`) |
| `tools/` | The scripts used to make the disassembly (see below) |

## The cartridge

`bin/Tilt.crt` is a Magic Desk cartridge (CRT type 19): ten 8K banks at
`$8000`, selected by writing to `$DE00` (bit 7 switches the cartridge off).
It is a snapshot-style conversion of the disk version:

| Bank | Contents |
|------|----------|
| 0 `$8000-$8333` | STATMAT loader: KERNAL-style reset, picture viewer, copy banks to RAM, start |
| 0 `$8334-$9FFF` | game image `$0334-$1FFF` |
| 1-7 | game image `$2000-$FFFF` (bank n -> RAM n * `$2000`) |
| 8 | loading picture, hires bitmap |
| 9 `$8000-$83E7` | loading picture, screen RAM |
| 9 `$8800-$8B85` | STATMAT picture viewer (shows the picture until fire / a key / 10 s) |

The game image is RAM exactly as the original disk loader left it after
loading the `PIC` and `TILT` files: that loader is still in screen memory and
the cartridge starts the game through its last two instructions at `$0460`
(screen off, `JMP $080D`).

`src/cart.asm` uses `LoadBinary("../build/tilt.prg")` to put the assembled
game image into the banks, so a changed `src/tilt.asm` goes straight into
`build/tilt.crt`.

## How the game works (short tour)

* **The board.** Each maze is a 40x25 character screen (`$A000-$AFFF`, four
  mazes). Light checkered characters are wall tops, the brown floor is the
  background. The character set at `$2000` is built at run time.
* **Tilting.** The joystick (port 2) or the keys tilt the board. The tilt
  angles (`tilt_angle_x/y`) ease toward the joystick direction; their 0-8
  "perspective shift" moves the whole board with the hardware fine scroll
  (raster IRQ step 3) and selects rebuilt edge characters (`build_wall_chars`
  and friends), so the walls get a lit side face that changes with the tilt.
* **The ball** rolls with the tilt: `steer_ball` moves the velocity toward a
  target speed for the tilt direction and the speed class (the level, up to
  4), `move_ball` adds it to the position. There is no wall physics: when the
  ball sprite touches a wall (VIC sprite-background collision of sprite 3) the
  ball is lost. Sprites 0-4 make up the ball (shading, shine, ball, shadow).
* **Gates.** Each maze has up to 8 gates across its corridors (`gate_table`,
  enabled per level by `gate_masks_by_level`, so each loop through the mazes
  has a different "trap" layout). Fire flips them open for a short time
  (`fire_gates`); a closed gate is a wall.
* **Exit hole.** Sprites 6 and 7. When the ball is over it (`ball_over_hole`)
  it drops in and the next maze slides in. One level is mazes 0-3; then the
  level goes up and the four mazes repeat with a faster ball, faster tilting,
  new gate masks and a slightly bigger ball (hardly visible before level 4-5).
* **Power.** The POWER bar is the ball's energy. Every tilt "clunk" costs
  power; when it runs out you get the BACKUP power, and losing a ball on
  BACKUP ends the game. The floor under the ball is marked as it rolls; at the
  end of a maze the marks are counted back into power and bonus points, x2
  when the maze was finished rather than the ball lost.
* **Timing.** Almost everything runs in the raster interrupt (`irq_handler`,
  12 raster lines per frame); the main program mostly waits for frames.
* **Controls.** Joystick in port 2, or the keys (one "diamond" per hand):
  `*` `;` `RETURN` `right SHIFT` or `Q/CTRL` `RUN/STOP` `A` `left SHIFT` for
  up / left / right / down, `SPACE` fire. On the title screen: fire = play,
  F7 = demo, M = music on/off. F1 restarts the game.
* **Checksum.** The start-up code checks the sum of `$0980-$8DFF`. If it is
  wrong, a glyph of the status line font is replaced (see
  `docs/memory_map.md` before you change code).

## Tools (how the disassembly was made)

| Script | Purpose |
|--------|---------|
| `tools/crt.py` | Read the CRT, rebuild the game image (`python3 tools/crt.py out.prg`), extract the picture (`--picture`) |
| `tools/emu.py`, `tools/snapshot.py` | Small C64 emulator with Magic Desk banking (from thrust-c64); boots the cartridge and saves the state at game start (`build/snapshot.pkl`) |
| `tools/coverage.py` | Runs the game from the snapshot with scripted input and logs executed / read / written addresses (`tools/coverage/*.pkl`) |
| `tools/disasm.py` | Generator: code/data separation (coverage + tracing), labels, comments, KickAss output |
| `tools/tilt_annotations.py`, `tools/ann_*.py` | Memory regions and all labels, comments and data formats |
| `tools/regen.sh` | Regenerate `src/tilt.asm` from the above and verify |
| `tools/mazeview.py` | Render the mazes to `docs/mazes/` |
| `tools/show.py`, `tools/compact.py`, `tools/callgraph.py`, `tools/report.py`, `tools/quickka.py` | Helpers for reading the code |

`src/tilt.asm` is generated by `tools/regen.sh`. While renaming and commenting
in bulk it is easiest to keep editing the annotation files and regenerating.
Once you want to edit the `.asm` by hand, stop using `regen.sh` (it would
overwrite your edits) — from then on the `.asm` file is the master copy.

## Credits

* Tilt by Steve Walters, published by Codemasters (1990).
* Cartridge conversion by STATMAT (2023).
* Emulator and generator scripts adapted from the thrust-c64 disassembly.
