// ============================================================================
// tilt-mod: in-game music (tune 5 on SID voice 1)
//
// Tune 5 is never played by the original game: it is tune 2's melody alone
// on voice 1 (voices 2 and 3 only rest), the one voice the sound effects
// leave free during play (rolling noise and gate sound: voice 3; clunks,
// tilt and ball sounds: voice 2). This plays it while the ball rolls
// (steering_on), when the music is on (M on the title screen).
//
// It runs in the raster IRQ after the line 105 colour split (step 6), which
// has about 5,800 free cycles before the next split; the driver needs 2,000
// at most. Only voice 1 is played: the driver's voice loop is limited to
// voice 0 while it runs (music_top_voice). Starting the tune does not call
// music_init, which would clear the whole SID.
//
// Voice 1 is left alone while something else uses it: the BACKUP alarm
// (backup_power), the power refill two-tone, the level jingle. Between
// mazes sid_off silences the voice; the tune carries on with its next note
// (every note sets the envelope again). After the level jingle, which uses
// the driver, the tune starts again from the beginning.
//
//   $6013  jmp ingame_music_irq     was "jmp KERNAL_IRQ_EXIT" (after a colour split)
// ============================================================================

.const INGAME_TUNE_SPEED = 2                // tune 5's speed (set by its rest pattern
                                            // on voices 2/3, which are not played)

// ----------------------------------------------------------------------------
// After the colour split of IRQ steps 1-11
// ----------------------------------------------------------------------------
ingame_music_irq:
    lda irq_step
    cmp #$06
    bne !exit+
    lda cefa_flag                           // music on
    beq !exit+
    lda demo_mode
    ora title_mode
    ora backup_power                        // the BACKUP alarm has voice 1
    ora two_tone_timer                      // power refill sound
    ora jingle_timer                        // level jingle (uses the driver)
    bne !exit+
    lda steering_on                         // only while the ball rolls: between
    beq !exit+                              // "ball waiting" and rolling it would hang on a note
    lda music_playing                       // the driver on tune 5? else start it
    beq !start+
    lda mus_seq_lo
    cmp #<tune5_voice1
    bne !start+
    lda mus_seq_hi
    cmp #>tune5_voice1
    beq !tick+
!start:
    jsr ingame_music_start
!tick:
    lda #$00                                // voice 1 only
    sta music_top_voice + 1
    jsr music_tick
    lda #$02
    sta music_top_voice + 1
!exit:
    jmp KERNAL_IRQ_EXIT

// ----------------------------------------------------------------------------
// Start tune 5 on voice 1 (music_start_tune for one voice, without music_init)
// ----------------------------------------------------------------------------
ingame_music_start:
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
    lda #INGAME_TUNE_SPEED
    sta music_speed
    lda #$01
    sta music_playing
    rts
