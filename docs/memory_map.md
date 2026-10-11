# Tilt (C64) — run-time memory map

Tilt runs where it loads: the STATMAT cartridge copies a 63K RAM image
(`$0334-$FFFF`) into memory and jumps to `$0460`. All addresses below are
both load and run-time addresses. VIC bank 0 (`$0000-$3FFF`) is used, with
`$D018 = $18` (screen `$0400`, font `$2000`). `$01 = $36`: BASIC ROM off,
I/O and KERNAL on (the game uses the KERNAL IRQ entry/exit).

| Address | Contents |
|---------|----------|
| `$00F8-$00FF` | zero page temporaries (`zp_f8`..`zp_ff`), saved by the raster IRQ |
| `$0334-$03FF` | cassette buffer: leftovers |
| `$0400-$07E7` | screen. Rows 0-1: status line (SCORE, POWER, LEVEL, HI); rows 2-24: the board |
| `$07F8-$07FF` | sprite pointers |
| `$0424-$0467` | (at start-up) the original disk loader, typed into screen RAM; the cartridge enters at `$0460` |
| `$0800-$080C` | BASIC line `0 SYS2061` |
| `$080D-$1B6E` | code: start-up + checksum, ball physics, tilt graphics, sounds, controls |
| `$08B0-$097F` | leftover of the developer's BASIC module loader (not used) |
| `$1B6F-$1BFF` | unused (`$FF`) |
| `$1C00-$1CFF` | demo mode recording: control bits and durations |
| `$1D00-$1D9F` | characters, copied to `$2320` at start-up |
| `$1E00-$1FFF` | pixel tables for the corner characters |
| `$2000-$27FF` | character set, built at run time. At load: maze 0 and 1 screens |
| `$2800-$37FF` | sprites, pointers `$A0-$DF` (some built at run time: `$C7` shadow, `$C8` dissolve, `$DC/$DE` masked ball / hole) |
| `$3800-$38BF` | shine offsets, sprite mask buffer |
| `$38C0-$76AD` | code: gates, floor marks, ball sprites, level flow, title screen, raster IRQ, demo, power bar, init |
| `$7594-$761B` | status line font (copied to `$2650`; the tamper check patches its first glyph) |
| `$76AE-$77FF` | unused |
| `$7800-$7BE7` | colour buffer (copied to colour RAM). `$7800/$7900`: floor mark list (low/high bytes). At load: maze 2 screen |
| `$7C00-$7FE7` | screen buffer (copied to the screen). At load: maze 3 screen |
| `$8000-$8CFF` | music driver (`$8000` = command byte, `$8001` = play) and music data (see [music.md](music.md)) |
| `$8D00-$8EFF` | title screen sprites (swapped with `$2800-$29FF`) |
| `$8F00-$9FFF` | **unused** (leftover bytes) |
| `$A000-$AFFF` | the four maze screens, 1K each (copied there at start-up) |
| `$B000-$CDFF` | **unused** (leftover bytes) |
| `$CE00-$CEFF` | variables kept across games (high score, music on/off, tamper flag) |
| `$CF00-$CFFF` | game variables (cleared by `init_machine`) |
| `$D000-$DFFF` | I/O. The RAM below is not used |
| `$E000-$FFFF` | KERNAL ROM. The RAM below is not used |

## Free RAM for mods

`$8F00-$9FFF` (4.25K) and `$B000-$CDFF` (7.5K) are never read or written by
the game. The RAM under I/O and the KERNAL is unused as well, but the game
keeps the KERNAL banked in.

**Checksum:** at start-up `checksum` adds up `$0980-$8DFF` and expects
`$3FDA:$37`. If the sum is different, `tampered` is set and the first glyph of
the status line font is replaced by an "E". A mod that changes anything in
that range must either fix up the sum (e.g. with a compensating byte in
unused RAM inside the range) or patch the check at `$0827`.

## Raster interrupt chain

`irq_handler` (`$5FED`, through `CINV`) runs 12 times per frame at the lines in
`irq_lines` (`$61A9`). Step 0 (line `$2A`) does the frame work: the whole game
logic (`frame_logic`) or the title animation (`title_irq`). Steps 1-11 split
the border/background colours for the status line and the wooden board frame,
and step 3 sets the hardware fine scroll of the board (`fine_scroll_x/y`):
that, together with rebuilt edge characters, is what makes the maze shift when
it tilts.

## Sprites while playing

| Sprite | Use |
|--------|-----|
| 0 | shading crescent on the ball (shape drawn at `$31C0`) |
| 1 | shine / glint on the ball |
| 2 | ball (grey), masked against the board edge (`$DC` at `$3700`) |
| 3 | ball (white): the sprite that collides with walls |
| 4 | the ball's shadow on the floor (black), offset by the perspective shift |
| 5 | demo mode: joystick picture |
| 6, 7 | exit hole |

Between levels sprites 0, 1, 4 and 5 show the spinning "LEVEL" sign.
