// ============================================================================
// tilt-mod: fire skips the interstitial between mazes
//
// After the bonus count, level_done slides the level sign in, slides the next
// maze in (or, after the last maze of a level, rolls back through the mazes),
// refills the power on a new level and slides the sign out: about 14 seconds
// per maze. A new fire press (fire must be released first) during that time
// jumps to the state the animation ends in.
//
// skip_arm (from level_done, $46A5) saves the stack pointer of level_done.
// The interstitial waits in wait_frames and slide_tick; both now call
// skip_check. On a new press it restores that stack pointer, which drops
// whatever loop was running, and skip_finish returns from level_done.
//
//   $46A5  jsr skip_arm            was "jsr mod_next_maze" (it still calls it)
//   $4667  jsr skip_poll_wait      was "lda wait_counter" (wait_frames loop)
//   $4309  jsr skip_poll_slide     was "lda slide_state" (slide_tick)
//   $46E8  jsr skip_sign_out       was "jsr level_sign_slide_out"
// ============================================================================

skip_armed:     .byte 0                     // 1 while the interstitial can be skipped
skip_released:  .byte 0                     // fire was up since skip_arm
skip_sp:        .byte 0                     // stack pointer inside level_done
skip_level_up:  .byte 0                     // this interstitial ends the level
skip_phase:     .byte 0                     // 1 = only the sign slide-out is left

// ----------------------------------------------------------------------------
// Replaces "jsr mod_next_maze" in level_done (not reached in demo mode)
// ----------------------------------------------------------------------------
skip_arm:
    jsr mod_next_maze
    tsx                                     // level_done's stack pointer: without
    inx                                     // this call's return address
    inx
    stx skip_sp
    lda level_end
    sta skip_level_up
    lda #$00
    sta skip_released
    sta skip_phase
    lda #$01
    sta skip_armed
    rts

// ----------------------------------------------------------------------------
// Replaces "jsr level_sign_slide_out" at the end of level_done
// ----------------------------------------------------------------------------
skip_sign_out:
    lda #$01
    sta skip_phase
    jsr level_sign_slide_out
    lda #$00
    sta skip_armed
    rts

// ----------------------------------------------------------------------------
// Replace "lda wait_counter" in wait_frames and "lda slide_state" in
// slide_tick: check for a skip, then do the load (flags as before)
// ----------------------------------------------------------------------------
skip_poll_wait:
    jsr skip_check
    lda wait_counter
    rts

skip_poll_slide:
    jsr skip_check
    lda slide_state
    rts

// ----------------------------------------------------------------------------
// Skip on a new fire press. Keeps X, Y and zp_ff (read_controls uses them).
// ----------------------------------------------------------------------------
skip_check:
    lda skip_armed
    bne !+
    rts
!:  txa
    pha
    tya
    pha
    lda zp_ff
    pha
    jsr read_controls                       // active low, bit 4 = fire / SPACE
    tax
    pla
    sta zp_ff
    pla
    tay
    txa
    and #$10
    bne !released+
    lda skip_released
    bne !skip+
    pla                                     // fire still held from before: wait
    tax
    rts
!released:
    lda #$01
    sta skip_released
    pla
    tax
    rts
!skip:
    ldx skip_sp                             // back to level_done's stack level
    txs
    // fall through

// ----------------------------------------------------------------------------
// End state of the interstitial, then return from level_done
// ----------------------------------------------------------------------------
skip_finish:
    lda #$00
    sta skip_armed
    sta slide_state                         // the IRQ stops sliding
    sta sign_sound_on
    sta blip_sound
    sta sign_spin_speed
    sta roll_sound_off
    jsr sid_off
    lda skip_phase
    bne !hide+
    lda skip_level_up
    beq !+
    lda level_end                           // level + 1 and maze 0, unless the
    beq !restarted+                         // roll-back has done it already
    jsr mod_restart_mazes
!restarted:
    lda #$00
    sta maze
!:  jsr draw_maze_screen                    // the maze into the buffers, as the slides do
    sec
    jsr draw_gates
    jsr draw_tilt_gates
    jsr fill_colour_buffer
    jsr colour_gates
    jsr copy_maze_buffer
    jsr init_hole                           // hole position, fine scroll back to 4
    lda skip_level_up
    beq !hide+
    lda #$00                                // new level: as level_done ($46CB-$46E6)
    sta two_tone_step
    lda #$01
    sta power_refill
    sta two_tone_timer
    sta scroll_level_step
    sta new_ball_size
!:  lda two_tone_timer                      // power refill, level number
    bne !-
!hide:
    lda #$f0                                // as level_sign_slide_out leaves the SID
    sta SID_V2_SR
    lda #$11
    sta SID_V2_CTRL
    lda #$00
    sta SID_V2_FREQ_HI
    jsr level_sign_hide
!:  lda #$01                                // fire up again, or the ball would be
    jsr wait_frames                         // released as soon as it appears
    jsr read_controls
    and #$10
    beq !-
    rts

// ----------------------------------------------------------------------------
// Screen and colour buffers, rows 2-24, to the screen (what the slide shows
// when it ends)
// ----------------------------------------------------------------------------
copy_maze_buffer:
    ldx #$50
!:  lda screen_buffer,x
    sta screen,x
    lda colour_buffer,x
    sta COLOR_RAM,x
    inx
    bne !-
!:  lda screen_buffer + $100,x
    sta screen + $100,x
    lda colour_buffer + $100,x
    sta COLOR_RAM + $100,x
    lda screen_buffer + $200,x
    sta screen + $200,x
    lda colour_buffer + $200,x
    sta COLOR_RAM + $200,x
    inx
    bne !-
!:  lda screen_buffer + $300,x
    sta screen + $300,x
    lda colour_buffer + $300,x
    sta COLOR_RAM + $300,x
    inx
    cpx #$e8
    bne !-
    rts
