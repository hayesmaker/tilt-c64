// ============================================================================
// tilt-mod: in-game sound modes (F2 / F3 / F4 on the title screen)
//
//   F2  0  SFX ONLY     sound effects only, as in the original
//   F3  1  MUSIC + SFX  tune 5 on SID voice 1 while the ball rolls; the effects
//                       keep voices 2 and 3 (the default)
//   F4  2  MUSIC        tune 2 on all three voices while the ball rolls; the
//                       effects are muted while it plays and sound again
//                       between mazes, when the ball is lost, ...
// M on the title screen still switches the title music and the level jingle
// on and off (cefa_flag); the sound mode does not depend on it.
//
// Tune 5 is never played by the original game: it is tune 2's melody alone
// on voice 1 (voices 2 and 3 only rest), the one voice the sound effects
// leave free during play (rolling noise and gate sound: voice 3; clunks,
// tilt and ball sounds: voice 2). Tune 2 is a full three-voice tune the
// original never plays either.
//
// The music runs in the raster IRQ after the line 105 colour split (step 6),
// which has about 5,800 free cycles before the next split; the driver needs
// 2,000 at most. It only plays while the ball rolls (steering_on): between
// "ball waiting" and rolling it would hang on a note.
//
// Mode 1: only voice 1 is played (the driver's voice loop is limited to
// voice 0 while it runs, music_top_voice), and the tune is started without
// music_init, which would clear the whole SID. Voice 1 is left alone while
// something else uses it: the BACKUP alarm, the power refill two-tone, the
// level jingle.
// Mode 2: the tune is started like the title music (music_init: SID cleared,
// volume 7, no filter). sfx_mute is set while it plays: the sound effects'
// SID stores (sfx_mute.asm) then do nothing. When the ball stops rolling the
// voices are silenced and the game's filter / volume set again.
// Between mazes sid_off silences the voices; the tune carries on with its
// next note (every note sets the envelope again). After the level jingle,
// which uses the driver, the tune starts again from the beginning.
//
//   $6013  jmp ingame_music_irq     was "jmp KERNAL_IRQ_EXIT" (after a colour split)
// ============================================================================

.const INGAME_TUNE5_SPEED = 2               // tune 5's speed (set by its rest pattern
                                            // on voices 2/3, which are not played)

sound_mode:     .byte 1                     // 0 SFX ONLY, 1 MUSIC + SFX, 2 MUSIC (kept across games)
sfx_mute:       .byte 0                     // bit 7: the sound effects' SID stores are skipped

ingame_tune_lo: .byte 0, <tune5_voice1, <tune2_voice1
ingame_tune_hi: .byte 0, >tune5_voice1, >tune2_voice1

// ----------------------------------------------------------------------------
// After the colour split of IRQ steps 1-11
// ----------------------------------------------------------------------------
ingame_music_irq:
    lda irq_step
    cmp #$06
    bne !exit+
    ldx sound_mode
    beq !stop+
    lda demo_mode
    ora title_mode
    ora two_tone_timer                      // power refill sound
    ora jingle_timer                        // level jingle (uses the driver)
    bne !stop+
    cpx #$02
    beq !+
    lda backup_power                        // mode 1: the BACKUP alarm has voice 1
    bne !stop+
!:  lda steering_on                         // only while the ball rolls
    beq !stop+
    lda music_playing                       // the driver on this mode's tune? else start it
    beq !start+
    lda mus_seq_lo
    cmp ingame_tune_lo,x
    bne !start+
    lda mus_seq_hi
    cmp ingame_tune_hi,x
    beq !tick+
!start:
    cpx #$02
    beq !start2+
    jsr ingame_tune5_start
    jmp !tick+
!start2:
    lda #$02                                // tune 2 like the title music: music_init
    sta music_command                       // clears the SID, volume 7
    jsr music_play
    lda #$80
    sta sfx_mute
!tick:
    ldx sound_mode
    cpx #$02
    beq !all+
    lda #$00                                // mode 1: voice 1 only
    sta music_top_voice + 1
    jsr music_tick
    lda #$02
    sta music_top_voice + 1
    jmp !exit+
!all:
    lda sfx_mute                            // mode 2, back after a pause: the SID is ours
    bmi !+                                  // again (no filter, volume 7)
    lda #$00
    sta SID_RES_FILT
    lda #$07
    sta SID_MODE_VOL
    lda #$80
    sta sfx_mute
!:  jsr music_tick
!exit:
    jmp KERNAL_IRQ_EXIT

!stop:
    lda sfx_mute                            // mode 2 music was playing: give the SID
    bpl !exit-                              // back to the sound effects
    lda #$00
    sta sfx_mute
    sta SID_V1_CTRL
    sta SID_V2_CTRL
    sta SID_V3_CTRL
    lda #$44                                // filter on voice 3, low pass, volume 15:
    sta SID_RES_FILT                        // as the game has them during play
    lda #$1f
    sta SID_MODE_VOL
    jmp KERNAL_IRQ_EXIT

// ----------------------------------------------------------------------------
// Start tune 5 on voice 1 (music_start_tune for one voice, without music_init)
// ----------------------------------------------------------------------------
ingame_tune5_start:
    ldx #$00
    lda #<tune5_voice1
    sta mus_seq_lo
    lda #>tune5_voice1
    sta mus_seq_hi
    lda #$00
    sta mus_length_count
    sta mus_porta_state
    sta mus_seq_pos
    sta music_speed_count
    jsr music_next_pattern
    lda #INGAME_TUNE5_SPEED
    sta music_speed
    lda #$01
    sta music_playing
    rts

