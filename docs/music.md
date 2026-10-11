# Tilt (C64) — music

The music driver and all its data sit at `$8000-$8CFF` (`src/music.asm`). The
game writes a tune number to `music_command` (`$8000`) and calls `music_play`
(`$8001`) once per frame:

| `music_command` | Meaning |
|-----------------|---------|
| `0` | stop the music |
| `1`-`5` | start tune n |
| `$FF` | keep playing (`music_play` writes it back after each call) |

## Tunes

`tune_table` (`$8735`) holds the start of each tune's three voice sequences.

| Tune | Voice 1 sequence | Used by the game | Notes |
|------|------------------|------------------|-------|
| 1 | `$883B` | title music: started by `title_music_key` (`$5F50`) when the logo rocks, if music is on (M) | loops; 3 voices |
| 2 | `$88CF` | never played | a complete looping 3-voice tune; excellent, and a candidate for in-game music |
| 3 | `$88FE` | level-start jingle (`level_jingle`, `$5F61`), only if music is on; cut off after 128 frames | |
| 4 | `$890A` | game-over jingle (`game_over_jingle`, `$5FA7`), but both branches skip it, so it is never heard | |
| 5 | `$8C0A` | never played (tilt-mod plays it during a game) | one voice: tune 2's melody (pattern `$19`) alone on voice 1, voices 2 and 3 rest. Probably meant as in-game music: voice 1 is the one the sound effects leave free |

A voice's sequence is a list of pattern numbers (`$00-$7F`); `$FF` jumps back
to its start, and other bytes from `$80` set the transpose to the byte + `$40`
(`$C0` = 0, `$CC` = +12, an octave up, `$BE` = -2). Tunes 3 and 4 play their
jingle pattern and then pattern `$03`, a long rest (`$F2,$C0,$9F,$00`: speed,
instrument 0, length 31, note 0), and repeat: on the title screen the jingle
comes back after a pause. Tune 5 uses the same rest on voices 2 and 3. Tune
2's voice 2 ends with the melody pattern `$19`, then the same an octave up
(`$C0,$19,$CC,$19`); tune 5 loops just that melody, untransposed, on voice 1.

**Listening to a tune:** the title tune is chosen by `lda #$01` at `$5F50`.
Changing that one byte to the tune number (in a copy of
`packages/tilt-mod/src/tilt.asm`, then `./build.sh`) makes a cartridge whose
title screen plays that tune instead.

## Music during play

The original plays no music during a game. tilt-mod does: tune 5 on voice 1
(see `packages/tilt-mod/README.md`, "In-game music"). Measured in the
emulator:

* **Cost:** `music_play` takes about 870 cycles per call on average and
  2,000 at most (title tune).
* **Where to call it:** the raster interrupt after the line-105 colour split
  has about 5,800 free cycles before the next split (line 199), enough even
  after the VIC's stolen cycles. The frame-logic interrupt (line 250) leaves
  only about 1,170 cycles before the status-line split at line 42, too few
  for the worst case.
* **Memory:** the driver and tunes are always loaded. Free RAM: see
  [memory_map.md](memory_map.md); tilt-mod uses `$C000` up to about `$C560`
  for its own code.
* **SID voices are the limit.** During play the sound effects use all three:
  voice 3 is the rolling noise (every frame, through the filter) and the gate
  sound, voice 2 the clunks, tilt and ball sounds, voice 1 only the power
  refill tone and the end-of-maze gate scoring. `roll_sound` also rewrites the
  volume / filter mode register (`$D418`) every frame. In-game music would
  have to use voice 1 only, or share voice 2 with the effects, unless the
  rolling sound is reworked. Tune 5 is already such a one-voice tune.