// ----------------------------------------------------------------------------
// Title screen: replaces "jsr title_music_key" in the title loop ($562A).
// F2 / F3 / F4 pick the sound mode (F2 = SHIFT+F1, F4 = SHIFT+F3 on the C64
// keyboard). Sprite 7 (free on the title: the Codemasters logo is 0-6) shows
// the current one: its key and a glyph (speaker / note and speaker / notes),
// frames at options_sprites ($0340, pointers 13-15). Hires, white, below the
// logo on raster lines 177-197: clear of the rocking logo and of every colour
// split, so it does not disturb the scroll text or the raster timing.
// The title sets the sprite registers once when it starts; sprite 7's are
// saved on the first title frame and given back when the title ends
// (mod_title_exit), so the game's exit hole sprite is untouched.
// ----------------------------------------------------------------------------
.const OPT_SPRITE_X  = 32                   // column 1
.const OPT_SPRITE_Y  = 176                  // raster lines 177-197
.const OPT_SPRITE_COLOUR = 1                // white

opt_sprite_on:  .byte 0                     // 1 while the title shows the sprite
opt_saved:      .fill 4, 0                  // pointer, X, Y, colour
opt_saved_bits: .fill 6, 0                  // bit 7 of the registers in opt_bit_regs

mod_title_keys:
    jsr title_music_key
    lda #$fd                                // SHIFT: left (column 1, row 7) or
    sta CIA1_PRA                            // right (column 6, row 4)
    lda CIA1_PRB
    and #$80
    beq !shift+
    lda #$bf
    sta CIA1_PRA
    lda CIA1_PRB
    and #$10
!shift:
    sta zp_ff                               // 0 = SHIFT held
    lda #$fe                                // column 0: F1 (row 4), F3 (row 5)
    sta CIA1_PRA
    lda CIA1_PRB
    tax
    ldy zp_ff
    and #$10
    bne !+
    tya                                     // F1 with SHIFT = F2: SFX ONLY
    bne !show+
    lda #$00
    beq !set+
!:  txa
    and #$20
    bne !show+
    lda #$01                                // F3: MUSIC + SFX
    cpy #$00
    bne !set+
    lda #$02                                // F3 with SHIFT = F4: MUSIC
!set:
    sta sound_mode
    lda #$00                                // a key: no demo yet
    sta title_idle
    sta title_idle + 1
!show:
    lda opt_sprite_on                       // first title frame: keep sprite 7's registers
    bne !+
    lda sprite_ptrs + 7
    sta opt_saved
    lda VIC_SPR7_X
    sta opt_saved + 1
    lda VIC_SPR7_Y
    sta opt_saved + 2
    lda VIC_SPR7_COL
    sta opt_saved + 3
    ldx #5
!save:
    jsr opt_bit_reg                         // A = bit 7 of register X
    sta opt_saved_bits,x
    dex
    bpl !save-
    lda #$01
    sta opt_sprite_on
!:  lda sound_mode
    clc
    adc #<(options_sprites / 64)
    sta sprite_ptrs + 7
    lda #OPT_SPRITE_X
    sta VIC_SPR7_X
    lda #OPT_SPRITE_Y
    sta VIC_SPR7_Y
    lda #OPT_SPRITE_COLOUR
    sta VIC_SPR7_COL
    lda VIC_SPR_X_MSB                       // hires, normal size, in front, X < 256
    and #$7f
    sta VIC_SPR_X_MSB
    lda VIC_SPR_MULTICOLOR
    and #$7f
    sta VIC_SPR_MULTICOLOR
    lda VIC_SPR_EXPAND_X
    and #$7f
    sta VIC_SPR_EXPAND_X
    lda VIC_SPR_EXPAND_Y
    and #$7f
    sta VIC_SPR_EXPAND_Y
    lda VIC_SPR_PRIORITY
    and #$7f
    sta VIC_SPR_PRIORITY
    lda VIC_SPR_ENABLE
    ora #$80
    sta VIC_SPR_ENABLE
    rts

// ----------------------------------------------------------------------------
// Replaces "jsr sid_off" at title_done ($566D): the title ends (game or demo).
// Sprite 7 as the title had it.
// ----------------------------------------------------------------------------
mod_title_exit:
    lda opt_sprite_on
    beq !+
    lda opt_saved
    sta sprite_ptrs + 7
    lda opt_saved + 1
    sta VIC_SPR7_X
    lda opt_saved + 2
    sta VIC_SPR7_Y
    lda opt_saved + 3
    sta VIC_SPR7_COL
    ldx #5
!restore:
    lda opt_bit_regs,x                      // register X: bit 7 as saved
    sta !rd+ + 1
    sta !wr+ + 1
!rd:
    lda $d000                               // self-modified
    and #$7f
    ora opt_saved_bits,x
!wr:
    sta $d000                               // self-modified
    dex
    bpl !restore-
    lda #$00
    sta opt_sprite_on
!:  jmp sid_off

// Sprite 7's bit in: enable, X bit 8, multicolour, Y / X expand, priority
opt_bit_regs:   .byte <VIC_SPR_ENABLE, <VIC_SPR_X_MSB, <VIC_SPR_MULTICOLOR
                .byte <VIC_SPR_EXPAND_Y, <VIC_SPR_EXPAND_X, <VIC_SPR_PRIORITY

opt_bit_reg:                                // A = bit 7 of VIC register opt_bit_regs[X]
    lda opt_bit_regs,x
    sta !rd+ + 1
!rd:
    lda $d000                               // self-modified
    and #$80
    rts

.assert "option sprites in VIC bank 0, 64-byte aligned", options_sprites & $c03f, 0
