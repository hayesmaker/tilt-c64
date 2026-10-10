// ============================================================================
// TILT (Commodore 64) - Codemasters, 1990
// Program by Steve Walters.
// Commented disassembly for KickAssembler 5.x
//
// This file assembles the game's RAM image, $0334-$FFFF, exactly as the
// STATMAT 2023 cartridge conversion (bin/Tilt.crt) copies it into memory
// before it jumps to $0460. src/cart.asm then packs the image, the cartridge
// loader and the loading picture into a byte-identical Tilt.crt.
//
// Build:   ./build.sh       (assembles src/tilt.asm, then src/cart.asm)
// ============================================================================

// Run-time memory (VIC bank 0)
.label screen        = $0400                // text screen, 40 x 25
.label sprite_ptrs   = $07f8                // sprite pointers
.label font          = $2000                // character set (built at run time)
.label colour_buffer = $7800                // maze colours, copied to colour RAM
.label screen_buffer = $7c00                // maze screen, copied to the screen
.function char(n)   { .return font + n * 8 }          // address of character n
.function sprite(n) { .return n * 64 }                // address of sprite pointer n

// ----------------------------------------------------------------------------
// Zero page
// ----------------------------------------------------------------------------
.label zp_f8                          = $f8     // pointer (the raster IRQ saves $F8-$FF around the frame work)
.label zp_f9                          = $f9
.label zp_fa                          = $fa
.label zp_fb                          = $fb     // pointer low / temporary
.label zp_fc                          = $fc     // pointer high / temporary
.label zp_fd                          = $fd     // pointer low / temporary
.label zp_fe                          = $fe     // pointer high / temporary
.label zp_ff                          = $ff

// ----------------------------------------------------------------------------
// Hardware registers, KERNAL and RAM outside the program image
// ----------------------------------------------------------------------------
.label CINV                           = $0314
.label CINV_HI                        = $0315
.label CBINV                          = $0316
.label CBINV_HI                       = $0317
.label NMINV                          = $0318
.label NMINV_HI                       = $0319
.label tampered                       = $cef9   // 1 = code checksum wrong: one glyph of the font is replaced
.label cefa_flag                      = $cefa
.label hiscore                        = $cefb   // high score, 3 bytes BCD (low byte first)
.label dev_maze                       = $cefe   // maze shown in developer mode
.label dev_mode                       = $ceff   // 1 = developer start ($0984): game runs in the IRQ, BASIC stays usable
.label ball_vx                        = $cf00   // ball velocity X (signed)
.label ball_vy                        = $cf01   // ball velocity Y (signed)
.label ball_x_frac                    = $cf02   // ball X position: fraction
.label ball_x                         = $cf03   // ball X position (sprite coordinates, low byte)
.label ball_x_hi                      = $cf04   // ball X position, bit 8
.label ball_y_frac                    = $cf05   // ball Y position: fraction
.label ball_y                         = $cf06   // ball Y position (sprite coordinates)
.label tilt_dx                        = $cf07   // tilt direction X from the controls: -1 left, 0, +1 right
.label tilt_dy                        = $cf08   // tilt direction Y: -1 up, 0, +1 down
.label tilt_shift_x                   = $cf09   // perspective shift of the maze 0-8 in X (4 = level)
.label tilt_shift_y                   = $cf0a   // perspective shift of the maze 0-8 in Y
.label tilt_shift_x_old               = $cf0b
.label tilt_shift_y_old               = $cf0c
.label irq_step                       = $cf0d   // raster IRQ chain step 0-11
.label fine_scroll_x                  = $cf0e   // fine scroll X for the board ($D016 bits 0-2), from the tilt
.label fine_scroll_y                  = $cf0f   // fine scroll Y for the board ($D011 bits 0-2), from the tilt
.label roll_volume                    = $cf10
.label roll_volume_old                = $cf11
.label roll_sweep_dir                 = $cf12
.label roll_sweep                     = $cf13
.label clunk_state                    = $cf15
.label clunk_toggle                   = $cf16
.label flash_phase                    = $cf17
.label flash_step                     = $cf18
.label wait_counter                   = $cf1a   // frames left to wait (wait_frames)
.label diag_hold_count                = $cf1b
.label diag_hold_state                = $cf1c
.label diag_tilt_dx                   = $cf1d
.label diag_tilt_dy                   = $cf1e
.label edge_step                      = $cf20
.label edge_run                       = $cf21
.label edge_char                      = $cf22
.label tilt_angle_x_old               = $cf23
.label tilt_angle_y_old               = $cf24
.label tilt_dx_old                    = $cf25
.label tilt_dy_old                    = $cf26
.label accel_x                        = $cf27
.label accel_y                        = $cf28
.label dv_x                           = $cf29
.label dv_y                           = $cf2a
.label sound_tilt_dx                  = $cf2b
.label sound_tilt_dy                  = $cf2c
.label maze                           = $cf2d   // maze on screen: 0-3
.label gate_frame                     = $cf2e
.label gate_frame_old                 = $cf2f
.label gate_count                     = $cf30
.label gate_index                     = $cf31
.label gate_gfx_offset                = $cf32
.label gate_anim                      = $cf33   // fire pressed: gate animation counter (0 = idle)
.label fire_latch                     = $cf34
.label tilt_angle_x                   = $cf35   // tilt angle X 0-255 ($80 = level), eases toward tilt_dx
.label tilt_angle_y                   = $cf36   // tilt angle Y 0-255 ($80 = level), eases toward tilt_dy
.label tilt_level_x                   = $cf37   // tilt angle X as 0-8
.label tilt_level_y                   = $cf38   // tilt angle Y as 0-8
.label mark_cell_count                = $cf39
.label gate_page_add                  = $cf3a
.label level                          = $cf3b   // level number (0 = level 1)
.label shine_x                        = $cf3c
.label shine_y                        = $cf3d
.label shine_x_tmp                    = $cf3e
.label shine_y_tmp                    = $cf3f
.label shine_x_limit                  = $cf40
.label shine_y_limit                  = $cf41
.label shine_quadrant_x               = $cf42
.label shine_quadrant_y               = $cf43
.label slide_column                   = $cf44
.label slide_state                    = $cf45
.label score                          = $cf47   // score, 3 bytes BCD (low byte first)
.label ball_in_hole                   = $cf4d   // set when the ball dropped into the exit hole
.label ball_lost                      = $cf4e   // set when the ball touched a wall (sprite-background collision)
.label steering_on                    = $cf50
.label fire_enabled                   = $cf51   // fire flips the gates
.label controls_enabled               = $cf52   // read the joystick / keys each frame
.label tilt_enabled                   = $cf53   // tilt angles follow the controls
.label controls                       = $cf54   // controls: joystick bits, active low (0 up 1 down 2 left 3 right 4 fire)
.label mark_count                     = $cf55   // number of floor marks in the list at $7800/$7900
.label tilt_rate                      = $cf57   // how fast the tilt angles follow the controls
.label scroll_score_step              = $cf59
.label scroll_hiscore_step            = $cf5a
.label scroll_level_step              = $cf5c
.label scroll_pause                   = $cf5d
.label slide_speed                    = $cf5e
.label slide_speed_sign               = $cf5f
.label slide_accel                    = $cf60
.label slide_dir                      = $cf61
.label slide_fine                     = $cf62
.label slide_fine_frac                = $cf63
.label slide_speed_max                = $cf64
.label slide_out_flag                 = $cf65
.label slide_bounce                   = $cf66
.label hole_x                         = $cf67   // exit hole X position (sprites 6 and 7)
.label hole_x_hi                      = $cf68
.label hole_y                         = $cf69   // exit hole Y position
.label hole_sprite                    = $cf6a
.label fall_timer                     = $cf6d
.label fall_delay                     = $cf6e
.label fall_freq                      = $cf6f
.label fall_freq_hi                   = $cf70
.label fall_freq_step                 = $cf71
.label fall_freq_step_hi              = $cf72
.label ball_waiting                   = $cf73   // ball has appeared, waiting for fire
.label glint_on                       = $cf74
.label blip_sound                     = $cf75
.label title_mode                     = $cf76   // 1 while the title screen runs (selects the IRQ frame work)
.label title_rock_dir                 = $cf77
.label title_rock_pause               = $cf78
.label new_ball_size                  = $cf79   // new level: the ball changes size (dissolve and reappear)
.label roll_sound_off                 = $cf7a   // no rolling sound (another sound is playing)
.label sign_x_left                    = $cf7f
.label sign_x_right                   = $cf80
.label sign_y                         = $cf81
.label sign_spin_speed                = $cf82
.label sign_spin                      = $cf83
.label level_sign_on                  = $cf84   // level sign sprites on screen
.label sign_sound_on                  = $cf85
.label slide_noise_old                = $cf86
.label demo_mode                      = $cf87   // demo mode (F7)
.label demo_playing                   = $cf88
.label cf89_unused                    = $cf89   // never set: would start a game at level 8 like the demo
.label demo_step_frames               = $cf8a
.label demo_step                      = $cf8b
.label controls_copy                  = $cf8c
.label demo_stops_at_end              = $cf8d   // demo recording stops when the ball is in the hole / lost
.label title_fine_scroll              = $cf8f
.label title_text_pos                 = $cf90
.label frame_flash_sides              = $cf91
.label frame_flash_corner             = $cf92
.label shine_state                    = $cf93   // 1 = shine on the ball, 2 = it just left (plays a sound)
.label edge_highlight_on              = $cf94
.label hole_wrap                      = $cf95
.label gate_hit_timer                 = $cf96
.label gate_hit_index                 = $cf98
.label gate_hit_frame                 = $cf99
.label count_marks_delay              = $cf9a
.label gate_mask                      = $cf9b   // bit mask: which of the 8 gate of the maze are on
.label count_marks_on                 = $cf9c
.label bumper_timer                   = $cf9d
.label bumper_index                   = $cf9e
.label bonus_left                     = $cfa0
.label shaking                        = $cfa1   // board is shaking (higher clunk sound)
.label ball_size                      = $cfa2
.label marking_on                     = $cfa3
.label shake_count                    = $cfa4
.label bonus_sound_on                 = $cfa5
.label ball_frame_changed             = $cfa7
.label two_tone_timer                 = $cfa8
.label two_tone_step                  = $cfa9
.label hole_spr_x                     = $cfab
.label hole_spr_y                     = $cfac
.label dissolve_step                  = $cfad
.label dissolve_time                  = $cfae
.label speed_class                    = $cfaf   // speed class 0-4 (level number, at most 4)
.label screen_on                      = $cfb0   // $D011 bit 4 (screen on $18 / off $08), used by the IRQ
.label power_lo                       = $cfb1   // power, fraction
.label power_hi                       = $cfb2   // power 0-$30 (8 per character of the bar)
.label power_refill                   = $cfb3
.label game_over                      = $cfb4   // set when the game is over
.label power_drain_on                 = $cfb5
.label backup_power                   = $cfb6
.label nmi_count                      = $cfb7
.label no_restart                     = $cfb8   // F1 restart not allowed
.label backup_flash_step              = $cfb9
.label backup_alarm_freq              = $cfba
.label bonus_flash                    = $cfbb
.label bg2_restore_timer              = $cfbc
.label diagonal_sound_timer           = $cfbd
.label title_delay                    = $cfbe
.label backup_allowed                 = $cfbf   // BACKUP power still available for this ball
.label m_key_up                       = $cfc8
.label jingle_timer                   = $cfc9
.label title_idle                     = $cfca   // title frames without input (16 bit): demo after $0F03
.label VIC_SPR0_X                     = $d000
.label VIC_SPR0_Y                     = $d001
.label VIC_SPR1_X                     = $d002
.label VIC_SPR1_Y                     = $d003
.label VIC_SPR2_X                     = $d004
.label VIC_SPR2_Y                     = $d005
.label VIC_SPR3_X                     = $d006
.label VIC_SPR3_Y                     = $d007
.label VIC_SPR4_X                     = $d008
.label VIC_SPR4_Y                     = $d009
.label VIC_SPR5_X                     = $d00a
.label VIC_SPR5_Y                     = $d00b
.label VIC_SPR6_X                     = $d00c
.label VIC_SPR6_Y                     = $d00d
.label VIC_SPR7_X                     = $d00e
.label VIC_SPR7_Y                     = $d00f
.label VIC_SPR_X_MSB                  = $d010
.label VIC_CTRL1                      = $d011
.label VIC_RASTER                     = $d012
.label VIC_SPR_ENABLE                 = $d015
.label VIC_CTRL2                      = $d016
.label VIC_SPR_EXPAND_Y               = $d017
.label VIC_MEMSETUP                   = $d018
.label VIC_IRQ_STATUS                 = $d019
.label VIC_IRQ_ENABLE                 = $d01a
.label VIC_SPR_PRIORITY               = $d01b
.label VIC_SPR_MULTICOLOR             = $d01c
.label VIC_SPR_EXPAND_X               = $d01d
.label VIC_SPR_BG_COLL                = $d01f
.label VIC_BORDER                     = $d020
.label VIC_BG0                        = $d021
.label VIC_BG1                        = $d022
.label VIC_BG2                        = $d023
.label VIC_SPR_MC0                    = $d025
.label VIC_SPR_MC1                    = $d026
.label VIC_SPR0_COL                   = $d027
.label VIC_SPR1_COL                   = $d028
.label VIC_SPR2_COL                   = $d029
.label VIC_SPR3_COL                   = $d02a
.label VIC_SPR4_COL                   = $d02b
.label VIC_SPR5_COL                   = $d02c
.label VIC_SPR6_COL                   = $d02d
.label VIC_SPR7_COL                   = $d02e
.label SID_V1_FREQ_LO                 = $d400
.label SID_V1_FREQ_HI                 = $d401
.label SID_V1_PW_LO                   = $d402
.label SID_V1_PW_HI                   = $d403
.label SID_V1_CTRL                    = $d404
.label SID_V1_AD                      = $d405
.label SID_V1_SR                      = $d406
.label SID_V2_FREQ_LO                 = $d407
.label SID_V2_FREQ_HI                 = $d408
.label SID_V2_PW_LO                   = $d409
.label SID_V2_PW_HI                   = $d40a
.label SID_V2_CTRL                    = $d40b
.label SID_V2_AD                      = $d40c
.label SID_V2_SR                      = $d40d
.label SID_V3_FREQ_LO                 = $d40e
.label SID_V3_FREQ_HI                 = $d40f
.label SID_V3_CTRL                    = $d412
.label SID_V3_AD                      = $d413
.label SID_V3_SR                      = $d414
.label SID_FC_HI                      = $d416
.label SID_RES_FILT                   = $d417
.label SID_MODE_VOL                   = $d418
.label SID_OSC3                       = $d41b
.label COLOR_RAM                      = $d800
.label CIA1_PRA                       = $dc00
.label CIA1_PRB                       = $dc01
.label CIA1_DDRA                      = $dc02
.label CIA1_CRA                       = $dc0e
.label CIA2_PRA                       = $dd00
.label KERNAL_IRQ                     = $ea31
.label KERNAL_IRQ_EXIT                = $ea81
.label SETLFS                         = $ffba
.label SETNAM                         = $ffbd
.label CLRCHN                         = $ffcc
.label CHRIN                          = $ffcf
.label LOAD                           = $ffd5
.label STOP                           = $ffe1

// ---------------------------------------------------------------- program image

// ============================================================================
// tape_buffer  ($0334-$03ff)
// Cassette buffer area: leftovers, partly used as a work buffer
// ============================================================================
* = $0334 "tape_buffer"
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0334
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0344
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0354
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0364
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0374
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0384
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0394
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03a4
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03b4
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03c4
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03d4
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03e4
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03f4

// ============================================================================
// screen  ($0400-$07ff)
// Screen RAM ($0400-$07E7) and sprite pointers ($07F8-$07FF).
// At start-up it still holds the original disk loader (typed into screen
// memory), which loaded "PIC" and "TILT". The cartridge enters at $0460,
// the loader's last two instructions.
// ============================================================================
* = $0400 "screen"
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0400
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0410
    .byte $20,$20,$20,$20,$20                   // $0420
    lda #$00                                    // $0425
    ldy #$01                                    // $0427
    ldx #$08                                    // $0429
    jsr SETLFS                                  // $042b
    lda #$03                                    // $042e
    ldx #$68                                    // $0430
    ldy #$04                                    // $0432
    jsr SETNAM                                  // $0434
    ldx #$ff                                    // $0437
    txs                                         // $0439
    cld                                         // $043a
    cli                                         // $043b
    lda #$00                                    // $043c
    jsr LOAD                                    // $043e
    jsr L081f+1                                 // $0441
    lda #$00                                    // $0444
    ldy #$01                                    // $0446
    ldx #$08                                    // $0448
    jsr SETLFS                                  // $044a
    lda #$04                                    // $044d
    ldx #$6b                                    // $044f
L0451:
    ldy #$04                                    // $0451
    jsr SETNAM                                  // $0453
    ldx #$ff                                    // $0456
    txs                                         // $0458
    cld                                         // $0459
    cli                                         // $045a
    lda #$00                                    // $045b
    jsr LOAD                                    // $045d
cart_entry:
    lda #$0b                                    // $0460
    sta VIC_CTRL1                               // $0462
    jmp start                                   // $0465
    .byte $50,$49,$43,$54,$49,$4c,$54,$57,$f1,$ca,$f1,$ed,$f6,$3e,$f1,$2f  // $0468
    .byte $f3,$66,$fe,$a5,$f4,$ed,$f5,$a9,$00,$a8,$99,$02,$00,$99,$00,$02  // $0478
    .byte $c0,$18,$90,$04,$c0,$1a,$90,$03,$99,$00,$03,$c8,$d0,$ec,$a2,$3c  // $0488
    .byte $a0,$03,$86,$b2,$84,$b3,$a9,$08,$85,$be,$a0,$80,$ad,$00,$80,$aa  // $0498
    .byte $49,$ff,$8d,$00,$80,$cd,$00,$80,$8e,$00,$80,$d0,$02,$a0,$a0,$a2  // $04a8
    .byte $00,$84,$c2,$18,$20,$2d,$fe,$a9,$08,$8d,$82,$02,$a9,$04,$8d,$88  // $04b8
    .byte $02,$60,$6a,$fc,$cd,$fb,$31,$ea,$2c,$f9,$a9,$7f,$8d,$0d,$dc,$8d  // $04c8
    .byte $0d,$dd,$8d,$00,$dc,$a9,$08,$8d,$0e,$dc,$8d,$0e,$dd,$8d,$0f,$dc  // $04d8
    .byte $8d,$0f,$dd,$a2,$00,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $04e8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $04f8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0508
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0518
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0528
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0538
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0548
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0558
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0568
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0578
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0588
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0598
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05a8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05b8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05c8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05d8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05e8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05f8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0608
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0618
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0628
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0638
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0648
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0658
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0668
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0678
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0688
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0698
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06a8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06b8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06c8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06d8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06e8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06f8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0708
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0718
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0728
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0738
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0748
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0758
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0768
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0778
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0788
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0798
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $07a8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $07b8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $07c8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $07d8
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $07e8
    .byte $20,$20,$20,$20,$20,$20,$20,$20       // $07f8

// ============================================================================
// basic  ($0800-$080c)
// BASIC line: 0 SYS2061
// ============================================================================
* = $0800 "basic"
    .byte $00,$0b,$08,$00,$00,$9e,$32,$30,$36,$31,$00,$00,$00  // $0800

// ============================================================================
// main  ($080d-$8eff)
// The TILT program
// ============================================================================
* = $080d "main"

// ----------------------------------------------------------------------------
// Start of the TILT program (SYS 2061; the cartridge gets here via $0460)
// ----------------------------------------------------------------------------
start:
    sei                                         // $080d
    lda #$36                                    // $080e  BASIC ROM off
    sta $01                                     // $0810
    lda VIC_CTRL1                               // $0812  screen off
    and #$ef                                    // $0815
    sta VIC_CTRL1                               // $0817
    lda #$00                                    // $081a  black border and background
    sta VIC_BORDER                              // $081c
L081f:
    sta VIC_BG0                                 // $081f
    lda #$01                                    // $0822  assume tampered
    sta tampered                                // $0824

// ----------------------------------------------------------------------------
// Copy protection / tamper check: the sum of $0980-$8DFF must be $3FDA:$37
// (A:X:Y). If it is not, 'tampered' is set and one character of the font gets
// replaced by an 'E' (tamper_glyph) - so changing the code shows up as a wrong
// glyph unless the checksum is corrected!
// ----------------------------------------------------------------------------
    jsr checksum                                // $0827  A:X:Y = checksum
    cmp #$da                                    // $082a
    bne save_mazes_loop                         // $082c
    cpx #$3f                                    // $082e
    bne save_mazes_loop                         // $0830
    cpy #$37                                    // $0832
    bne save_mazes_loop                         // $0834
    lda #$00                                    // $0836  checksum is right
    sta tampered                                // $0838

// ----------------------------------------------------------------------------
// Save the four 1K maze screens ($2000-$27FF and $7800-$7FFF in the loaded
// file) to $A000-$AFFF: both areas are reused at run time (character set at
// $2000, screen and colour buffers at $7800-$7FFF). draw_maze_screen copies a
// maze back from $A000 + maze * $400.
// ----------------------------------------------------------------------------
save_mazes_loop:
    ldx #$08                                    // $083b
    ldy #$00                                    // $083d  8 pages each
L083f:
    lda char($00),y                             // $083f
L0842:
    sta $a000,y                                 // $0842
L0845:
    lda colour_buffer,y                         // $0845
L0848:
    sta $a800,y                                 // $0848
    iny                                         // $084b
    bne L083f                                   // $084c
    inc L083f+2                                 // $084e  self-modifying: next page
    inc L0842+2                                 // $0851
    inc L0845+2                                 // $0854
    inc L0848+2                                 // $0857
    dex                                         // $085a
    bne L083f                                   // $085b

// ----------------------------------------------------------------------------
// $1D00-$1D9F -> $2320 (characters)
// ----------------------------------------------------------------------------
    ldy #$00                                    // $085d
L085f:
    lda chars_1d00,y                            // $085f
    sta char($64),y                             // $0862
    iny                                         // $0865
    cpy #$a0                                    // $0866
    bcc L085f                                   // $0868
    ldx #$fe                                    // $086a  reset the stack
    sei                                         // $086c
    txs                                         // $086d
    cld                                         // $086e
    lda #$0b                                    // $086f
    sta VIC_CTRL1                               // $0871
    lda #$c8                                    // $0874  40 columns, multicolour off
    sta VIC_CTRL2                               // $0876
    lda #$15                                    // $0879  screen $0400, upper case ROM font
    sta VIC_MEMSETUP                            // $087b
    lda #$97                                    // $087e  VIC bank 0 ($0000-$3FFF)
    sta CIA2_PRA                                // $0880
    cld                                         // $0883
    jmp start_game                              // $0884

// ----------------------------------------------------------------------------
// Sum of all bytes $0980-$8DFF: returns A = low byte, X/Y = 16 bit carry count
// ----------------------------------------------------------------------------
checksum:
    lda #$09                                    // $0887
    sta zp_fc                                   // $0889
    lda #$00                                    // $088b
    sta zp_fb                                   // $088d
    sta zp_fd                                   // $088f
    sta zp_fe                                   // $0891
    ldy #$80                                    // $0893
L0895:
    clc                                         // $0895
    adc (zp_fb),y                               // $0896
    bcc L08a0                                   // $0898
    inc zp_fd                                   // $089a
    bne L08a0                                   // $089c
    inc zp_fe                                   // $089e
L08a0:
    iny                                         // $08a0
    bne L0895                                   // $08a1
    inc zp_fc                                   // $08a3
    ldx zp_fc                                   // $08a5
    cpx #$8e                                    // $08a7
    bcc L0895                                   // $08a9
    ldx zp_fd                                   // $08ab
    ldy zp_fe                                   // $08ad
    rts                                         // $08af

// ----------------------------------------------------------------------------
// Leftover of the developer's BASIC loader (tokenized, $93 = LOAD):
//   LOAD "CHAR35-42.MOD",8,1   LOAD "CHAR100-119.MOD",8,1   LOAD "TABLES.MOD",8,1
//   LOAD "SPRITES.MOD",8,1     LOAD "COSINE.MOD",8,1        LOAD "DEMO.MOD",8,1
//   LOAD "MUSIC.MOD",8,1
// The game was put together from these modules. Not used.
// ----------------------------------------------------------------------------
basic_leftovers:
    .byte $3c,$00,$93,$22,$43,$48,$41,$52,$33,$35,$2d,$34,$32,$2e,$4d,$4f  // $08b0  "<.."CHAR35-42.MO"
    .byte $44,$22,$2c,$38,$2c,$31,$00,$e2,$08,$46,$00,$93,$22,$43,$48,$41  // $08c0  "D",8,1...F.."CHA"
    .byte $52,$31,$30,$30,$2d,$31,$31,$39,$2e,$4d,$4f,$44,$22,$2c,$38,$2c  // $08d0  "R100-119.MOD",8,"
    .byte $31,$00,$f8,$08,$50,$00,$93,$22,$54,$41,$42,$4c,$45,$53,$2e,$4d  // $08e0  "1...P.."TABLES.M"
    .byte $4f,$44,$22,$2c,$38,$2c,$31,$00,$0f,$09,$5a,$00,$93,$22,$53,$50  // $08f0  "OD",8,1...Z.."SP"
    .byte $52,$49,$54,$45,$53,$2e,$4d,$4f,$44,$22,$2c,$38,$2c,$31,$00,$25  // $0900  "RITES.MOD",8,1.%"
    .byte $09,$64,$00,$93,$22,$43,$4f,$53,$49,$4e,$45,$2e,$4d,$4f,$44,$22  // $0910  ".d.."COSINE.MOD""
    .byte $2c,$38,$2c,$31,$00,$39,$09,$6e,$00,$93,$22,$44,$45,$4d,$4f,$2e  // $0920  ",8,1.9.n.."DEMO."
    .byte $4d,$4f,$44,$22,$2c,$38,$2c,$31,$00,$4e,$09,$73,$00,$93,$22,$4d  // $0930  "MOD",8,1.N.s.."M"
    .byte $55,$53,$49,$43,$2e,$4d,$4f,$44,$22,$2c,$38,$2c,$31,$00,$54,$09  // $0940  "USIC.MOD",8,1.T."
    .byte $78,$00,$80,$00,$00,$00,$42,$00,$84,$30,$00,$00,$00,$00,$00,$00  // $0950  "x.....B..0......"
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cf  // $0960  "................"
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00  // $0970  "..........@....."

// ----------------------------------------------------------------------------
// Game start. $0984 (SYS 2436) is a developer entry: the game then runs
// from the raster interrupt and BASIC stays usable.
// ----------------------------------------------------------------------------
start_game:
    lda #$00                                    // $0980
    beq start_common                            // $0982
start_dev_mode:
    lda #$01                                    // $0984
start_common:
    sta dev_mode                                // $0986
    lda tampered                                // $0989  tampered: replace a glyph of the font copy
    beq L0999                                   // $098c
    ldx #$07                                    // $098e
L0990:
    lda tamper_glyph,x                          // $0990
    sta status_font,x                           // $0993
    dex                                         // $0996
    bpl L0990                                   // $0997
L0999:
    lda #$00                                    // $0999
    sta dev_maze                                // $099b
    lda #$00                                    // $099e
    sta hiscore                                 // $09a0
    sta hiscore+1                               // $09a3
    sta hiscore+2                               // $09a6
    lda #$01                                    // $09a9
    sta cefa_flag                               // $09ab
    ldx #$2f                                    // $09ae
L09b0:
    ldy #$07                                    // $09b0
L09b2:
    lda digit_glyphs,y                          // $09b2  score display: six "0" glyphs -> $2780-$27AF
    sta char($f0),x                             // $09b5
    dex                                         // $09b8
    dey                                         // $09b9
    bpl L09b2                                   // $09ba
    txa                                         // $09bc
    bpl L09b0                                   // $09bd
    sei                                         // $09bf
    ldy #$00                                    // $09c0
L09c2:
    lda status_font,y                           // $09c2  font for the status line -> $2650-$26D7
    sta char($ca),y                             // $09c5
    iny                                         // $09c8
    cpy #$88                                    // $09c9
    bcc L09c2                                   // $09cb
    jmp main_loop                               // $09cd  go to the main loop
tamper_glyph:
    .byte $00,$7e,$60,$60,$78,$60,$60,$7e       // $09d0

// ----------------------------------------------------------------------------
// Params: A = velocity (signed), C = 1
// Returns: $FB/$FC = velocity * 4 (or more: X+1 shifts) as a signed 16 bit
// position delta
// ----------------------------------------------------------------------------
velocity_to_delta:
    ldx #$01                                    // $09d8  C=1: shift count 2 (velocity * 4)
    sta zp_fb                                   // $09da
    and #$80                                    // $09dc  remember the sign
    sta zp_fd                                   // $09de
    bpl L09eb                                   // $09e0
    lda zp_fb                                   // $09e2  work with |velocity|
    eor #$ff                                    // $09e4
    clc                                         // $09e6
    adc #$01                                    // $09e7
    sta zp_fb                                   // $09e9
L09eb:
    lda #$00                                    // $09eb
L09ed:
    asl zp_fb                                   // $09ed  shift into zp_fb (low) and A (high)
    rol                                         // $09ef
    dex                                         // $09f0
    bpl L09ed                                   // $09f1
    sta zp_fc                                   // $09f3
    lda zp_fd                                   // $09f5  negative: negate the 16 bit result
    bpl L0a0a                                   // $09f7
    lda zp_fb                                   // $09f9
    eor #$ff                                    // $09fb
    clc                                         // $09fd
    adc #$01                                    // $09fe
    sta zp_fb                                   // $0a00
    lda zp_fc                                   // $0a02
    eor #$ff                                    // $0a04
    adc #$00                                    // $0a06
    sta zp_fc                                   // $0a08
L0a0a:
    rts                                         // $0a0a

// ----------------------------------------------------------------------------
// Add the velocity to the ball position (X 24 bit: frac, low, bit 8;
// Y 16 bit: frac, position)
// ----------------------------------------------------------------------------
move_ball:
    lda ball_vx                                 // $0a0b  X: frac/low += velocity * 4
    sec                                         // $0a0e
    jsr velocity_to_delta                       // $0a0f
    lda ball_x_frac                             // $0a12
    clc                                         // $0a15
    adc zp_fb                                   // $0a16
    sta ball_x_frac                             // $0a18
    lda ball_x                                  // $0a1b
    adc zp_fc                                   // $0a1e
    sta ball_x                                  // $0a20
    lda zp_fc                                   // $0a23  carry into bit 8 (sign of the delta decides up or down)
    bcs L0a2d                                   // $0a25
    bpl L0a34                                   // $0a27
    ldx #$00                                    // $0a29
    beq L0a31                                   // $0a2b
L0a2d:
    bmi L0a34                                   // $0a2d
    ldx #$01                                    // $0a2f
L0a31:
    stx ball_x_hi                               // $0a31
L0a34:
    lda ball_vy                                 // $0a34  Y: frac/position += velocity * 4
    sec                                         // $0a37
    jsr velocity_to_delta                       // $0a38
    lda ball_y_frac                             // $0a3b
    clc                                         // $0a3e
    adc zp_fb                                   // $0a3f
    sta ball_y_frac                             // $0a41
    lda ball_y                                  // $0a44
    adc zp_fc                                   // $0a47
    sta ball_y                                  // $0a49
    rts                                         // $0a4c

// ----------------------------------------------------------------------------
// Read the tilt direction from the controls and steer the ball velocity
// toward the target speed for that direction. A diagonal held for a while
// is remembered for a few frames (diag_hold_*), so that releasing one
// direction a little early does not stop the diagonal roll.
// ----------------------------------------------------------------------------
steer_ball:
    lda tilt_dx                                 // $0a4d  remember the old tilt direction
    sta tilt_dx_old                             // $0a50
    lda tilt_dy                                 // $0a53
    sta tilt_dy_old                             // $0a56
    lda controls                                // $0a59
    sta zp_fb                                   // $0a5c
    ldy #$03                                    // $0a5e  X = number of directions pressed
    ldx #$00                                    // $0a60
L0a62:
    lsr                                         // $0a62
    bcs L0a66                                   // $0a63
    inx                                         // $0a65
L0a66:
    dey                                         // $0a66
    bpl L0a62                                   // $0a67
    cpx #$02                                    // $0a69  diagonal: remember it
    bne L0a94                                   // $0a6b
    lda #$00                                    // $0a6d
    sta diag_hold_count                         // $0a6f
    lda tilt_dx                                 // $0a72
    sta diag_tilt_dx                            // $0a75
    lda tilt_dy                                 // $0a78
    sta diag_tilt_dy                            // $0a7b
    lda diag_hold_state                         // $0a7e  held long enough: diagonal sound once
    bmi L0a94                                   // $0a81
    clc                                         // $0a83
    adc #$01                                    // $0a84
    cmp #$05                                    // $0a86
    bne L0a91                                   // $0a88
    lda #$02                                    // $0a8a
    sta diagonal_sound_timer                    // $0a8c
    lda #$80                                    // $0a8f
L0a91:
    sta diag_hold_state                         // $0a91
L0a94:
    cpx #$01                                    // $0a94  one direction after a diagonal: keep the diagonal for 8 frames
    bne L0aa7                                   // $0a96
    lda diag_hold_state                         // $0a98
    bpl L0abc                                   // $0a9b
    inc diag_hold_count                         // $0a9d
    lda diag_hold_count                         // $0aa0
    cmp #$08                                    // $0aa3
    beq L0abc                                   // $0aa5
L0aa7:
    cpx #$00                                    // $0aa7  no direction: restore a recent diagonal
    bne L0ac4                                   // $0aa9
    lda diag_hold_count                         // $0aab
    beq L0abc                                   // $0aae
    lda diag_tilt_dx                            // $0ab0
    sta tilt_dx                                 // $0ab3
    lda diag_tilt_dy                            // $0ab6
    sta tilt_dy                                 // $0ab9
L0abc:
    lda #$00                                    // $0abc
    sta diag_hold_count                         // $0abe
    sta diag_hold_state                         // $0ac1
L0ac4:
    cpx #$00                                    // $0ac4  set tilt_dx / tilt_dy from the control bits
    beq L0afa                                   // $0ac6
    lda #$00                                    // $0ac8
    sta tilt_dx                                 // $0aca
    sta tilt_dy                                 // $0acd
    lda zp_fb                                   // $0ad0  left (bit 2)
    and #$04                                    // $0ad2
    bne L0ada                                   // $0ad4
    ldx #$ff                                    // $0ad6
    bne L0ae2                                   // $0ad8
L0ada:
    lda zp_fb                                   // $0ada  right (bit 3)
    and #$08                                    // $0adc
    bne L0ae5                                   // $0ade
    ldx #$01                                    // $0ae0
L0ae2:
    stx tilt_dx                                 // $0ae2
L0ae5:
    lda zp_fb                                   // $0ae5  up (bit 0)
    and #$01                                    // $0ae7
    bne L0aef                                   // $0ae9
    ldx #$ff                                    // $0aeb
    bne L0af7                                   // $0aed
L0aef:
    lda zp_fb                                   // $0aef  down (bit 1)
    and #$02                                    // $0af1
    bne L0afa                                   // $0af3
    ldx #$01                                    // $0af5
L0af7:
    stx tilt_dy                                 // $0af7
L0afa:
    ldx tilt_dx                                 // $0afa  target speeds for X and Y
    ldy tilt_dy                                 // $0afd
    jsr target_speed                            // $0b00
    sta zp_fb                                   // $0b03
    ldx tilt_dy                                 // $0b05
    ldy tilt_dx                                 // $0b08
    jsr target_speed                            // $0b0b
    sta zp_fc                                   // $0b0e
    lda tilt_dx                                 // $0b10  direction changed: new acceleration split
    cmp tilt_dx_old                             // $0b13
    bne L0b20                                   // $0b16
    lda tilt_dy                                 // $0b18
    cmp tilt_dy_old                             // $0b1b
    beq L0b23                                   // $0b1e
L0b20:
    jsr calc_accel                              // $0b20
L0b23:
    lda steering_on                             // $0b23  steering off while the ball appears / drops
    beq L0b44                                   // $0b26
    lda ball_vx                                 // $0b28  velocity -> target speed by the acceleration
    ldx zp_fb                                   // $0b2b
    ldy accel_x                                 // $0b2d
    jsr approach                                // $0b30
    sta ball_vx                                 // $0b33
    lda ball_vy                                 // $0b36
    ldx zp_fc                                   // $0b39
    ldy accel_y                                 // $0b3b
    jsr approach                                // $0b3e
    sta ball_vy                                 // $0b41
L0b44:
    rts                                         // $0b44

// ----------------------------------------------------------------------------
// Params: X = tilt direction of this axis, Y = of the other axis (-1/0/1)
// Returns: A = target velocity + $80 for this axis and speed class.
// Diagonal tilts give a lower speed per axis (e.g. 68 instead of 96).
// ----------------------------------------------------------------------------
target_speed:
    iny                                         // $0b45  other axis -1/+1 -> row 0 (diagonal), 0 -> row 1
    cpy #$02                                    // $0b46
    bne L0b4c                                   // $0b48
    ldy #$00                                    // $0b4a
L0b4c:
    tya                                         // $0b4c
    asl                                         // $0b4d
    asl                                         // $0b4e
    stx zp_fd                                   // $0b4f
    sec                                         // $0b51
    adc zp_fd                                   // $0b52
    sta zp_fd                                   // $0b54
    lda speed_class                             // $0b56  8 entries per speed class
    asl                                         // $0b59
    asl                                         // $0b5a
    asl                                         // $0b5b
    clc                                         // $0b5c
    adc zp_fd                                   // $0b5d
    tax                                         // $0b5f
    lda target_speed_table,x                    // $0b60
    rts                                         // $0b63

// ----------------------------------------------------------------------------
// Params: A = velocity (signed), X = target velocity + $80, Y = step
// Returns: A moved by at most Y toward the target
// ----------------------------------------------------------------------------
approach:
    stx zp_fd                                   // $0b64
    sty zp_fe                                   // $0b66
    clc                                         // $0b68
    adc #$80                                    // $0b69
    cmp zp_fd                                   // $0b6b
    bcs L0b7a                                   // $0b6d
    clc                                         // $0b6f
    adc zp_fe                                   // $0b70
    bcs L0b83                                   // $0b72
    cmp zp_fd                                   // $0b74
    bcs L0b83                                   // $0b76
    bcc L0b85                                   // $0b78
L0b7a:
    sec                                         // $0b7a
    sbc zp_fe                                   // $0b7b
    bcc L0b83                                   // $0b7d
    cmp zp_fd                                   // $0b7f
    bcs L0b85                                   // $0b81
L0b83:
    lda zp_fd                                   // $0b83
L0b85:
    sec                                         // $0b85
    sbc #$80                                    // $0b86
    rts                                         // $0b88

// ----------------------------------------------------------------------------
// Target velocities + $80, 8 bytes per speed class:
// X = -1, 0, +1 (diagonal), unused, X = -1, 0, +1 (straight), unused
// ----------------------------------------------------------------------------
target_speed_table:
    .byte $3c,$80,$c4,$00,$20,$80,$e0,$00       // $0b89
    .byte $36,$80,$ca,$00,$18,$80,$e8,$00       // $0b91
    .byte $31,$80,$cf,$00,$10,$80,$f0,$00       // $0b99
    .byte $2b,$80,$d5,$00,$08,$80,$f8,$00       // $0ba1
    .byte $26,$80,$da,$00,$00,$80,$ff,$00       // $0ba9

// ----------------------------------------------------------------------------
// Split the acceleration over X and Y in proportion to how far each
// velocity is from its target, so the ball turns smoothly.
// ----------------------------------------------------------------------------
calc_accel:
    ldx speed_class                             // $0bb1
    lda accel_steps_table,x                     // $0bb4
    sta zp_ff                                   // $0bb7
    lda ball_vx                                 // $0bb9
    clc                                         // $0bbc
    adc #$80                                    // $0bbd
    sec                                         // $0bbf
    sbc zp_fb                                   // $0bc0
    bcs L0bc9                                   // $0bc2
    eor #$ff                                    // $0bc4
    clc                                         // $0bc6
    adc #$01                                    // $0bc7
L0bc9:
    sta dv_x                                    // $0bc9
    lda ball_vy                                 // $0bcc
    clc                                         // $0bcf
    adc #$80                                    // $0bd0
    sec                                         // $0bd2
    sbc zp_fc                                   // $0bd3
    bcs L0bdc                                   // $0bd5
    eor #$ff                                    // $0bd7
    clc                                         // $0bd9
    adc #$01                                    // $0bda
L0bdc:
    sta dv_y                                    // $0bdc
    ldx zp_ff                                   // $0bdf
    stx accel_x                                 // $0be1
    stx accel_y                                 // $0be4
    ldy #$00                                    // $0be7
    lda dv_x                                    // $0be9
    cmp dv_y                                    // $0bec
    bcc L0bf2                                   // $0bef
    iny                                         // $0bf1
L0bf2:
    lda #$00                                    // $0bf2
    sta zp_fe                                   // $0bf4
L0bf6:
    clc                                         // $0bf6
    adc dv_x,y                                  // $0bf7
    bcc L0bfe                                   // $0bfa
    inc zp_fe                                   // $0bfc
L0bfe:
    dex                                         // $0bfe
    bne L0bf6                                   // $0bff
    sta zp_fd                                   // $0c01
    tya                                         // $0c03
    eor #$01                                    // $0c04
    tay                                         // $0c06
    lda dv_x,y                                  // $0c07
    beq L0c23                                   // $0c0a
    ldx #$00                                    // $0c0c
L0c0e:
    lda zp_fd                                   // $0c0e
    sec                                         // $0c10
    sbc dv_x,y                                  // $0c11
    sta zp_fd                                   // $0c14
    lda zp_fe                                   // $0c16
    sbc #$00                                    // $0c18
    sta zp_fe                                   // $0c1a
    inx                                         // $0c1c
    bcs L0c0e                                   // $0c1d
    cpx zp_ff                                   // $0c1f
    bcc L0c25                                   // $0c21
L0c23:
    ldx zp_ff                                   // $0c23
L0c25:
    tya                                         // $0c25
    eor #$01                                    // $0c26
    tay                                         // $0c28
    txa                                         // $0c29
    sta accel_x,y                               // $0c2a
    rts                                         // $0c2d
accel_steps_table:
    .byte $05,$06,$06,$07,$07                   // $0c2e

// ----------------------------------------------------------------------------
// Build the wall-edge characters ($2008-$20C7) for the current maze
// shift: params zp_fb = Y shift 0-8, zp_fc = X shift 0-8 (4 = level).
// The maze walls have a lit side face whose width follows the tilt;
// these characters hold every combination of edges.
// ----------------------------------------------------------------------------
build_wall_chars:
    lda zp_fc                                   // $0c33
    cmp #$04                                    // $0c35
    bne L0c46                                   // $0c37
    ldx #$07                                    // $0c39
    jsr clear_edges_left                        // $0c3b
    ldx #$00                                    // $0c3e
    jsr clear_edges_right                       // $0c40
    clc                                         // $0c43
    bcc L0c6e                                   // $0c44
L0c46:
    bcs L0c5b                                   // $0c46
    asl                                         // $0c48
    sta zp_fe                                   // $0c49
    tax                                         // $0c4b
    dex                                         // $0c4c
    jsr clear_edges_left                        // $0c4d
    ldx #$00                                    // $0c50
    jsr clear_edges_right                       // $0c52
    jsr edge_chars_left                         // $0c55
    clc                                         // $0c58
    bcc L0c6e                                   // $0c59
L0c5b:
    asl                                         // $0c5b
    sec                                         // $0c5c
    sbc #$09                                    // $0c5d
    sta zp_fe                                   // $0c5f
    tax                                         // $0c61
    inx                                         // $0c62
    jsr clear_edges_right                       // $0c63
    ldx #$07                                    // $0c66
    jsr clear_edges_left                        // $0c68
    jsr edge_chars_right                        // $0c6b
L0c6e:
    lda zp_fb                                   // $0c6e
    cmp #$04                                    // $0c70
    bne L0c7d                                   // $0c72
    jsr clear_edges_top                         // $0c74
    jsr clear_edges_bottom                      // $0c77
    clc                                         // $0c7a
    bcc L0c95                                   // $0c7b
L0c7d:
    bcs L0c8a                                   // $0c7d
    sta zp_fe                                   // $0c7f
    jsr clear_edges_bottom                      // $0c81
    jsr edge_chars_top                          // $0c84
    clc                                         // $0c87
    bcc L0c95                                   // $0c88
L0c8a:
    sec                                         // $0c8a
    sbc #$05                                    // $0c8b
    sta zp_fe                                   // $0c8d
    jsr clear_edges_top                         // $0c8f
    jsr edge_chars_bottom                       // $0c92
L0c95:
    ldx #$07                                    // $0c95
L0c97:
    lda char($06),x                             // $0c97
    eor char($0a),x                             // $0c9a
    ora char($08),x                             // $0c9d
    sta char($11),x                             // $0ca0
    lda char($0e),x                             // $0ca3
    eor char($0a),x                             // $0ca6
    ora char($0c),x                             // $0ca9
    sta char($12),x                             // $0cac
    lda char($0e),x                             // $0caf
    eor char($02),x                             // $0cb2
    ora char($10),x                             // $0cb5
    sta char($13),x                             // $0cb8
    lda char($02),x                             // $0cbb
    eor char($06),x                             // $0cbe
    ora char($04),x                             // $0cc1
    sta char($14),x                             // $0cc4
    lda char($01),x                             // $0cc7
    and char($03),x                             // $0cca
    sta char($15),x                             // $0ccd
    lda char($05),x                             // $0cd0
    and char($07),x                             // $0cd3
    sta char($16),x                             // $0cd6
    lda char($0b),x                             // $0cd9
    and char($09),x                             // $0cdc
    sta char($17),x                             // $0cdf
    lda char($0f),x                             // $0ce2
    and char($0d),x                             // $0ce5
    sta char($18),x                             // $0ce8
    dex                                         // $0ceb
    bpl L0c97                                   // $0cec
    rts                                         // $0cee
clear_edges_left:
    lda #$00                                    // $0cef
L0cf1:
    cpx #$00                                    // $0cf1
    bmi L0d08                                   // $0cf3
    sta char($10),x                             // $0cf5
    sta char($01),x                             // $0cf8
    sta char($02),x                             // $0cfb
    sta char($03),x                             // $0cfe
    sta char($04),x                             // $0d01
    dex                                         // $0d04
    jmp L0cf1                                   // $0d05
L0d08:
    rts                                         // $0d08
clear_edges_right:
    lda #$00                                    // $0d09
L0d0b:
    cpx #$08                                    // $0d0b
    bcs L0d22                                   // $0d0d
    sta char($0c),x                             // $0d0f
    sta char($0b),x                             // $0d12
    sta char($0a),x                             // $0d15
    sta char($09),x                             // $0d18
    sta char($08),x                             // $0d1b
    inx                                         // $0d1e
    jmp L0d0b                                   // $0d1f
L0d22:
    rts                                         // $0d22
clear_edges_top:
    ldx #$07                                    // $0d23
    lda #$00                                    // $0d25
L0d27:
    sta char($0d),x                             // $0d27
    sta char($0e),x                             // $0d2a
    sta char($0f),x                             // $0d2d
    dex                                         // $0d30
    bpl L0d27                                   // $0d31
    rts                                         // $0d33
clear_edges_bottom:
    ldx #$07                                    // $0d34
    lda #$00                                    // $0d36
L0d38:
    sta char($05),x                             // $0d38
    sta char($06),x                             // $0d3b
    sta char($07),x                             // $0d3e
    dex                                         // $0d41
    bpl L0d38                                   // $0d42
    rts                                         // $0d44

// ----------------------------------------------------------------------------
// Ease the tilt angles toward the tilt direction and derive the
// perspective shift (tilt_level, cf0e/cf0f)
// ----------------------------------------------------------------------------
ease_tilt:
    ldx tilt_dx                                 // $0d45
    lda tilt_angle_x                            // $0d48
    sta tilt_angle_x_old                        // $0d4b
    jsr ease_angle                              // $0d4e
    sta tilt_angle_x                            // $0d51
    ldx tilt_dy                                 // $0d54
    lda tilt_angle_y                            // $0d57
    sta tilt_angle_y_old                        // $0d5a
    jsr ease_angle                              // $0d5d
    sta tilt_angle_y                            // $0d60
    lda tilt_angle_x                            // $0d63
    sec                                         // $0d66
    sbc #$02                                    // $0d67
    bcs L0d6d                                   // $0d69
    lda #$00                                    // $0d6b
L0d6d:
    ldx #$09                                    // $0d6d
    sec                                         // $0d6f
L0d70:
    dex                                         // $0d70
    sbc #$1c                                    // $0d71
    bcs L0d70                                   // $0d73
    txa                                         // $0d75
    bpl L0d7a                                   // $0d76
    ldx #$00                                    // $0d78
L0d7a:
    stx tilt_level_x                            // $0d7a
    lda tilt_level_shift_x,x                    // $0d7d
    sta fine_scroll_x                           // $0d80
    lda tilt_angle_y                            // $0d83
    sec                                         // $0d86
    sbc #$02                                    // $0d87
    bcs L0d8d                                   // $0d89
    lda #$00                                    // $0d8b
L0d8d:
    ldx #$09                                    // $0d8d
    sec                                         // $0d8f
L0d90:
    dex                                         // $0d90
    sbc #$1c                                    // $0d91
    bcs L0d90                                   // $0d93
    txa                                         // $0d95
    bpl L0d9a                                   // $0d96
    ldx #$00                                    // $0d98
L0d9a:
    stx tilt_level_y                            // $0d9a
    lda tilt_level_shift_y,x                    // $0d9d
    sta fine_scroll_y                           // $0da0
    rts                                         // $0da3
pick_hole_sprite:
    ldx tilt_shift_y                            // $0da4
    lda hole_sprite_index,x                     // $0da7
    asl                                         // $0daa
    asl                                         // $0dab
    asl                                         // $0dac
    ldx tilt_shift_x                            // $0dad
    clc                                         // $0db0
    adc hole_sprite_index,x                     // $0db1
    tax                                         // $0db4
    lda hole_sprite_table,x                     // $0db5
    sta hole_sprite                             // $0db8
    rts                                         // $0dbb
tilt_level_shift_x:
    .byte $07,$07,$06,$05,$04,$03,$02,$01,$00   // $0dbc
tilt_level_shift_y:
    .byte $02,$02,$01,$00,$07,$06,$05,$04,$03   // $0dc5
hole_sprite_index:
    .byte $00,$01,$01,$02,$02,$02,$03,$03,$04   // $0dce
hole_sprite_table:
    .byte $bc,$bb,$b8,$bd,$be,$00,$00,$00,$bb,$bb,$b7,$bd,$bd,$00,$00,$00  // $0dd7
    .byte $ba,$b9,$b6,$b9,$ba,$00,$00,$00,$bd,$bd,$b7,$bb,$bb,$00,$00,$00  // $0de7
    .byte $be,$bd,$b8,$bb,$bc,$00,$00,$00       // $0df7

// ----------------------------------------------------------------------------
// Params: A = angle, X = direction (-1/0/1)
// Returns: A moved by tilt_rate toward 0, $80 or 255
// ----------------------------------------------------------------------------
ease_angle:
    cpx #$00                                    // $0dff
    bne L0e18                                   // $0e01
    tay                                         // $0e03
    bpl L0e0f                                   // $0e04
    sec                                         // $0e06
    sbc tilt_rate                               // $0e07
    bmi L0e0e                                   // $0e0a
    lda #$80                                    // $0e0c
L0e0e:
    rts                                         // $0e0e
L0e0f:
    clc                                         // $0e0f
    adc tilt_rate                               // $0e10
    bpl L0e17                                   // $0e13
    lda #$80                                    // $0e15
L0e17:
    rts                                         // $0e17
L0e18:
    cpx #$ff                                    // $0e18
    bne L0e25                                   // $0e1a
    sec                                         // $0e1c
    sbc tilt_rate                               // $0e1d
    bcs L0e24                                   // $0e20
    lda #$00                                    // $0e22
L0e24:
    rts                                         // $0e24
L0e25:
    clc                                         // $0e25
    adc tilt_rate                               // $0e26
    bcc L0e2d                                   // $0e29
    lda #$ff                                    // $0e2b
L0e2d:
    rts                                         // $0e2d
edge_chars_left:
    ldy zp_fb                                   // $0e2e
    cpy #$05                                    // $0e30
    bcs L0e47                                   // $0e32
    ldx zp_fe                                   // $0e34
L0e36:
    lda #$55                                    // $0e36
    sta char($01),x                             // $0e38
    lda #$00                                    // $0e3b
    sta char($04),x                             // $0e3d
    inx                                         // $0e40
    cpx #$08                                    // $0e41
    bcc L0e36                                   // $0e43
    bcs L0e7f                                   // $0e45
L0e47:
    tya                                         // $0e47
    sec                                         // $0e48
    sbc #$05                                    // $0e49
    asl                                         // $0e4b
    asl                                         // $0e4c
    asl                                         // $0e4d
    asl                                         // $0e4e
    sta zp_fd                                   // $0e4f
    lda #$03                                    // $0e51
    sec                                         // $0e53
    sbc zp_fc                                   // $0e54
    asl                                         // $0e56
    asl                                         // $0e57
    clc                                         // $0e58
    adc zp_fd                                   // $0e59
    sta zp_fd                                   // $0e5b
    ldx #$00                                    // $0e5d
L0e5f:
    ldy zp_fd                                   // $0e5f
    lda edge_shade_left,y                       // $0e61
    sta char($04),x                             // $0e64
    sta char($04)+1,x                           // $0e67
    lda edge_pixels_table,y                     // $0e6a
    tay                                         // $0e6d
    lda edge_fill_left,y                        // $0e6e
    sta char($01),x                             // $0e71
    inx                                         // $0e74
    sta char($01),x                             // $0e75
    inc zp_fd                                   // $0e78
    inx                                         // $0e7a
    cpx #$08                                    // $0e7b
    bcc L0e5f                                   // $0e7d
L0e7f:
    ldx zp_fe                                   // $0e7f
    lda #$55                                    // $0e81
L0e83:
    sta char($02),x                             // $0e83
    inx                                         // $0e86
    cpx #$08                                    // $0e87
    bne L0e83                                   // $0e89
    ldy zp_fb                                   // $0e8b
    cpy #$04                                    // $0e8d
    bcc L0ea4                                   // $0e8f
    ldx zp_fe                                   // $0e91
L0e93:
    lda #$55                                    // $0e93
    sta char($03),x                             // $0e95
    lda #$00                                    // $0e98
    sta char($10),x                             // $0e9a
    inx                                         // $0e9d
    cpx #$08                                    // $0e9e
    bcc L0e93                                   // $0ea0
    bcs L0edf                                   // $0ea2
L0ea4:
    sty zp_fd                                   // $0ea4
    lda #$03                                    // $0ea6
    sec                                         // $0ea8
    sbc zp_fd                                   // $0ea9
    asl                                         // $0eab
    asl                                         // $0eac
    asl                                         // $0ead
    asl                                         // $0eae
    sta zp_fd                                   // $0eaf
    lda #$03                                    // $0eb1
    sec                                         // $0eb3
    sbc zp_fc                                   // $0eb4
    asl                                         // $0eb6
    asl                                         // $0eb7
    clc                                         // $0eb8
    adc zp_fd                                   // $0eb9
    sta zp_fd                                   // $0ebb
    ldx #$00                                    // $0ebd
L0ebf:
    ldy zp_fd                                   // $0ebf
    lda edge_shade_right,y                      // $0ec1
    sta char($10),x                             // $0ec4
    sta char($10)+1,x                           // $0ec7
    lda edge_pixels_table,y                     // $0eca
    tay                                         // $0ecd
    lda edge_fill_right,y                       // $0ece
    sta char($03),x                             // $0ed1
    inx                                         // $0ed4
    sta char($03),x                             // $0ed5
    inc zp_fd                                   // $0ed8
    inx                                         // $0eda
    cpx #$08                                    // $0edb
    bcc L0ebf                                   // $0edd
L0edf:
    rts                                         // $0edf
edge_pixels_table:
    .byte $00,$00,$00,$03,$00,$00,$03,$04,$00,$03,$03,$04,$03,$03,$04,$04  // $0ee0
    .byte $00,$00,$00,$02,$00,$00,$02,$03,$00,$02,$03,$04,$02,$03,$03,$04  // $0ef0
    .byte $00,$00,$00,$01,$00,$00,$01,$03,$00,$01,$02,$03,$01,$02,$03,$04  // $0f00
    .byte $00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$01,$03,$00,$01,$02,$03  // $0f10
edge_pixels_table2:
    .byte $00,$01,$01,$01,$01,$02,$02,$02,$01,$03,$03,$03,$02,$04,$04,$04  // $0f20
    .byte $00,$00,$01,$01,$00,$01,$02,$02,$01,$02,$03,$03,$01,$03,$04,$04  // $0f30
    .byte $00,$00,$00,$01,$00,$01,$01,$02,$00,$01,$02,$03,$01,$02,$03,$04  // $0f40
    .byte $00,$00,$00,$00,$00,$00,$01,$01,$00,$01,$01,$02,$00,$01,$02,$03  // $0f50
edge_fill_left:
    .byte $00,$01,$05,$15,$55                   // $0f60
edge_fill_right:
    .byte $00,$40,$50,$54,$55                   // $0f65
edge_shade_left:
    .byte $00,$00,$00,$40,$00,$00,$40,$40,$00,$40,$40,$40,$40,$40,$40,$40  // $0f6a
    .byte $00,$00,$00,$50,$00,$00,$40,$10,$00,$40,$10,$10,$40,$10,$10,$10  // $0f7a
    .byte $00,$00,$00,$54,$00,$00,$50,$04,$00,$50,$44,$14,$50,$44,$44,$14  // $0f8a
    .byte $00,$00,$00,$55,$00,$00,$54,$01,$00,$54,$41,$15,$54,$51,$45,$15  // $0f9a
edge_shade_right:
    .byte $00,$00,$00,$01,$00,$00,$01,$01,$00,$01,$01,$01,$01,$01,$01,$01  // $0faa
    .byte $00,$00,$00,$05,$00,$00,$01,$04,$00,$01,$04,$04,$01,$04,$04,$04  // $0fba
    .byte $00,$00,$00,$15,$00,$00,$05,$10,$00,$05,$11,$14,$05,$11,$11,$14  // $0fca
    .byte $00,$00,$00,$55,$00,$00,$15,$40,$00,$15,$41,$54,$15,$45,$51,$54  // $0fda
edge_chars_right:
    ldy zp_fb                                   // $0fea
    cpy #$05                                    // $0fec
    bcs L1001                                   // $0fee
    ldx zp_fe                                   // $0ff0
L0ff2:
    lda #$55                                    // $0ff2
    sta char($0b),x                             // $0ff4
    lda #$00                                    // $0ff7
    sta char($08),x                             // $0ff9
    dex                                         // $0ffc
    bpl L0ff2                                   // $0ffd
    bmi L1035                                   // $0fff
L1001:
    tya                                         // $1001
    sec                                         // $1002
    sbc #$05                                    // $1003
    asl                                         // $1005
    asl                                         // $1006
    asl                                         // $1007
    asl                                         // $1008
    sta zp_fd                                   // $1009
    lda zp_fe                                   // $100b
    lsr                                         // $100d
    asl                                         // $100e
    asl                                         // $100f
    clc                                         // $1010
    adc zp_fd                                   // $1011
    sta zp_fd                                   // $1013
    ldx #$07                                    // $1015
L1017:
    ldy zp_fd                                   // $1017
    lda edge_shade_left,y                       // $1019
    sta char($08),x                             // $101c
    sta char($07)+7,x                           // $101f
    lda edge_pixels_table,y                     // $1022
    tay                                         // $1025
    lda edge_fill_left,y                        // $1026
    sta char($0b),x                             // $1029
    dex                                         // $102c
    sta char($0b),x                             // $102d
    inc zp_fd                                   // $1030
    dex                                         // $1032
    bpl L1017                                   // $1033
L1035:
    ldx zp_fe                                   // $1035
    lda #$55                                    // $1037
L1039:
    sta char($0a),x                             // $1039
    dex                                         // $103c
    bpl L1039                                   // $103d
    ldy zp_fb                                   // $103f
    cpy #$04                                    // $1041
    bcc L1056                                   // $1043
    ldx zp_fe                                   // $1045
L1047:
    lda #$55                                    // $1047
    sta char($09),x                             // $1049
    lda #$00                                    // $104c
    sta char($0c),x                             // $104e
    dex                                         // $1051
    bpl L1047                                   // $1052
    bmi L108d                                   // $1054
L1056:
    sty zp_fd                                   // $1056
    lda #$03                                    // $1058
    sec                                         // $105a
    sbc zp_fd                                   // $105b
    asl                                         // $105d
    asl                                         // $105e
    asl                                         // $105f
    asl                                         // $1060
    sta zp_fd                                   // $1061
    lda zp_fe                                   // $1063
    lsr                                         // $1065
    asl                                         // $1066
    asl                                         // $1067
    clc                                         // $1068
    adc zp_fd                                   // $1069
    sta zp_fd                                   // $106b
    ldx #$07                                    // $106d
L106f:
    ldy zp_fd                                   // $106f
    lda edge_shade_right,y                      // $1071
    sta char($0c),x                             // $1074
    sta char($0b)+7,x                           // $1077
    lda edge_pixels_table,y                     // $107a
    tay                                         // $107d
    lda edge_fill_right,y                       // $107e
    sta char($09),x                             // $1081
    dex                                         // $1084
    sta char($09),x                             // $1085
    inc zp_fd                                   // $1088
    dex                                         // $108a
    bpl L106f                                   // $108b
L108d:
    rts                                         // $108d
edge_chars_top:
    ldy zp_fc                                   // $108e
    cpy #$05                                    // $1090
    bcs L10a3                                   // $1092
    ldy zp_fe                                   // $1094
    lda edge_fill_top,y                         // $1096
    ldx #$07                                    // $1099
L109b:
    sta char($0f),x                             // $109b
    dex                                         // $109e
    bpl L109b                                   // $109f
    bmi L10d2                                   // $10a1
L10a3:
    tya                                         // $10a3
    sec                                         // $10a4
    sbc #$05                                    // $10a5
    asl                                         // $10a7
    asl                                         // $10a8
    asl                                         // $10a9
    asl                                         // $10aa
    sta zp_fd                                   // $10ab
    lda #$03                                    // $10ad
    sec                                         // $10af
    sbc zp_fe                                   // $10b0
    asl                                         // $10b2
    asl                                         // $10b3
    clc                                         // $10b4
    adc zp_fd                                   // $10b5
    sta zp_fd                                   // $10b7
    ldx #$00                                    // $10b9
L10bb:
    ldy zp_fd                                   // $10bb
    lda edge_pixels_table2,y                    // $10bd
    tay                                         // $10c0
    lda edge_fill_left,y                        // $10c1
    sta char($0f),x                             // $10c4
    inx                                         // $10c7
    sta char($0f),x                             // $10c8
    inc zp_fd                                   // $10cb
    inx                                         // $10cd
    cpx #$08                                    // $10ce
    bcc L10bb                                   // $10d0
L10d2:
    ldy zp_fe                                   // $10d2
    lda edge_fill_top,y                         // $10d4
    ldx #$07                                    // $10d7
L10d9:
    sta char($0e),x                             // $10d9
    dex                                         // $10dc
    bpl L10d9                                   // $10dd
    ldy zp_fc                                   // $10df
    cpy #$04                                    // $10e1
    bcc L10f4                                   // $10e3
    ldy zp_fe                                   // $10e5
    lda edge_fill_top,y                         // $10e7
    ldx #$07                                    // $10ea
L10ec:
    sta char($0d),x                             // $10ec
    dex                                         // $10ef
    bpl L10ec                                   // $10f0
    bmi L1124                                   // $10f2
L10f4:
    sty zp_fd                                   // $10f4
    lda #$03                                    // $10f6
    sec                                         // $10f8
    sbc zp_fd                                   // $10f9
    asl                                         // $10fb
    asl                                         // $10fc
    asl                                         // $10fd
    asl                                         // $10fe
    sta zp_fd                                   // $10ff
    lda #$03                                    // $1101
    sec                                         // $1103
    sbc zp_fe                                   // $1104
    asl                                         // $1106
    asl                                         // $1107
    clc                                         // $1108
    adc zp_fd                                   // $1109
    sta zp_fd                                   // $110b
    ldx #$07                                    // $110d
L110f:
    ldy zp_fd                                   // $110f
    lda edge_pixels_table2,y                    // $1111
    tay                                         // $1114
    lda edge_fill_left,y                        // $1115
    sta char($0d),x                             // $1118
    dex                                         // $111b
    sta char($0d),x                             // $111c
    inc zp_fd                                   // $111f
    dex                                         // $1121
    bpl L110f                                   // $1122
L1124:
    rts                                         // $1124
edge_fill_top:
    .byte $55,$15,$05,$01                       // $1125
edge_chars_bottom:
    ldy zp_fc                                   // $1129
    cpy #$05                                    // $112b
    bcs L113e                                   // $112d
    ldy zp_fe                                   // $112f
    lda edge_fill_bottom,y                      // $1131
    ldx #$07                                    // $1134
L1136:
    sta char($05),x                             // $1136
    dex                                         // $1139
    bpl L1136                                   // $113a
    bmi L116a                                   // $113c
L113e:
    tya                                         // $113e
    sec                                         // $113f
    sbc #$05                                    // $1140
    asl                                         // $1142
    asl                                         // $1143
    asl                                         // $1144
    asl                                         // $1145
    sta zp_fd                                   // $1146
    lda zp_fe                                   // $1148
    asl                                         // $114a
    asl                                         // $114b
    clc                                         // $114c
    adc zp_fd                                   // $114d
    sta zp_fd                                   // $114f
    ldx #$00                                    // $1151
L1153:
    ldy zp_fd                                   // $1153
    lda edge_pixels_table2,y                    // $1155
    tay                                         // $1158
    lda edge_fill_right,y                       // $1159
    sta char($05),x                             // $115c
    inx                                         // $115f
    sta char($05),x                             // $1160
    inc zp_fd                                   // $1163
    inx                                         // $1165
    cpx #$08                                    // $1166
    bcc L1153                                   // $1168
L116a:
    ldy zp_fe                                   // $116a
    lda edge_fill_bottom,y                      // $116c
    ldx #$07                                    // $116f
L1171:
    sta char($06),x                             // $1171
    dex                                         // $1174
    bpl L1171                                   // $1175
    ldy zp_fc                                   // $1177
    cpy #$04                                    // $1179
    bcc L118c                                   // $117b
    ldy zp_fe                                   // $117d
    lda edge_fill_bottom,y                      // $117f
    ldx #$07                                    // $1182
L1184:
    sta char($07),x                             // $1184
    dex                                         // $1187
    bpl L1184                                   // $1188
    bmi L11b9                                   // $118a
L118c:
    sty zp_fd                                   // $118c
    lda #$03                                    // $118e
    sec                                         // $1190
    sbc zp_fd                                   // $1191
    asl                                         // $1193
    asl                                         // $1194
    asl                                         // $1195
    asl                                         // $1196
    sta zp_fd                                   // $1197
    lda zp_fe                                   // $1199
    asl                                         // $119b
    asl                                         // $119c
    clc                                         // $119d
    adc zp_fd                                   // $119e
    sta zp_fd                                   // $11a0
    ldx #$07                                    // $11a2
L11a4:
    ldy zp_fd                                   // $11a4
    lda edge_pixels_table2,y                    // $11a6
    tay                                         // $11a9
    lda edge_fill_right,y                       // $11aa
    sta char($07),x                             // $11ad
    dex                                         // $11b0
    sta char($07),x                             // $11b1
    inc zp_fd                                   // $11b4
    dex                                         // $11b6
    bpl L11a4                                   // $11b7
L11b9:
    rts                                         // $11b9
edge_fill_bottom:
    .byte $40,$50,$54,$55                       // $11ba
build_corner_chars:
    lda zp_fb                                   // $11be
    sec                                         // $11c0
    sbc #$04                                    // $11c1
    sta zp_fa                                   // $11c3
    lda #$04                                    // $11c5
    sec                                         // $11c7
    sbc zp_fc                                   // $11c8
    sta zp_ff                                   // $11ca
    jsr corner_distance                         // $11cc
    lda zp_fb                                   // $11cf
    sec                                         // $11d1
    sbc zp_fc                                   // $11d2
    bpl L11da                                   // $11d4
    lda #$00                                    // $11d6
    beq L11dc                                   // $11d8
L11da:
    lda zp_fe                                   // $11da
L11dc:
    clc                                         // $11dc
    adc #$01                                    // $11dd
    asl                                         // $11df
    asl                                         // $11e0
    asl                                         // $11e1
    tax                                         // $11e2
    dex                                         // $11e3
    ldy #$07                                    // $11e4
L11e6:
    lda corner_pixels,x                         // $11e6
    sta char($23),y                             // $11e9
    lda corner_pixels+72,x                      // $11ec
    sta char($24),y                             // $11ef
    dex                                         // $11f2
    dey                                         // $11f3
    bpl L11e6                                   // $11f4
    lda zp_fc                                   // $11f6
    sec                                         // $11f8
    sbc zp_fb                                   // $11f9
    bpl L1201                                   // $11fb
    lda #$00                                    // $11fd
    beq L1203                                   // $11ff
L1201:
    lda zp_fe                                   // $1201
L1203:
    asl                                         // $1203
    asl                                         // $1204
    asl                                         // $1205
    tax                                         // $1206
    pha                                         // $1207
    ldy #$00                                    // $1208
L120a:
    lda corner_pixels+360,x                     // $120a
    sta char($25),y                             // $120d
    inx                                         // $1210
    iny                                         // $1211
    cpy #$08                                    // $1212
    bne L120a                                   // $1214
    pla                                         // $1216
    tax                                         // $1217
    ldy #$07                                    // $1218
L121a:
    lda corner_pixels+216,x                     // $121a
    sta char($26),y                             // $121d
    inx                                         // $1220
    dey                                         // $1221
    bpl L121a                                   // $1222
    lda zp_fb                                   // $1224
    sec                                         // $1226
    sbc #$04                                    // $1227
    sta zp_fa                                   // $1229
    lda zp_fc                                   // $122b
    sec                                         // $122d
    sbc #$04                                    // $122e
    sta zp_ff                                   // $1230
    jsr corner_distance                         // $1232
    lda zp_fb                                   // $1235
    clc                                         // $1237
    adc zp_fc                                   // $1238
    sta zp_fd                                   // $123a
    lda #$08                                    // $123c
    sec                                         // $123e
    sbc zp_fd                                   // $123f
    bpl L1247                                   // $1241
    lda #$00                                    // $1243
    beq L1249                                   // $1245
L1247:
    lda zp_fe                                   // $1247
L1249:
    clc                                         // $1249
    adc #$01                                    // $124a
    asl                                         // $124c
    asl                                         // $124d
    asl                                         // $124e
    tax                                         // $124f
    dex                                         // $1250
    ldy #$07                                    // $1251
L1253:
    lda corner_pixels+144,x                     // $1253
    sta char($27),y                             // $1256
    lda corner_pixels+216,x                     // $1259
    sta char($28),y                             // $125c
    dex                                         // $125f
    dey                                         // $1260
    bpl L1253                                   // $1261
    lda zp_fd                                   // $1263
    sec                                         // $1265
    sbc #$08                                    // $1266
    bpl L126e                                   // $1268
    lda #$00                                    // $126a
    beq L1270                                   // $126c
L126e:
    lda zp_fe                                   // $126e
L1270:
    asl                                         // $1270
    asl                                         // $1271
    asl                                         // $1272
    tax                                         // $1273
    pha                                         // $1274
    ldy #$00                                    // $1275
L1277:
    lda corner_pixels+288,x                     // $1277
    sta char($29),y                             // $127a
    inx                                         // $127d
    iny                                         // $127e
    cpy #$08                                    // $127f
    bne L1277                                   // $1281
    pla                                         // $1283
    tax                                         // $1284
    ldy #$07                                    // $1285
L1287:
    lda corner_pixels+72,x                      // $1287
    sta char($2a),y                             // $128a
    inx                                         // $128d
    dey                                         // $128e
    bpl L1287                                   // $128f
    rts                                         // $1291
corner_distance:
    lda zp_fa                                   // $1292
    clc                                         // $1294
    adc zp_ff                                   // $1295
    bpl L129e                                   // $1297
    eor #$ff                                    // $1299
    clc                                         // $129b
    adc #$01                                    // $129c
L129e:
    sta zp_fe                                   // $129e
    lda zp_fa                                   // $12a0
    bpl L12a9                                   // $12a2
    eor #$ff                                    // $12a4
    clc                                         // $12a6
    adc #$01                                    // $12a7
L12a9:
    sta zp_fa                                   // $12a9
    lda zp_ff                                   // $12ab
    bpl L12b4                                   // $12ad
    eor #$ff                                    // $12af
    clc                                         // $12b1
    adc #$01                                    // $12b2
L12b4:
    sec                                         // $12b4
    sbc zp_fa                                   // $12b5
    bpl L12be                                   // $12b7
    eor #$ff                                    // $12b9
    clc                                         // $12bb
    adc #$01                                    // $12bc
L12be:
    clc                                         // $12be
    adc zp_fe                                   // $12bf
    sta zp_fe                                   // $12c1
    rts                                         // $12c3
build_corner_chars2:
    ldx #$07                                    // $12c4
L12c6:
    lda char($23),x                             // $12c6
    lsr                                         // $12c9
    ora char($23),x                             // $12ca
    tay                                         // $12cd
    and char($02),x                             // $12ce
    sta char($2b),x                             // $12d1
    tya                                         // $12d4
    and char($06),x                             // $12d5
    sta char($2e),x                             // $12d8
    lda char($24),x                             // $12db
    tay                                         // $12de
    and char($02),x                             // $12df
    sta char($2c),x                             // $12e2
    tya                                         // $12e5
    and char($06),x                             // $12e6
    sta char($2d),x                             // $12e9
    dex                                         // $12ec
    bpl L12c6                                   // $12ed
    ldx #$07                                    // $12ef
L12f1:
    lda char($29),x                             // $12f1
    lsr                                         // $12f4
    ora char($29),x                             // $12f5
    tay                                         // $12f8
    and char($06),x                             // $12f9
    sta char($2f),x                             // $12fc
    tya                                         // $12ff
    and char($0a),x                             // $1300
    sta char($31),x                             // $1303
    lda char($2a),x                             // $1306
    tay                                         // $1309
    and char($06),x                             // $130a
    sta char($30),x                             // $130d
    tya                                         // $1310
    and char($0a),x                             // $1311
    sta char($32),x                             // $1314
    dex                                         // $1317
    bpl L12f1                                   // $1318
    ldx #$07                                    // $131a
L131c:
    lda char($25),x                             // $131c
    lsr                                         // $131f
    ora char($25),x                             // $1320
    tay                                         // $1323
    and char($0a),x                             // $1324
    sta char($34),x                             // $1327
    tya                                         // $132a
    and char($0e),x                             // $132b
    sta char($35),x                             // $132e
    lda char($26),x                             // $1331
    tay                                         // $1334
    and char($0a),x                             // $1335
    sta char($33),x                             // $1338
    tya                                         // $133b
    and char($0e),x                             // $133c
    sta char($36),x                             // $133f
    dex                                         // $1342
    bpl L131c                                   // $1343
    ldx #$07                                    // $1345
L1347:
    lda char($27),x                             // $1347
    lsr                                         // $134a
    ora char($27),x                             // $134b
    tay                                         // $134e
    and char($0e),x                             // $134f
    sta char($38),x                             // $1352
    tya                                         // $1355
    and char($02),x                             // $1356
    sta char($3a),x                             // $1359
    lda char($28),x                             // $135c
    tay                                         // $135f
    and char($0e),x                             // $1360
    sta char($37),x                             // $1363
    tya                                         // $1366
    and char($02),x                             // $1367
    sta char($39),x                             // $136a
    dex                                         // $136d
    bpl L1347                                   // $136e
    rts                                         // $1370
build_corner_chars3:
    ldx #$07                                    // $1371
L1373:
    lda char($26),x                             // $1373
    tay                                         // $1376
    ora char($0a),x                             // $1377
    sta char($19),x                             // $137a
    tya                                         // $137d
    ora char($0e),x                             // $137e
    sta char($1a),x                             // $1381
    dex                                         // $1384
    bpl L1373                                   // $1385
    ldx #$07                                    // $1387
L1389:
    lda char($28),x                             // $1389
    tay                                         // $138c
    ora char($0e),x                             // $138d
    sta char($1b),x                             // $1390
    tya                                         // $1393
    ora char($02),x                             // $1394
    sta char($1c),x                             // $1397
    dex                                         // $139a
    bpl L1389                                   // $139b
    ldx #$07                                    // $139d
L139f:
    lda char($24),x                             // $139f
    tay                                         // $13a2
    ora char($02),x                             // $13a3
    sta char($1d),x                             // $13a6
    tya                                         // $13a9
    ora char($06),x                             // $13aa
    sta char($1e),x                             // $13ad
    dex                                         // $13b0
    bpl L139f                                   // $13b1
    ldx #$07                                    // $13b3
L13b5:
    lda char($2a),x                             // $13b5
    tay                                         // $13b8
    ora char($06),x                             // $13b9
    sta char($1f),x                             // $13bc
    tya                                         // $13bf
    ora char($0a),x                             // $13c0
    sta char($21),x                             // $13c3
    dex                                         // $13c6
    bpl L13b5                                   // $13c7
    rts                                         // $13c9
build_junction_chars:
    ldx #$07                                    // $13ca
L13cc:
    lda char($07),x                             // $13cc
    and char($2e),x                             // $13cf
    sta char($3b),x                             // $13d2
    lda char($09),x                             // $13d5
    and char($26),x                             // $13d8
    sta char($3c),x                             // $13db
    lda char($06),x                             // $13de
    and char($34),x                             // $13e1
    sta char($3d),x                             // $13e4
    lda char($07),x                             // $13e7
    and char($24),x                             // $13ea
    sta char($3e),x                             // $13ed
    lda char($09),x                             // $13f0
    and char($34),x                             // $13f3
    sta char($3f),x                             // $13f6
    lda char($0a),x                             // $13f9
    and char($2e),x                             // $13fc
    sta char($40),x                             // $13ff
    lda char($03),x                             // $1402
    and char($28),x                             // $1405
    sta char($41),x                             // $1408
    lda char($06),x                             // $140b
    and char($3a),x                             // $140e
    sta char($42),x                             // $1411
    lda char($05),x                             // $1414
    and char($2f),x                             // $1417
    sta char($43),x                             // $141a
    lda char($03),x                             // $141d
    and char($3a),x                             // $1420
    sta char($44),x                             // $1423
    lda char($02),x                             // $1426
    and char($2f),x                             // $1429
    sta char($45),x                             // $142c
    lda char($05),x                             // $142f
    and char($2a),x                             // $1432
    sta char($46),x                             // $1435
    dex                                         // $1438
    bpl L13cc                                   // $1439
    ldx #$07                                    // $143b
L143d:
    lda char($0e),x                             // $143d
    and char($2b),x                             // $1440
    sta char($47),x                             // $1443
    lda char($01),x                             // $1446
    and char($24),x                             // $1449
    sta char($48),x                             // $144c
    lda char($0f),x                             // $144f
    and char($35),x                             // $1452
    sta char($49),x                             // $1455
    lda char($02),x                             // $1458
    and char($35),x                             // $145b
    sta char($4a),x                             // $145e
    lda char($01),x                             // $1461
    and char($2b),x                             // $1464
    sta char($4b),x                             // $1467
    lda char($0f),x                             // $146a
    and char($26),x                             // $146d
    sta char($4c),x                             // $1470
    lda char($0d),x                             // $1473
    and char($38),x                             // $1476
    sta char($4d),x                             // $1479
    lda char($0e),x                             // $147c
    and char($31),x                             // $147f
    sta char($4e),x                             // $1482
    lda char($0b),x                             // $1485
    and char($2a),x                             // $1488
    sta char($4f),x                             // $148b
    lda char($0d),x                             // $148e
    and char($28),x                             // $1491
    sta char($50),x                             // $1494
    lda char($0a),x                             // $1497
    and char($38),x                             // $149a
    sta char($51),x                             // $149d
    lda char($0b),x                             // $14a0
    and char($31),x                             // $14a3
    sta char($52),x                             // $14a6
    dex                                         // $14a9
    bpl L143d                                   // $14aa
    rts                                         // $14ac
build_junction_chars2:
    ldx #$07                                    // $14ad
L14af:
    lda char($28),x                             // $14af
    and char($2b),x                             // $14b2
    sta char($53),x                             // $14b5
    lda char($24),x                             // $14b8
    and char($3a),x                             // $14bb
    sta char($54),x                             // $14be
    lda char($24),x                             // $14c1
    and char($2f),x                             // $14c4
    sta char($55),x                             // $14c7
    lda char($2a),x                             // $14ca
    and char($2e),x                             // $14cd
    sta char($56),x                             // $14d0
    lda char($31),x                             // $14d3
    and char($26),x                             // $14d6
    sta char($57),x                             // $14d9
    lda char($34),x                             // $14dc
    and char($2a),x                             // $14df
    sta char($58),x                             // $14e2
    lda char($35),x                             // $14e5
    and char($28),x                             // $14e8
    sta char($59),x                             // $14eb
    lda char($38),x                             // $14ee
    and char($26),x                             // $14f1
    sta char($5a),x                             // $14f4
    dex                                         // $14f7
    bpl L14af                                   // $14f8
    rts                                         // $14fa
build_junction_chars3:
    ldx #$07                                    // $14fb
L14fd:
    lda char($29),x                             // $14fd
    sta zp_fb                                   // $1500
    lsr                                         // $1502
    ora zp_fb                                   // $1503
    eor #$ff                                    // $1505
    and char($26),x                             // $1507
    ora zp_fb                                   // $150a
    sta char($5b),x                             // $150c
    lda char($25),x                             // $150f
    sta zp_fb                                   // $1512
    lsr                                         // $1514
    ora zp_fb                                   // $1515
    eor #$ff                                    // $1517
    and char($2a),x                             // $1519
    ora zp_fb                                   // $151c
    sta char($5c),x                             // $151e
    lda char($25),x                             // $1521
    sta zp_fb                                   // $1524
    lsr                                         // $1526
    ora zp_fb                                   // $1527
    eor #$ff                                    // $1529
    and char($28),x                             // $152b
    ora zp_fb                                   // $152e
    sta char($5d),x                             // $1530
    lda char($27),x                             // $1533
    sta zp_fb                                   // $1536
    lsr                                         // $1538
    ora zp_fb                                   // $1539
    eor #$ff                                    // $153b
    and char($26),x                             // $153d
    ora zp_fb                                   // $1540
    sta char($5e),x                             // $1542
    dex                                         // $1545
    bpl L14fd                                   // $1546
    ldx #$07                                    // $1548
L154a:
    lda char($23),x                             // $154a
    sta zp_fb                                   // $154d
    lsr                                         // $154f
    ora zp_fb                                   // $1550
    eor #$ff                                    // $1552
    and char($28),x                             // $1554
    ora zp_fb                                   // $1557
    sta char($5f),x                             // $1559
    lda char($27),x                             // $155c
    sta zp_fb                                   // $155f
    lsr                                         // $1561
    ora zp_fb                                   // $1562
    eor #$ff                                    // $1564
    and char($24),x                             // $1566
    ora zp_fb                                   // $1569
    sta char($60),x                             // $156b
    lda char($29),x                             // $156e
    sta zp_fb                                   // $1571
    lsr                                         // $1573
    ora zp_fb                                   // $1574
    eor #$ff                                    // $1576
    and char($24),x                             // $1578
    ora zp_fb                                   // $157b
    sta char($61),x                             // $157d
    lda char($23),x                             // $1580
    sta zp_fb                                   // $1583
    lsr                                         // $1585
    ora zp_fb                                   // $1586
    eor #$ff                                    // $1588
    and char($2a),x                             // $158a
    ora zp_fb                                   // $158d
    sta char($62),x                             // $158f
    dex                                         // $1592
    bpl L154a                                   // $1593
    rts                                         // $1595

// ----------------------------------------------------------------------------
// Rolling noise: SID voice 3 noise, volume and filter follow the ball speed
// ----------------------------------------------------------------------------
roll_sound:
    ldx #$1f                                    // $1596
    stx SID_MODE_VOL                            // $1598
    lda #$00                                    // $159b
    sta SID_V3_FREQ_LO                          // $159d
    lda #$08                                    // $15a0
    sta SID_V3_FREQ_HI                          // $15a2
    lda ball_vx                                 // $15a5
    bpl L15af                                   // $15a8
    eor #$ff                                    // $15aa
    clc                                         // $15ac
    adc #$01                                    // $15ad
L15af:
    sta zp_fb                                   // $15af
    lda ball_vy                                 // $15b1
    bpl L15bb                                   // $15b4
    eor #$ff                                    // $15b6
    clc                                         // $15b8
    adc #$01                                    // $15b9
L15bb:
    clc                                         // $15bb
    adc zp_fb                                   // $15bc
    ror                                         // $15be
    lsr                                         // $15bf
    ldx ball_in_hole                            // $15c0
    beq L15c7                                   // $15c3
    lda #$00                                    // $15c5
L15c7:
    sta zp_fc                                   // $15c7
    lsr                                         // $15c9
    cmp #$10                                    // $15ca
    bcc L15d0                                   // $15cc
    lda #$0f                                    // $15ce
L15d0:
    sta roll_volume                             // $15d0
    asl                                         // $15d3
    asl                                         // $15d4
    asl                                         // $15d5
    asl                                         // $15d6
    sta SID_V3_SR                               // $15d7
    lda roll_volume_old                         // $15da
    cmp roll_volume                             // $15dd
    bcs L15e7                                   // $15e0
    lda #$80                                    // $15e2
    sta SID_V3_CTRL                             // $15e4
L15e7:
    lda #$81                                    // $15e7
    sta SID_V3_CTRL                             // $15e9
    lda roll_volume                             // $15ec
    sta roll_volume_old                         // $15ef
    ldy #$ff                                    // $15f2
    lda zp_fc                                   // $15f4
    cmp #$02                                    // $15f6
    bcs L15ff                                   // $15f8
    lda #$00                                    // $15fa
    sta roll_sweep                              // $15fc
L15ff:
    cmp #$1b                                    // $15ff
    bcc L1605                                   // $1601
    lda #$1b                                    // $1603
L1605:
    ldx roll_sweep_dir                          // $1605
    bne L1620                                   // $1608
    clc                                         // $160a
    adc roll_sweep                              // $160b
    cmp #$1c                                    // $160e
    bcc L1636                                   // $1610
    eor #$ff                                    // $1612
    clc                                         // $1614
    adc #$38                                    // $1615
    ldx #$01                                    // $1617
    stx roll_sweep_dir                          // $1619
    ldy #$1c                                    // $161c
    bne L1636                                   // $161e
L1620:
    sta zp_fb                                   // $1620
    lda roll_sweep                              // $1622
    sec                                         // $1625
    sbc zp_fb                                   // $1626
    bcs L1636                                   // $1628
    eor #$ff                                    // $162a
    clc                                         // $162c
    adc #$01                                    // $162d
    ldx #$00                                    // $162f
    stx roll_sweep_dir                          // $1631
    ldy #$00                                    // $1634
L1636:
    sta roll_sweep                              // $1636
    cpy #$ff                                    // $1639
    beq L163e                                   // $163b
    tya                                         // $163d
L163e:
    lsr zp_fc                                   // $163e
    clc                                         // $1640
    adc zp_fc                                   // $1641
    sta SID_FC_HI                               // $1643
    rts                                         // $1646

// ----------------------------------------------------------------------------
// Ball shadow (sprite 4, black) = ball position + perspective shift - 4
// ----------------------------------------------------------------------------
place_ball_shadow:
    lda ball_x                                  // $1647
    clc                                         // $164a
    adc tilt_shift_x                            // $164b
    sta zp_fb                                   // $164e
    lda ball_x_hi                               // $1650
    adc #$00                                    // $1653
    sta zp_fc                                   // $1655
    lda zp_fb                                   // $1657
    sec                                         // $1659
    sbc #$04                                    // $165a
    sta zp_fb                                   // $165c
    lda zp_fc                                   // $165e
    sbc #$00                                    // $1660
    sta zp_fc                                   // $1662
    lda zp_fb                                   // $1664
    sta VIC_SPR4_X                              // $1666
    lda VIC_SPR_X_MSB                           // $1669
    ldx zp_fc                                   // $166c
    beq L1674                                   // $166e
    ora #$10                                    // $1670
    bne L1676                                   // $1672
L1674:
    and #$ef                                    // $1674
L1676:
    sta VIC_SPR_X_MSB                           // $1676
    lda ball_y                                  // $1679
    clc                                         // $167c
    adc tilt_shift_y                            // $167d
    sec                                         // $1680
    sbc #$04                                    // $1681
    sta VIC_SPR4_Y                              // $1683
    rts                                         // $1686

// ----------------------------------------------------------------------------
// Params: X, Y = perspective shift 0-8
// Returns: X, Y = start/end of the visible side of the board frame
// ----------------------------------------------------------------------------
frame_side_shift:
    cpy #$05                                    // $1687
    bcc L1691                                   // $1689
    ldx #$04                                    // $168b
    ldy #$04                                    // $168d
    bpl L16c0                                   // $168f
L1691:
    stx zp_fb                                   // $1691
    cpx #$05                                    // $1693
    bcc L169d                                   // $1695
    lda #$08                                    // $1697
    sec                                         // $1699
    sbc zp_fb                                   // $169a
    tax                                         // $169c
L169d:
    tya                                         // $169d
    asl                                         // $169e
    asl                                         // $169f
    sty zp_fc                                   // $16a0
    clc                                         // $16a2
    adc zp_fc                                   // $16a3
    stx zp_fc                                   // $16a5
    clc                                         // $16a7
    adc zp_fc                                   // $16a8
    asl                                         // $16aa
    tax                                         // $16ab
    lda D16c2,x                                 // $16ac
    tay                                         // $16af
    lda frame_side_table,x                      // $16b0
    tax                                         // $16b3
    lda zp_fb                                   // $16b4
    cmp #$05                                    // $16b6
    bcc L16c0                                   // $16b8
    stx zp_fc                                   // $16ba
    tya                                         // $16bc
    tax                                         // $16bd
    ldy zp_fc                                   // $16be
L16c0:
    rts                                         // $16c0
frame_side_table:
    .byte $04                                   // $16c1
D16c2:
    .byte $00,$03,$00,$02,$00,$01,$00,$00,$00,$04,$00,$03,$00,$02,$01,$01  // $16c2
    .byte $01,$01,$01,$04,$00,$03,$01,$02,$01,$02,$02,$02,$02,$04,$00,$03  // $16d2
    .byte $01,$03,$02,$03,$02,$03,$03,$04,$00,$04,$01,$04,$02,$04,$03,$04  // $16e2
    .byte $04                                   // $16f2

// ----------------------------------------------------------------------------
// Draw the board frame sides with the characters for the current tilt
// (bottom row $079A, top row $047A, left column $04A1, right column $04C5)
// ----------------------------------------------------------------------------
draw_frame_bottom:
    ldx tilt_shift_x                            // $16f3
    ldy tilt_shift_y                            // $16f6
    jsr frame_side_shift                        // $16f9
    stx zp_fb                                   // $16fc
    tya                                         // $16fe
    sec                                         // $16ff
    sbc zp_fb                                   // $1700
    ldy #$01                                    // $1702
    bcs L170d                                   // $1704
    ldy #$ff                                    // $1706
    eor #$ff                                    // $1708
    clc                                         // $170a
    adc #$01                                    // $170b
L170d:
    sty edge_step                               // $170d
    tax                                         // $1710
    lda frame_run_lengths,x                     // $1711
    sta zp_fc                                   // $1714
    ldx #$00                                    // $1716
    asl zp_fb                                   // $1718
L171a:
    ldy zp_fb                                   // $171a
    tya                                         // $171c
    clc                                         // $171d
    adc edge_step                               // $171e
    sta zp_fb                                   // $1721
    lda frame_bottom_chars,y                    // $1723
    ldy zp_fc                                   // $1726
L1728:
    sta screen+23*40+2,x                        // $1728
    inx                                         // $172b
    cpx #$23                                    // $172c
    beq L1735                                   // $172e
    dey                                         // $1730
    bne L1728                                   // $1731
    beq L171a                                   // $1733
L1735:
    rts                                         // $1735
frame_bottom_chars:
    .byte $a0,$6a,$69,$68,$67,$66,$65,$64,$00   // $1736
frame_run_lengths:
    .byte $ff,$0c,$07,$05,$04                   // $173f
draw_frame_top:
    ldx tilt_shift_x                            // $1744
    lda #$08                                    // $1747
    sec                                         // $1749
    sbc tilt_shift_y                            // $174a
    tay                                         // $174d
    jsr frame_side_shift                        // $174e
    stx zp_fb                                   // $1751
    tya                                         // $1753
    sec                                         // $1754
    sbc zp_fb                                   // $1755
    ldy #$01                                    // $1757
    bcs L1762                                   // $1759
    ldy #$ff                                    // $175b
    eor #$ff                                    // $175d
    clc                                         // $175f
    adc #$01                                    // $1760
L1762:
    sty edge_step                               // $1762
    tax                                         // $1765
    lda frame_run_lengths,x                     // $1766
    sta zp_fc                                   // $1769
    ldx #$00                                    // $176b
    asl zp_fb                                   // $176d
L176f:
    ldy zp_fb                                   // $176f
    tya                                         // $1771
    clc                                         // $1772
    adc edge_step                               // $1773
    sta zp_fb                                   // $1776
    lda frame_top_chars,y                       // $1778
    ldy zp_fc                                   // $177b
L177d:
    sta screen+3*40+2,x                         // $177d
    inx                                         // $1780
    cpx #$23                                    // $1781
    beq L178a                                   // $1783
    dey                                         // $1785
    bne L177d                                   // $1786
    beq L176f                                   // $1788
L178a:
    rts                                         // $178a
frame_top_chars:
    .byte $a0,$71,$70,$6f,$6e,$6d,$6c,$6b,$00   // $178b
draw_frame_left:
    lda #$08                                    // $1794
    sec                                         // $1796
    sbc tilt_shift_x                            // $1797
    tay                                         // $179a
    ldx tilt_shift_y                            // $179b
    jsr frame_side_shift                        // $179e
    txa                                         // $17a1
    nop                                         // $17a2
    tax                                         // $17a3
    tya                                         // $17a4
    nop                                         // $17a5
    tay                                         // $17a6
    stx zp_fb                                   // $17a7
    tya                                         // $17a9
    sec                                         // $17aa
    sbc zp_fb                                   // $17ab
    ldy #$01                                    // $17ad
    bcs L17b8                                   // $17af
    ldy #$ff                                    // $17b1
    eor #$ff                                    // $17b3
    clc                                         // $17b5
    adc #$01                                    // $17b6
L17b8:
    sty edge_step                               // $17b8
    tax                                         // $17bb
    lda frame_run_lengths_v,x                   // $17bc
    sta edge_run                                // $17bf
    lda #<(screen+4*40+1)                       // $17c2
    sta zp_fd                                   // $17c4
    lda #>(screen+4*40+1)                       // $17c6
    sta zp_fe                                   // $17c8
    lda #$13                                    // $17ca
    sta zp_fc                                   // $17cc
L17ce:
    ldy zp_fb                                   // $17ce
    tya                                         // $17d0
    clc                                         // $17d1
    adc edge_step                               // $17d2
    sta zp_fb                                   // $17d5
    lda frame_left_chars,y                      // $17d7
    sta edge_char                               // $17da
    ldy #$00                                    // $17dd
    ldx edge_run                                // $17df
L17e2:
    lda edge_char                               // $17e2
    sta (zp_fd),y                               // $17e5
    dec zp_fc                                   // $17e7
    beq L17fb                                   // $17e9
    lda zp_fd                                   // $17eb
    clc                                         // $17ed
    adc #$28                                    // $17ee
    sta zp_fd                                   // $17f0
    bcc L17f6                                   // $17f2
    inc zp_fe                                   // $17f4
L17f6:
    dex                                         // $17f6
    bne L17e2                                   // $17f7
    beq L17ce                                   // $17f9
L17fb:
    rts                                         // $17fb
frame_run_lengths_v:
    .byte $ff,$0a,$07,$05,$04                   // $17fc
frame_left_chars:
    .byte $a0,$74,$73,$72,$00                   // $1801
draw_frame_right:
    ldx tilt_shift_y                            // $1806
    ldy tilt_shift_x                            // $1809
    jsr frame_side_shift                        // $180c
    txa                                         // $180f
    nop                                         // $1810
    tax                                         // $1811
    tya                                         // $1812
    nop                                         // $1813
    tay                                         // $1814
    stx zp_fb                                   // $1815
    tya                                         // $1817
    sec                                         // $1818
    sbc zp_fb                                   // $1819
    ldy #$01                                    // $181b
    bcs L1826                                   // $181d
    ldy #$ff                                    // $181f
    eor #$ff                                    // $1821
    clc                                         // $1823
    adc #$01                                    // $1824
L1826:
    sty edge_step                               // $1826
    tax                                         // $1829
    lda frame_run_lengths_v,x                   // $182a
    sta edge_run                                // $182d
    lda #<(screen+4*40+37)                      // $1830
    sta zp_fd                                   // $1832
    lda #>(screen+4*40+37)                      // $1834
    sta zp_fe                                   // $1836
    lda #$13                                    // $1838
    sta zp_fc                                   // $183a
L183c:
    ldy zp_fb                                   // $183c
    tya                                         // $183e
    clc                                         // $183f
    adc edge_step                               // $1840
    sta zp_fb                                   // $1843
    lda frame_right_chars,y                     // $1845
    sta edge_char                               // $1848
    ldy #$00                                    // $184b
    ldx edge_run                                // $184d
L1850:
    lda edge_char                               // $1850
    sta (zp_fd),y                               // $1853
    dec zp_fc                                   // $1855
    beq L1869                                   // $1857
    lda zp_fd                                   // $1859
    clc                                         // $185b
    adc #$28                                    // $185c
    sta zp_fd                                   // $185e
    bcc L1864                                   // $1860
    inc zp_fe                                   // $1862
L1864:
    dex                                         // $1864
    bne L1850                                   // $1865
    beq L183c                                   // $1867
L1869:
    rts                                         // $1869
frame_right_chars:
    .byte $a0,$77,$76,$75,$00                   // $186a

// ----------------------------------------------------------------------------
// A = character code -> zp_fb/zp_fc = its address in the font at $2000
// ----------------------------------------------------------------------------
char_addr_fb:
    sta zp_fb                                   // $186f
    lda #$00                                    // $1871
    asl zp_fb                                   // $1873
    rol                                         // $1875
    asl zp_fb                                   // $1876
    rol                                         // $1878
    asl zp_fb                                   // $1879
    rol                                         // $187b
    clc                                         // $187c
    adc #$20                                    // $187d
    sta zp_fc                                   // $187f
    rts                                         // $1881

// ----------------------------------------------------------------------------
// A = character code -> zp_fd/zp_fe = its address in the font at $2000
// ----------------------------------------------------------------------------
char_addr_fd:
    sta zp_fd                                   // $1882
    lda #$00                                    // $1884
    asl zp_fd                                   // $1886
    rol                                         // $1888
    asl zp_fd                                   // $1889
    rol                                         // $188b
    asl zp_fd                                   // $188c
    rol                                         // $188e
    clc                                         // $188f
    adc #$20                                    // $1890
    sta zp_fe                                   // $1892
    rts                                         // $1894
build_frame_corners:
    lda screen+3*40+2                           // $1895
    jsr char_addr_fb                            // $1898
    lda screen+4*40+1                           // $189b
    jsr char_addr_fd                            // $189e
    ldy #$07                                    // $18a1
L18a3:
    lda (zp_fb),y                               // $18a3
    and (zp_fd),y                               // $18a5
    sta zp_fa                                   // $18a7
    eor #$ff                                    // $18a9
    sta zp_ff                                   // $18ab
    lsr                                         // $18ad
    and zp_ff                                   // $18ae
    and #$55                                    // $18b0
    ora zp_fa                                   // $18b2
    sta char($78),y                             // $18b4
    dey                                         // $18b7
    bpl L18a3                                   // $18b8
    lda screen+3*40+36                          // $18ba
    jsr char_addr_fb                            // $18bd
    lda screen+4*40+37                          // $18c0
    jsr char_addr_fd                            // $18c3
    ldy #$07                                    // $18c6
L18c8:
    lda (zp_fb),y                               // $18c8
    and (zp_fd),y                               // $18ca
    sta zp_fa                                   // $18cc
    eor #$ff                                    // $18ce
    sta zp_ff                                   // $18d0
    lsr                                         // $18d2
    and zp_ff                                   // $18d3
    and #$55                                    // $18d5
    ora zp_fa                                   // $18d7
    sta char($79),y                             // $18d9
    dey                                         // $18dc
    bpl L18c8                                   // $18dd
    lda screen+22*40+37                         // $18df
    jsr char_addr_fb                            // $18e2
    lda screen+23*40+36                         // $18e5
    jsr char_addr_fd                            // $18e8
    ldy #$07                                    // $18eb
L18ed:
    lda (zp_fb),y                               // $18ed
    and (zp_fd),y                               // $18ef
    sta zp_fa                                   // $18f1
    eor #$ff                                    // $18f3
    sta zp_ff                                   // $18f5
    lsr                                         // $18f7
    and zp_ff                                   // $18f8
    and #$55                                    // $18fa
    ora zp_fa                                   // $18fc
    sta char($7a),y                             // $18fe
    dey                                         // $1901
    bpl L18ed                                   // $1902
    lda screen+22*40+1                          // $1904
    jsr char_addr_fb                            // $1907
    lda screen+23*40+2                          // $190a
    jsr char_addr_fd                            // $190d
    ldy #$07                                    // $1910
L1912:
    lda (zp_fb),y                               // $1912
    and (zp_fd),y                               // $1914
    sta zp_fa                                   // $1916
    eor #$ff                                    // $1918
    sta zp_ff                                   // $191a
    lsr                                         // $191c
    and zp_ff                                   // $191d
    and #$55                                    // $191f
    ora zp_fa                                   // $1921
    sta char($7b),y                             // $1923
    dey                                         // $1926
    bpl L1912                                   // $1927
    rts                                         // $1929
build_hole_chars:
    ldx #$06                                    // $192a
L192c:
    lda char($25),x                             // $192c
    ora char($29),x                             // $192f
    and #$3c                                    // $1932
    sta zp_fb                                   // $1934
    lda char($00),x                             // $1936
    and #$c3                                    // $1939
    ora zp_fb                                   // $193b
    sta char($7c),x                             // $193d
    inx                                         // $1940
    cpx #$08                                    // $1941
    bne L192c                                   // $1943
    ldx #$01                                    // $1945
L1947:
    lda char($23),x                             // $1947
    ora char($27),x                             // $194a
    and #$3c                                    // $194d
    sta zp_fb                                   // $194f
    lda char($00),x                             // $1951
    and #$c3                                    // $1954
    ora zp_fb                                   // $1956
    sta char($7e),x                             // $1958
    dex                                         // $195b
    bpl L1947                                   // $195c
    ldx #$02                                    // $195e
L1960:
    lda char($25),x                             // $1960
    ora char($27),x                             // $1963
    and #$c0                                    // $1966
    sta zp_fb                                   // $1968
    lda char($00),x                             // $196a
    and #$3f                                    // $196d
    ora zp_fb                                   // $196f
    sta char($80),x                             // $1971
    lda char($29),x                             // $1974
    ora char($23),x                             // $1977
    and #$03                                    // $197a
    sta zp_fb                                   // $197c
    lda char($00),x                             // $197e
    and #$fc                                    // $1981
    ora zp_fb                                   // $1983
    sta char($82),x                             // $1985
    inx                                         // $1988
    cpx #$06                                    // $1989
    bne L1960                                   // $198b
    rts                                         // $198d
build_hole_chars2:
    ldx #$07                                    // $198e
L1990:
    lda char($2a),x                             // $1990
    ora char($26),x                             // $1993
    sta char($7d),x                             // $1996
    lda char($24),x                             // $1999
    ora char($28),x                             // $199c
    sta char($7f),x                             // $199f
    lda char($26),x                             // $19a2
    ora char($28),x                             // $19a5
    sta char($81),x                             // $19a8
    lda char($2a),x                             // $19ab
    ora char($24),x                             // $19ae
    sta char($83),x                             // $19b1
    dex                                         // $19b4
    bpl L1990                                   // $19b5
    rts                                         // $19b7

// ----------------------------------------------------------------------------
// Tilt "clunk" sound when the tilt direction changes (voice 2)
// ----------------------------------------------------------------------------
tilt_clunk_sound:
    lda diag_hold_count                         // $19b8
    bne L19f2                                   // $19bb
    lda tilt_dx                                 // $19bd
    cmp sound_tilt_dx                           // $19c0
    bne L19cd                                   // $19c3
    lda tilt_dy                                 // $19c5
    cmp sound_tilt_dy                           // $19c8
    beq L19e6                                   // $19cb
L19cd:
    lda #$01                                    // $19cd
    sta clunk_state                             // $19cf
    lda #$10                                    // $19d2
    sta SID_V2_CTRL                             // $19d4
    lda #$e0                                    // $19d7
    sta SID_V2_SR                               // $19d9
    lda #$00                                    // $19dc
    sta SID_V2_AD                               // $19de
    lda #$11                                    // $19e1
    sta SID_V2_CTRL                             // $19e3
L19e6:
    lda tilt_dx                                 // $19e6
    sta sound_tilt_dx                           // $19e9
    lda tilt_dy                                 // $19ec
    sta sound_tilt_dy                           // $19ef
L19f2:
    lda tilt_angle_x                            // $19f2
    cmp tilt_angle_x_old                        // $19f5
    bne L1a1f                                   // $19f8
    lda tilt_angle_y                            // $19fa
    cmp tilt_angle_y_old                        // $19fd
    bne L1a1f                                   // $1a00
    lda clunk_state                             // $1a02
    beq L1a1f                                   // $1a05
    cmp #$80                                    // $1a07
    bne L1a12                                   // $1a09
    lda #$81                                    // $1a0b
    sta clunk_state                             // $1a0d
    bne L1a1f                                   // $1a10
L1a12:
    cmp #$80                                    // $1a12
    bcs L1a1f                                   // $1a14
    lda #$8a                                    // $1a16
    sec                                         // $1a18
    sbc clunk_state                             // $1a19
    sta clunk_state                             // $1a1c
L1a1f:
    lda clunk_state                             // $1a1f
    beq L1a3c                                   // $1a22
    cmp #$80                                    // $1a24
    bne L1a3f                                   // $1a26
    lda clunk_toggle                            // $1a28
    eor #$01                                    // $1a2b
    sta clunk_toggle                            // $1a2d
    ldx #$0f                                    // $1a30
    and #$01                                    // $1a32
    beq L1a38                                   // $1a34
    ldx #$10                                    // $1a36
L1a38:
    txa                                         // $1a38
    jsr tilt_sound_freq                         // $1a39
L1a3c:
    clc                                         // $1a3c
    bcc L1a6b                                   // $1a3d
L1a3f:
    tax                                         // $1a3f
    bmi L1a52                                   // $1a40
    clc                                         // $1a42
    adc #$07                                    // $1a43
    jsr tilt_sound_freq                         // $1a45
    inx                                         // $1a48
    cpx #$0a                                    // $1a49
    bcc L1a4f                                   // $1a4b
    ldx #$80                                    // $1a4d
L1a4f:
    clc                                         // $1a4f
    bcc L1a68                                   // $1a50
L1a52:
    lda #$90                                    // $1a52
    sec                                         // $1a54
    sbc clunk_state                             // $1a55
    jsr tilt_sound_freq                         // $1a58
    inx                                         // $1a5b
    cpx #$90                                    // $1a5c
    bcc L1a68                                   // $1a5e
    ldx #$00                                    // $1a60
    stx SID_V2_FREQ_HI                          // $1a62
    stx SID_V2_FREQ_LO                          // $1a65
L1a68:
    stx clunk_state                             // $1a68
L1a6b:
    rts                                         // $1a6b
tilt_sound_freq:
    clc                                         // $1a6c
    adc speed_class                             // $1a6d
    clc                                         // $1a70
    adc #$01                                    // $1a71
    ldy shaking                                 // $1a73
    beq L1a7b                                   // $1a76
    clc                                         // $1a78
    adc #$02                                    // $1a79
L1a7b:
    sta SID_V2_FREQ_HI                          // $1a7b
    ldy #$00                                    // $1a7e
    sty SID_V2_FREQ_LO                          // $1a80
    rts                                         // $1a83
dev_mode_screen:
    dec dev_mode                                // $1a84
    bne L1ab5                                   // $1a87
    ldx #$1e                                    // $1a89
    stx dev_mode                                // $1a8b
    lda #<screen                                // $1a8e
    sta zp_fb                                   // $1a90
    sta zp_fd                                   // $1a92
    lda #>screen                                // $1a94
    sta zp_fc                                   // $1a96
    lda dev_maze                                // $1a98
    asl                                         // $1a9b
    asl                                         // $1a9c
    clc                                         // $1a9d
    adc #$a0                                    // $1a9e
    sta zp_fe                                   // $1aa0
    ldy #$00                                    // $1aa2
L1aa4:
    lda (zp_fb),y                               // $1aa4
    sta (zp_fd),y                               // $1aa6
    iny                                         // $1aa8
    bne L1aa4                                   // $1aa9
    inc zp_fe                                   // $1aab
    inc zp_fc                                   // $1aad
    lda zp_fc                                   // $1aaf
    cmp #$08                                    // $1ab1
    bne L1aa4                                   // $1ab3
L1ab5:
    rts                                         // $1ab5

// ----------------------------------------------------------------------------
// Read the controls: joystick in port 2 ANDed with keys on the keyboard.
// Returns A = joystick style bits, active low: 0 up, 1 down, 2 left,
// 3 right, 4 fire. Keys, one "diamond" for each hand:
//     right hand:  * up   ; left   RETURN right   right SHIFT down
//     left hand:   Q / CTRL up   RUN/STOP left   A right   left SHIFT down
//     SPACE fire
// Pressing two opposite directions cancels both.
// ----------------------------------------------------------------------------
read_controls:
    lda #$ff                                    // $1ab6
    sta CIA1_DDRA                               // $1ab8
    lda #$00                                    // $1abb
    sta zp_ff                                   // $1abd
    sec                                         // $1abf  fire: SPACE
    lda #$7f                                    // $1ac0
    sta CIA1_PRA                                // $1ac2
    lda CIA1_PRB                                // $1ac5
    and #$10                                    // $1ac8
    bne L1acd                                   // $1aca
    clc                                         // $1acc
L1acd:
    rol zp_ff                                   // $1acd
    sec                                         // $1acf  right: RETURN or A
    lda #$fe                                    // $1ad0
    sta CIA1_PRA                                // $1ad2
    lda CIA1_PRB                                // $1ad5
    and #$02                                    // $1ad8
    beq L1ae8                                   // $1ada
    lda #$fd                                    // $1adc
    sta CIA1_PRA                                // $1ade
    lda CIA1_PRB                                // $1ae1
    and #$04                                    // $1ae4
    bne L1ae9                                   // $1ae6
L1ae8:
    clc                                         // $1ae8
L1ae9:
    rol zp_ff                                   // $1ae9
    sec                                         // $1aeb  left: ; or RUN/STOP
    lda #$bf                                    // $1aec
    sta CIA1_PRA                                // $1aee
    lda CIA1_PRB                                // $1af1
    and #$04                                    // $1af4
    beq L1b04                                   // $1af6
    lda #$7f                                    // $1af8
    sta CIA1_PRA                                // $1afa
    lda CIA1_PRB                                // $1afd
    and #$80                                    // $1b00
    bne L1b05                                   // $1b02
L1b04:
    clc                                         // $1b04
L1b05:
    rol zp_ff                                   // $1b05
    sec                                         // $1b07  down: right SHIFT or left SHIFT
    lda #$bf                                    // $1b08
    sta CIA1_PRA                                // $1b0a
    lda CIA1_PRB                                // $1b0d
    and #$10                                    // $1b10
    beq L1b20                                   // $1b12
    lda #$fd                                    // $1b14
    sta CIA1_PRA                                // $1b16
    lda CIA1_PRB                                // $1b19
    and #$80                                    // $1b1c
    bne L1b21                                   // $1b1e
L1b20:
    clc                                         // $1b20
L1b21:
    rol zp_ff                                   // $1b21
    sec                                         // $1b23  up: *, or Q / CTRL (ignored while ; or right SHIFT is down)
    lda #$bf                                    // $1b24
    sta CIA1_PRA                                // $1b26
    lda CIA1_PRB                                // $1b29
    tax                                         // $1b2c
    and #$02                                    // $1b2d
    beq L1b46                                   // $1b2f
    txa                                         // $1b31
    and #$14                                    // $1b32
    eor #$14                                    // $1b34
    bne L1b47                                   // $1b36
    lda #$7f                                    // $1b38
    sta CIA1_PRA                                // $1b3a
    lda CIA1_PRB                                // $1b3d
    and #$44                                    // $1b40
    eor #$44                                    // $1b42
    beq L1b47                                   // $1b44
L1b46:
    clc                                         // $1b46
L1b47:
    rol zp_ff                                   // $1b47
    ldx zp_ff                                   // $1b49
    txa                                         // $1b4b  up and down together: neither
    and #$03                                    // $1b4c
    bne L1b54                                   // $1b4e
    txa                                         // $1b50
    ora #$03                                    // $1b51
    tax                                         // $1b53
L1b54:
    txa                                         // $1b54  left and right together: neither
    and #$0c                                    // $1b55
    bne L1b5d                                   // $1b57
    txa                                         // $1b59
    ora #$0c                                    // $1b5a
    tax                                         // $1b5c
L1b5d:
    stx zp_ff                                   // $1b5d
    ldx #$ff                                    // $1b5f
    lda #$00                                    // $1b61  read joystick port 2 with port A as input
    sta CIA1_DDRA                               // $1b63
    lda CIA1_PRA                                // $1b66
    stx CIA1_DDRA                               // $1b69
    and zp_ff                                   // $1b6c
    rts                                         // $1b6e
unused_1b6f:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1b6f
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1b7f
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1b8f
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1b9f
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1baf
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1bbf
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1bcf
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1bdf
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1bef
    .byte $ff                                   // $1bff

// ----------------------------------------------------------------------------
// Demo mode recording: the control bits for each step (active low, as
// read_controls returns them), and how many frames each step is held
// (demo_durations). Played back by demo_play.
// ----------------------------------------------------------------------------
demo_controls:
    .byte $1d,$1e,$1f,$19,$1f,$0f,$1f,$17,$1f,$1d,$1f,$1e,$1f,$1d,$1f,$1b  // $1c00
    .byte $1f,$17,$1f,$1b,$1f,$1a,$1f,$0f,$1f,$0f,$1f,$17,$1f,$1b,$1f,$17  // $1c10
    .byte $1f,$1b,$1f,$17,$1f,$19,$1f,$0f,$1f,$17,$1f,$0f,$1f,$1f,$1f,$1f  // $1c20
    .byte $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f  // $1c30
    .byte $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f  // $1c40
    .byte $19,$1d,$1f,$0f,$1f,$17,$1f,$1b,$1f,$17,$1f,$1d,$1f,$1e,$35,$00  // $1c50
    .byte $68,$77,$02,$53,$43,$4c,$43,$00,$73,$77,$0c,$53,$41,$44,$43,$20  // $1c60
    .byte $23,$31,$00,$7f,$77,$16,$53,$53,$54,$41,$20,$53,$2b,$31,$00,$8a  // $1c70
demo_durations:
    .byte $1e,$6f,$0d,$10,$2a,$10,$31,$0a,$15,$0a,$08,$0a,$09,$0a,$09,$0a  // $1c80
    .byte $1c,$0a,$09,$0a,$12,$0a,$05,$0a,$10,$0a,$16,$0a,$1a,$0a,$09,$0a  // $1c90
    .byte $1c,$0a,$09,$0a,$10,$0a,$14,$0a,$12,$0a,$12,$0a,$00,$00,$00,$00  // $1ca0
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$04,$08,$09,$01,$0a,$01,$12,$01  // $1cb0
    .byte $01,$07,$01,$01,$11,$07,$00,$08,$32,$0b,$25,$04,$1b,$09,$2d,$02  // $1cc0
    .byte $1a,$01,$1f,$39,$17,$09,$14,$0e,$15,$09,$1e,$0b,$05,$00,$53,$42  // $1cd0
    .byte $4e,$45,$20,$2a,$2b,$32,$2b,$24,$32,$43,$00,$f7,$77,$66,$53,$4c  // $1ce0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1cf0

// ----------------------------------------------------------------------------
// Characters copied to $2320-$23BF at start-up
// ----------------------------------------------------------------------------
chars_1d00:
    .byte $ee,$bb,$ee,$bb,$ee,$bb,$ee,$55,$ee,$bb,$ee,$bb,$ee,$bb,$55,$55  // $1d00
    .byte $ee,$bb,$ee,$bb,$ee,$55,$55,$55,$ee,$bb,$ee,$bb,$55,$55,$55,$55  // $1d10
    .byte $ee,$bb,$ee,$55,$55,$55,$55,$55,$ee,$bb,$55,$55,$55,$55,$55,$55  // $1d20
    .byte $ee,$55,$55,$55,$55,$55,$55,$55,$55,$bb,$ee,$bb,$ee,$bb,$ee,$bb  // $1d30
    .byte $55,$55,$ee,$bb,$ee,$bb,$ee,$bb,$55,$55,$55,$bb,$ee,$bb,$ee,$bb  // $1d40
    .byte $55,$55,$55,$55,$ee,$bb,$ee,$bb,$55,$55,$55,$55,$55,$bb,$ee,$bb  // $1d50
    .byte $55,$55,$55,$55,$55,$55,$ee,$bb,$55,$55,$55,$55,$55,$55,$55,$bb  // $1d60
    .byte $6e,$7b,$6e,$7b,$6e,$7b,$6e,$7b,$5e,$5b,$5e,$5b,$5e,$5b,$5e,$5b  // $1d70
    .byte $56,$57,$56,$57,$56,$57,$56,$57,$ed,$b9,$ed,$b9,$ed,$b9,$ed,$b9  // $1d80
    .byte $e5,$b5,$e5,$b5,$e5,$b5,$e5,$b5,$d5,$95,$d5,$95,$d5,$95,$d5,$95  // $1d90
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1da0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1db0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1dc0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1dd0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1de0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1df0

// ----------------------------------------------------------------------------
// Pixel patterns for the maze corner characters (build_corner_chars)
// ----------------------------------------------------------------------------
corner_pixels:
    .byte $c0,$80,$e0,$b0,$ec,$b8,$ee,$bb,$c0,$90,$e0,$b4,$ec,$b9,$ee,$bb  // $1e00
    .byte $d0,$90,$e4,$b4,$ed,$b9,$ee,$bb,$d0,$94,$e4,$b5,$ed,$b9,$ee,$bb  // $1e10
    .byte $d4,$94,$e5,$b5,$ed,$b9,$ee,$bb,$d4,$95,$e5,$b5,$ed,$b9,$ee,$bb  // $1e20
    .byte $d5,$95,$e5,$b5,$ed,$b9,$ee,$bb,$d5,$95,$e5,$b5,$ed,$b9,$ee,$bb  // $1e30
    .byte $d5,$95,$e5,$b5,$ed,$b9,$ee,$bb,$00,$00,$00,$00,$00,$00,$00,$00  // $1e40
    .byte $00,$00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00,$00,$40,$40  // $1e50
    .byte $00,$00,$00,$00,$00,$40,$40,$50,$00,$00,$00,$00,$40,$40,$50,$50  // $1e60
    .byte $00,$00,$00,$40,$40,$50,$50,$54,$00,$00,$40,$40,$50,$50,$54,$54  // $1e70
    .byte $00,$40,$40,$50,$50,$54,$54,$55,$40,$40,$50,$50,$54,$54,$55,$55  // $1e80
    .byte $02,$03,$0e,$0b,$2e,$3b,$ee,$bb,$02,$07,$0e,$1b,$2e,$7b,$ee,$bb  // $1e90
    .byte $06,$07,$1e,$1b,$6e,$7b,$ee,$bb,$06,$17,$1e,$5b,$6e,$7b,$ee,$bb  // $1ea0
    .byte $16,$17,$5e,$5b,$6e,$7b,$ee,$bb,$16,$57,$5e,$5b,$6e,$7b,$ee,$bb  // $1eb0
    .byte $56,$57,$5e,$5b,$6e,$7b,$ee,$bb,$56,$57,$5e,$5b,$6e,$7b,$ee,$bb  // $1ec0
    .byte $56,$57,$5e,$5b,$6e,$7b,$ee,$bb,$00,$00,$00,$00,$00,$00,$00,$00  // $1ed0
    .byte $00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$01  // $1ee0
    .byte $00,$00,$00,$00,$00,$01,$01,$05,$00,$00,$00,$00,$01,$01,$05,$05  // $1ef0
    .byte $00,$00,$00,$01,$01,$05,$05,$15,$00,$00,$01,$01,$05,$05,$15,$15  // $1f00
    .byte $00,$01,$01,$05,$05,$15,$15,$55,$01,$01,$05,$05,$15,$15,$55,$55  // $1f10
    .byte $ee,$bb,$ec,$b8,$e0,$b0,$c0,$80,$ee,$bb,$ed,$b8,$e4,$b0,$d0,$80  // $1f20
    .byte $ee,$bb,$ed,$b9,$e4,$b4,$d0,$90,$ee,$bb,$ed,$b9,$e5,$b4,$d4,$90  // $1f30
    .byte $ee,$bb,$ed,$b9,$e5,$b5,$d4,$94,$ee,$bb,$ed,$b9,$e5,$b5,$d5,$94  // $1f40
    .byte $ee,$bb,$ed,$b9,$e5,$b5,$d5,$95,$ee,$bb,$ed,$b9,$e5,$b5,$d5,$95  // $1f50
    .byte $ee,$bb,$ed,$b9,$e5,$b5,$d5,$95,$ee,$bb,$2e,$3b,$0e,$0b,$02,$03  // $1f60
    .byte $ee,$bb,$6e,$3b,$1e,$0b,$06,$03,$ee,$bb,$6e,$7b,$1e,$1b,$06,$07  // $1f70
    .byte $ee,$bb,$6e,$7b,$5e,$1b,$16,$07,$ee,$bb,$6e,$7b,$5e,$5b,$16,$17  // $1f80
    .byte $ee,$bb,$6e,$7b,$5e,$5b,$56,$17,$ee,$bb,$6e,$7b,$5e,$5b,$56,$57  // $1f90
    .byte $ee,$bb,$6e,$7b,$5e,$5b,$56,$57,$ee,$bb,$6e,$7b,$5e,$5b,$56,$57  // $1fa0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1fb0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1fc0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1fd0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1fe0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1ff0

    #import "mazes_0_1.asm"

    #import "sprites.asm"

// ----------------------------------------------------------------------------
// Shine offset for each value of shine_x / shine_y
// ----------------------------------------------------------------------------
shine_offset_table:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fd,$fd,$fc,$fc,$fb  // $3800
    .byte $fb,$fa,$f9,$f9,$f8,$f7,$f6,$f5,$f4,$f4,$f3,$f2,$f1,$ef,$ee,$ed  // $3810
    .byte $ec,$eb,$ea,$e8,$e7,$e6,$e4,$e3,$e1,$e0,$de,$dd,$db,$d9,$d8,$d6  // $3820
    .byte $d4,$d3,$d1,$cf,$cd,$cb,$c9,$c7,$c5,$c3,$c1,$bf,$bd,$bb,$b9,$b7  // $3830
    .byte $b5,$b2,$b0,$ae,$ab,$a9,$a7,$a4,$a2,$9f,$9d,$9b,$98,$95,$93,$90  // $3840
    .byte $8e,$8b,$88,$86,$83,$80,$7e,$7b,$78,$75,$73,$70,$6d,$6a,$67,$64  // $3850
    .byte $61,$5f,$5c,$59,$56,$53,$50,$4d,$4a,$47,$44,$41,$3e,$3b,$38,$35  // $3860
    .byte $31,$2e,$2b,$28,$25,$22,$1f,$1c,$19,$15,$12,$0f,$0c,$09,$06,$03  // $3870
sprite_mask_buffer:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3880
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3890
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $38a0
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $38b0

// ----------------------------------------------------------------------------
// $2508-$2587 = (characters $2008-$2087 << 1) | $55
// ----------------------------------------------------------------------------
build_chars_2508:
    ldx #$00                                    // $38c0
L38c2:
    lda char($01),x                             // $38c2
    asl                                         // $38c5
    ora #$55                                    // $38c6
    sta char($a1),x                             // $38c8
    inx                                         // $38cb
    bpl L38c2                                   // $38cc
    rts                                         // $38ce

// ----------------------------------------------------------------------------
// Draw the gates (the "gates" of the maze: bars across the corridors).
// Fire flips them open for a moment (fire_gates).
// C = 0: redraw the gates on the screen when gate_frame changed
// C = 1: take the gate mask for the level and maze, draw all of them into
//        the screen buffer at $7C00
// ----------------------------------------------------------------------------
draw_gates:
    lda #$00                                    // $38cf
    bcc L38d5                                   // $38d1
    lda #$78                                    // $38d3
L38d5:
    sta gate_page_add                           // $38d5
    bcc L38fa                                   // $38d8
    lda level                                   // $38da
    cmp #$04                                    // $38dd
    bcc L38e3                                   // $38df
    lda #$04                                    // $38e1
L38e3:
    asl                                         // $38e3
    asl                                         // $38e4
    clc                                         // $38e5
    adc maze                                    // $38e6
    tax                                         // $38e9
    lda gate_masks_by_level,x                   // $38ea
    sta gate_mask                               // $38ed
    lda #$00                                    // $38f0
    sta gate_gfx_offset                         // $38f2
    sta gate_frame_old                          // $38f5
    beq L3910                                   // $38f8
L38fa:
    lda gate_frame                              // $38fa
    cmp gate_frame_old                          // $38fd
    sta gate_frame_old                          // $3900
    beq L3938                                   // $3903
    asl                                         // $3905
    sta zp_fb                                   // $3906
    asl                                         // $3908
    asl                                         // $3909
    clc                                         // $390a
    adc zp_fb                                   // $390b
    sta gate_gfx_offset                         // $390d
L3910:
    lda #$08                                    // $3910
    sta gate_count                              // $3912
    ldx maze                                    // $3915
    lda maze_gate_index,x                       // $3918
    sta gate_index                              // $391b
    lda gate_mask                               // $391e
    sta zp_fa                                   // $3921
L3923:
    ror zp_fa                                   // $3923
    bcc L392a                                   // $3925
    jsr draw_gate                               // $3927
L392a:
    lda gate_index                              // $392a
    clc                                         // $392d
    adc #$03                                    // $392e
    sta gate_index                              // $3930
    dec gate_count                              // $3933
    bne L3923                                   // $3936
L3938:
    rts                                         // $3938

// ----------------------------------------------------------------------------
// Draw one gate: gate_index = entry in gate_table
// (3 bytes: screen offset low, high, orientation)
// ----------------------------------------------------------------------------
draw_gate:
    ldx gate_index                              // $3939
    lda gate_table,x                            // $393c
    sta zp_fd                                   // $393f
    inx                                         // $3941
    lda gate_table,x                            // $3942
    clc                                         // $3945
    adc gate_page_add                           // $3946
    sta zp_fe                                   // $3949
    inx                                         // $394b
    lda gate_table,x                            // $394c
    ldy #$08                                    // $394f
    cmp #$02                                    // $3951
    bcc L3957                                   // $3953
    ldy #$09                                    // $3955
L3957:
    sty zp_fc                                   // $3957
    asl                                         // $3959
    asl                                         // $395a
    asl                                         // $395b
    asl                                         // $395c
    sta zp_fb                                   // $395d
    asl                                         // $395f
    asl                                         // $3960
    clc                                         // $3961
    adc gate_gfx_offset                         // $3962
    tax                                         // $3965
L3966:
    ldy zp_fb                                   // $3966
    lda gate_cell_offsets,y                     // $3968
    tay                                         // $396b
    lda gate_chars,x                            // $396c
    sta (zp_fd),y                               // $396f
    inx                                         // $3971
    inc zp_fb                                   // $3972
    dec zp_fc                                   // $3974
    bpl L3966                                   // $3976
    rts                                         // $3978

// ----------------------------------------------------------------------------
// Gate masks: 4 masks per level (one per maze), levels 1-5
// (level 5 and up use the last row)
// ----------------------------------------------------------------------------
gate_masks_by_level:
    .byte $ff,$ff,$ff,$ff,$fe,$fe,$ef,$fb,$de,$de,$ed,$bb,$d6,$dc,$cd,$3b  // $3979
    .byte $56,$9c,$cc,$39                       // $3989

// ----------------------------------------------------------------------------
// Index of each maze's first entry in gate_table (8 entries of 3 bytes per maze)
// ----------------------------------------------------------------------------
maze_gate_index:
    .byte $00,$18,$30,$48                       // $398d

// ----------------------------------------------------------------------------
// Gates: 8 per maze. Screen offset (low, high) of the gate
// and its orientation (0-3)
// ----------------------------------------------------------------------------
gate_table:
    .byte $02,$07,$00                           // $3991
    .byte $0a,$07,$00                           // $3994
    .byte $fd,$05,$00                           // $3997
    .byte $e2,$04,$00                           // $399a
    .byte $cc,$05,$01                           // $399d
    .byte $63,$06,$00                           // $39a0
    .byte $47,$05,$00                           // $39a3
    .byte $4e,$05,$00                           // $39a6
    .byte $13,$07,$00                           // $39a9
    .byte $0c,$07,$00                           // $39ac
    .byte $10,$06,$02                           // $39af
    .byte $49,$05,$00                           // $39b2
    .byte $7c,$05,$01                           // $39b5
    .byte $e3,$04,$00                           // $39b8
    .byte $b1,$05,$01                           // $39bb
    .byte $d0,$05,$01                           // $39be
    .byte $79,$06,$01                           // $39c1
    .byte $10,$07,$00                           // $39c4
    .byte $65,$06,$02                           // $39c7
    .byte $6f,$05,$02                           // $39ca
    .byte $d3,$04,$00                           // $39cd
    .byte $dc,$04,$00                           // $39d0
    .byte $a6,$05,$03                           // $39d3
    .byte $70,$06,$00                           // $39d6
    .byte $0e,$06,$02                           // $39d9
    .byte $14,$06,$01                           // $39dc
    .byte $d5,$04,$00                           // $39df
    .byte $e5,$04,$00                           // $39e2
    .byte $b1,$05,$01                           // $39e5
    .byte $9d,$06,$03                           // $39e8
    .byte $0d,$07,$00                           // $39eb
    .byte $f6,$05,$00                           // $39ee
gate_cell_offsets:
    .byte $00,$01,$02,$28,$29,$2a,$50,$51,$52,$00,$00,$00,$00,$00,$00,$00  // $39f1
    .byte $00,$01,$02,$28,$29,$2a,$50,$51,$52,$00,$00,$00,$00,$00,$00,$00  // $3a01
    .byte $02,$29,$2a,$2b,$50,$51,$52,$53,$79,$7a,$00,$00,$00,$00,$00,$00  // $3a11
    .byte $01,$28,$29,$2a,$50,$51,$52,$53,$79,$7a,$00,$00,$00,$00,$00,$00  // $3a21
gate_chars:
    .byte $12,$00,$11,$0e,$00,$06,$13,$7c,$14,$ff,$12,$00,$11,$0d,$7c,$07  // $3a31
    .byte $02,$02,$02,$ff,$12,$00,$11,$0d,$7c,$07,$02,$02,$02,$ff,$12,$7c  // $3a41
    .byte $11,$0c,$17,$08,$02,$02,$02,$ff,$12,$7c,$11,$0c,$17,$08,$02,$02  // $3a51
    .byte $02,$ff,$0a,$0a,$0a,$20,$20,$20,$02,$02,$02,$ff,$ff,$ff,$ff,$ff  // $3a61
    .byte $14,$02,$13,$00,$00,$82,$11,$0a,$12,$ff,$14,$03,$0e,$00,$82,$0e  // $3a71
    .byte $11,$09,$0e,$ff,$14,$03,$0e,$00,$82,$0e,$11,$09,$0e,$ff,$14,$04  // $3a81
    .byte $0e,$82,$16,$0e,$11,$08,$0e,$ff,$14,$04,$0e,$82,$16,$0e,$11,$08  // $3a91
    .byte $0e,$ff,$06,$20,$0e,$06,$20,$0e,$06,$20,$0e,$ff,$ff,$ff,$ff,$ff  // $3aa1
    .byte $5d,$28,$5e,$7c,$5f,$60,$29,$7d,$98,$83,$5d,$28,$5e,$7c,$5f,$60  // $3ab1
    .byte $29,$7d,$62,$24,$5d,$37,$5e,$7c,$23,$24,$29,$7d,$23,$24,$5d,$50  // $3ac1
    .byte $5e,$7c,$23,$24,$52,$7d,$23,$24,$25,$20,$1a,$7c,$23,$24,$4e,$7d  // $3ad1
    .byte $23,$24,$25,$20,$26,$25,$23,$24,$20,$26,$23,$24,$ff,$ff,$ff,$ff  // $3ae1
    .byte $61,$7c,$62,$24,$7d,$25,$5f,$60,$81,$99,$61,$7c,$62,$24,$7d,$25  // $3af1
    .byte $5f,$60,$28,$5e,$61,$7c,$62,$2d,$7d,$25,$28,$27,$28,$27,$61,$7c  // $3b01
    .byte $62,$3e,$7d,$3f,$28,$27,$28,$27,$29,$7c,$1f,$20,$7d,$3d,$28,$27  // $3b11
    .byte $28,$27,$29,$29,$2a,$20,$2a,$20,$28,$27,$28,$27  // $3b21

// ----------------------------------------------------------------------------
// Fire button: open the gates. Once per press: the gates flip open over
// 5 steps (gate_frame 0-5), stay open for a while (shorter on higher
// levels: gate_anim_start), then close again by themselves.
// ----------------------------------------------------------------------------
fire_gates:
    lda controls                                // $3b2d  fire released: allow the next press
    and #$10                                    // $3b30
    beq L3b39                                   // $3b32
    lda #$00                                    // $3b34
    sta fire_latch                              // $3b36
L3b39:
    lda gate_anim                               // $3b39
    bne L3b52                                   // $3b3c
    lda controls                                // $3b3e
    and #$10                                    // $3b41
    bne L3b9a                                   // $3b43
    lda fire_latch                              // $3b45
    bne L3b9a                                   // $3b48
    lda #$01                                    // $3b4a  new press: start the gate animation
    sta fire_latch                              // $3b4c
    sta gate_anim                               // $3b4f
L3b52:
    inc gate_anim                               // $3b52
    cmp #$0b                                    // $3b55  steps 1-10: opening (gate_frame 0-5)
    bcs L3b5e                                   // $3b57
    lsr                                         // $3b59
    sta gate_frame                              // $3b5a
    rts                                         // $3b5d
L3b5e:
    cmp #$0b                                    // $3b5e  step 11: open, gate sound
    bne L3b6c                                   // $3b60
    ldx gate_mask                               // $3b62
    beq L3b6b                                   // $3b65
    sec                                         // $3b67
    jsr gate_sound                              // $3b68
L3b6b:
    rts                                         // $3b6b
L3b6c:
    ldx speed_class                             // $3b6c  hold open until step gate_anim_start
    cmp gate_anim_start,x                       // $3b6f
    bcs L3b75                                   // $3b72
    rts                                         // $3b74
L3b75:
    sta zp_fb                                   // $3b75  then close: gate_frame back to 0
    ldx speed_class                             // $3b77
    lda gate_anim_end,x                         // $3b7a
    sec                                         // $3b7d
    sbc zp_fb                                   // $3b7e
    beq L3b89                                   // $3b80
    lsr                                         // $3b82
    sta gate_frame                              // $3b83
    jmp L3b9a                                   // $3b86
L3b89:
    ldx gate_mask                               // $3b89  closed again: gate sound, done
    beq L3b92                                   // $3b8c
    clc                                         // $3b8e
    jsr gate_sound                              // $3b8f
L3b92:
    lda #$00                                    // $3b92
    sta gate_frame                              // $3b94
    sta gate_anim                               // $3b97
L3b9a:
    rts                                         // $3b9a
gate_anim_start:
    .byte $1a,$19,$18,$17,$16                   // $3b9b
gate_anim_end:
    .byte $24,$23,$22,$21,$20                   // $3ba0

// ----------------------------------------------------------------------------
// Gate sound (voice 3 noise): C = 1 high, C = 0 low
// ----------------------------------------------------------------------------
gate_sound:
    lda #$0f                                    // $3ba5
    bcc L3bab                                   // $3ba7
    lda #$ff                                    // $3ba9
L3bab:
    sta SID_V3_FREQ_HI                          // $3bab
    lda #$80                                    // $3bae
    sta SID_V3_CTRL                             // $3bb0
    lda #$00                                    // $3bb3
    sta SID_V3_FREQ_LO                          // $3bb5
    sta SID_V3_AD                               // $3bb8
    lda #$f0                                    // $3bbb
    sta SID_V3_SR                               // $3bbd
    lda #$0f                                    // $3bc0
    sta roll_volume_old                         // $3bc2
    lda #$2f                                    // $3bc5
    sta SID_MODE_VOL                            // $3bc7
    lda #$6e                                    // $3bca
    sta SID_FC_HI                               // $3bcc
    lda #$81                                    // $3bcf
    sta SID_V3_CTRL                             // $3bd1
    rts                                         // $3bd4

// ----------------------------------------------------------------------------
// Mark the floor under the ball: every floor character ($20 or $B3) the
// ball covers becomes $63, and its address goes into the mark list at
// $7800/$7900 (mark_count entries). At the end of the level the marks are
// counted back for bonus points and power (count_marks).
// ----------------------------------------------------------------------------
mark_floor:
    lda #$00                                    // $3bd5
    sta zp_fc                                   // $3bd7
    lda ball_y                                  // $3bd9
    sec                                         // $3bdc
    sbc #$2e                                    // $3bdd
    bcs L3be3                                   // $3bdf
    lda #$00                                    // $3be1
L3be3:
    lsr                                         // $3be3
    lsr                                         // $3be4
    lsr                                         // $3be5
    cmp #$04                                    // $3be6
    bcs L3bec                                   // $3be8
    lda #$04                                    // $3bea
L3bec:
    cmp #$16                                    // $3bec
    bcc L3bf2                                   // $3bee
    lda #$16                                    // $3bf0
L3bf2:
    asl                                         // $3bf2
    asl                                         // $3bf3
    asl                                         // $3bf4
    sta zp_fb                                   // $3bf5
    asl                                         // $3bf7
    rol zp_fc                                   // $3bf8
    asl                                         // $3bfa
    rol zp_fc                                   // $3bfb
    clc                                         // $3bfd
    adc zp_fb                                   // $3bfe
    sta zp_fb                                   // $3c00
    bcc L3c06                                   // $3c02
    inc zp_fc                                   // $3c04
L3c06:
    lda ball_x_hi                               // $3c06
    lsr                                         // $3c09
    lda ball_x                                  // $3c0a
    ror                                         // $3c0d
    sec                                         // $3c0e
    sbc #$08                                    // $3c0f
    bcs L3c15                                   // $3c11
    lda #$00                                    // $3c13
L3c15:
    lsr                                         // $3c15
    lsr                                         // $3c16
    cmp #$03                                    // $3c17
    bcs L3c1d                                   // $3c19
    lda #$03                                    // $3c1b
L3c1d:
    cmp #$25                                    // $3c1d
    bcc L3c23                                   // $3c1f
    lda #$25                                    // $3c21
L3c23:
    clc                                         // $3c23
    adc zp_fb                                   // $3c24
    sta zp_fb                                   // $3c26
    lda zp_fc                                   // $3c28
    adc #$04                                    // $3c2a
    sta zp_fc                                   // $3c2c
    lda zp_fb                                   // $3c2e
    sec                                         // $3c30
    sbc #$29                                    // $3c31
    sta zp_fb                                   // $3c33
    lda zp_fc                                   // $3c35
    sbc #$00                                    // $3c37
    sta zp_fc                                   // $3c39
    lda tilt_dy                                 // $3c3b
    clc                                         // $3c3e
    adc #$01                                    // $3c3f
    sta zp_fd                                   // $3c41
    asl                                         // $3c43
    clc                                         // $3c44
    adc zp_fd                                   // $3c45
    sec                                         // $3c47
    adc tilt_dx                                 // $3c48
    tax                                         // $3c4b
    lda mark_cell_counts,x                      // $3c4c
    sta mark_cell_count                         // $3c4f
    txa                                         // $3c52
    asl                                         // $3c53
    sta zp_fd                                   // $3c54
    asl                                         // $3c56
    clc                                         // $3c57
    adc zp_fd                                   // $3c58
    tax                                         // $3c5a
    lda zp_fb                                   // $3c5b
    sta zp_fd                                   // $3c5d
    lda zp_fc                                   // $3c5f
    clc                                         // $3c61
    adc #$78                                    // $3c62
    sta zp_fe                                   // $3c64
L3c66:
    lda mark_cell_offsets,x                     // $3c66
    tay                                         // $3c69
    lda (zp_fd),y                               // $3c6a  floor?
    cmp #$20                                    // $3c6c
    beq L3c74                                   // $3c6e
    cmp #$b3                                    // $3c70
    bne L3c77                                   // $3c72
L3c74:
    jsr mark_cell                               // $3c74
L3c77:
    inx                                         // $3c77
    dec mark_cell_count                         // $3c78
    bne L3c66                                   // $3c7b
    rts                                         // $3c7d
mark_cell:
    stx zp_fa                                   // $3c7e
    ldx mark_count                              // $3c80
    tya                                         // $3c83
    clc                                         // $3c84
    adc zp_fb                                   // $3c85
    sta colour_buffer,x                         // $3c87
    lda zp_fc                                   // $3c8a
    adc #$00                                    // $3c8c
    sta colour_buffer+6*40+16,x                 // $3c8e
    lda #$63                                    // $3c91  floor mark character
    sta (zp_fd),y                               // $3c93
    txa                                         // $3c95
    sec                                         // $3c96
    sbc #$02                                    // $3c97
    bcc L3cb2                                   // $3c99
    tax                                         // $3c9b
    lda colour_buffer,x                         // $3c9c
    sta zp_f8                                   // $3c9f
    lda colour_buffer+6*40+16,x                 // $3ca1
    sta zp_f9                                   // $3ca4
    ldy #$00                                    // $3ca6
    lda (zp_f8),y                               // $3ca8
    cmp #$20                                    // $3caa
    bne L3cb2                                   // $3cac
    lda #$63                                    // $3cae
    sta (zp_f8),y                               // $3cb0
L3cb2:
    inc mark_count                              // $3cb2
    ldx zp_fa                                   // $3cb5
    rts                                         // $3cb7
mark_cell_counts:
    .byte $06,$06,$06,$06,$01,$06,$06,$06,$06   // $3cb8
mark_cell_offsets:
    .byte $02,$29,$2a,$50,$51,$52,$28,$29,$2a,$50,$51,$52,$00,$28,$29,$50  // $3cc1
    .byte $51,$52,$01,$02,$29,$2a,$51,$52,$29,$29,$29,$29,$29,$29,$00,$01  // $3cd1
    .byte $28,$29,$50,$51,$00,$01,$02,$29,$2a,$52,$00,$01,$02,$28,$29,$2a  // $3ce1
    .byte $00,$01,$02,$28,$29,$50               // $3cf1

// ----------------------------------------------------------------------------
// Params: X, Y = factors
// Returns: Y = high byte, X = low byte of X * Y
// ----------------------------------------------------------------------------
multiply:
    stx zp_fb                                   // $3cf7
    sty zp_fc                                   // $3cf9
    lda #$00                                    // $3cfb
    sta zp_fd                                   // $3cfd
    ldy #$08                                    // $3cff
L3d01:
    lsr zp_fb                                   // $3d01
    bcc L3d08                                   // $3d03
    clc                                         // $3d05
    adc zp_fc                                   // $3d06
L3d08:
    ror                                         // $3d08
    ror zp_fd                                   // $3d09
    dey                                         // $3d0b
    bne L3d01                                   // $3d0c
    tay                                         // $3d0e
    ldx zp_fd                                   // $3d0f
    rts                                         // $3d11

// ----------------------------------------------------------------------------
// Choose the ball sprite frame for the light direction: the lit side
// depends on the tilt and on where the ball is on the board
// ----------------------------------------------------------------------------
pick_ball_frame:
    lda tilt_dx                                 // $3d12
    bne L3d2c                                   // $3d15
    lda #$01                                    // $3d17
    ldx tilt_angle_y                            // $3d19
    bpl L3d20                                   // $3d1c
    eor #$01                                    // $3d1e
L3d20:
    ldx ball_y                                  // $3d20
    cpx #$a0                                    // $3d23
    bcs L3d29                                   // $3d25
    eor #$01                                    // $3d27
L3d29:
    jmp set_ball_frame                          // $3d29
L3d2c:
    lda tilt_dy                                 // $3d2c
    bne L3d4b                                   // $3d2f
    lda #$01                                    // $3d31
    ldx tilt_angle_x                            // $3d33
    bpl L3d3a                                   // $3d36
    eor #$01                                    // $3d38
L3d3a:
    ldx ball_x_hi                               // $3d3a
    bne L3d48                                   // $3d3d
    ldx ball_x                                  // $3d3f
    cpx #$a0                                    // $3d42
    bcs L3d48                                   // $3d44
    eor #$01                                    // $3d46
L3d48:
    jmp set_ball_frame                          // $3d48
L3d4b:
    lda tilt_dx                                 // $3d4b
    cmp tilt_dy                                 // $3d4e
    bne L3d7c                                   // $3d51
    ldy #$00                                    // $3d53
    lda tilt_angle_x                            // $3d55
    clc                                         // $3d58
    adc tilt_angle_y                            // $3d59
    bcs L3d62                                   // $3d5c
    tya                                         // $3d5e
    eor #$01                                    // $3d5f
    tay                                         // $3d61
L3d62:
    lda ball_x_hi                               // $3d62
    ror                                         // $3d65
    lda ball_x                                  // $3d66
    ror                                         // $3d69
    clc                                         // $3d6a
    adc ball_y                                  // $3d6b
    bcs L3d78                                   // $3d6e
    cmp #$e6                                    // $3d70
    bcs L3d78                                   // $3d72
    tya                                         // $3d74
    eor #$01                                    // $3d75
    tay                                         // $3d77
L3d78:
    tya                                         // $3d78
    jmp set_ball_frame                          // $3d79
L3d7c:
    ldy #$00                                    // $3d7c
    lda tilt_angle_x                            // $3d7e
    cmp tilt_angle_y                            // $3d81
    bcs L3d8a                                   // $3d84
    tya                                         // $3d86
    eor #$01                                    // $3d87
    tay                                         // $3d89
L3d8a:
    lda ball_x_hi                               // $3d8a
    ror                                         // $3d8d
    lda ball_x                                  // $3d8e
    ror                                         // $3d91
    sec                                         // $3d92
    sbc ball_y                                  // $3d93
    bcs L3da0                                   // $3d96
    cmp #$b4                                    // $3d98
    bcs L3da0                                   // $3d9a
    tya                                         // $3d9c
    eor #$01                                    // $3d9d
    tay                                         // $3d9f
L3da0:
    tya                                         // $3da0
set_ball_frame:
    sta zp_fb                                   // $3da1
    lda ball_size                               // $3da3
    asl                                         // $3da6
    clc                                         // $3da7
    adc #$a7                                    // $3da8
    clc                                         // $3daa
    adc zp_fb                                   // $3dab
    cmp sprite_ptrs+3                           // $3dad
    beq L3db7                                   // $3db0
    ldx #$01                                    // $3db2
    stx ball_frame_changed                      // $3db4
L3db7:
    sta sprite_ptrs+3                           // $3db7
    sta sprite_ptrs+4                           // $3dba
    rts                                         // $3dbd

// ----------------------------------------------------------------------------
// Move the shine (sprite 1) over the ball with the ball's velocity,
// bouncing off the edges of the ball; sprite 1 is hidden while it is
// off the ball
// ----------------------------------------------------------------------------
move_shine:
    lda shine_y                                 // $3dbe
    sta shine_x_tmp                             // $3dc1
    lda #$7f                                    // $3dc4
    sec                                         // $3dc6
    sbc shine_x_tmp                             // $3dc7
    sta shine_x_limit                           // $3dca
    lda shine_x                                 // $3dcd
    sta shine_y_tmp                             // $3dd0
    lda #$7f                                    // $3dd3
    sec                                         // $3dd5
    sbc shine_y_tmp                             // $3dd6
    sta shine_y_limit                           // $3dd9
    lda ball_vx                                 // $3ddc
    bpl L3de6                                   // $3ddf
    eor #$ff                                    // $3de1
    clc                                         // $3de3
    adc #$01                                    // $3de4
L3de6:
    tax                                         // $3de6
    lda shine_x_tmp                             // $3de7
    tay                                         // $3dea
    jsr multiply                                // $3deb
    tya                                         // $3dee
    ldx #$01                                    // $3def
L3df1:
    lsr                                         // $3df1
    dex                                         // $3df2
    bne L3df1                                   // $3df3
    sta zp_fb                                   // $3df5
    lda ball_vx                                 // $3df7
    ldx shine_quadrant_x                        // $3dfa
    eor quadrant_sign,x                         // $3dfd
    bpl L3e0b                                   // $3e00
    lda zp_fb                                   // $3e02
    eor #$ff                                    // $3e04
    clc                                         // $3e06
    adc #$01                                    // $3e07
    sta zp_fb                                   // $3e09
L3e0b:
    lda shine_x                                 // $3e0b
    clc                                         // $3e0e
    adc zp_fb                                   // $3e0f
    bpl L3e25                                   // $3e11
    ldx zp_fb                                   // $3e13
    bpl L3e1b                                   // $3e15
    lda #$ff                                    // $3e17
    bne L3e25                                   // $3e19
L3e1b:
    ldy shine_state                             // $3e1b
    cpy #$01                                    // $3e1e
    bne L3e25                                   // $3e20
    inc shine_state                             // $3e22
L3e25:
    sta shine_x                                 // $3e25
    lda ball_vy                                 // $3e28
    bpl L3e32                                   // $3e2b
    eor #$ff                                    // $3e2d
    clc                                         // $3e2f
    adc #$01                                    // $3e30
L3e32:
    tax                                         // $3e32
    lda shine_y_tmp                             // $3e33
    tay                                         // $3e36
    jsr multiply                                // $3e37
    tya                                         // $3e3a
    ldx #$01                                    // $3e3b
L3e3d:
    lsr                                         // $3e3d
    dex                                         // $3e3e
    bne L3e3d                                   // $3e3f
    sta zp_fb                                   // $3e41
    lda ball_vy                                 // $3e43
    ldx shine_quadrant_y                        // $3e46
    eor quadrant_sign,x                         // $3e49
    bpl L3e57                                   // $3e4c
    lda zp_fb                                   // $3e4e
    eor #$ff                                    // $3e50
    clc                                         // $3e52
    adc #$01                                    // $3e53
    sta zp_fb                                   // $3e55
L3e57:
    lda shine_y                                 // $3e57
    clc                                         // $3e5a
    adc zp_fb                                   // $3e5b
    bpl L3e71                                   // $3e5d
    ldx zp_fb                                   // $3e5f
    bpl L3e67                                   // $3e61
    lda #$ff                                    // $3e63
    bne L3e71                                   // $3e65
L3e67:
    ldy shine_state                             // $3e67
    cpy #$01                                    // $3e6a
    bne L3e71                                   // $3e6c
    inc shine_state                             // $3e6e
L3e71:
    sta shine_y                                 // $3e71
    lda tilt_dy                                 // $3e74
    bne L3e8a                                   // $3e77
    lda shine_quadrant_x                        // $3e79
    cmp #$02                                    // $3e7c
    bcc L3e8a                                   // $3e7e
    lda #$50                                    // $3e80
    cmp shine_y                                 // $3e82
    bcc L3e8a                                   // $3e85
    sta shine_y                                 // $3e87
L3e8a:
    lda tilt_dx                                 // $3e8a
    bne L3ea0                                   // $3e8d
    lda shine_quadrant_y                        // $3e8f
    cmp #$02                                    // $3e92
    bcc L3ea0                                   // $3e94
    lda #$50                                    // $3e96
    cmp shine_x                                 // $3e98
    bcc L3ea0                                   // $3e9b
    sta shine_x                                 // $3e9d
L3ea0:
    ldy #$00                                    // $3ea0
    lda shine_x                                 // $3ea2
    cmp shine_x_limit                           // $3ea5
    bcc L3eae                                   // $3ea8
    cmp #$ff                                    // $3eaa
    bne L3eaf                                   // $3eac
L3eae:
    iny                                         // $3eae
L3eaf:
    lda shine_y                                 // $3eaf
    cmp shine_y_limit                           // $3eb2
    bcc L3ebb                                   // $3eb5
    cmp #$ff                                    // $3eb7
    bne L3ebd                                   // $3eb9
L3ebb:
    iny                                         // $3ebb
    iny                                         // $3ebc
L3ebd:
    tya                                         // $3ebd
    and #$01                                    // $3ebe
    beq L3ecd                                   // $3ec0
    lda shine_x_limit                           // $3ec2
    asl                                         // $3ec5
    sec                                         // $3ec6
    sbc shine_x                                 // $3ec7
    sta shine_x                                 // $3eca
L3ecd:
    tya                                         // $3ecd
    and #$02                                    // $3ece
    beq L3edd                                   // $3ed0
    lda shine_y_limit                           // $3ed2
    asl                                         // $3ed5
    sec                                         // $3ed6
    sbc shine_y                                 // $3ed7
    sta shine_y                                 // $3eda
L3edd:
    tya                                         // $3edd
    beq L3ef2                                   // $3ede
    ldx shine_quadrant_x                        // $3ee0
    lda quadrant_flip_x,x                       // $3ee3
    sta shine_quadrant_x                        // $3ee6
    ldx shine_quadrant_y                        // $3ee9
    lda quadrant_flip_x,x                       // $3eec
    sta shine_quadrant_y                        // $3eef
L3ef2:
    lda shine_x                                 // $3ef2
    bpl L3f0d                                   // $3ef5
    eor #$ff                                    // $3ef7
    cmp shine_x_limit                           // $3ef9
    bcs L3f01                                   // $3efc
    lda shine_x_limit                           // $3efe
L3f01:
    sta shine_x                                 // $3f01
    ldx shine_quadrant_x                        // $3f04
    lda quadrant_flip_y,x                       // $3f07
    sta shine_quadrant_x                        // $3f0a
L3f0d:
    lda shine_y                                 // $3f0d
    bpl L3f28                                   // $3f10
    eor #$ff                                    // $3f12
    cmp shine_y_limit                           // $3f14
    bcs L3f1c                                   // $3f17
    lda shine_y_limit                           // $3f19
L3f1c:
    sta shine_y                                 // $3f1c
    ldx shine_quadrant_y                        // $3f1f
    lda quadrant_flip_y,x                       // $3f22
    sta shine_quadrant_y                        // $3f25
L3f28:
    lda VIC_SPR_ENABLE                          // $3f28
    and #$fd                                    // $3f2b
    ldx shine_quadrant_x                        // $3f2d
    cpx #$02                                    // $3f30
    bcs L3f3d                                   // $3f32
    ldx shine_quadrant_y                        // $3f34
    cpx #$02                                    // $3f37
    bcs L3f3d                                   // $3f39
    ora #$02                                    // $3f3b
L3f3d:
    sta VIC_SPR_ENABLE                          // $3f3d
    and #$02                                    // $3f40
    bne L3f51                                   // $3f42
    ldy shine_state                             // $3f44
    cpy #$02                                    // $3f47
    bne L3f56                                   // $3f49
    jsr shine_off_sound                         // $3f4b
    jmp L3f56                                   // $3f4e
L3f51:
    ldy #$01                                    // $3f51
    sty shine_state                             // $3f53
L3f56:
    ldx shine_x                                 // $3f56
    lda shine_offset_table,x                    // $3f59
    tay                                         // $3f5c
    lda glint_on                                // $3f5d
    beq L3f6a                                   // $3f60
    lda tilt_dx                                 // $3f62
    and tilt_dy                                 // $3f65
    bne L3f6e                                   // $3f68
L3f6a:
    lda #$03                                    // $3f6a
    bne L3f70                                   // $3f6c
L3f6e:
    lda #$02                                    // $3f6e
L3f70:
    clc                                         // $3f70
    adc ball_size                               // $3f71
    tax                                         // $3f74
    sta zp_fe                                   // $3f75
    jsr multiply                                // $3f77
    sty zp_fb                                   // $3f7a
    lda #$00                                    // $3f7c
    sta zp_fc                                   // $3f7e
    ldx shine_quadrant_x                        // $3f80
    lda quadrant_dir,x                          // $3f83
    bne L3f99                                   // $3f86
    lda zp_fb                                   // $3f88
    eor #$ff                                    // $3f8a
    clc                                         // $3f8c
    adc #$01                                    // $3f8d
    sta zp_fb                                   // $3f8f
    lda zp_fc                                   // $3f91
    eor #$ff                                    // $3f93
    adc #$00                                    // $3f95
    sta zp_fc                                   // $3f97
L3f99:
    lda ball_x                                  // $3f99
    clc                                         // $3f9c
    adc zp_fb                                   // $3f9d
    sta VIC_SPR1_X                              // $3f9f
    lda ball_x_hi                               // $3fa2
    adc zp_fc                                   // $3fa5
    bne L3fb1                                   // $3fa7
    lda VIC_SPR_X_MSB                           // $3fa9
    and #$fd                                    // $3fac
    clc                                         // $3fae
    bcc L3fb6                                   // $3faf
L3fb1:
    lda VIC_SPR_X_MSB                           // $3fb1
    ora #$02                                    // $3fb4
L3fb6:
    sta VIC_SPR_X_MSB                           // $3fb6
    ldx shine_y                                 // $3fb9
    lda shine_offset_table,x                    // $3fbc
    tay                                         // $3fbf
    ldx zp_fe                                   // $3fc0
    jsr multiply                                // $3fc2
    sty zp_fb                                   // $3fc5
    ldx shine_quadrant_y                        // $3fc7
    lda quadrant_dir,x                          // $3fca
    bne L3fd8                                   // $3fcd
    lda zp_fb                                   // $3fcf
    eor #$ff                                    // $3fd1
    clc                                         // $3fd3
    adc #$01                                    // $3fd4
    sta zp_fb                                   // $3fd6
L3fd8:
    lda ball_y                                  // $3fd8
    clc                                         // $3fdb
    adc zp_fb                                   // $3fdc
    sta VIC_SPR1_Y                              // $3fde
    jsr shine_diagonal                          // $3fe1
    lda glint_on                                // $3fe4
    beq L3fec                                   // $3fe7
    jsr draw_ball_glint                         // $3fe9
L3fec:
    rts                                         // $3fec
shine_diagonal:
    lda tilt_dx                                 // $3fed
    and tilt_dy                                 // $3ff0
    beq L4018                                   // $3ff3
    lda #$02                                    // $3ff5
    ldx shine_x                                 // $3ff7
    cpx shine_y                                 // $3ffa
    bcs L400d                                   // $3ffd
    clc                                         // $3fff
    adc shine_x                                 // $4000
    bpl L4007                                   // $4003
    lda #$7f                                    // $4005
L4007:
    sta shine_x                                 // $4007
    clc                                         // $400a
    bcc L4018                                   // $400b
L400d:
    clc                                         // $400d
    adc shine_y                                 // $400e
    bpl L4015                                   // $4011
    lda #$7f                                    // $4013
L4015:
    sta shine_y                                 // $4015
L4018:
    rts                                         // $4018
quadrant_sign:
    .byte $00,$80,$00,$80                       // $4019
quadrant_dir:
    .byte $00,$01,$01,$00                       // $401d
quadrant_flip_y:
    .byte $01,$00,$03,$02                       // $4021
quadrant_flip_x:
    .byte $03,$02,$01,$00                       // $4025

// ----------------------------------------------------------------------------
// Main loop
// ----------------------------------------------------------------------------
main_loop:
    jsr init_machine                            // $4029  machine init
title_loop:
    jsr check_hiscore                           // $402c  after a game: new high score?
new_game:
    jsr title_screen                            // $402f  title screen (waits for fire, or runs the demo)
    jsr init_game                               // $4032  game variables
    jsr start_first_maze                        // $4035  first maze
level_loop:
    jsr play_level                              // $4038  play one level
    lda demo_mode                               // $403b  demo: back to the title
    bne new_game                                // $403e
    lda game_over                               // $4040  game over: back to the title
    beq level_loop                              // $4043
    jmp title_loop                              // $4045

// ----------------------------------------------------------------------------
// Copy the current maze's screen from $A000 + maze * $400 to the screen
// buffer at $7C00, then draw the board frame around it
// ----------------------------------------------------------------------------
draw_maze_screen:
    lda maze                                    // $4048
    asl                                         // $404b
    asl                                         // $404c
    clc                                         // $404d
    adc #$a0                                    // $404e
    sta zp_fc                                   // $4050
    lda #$00                                    // $4052
    sta zp_fb                                   // $4054
    sta zp_fd                                   // $4056
    lda #$7c                                    // $4058
    sta zp_fe                                   // $405a
    ldx #$04                                    // $405c
    ldy #$00                                    // $405e
L4060:
    lda (zp_fb),y                               // $4060
    sta (zp_fd),y                               // $4062
    iny                                         // $4064
    bne L4060                                   // $4065
    inc zp_fc                                   // $4067
    inc zp_fe                                   // $4069
    dex                                         // $406b
    bne L4060                                   // $406c
    lda #$78                                    // $406e
    sta screen_buffer+3*40+1                    // $4070
    lda #$79                                    // $4073
    sta screen_buffer+3*40+37                   // $4075
    lda #$7a                                    // $4078
    sta screen_buffer+23*40+37                  // $407a
    lda #$7b                                    // $407d
    sta screen_buffer+23*40+1                   // $407f
    jsr draw_board_frame                        // $4082
    rts                                         // $4085

// ----------------------------------------------------------------------------
// Board frame: left / right columns and top / bottom rows with corners
// ----------------------------------------------------------------------------
draw_board_frame:
    ldx #$17                                    // $4086
    lda #<(screen_buffer+2*40+0)                // $4088
    sta zp_fb                                   // $408a
    lda #>(screen_buffer+2*40+0)                // $408c
    sta zp_fc                                   // $408e
L4090:
    ldy #$00                                    // $4090
    lda #$ae                                    // $4092
    sta (zp_fb),y                               // $4094
    ldy #$26                                    // $4096
    lda #$a6                                    // $4098
    sta (zp_fb),y                               // $409a
    ldy #$27                                    // $409c
    lda #$a0                                    // $409e
    sta (zp_fb),y                               // $40a0
    lda zp_fb                                   // $40a2
    clc                                         // $40a4
    adc #$28                                    // $40a5
    sta zp_fb                                   // $40a7
    bcc L40ad                                   // $40a9
    inc zp_fc                                   // $40ab
L40ad:
    dex                                         // $40ad
    bne L4090                                   // $40ae
    ldx #$26                                    // $40b0
L40b2:
    lda #$a2                                    // $40b2
    sta screen_buffer+2*40+0,x                  // $40b4
    lda #$aa                                    // $40b7
    sta screen_buffer+24*40+0,x                 // $40b9
    dex                                         // $40bc
    bpl L40b2                                   // $40bd
    lda #$a1                                    // $40bf
    sta screen_buffer+2*40+1                    // $40c1
    lda #$a3                                    // $40c4
    sta screen_buffer+2*40+37                   // $40c6
    lda #$a4                                    // $40c9
    sta screen_buffer+2*40+38                   // $40cb
    lda #$a5                                    // $40ce
    sta screen_buffer+3*40+38                   // $40d0
    lda #$a7                                    // $40d3
    sta screen_buffer+23*40+38                  // $40d5
    lda #$a8                                    // $40d8
    sta screen_buffer+24*40+38                  // $40da
    lda #$a9                                    // $40dd
    sta screen_buffer+24*40+37                  // $40df
    lda #$ab                                    // $40e2
    sta screen_buffer+24*40+1                   // $40e4
    lda #$ac                                    // $40e7
    sta screen_buffer+24*40+0                   // $40e9
    lda #$ad                                    // $40ec
    sta screen_buffer+23*40+0                   // $40ee
    lda #$af                                    // $40f1
    sta screen_buffer+3*40+0                    // $40f3
    lda #$b0                                    // $40f6
    sta screen_buffer+2*40+0                    // $40f8
    rts                                         // $40fb

// ----------------------------------------------------------------------------
// Copy the screen buffer ($7C50-$7FFF) to the screen ($0450) and the
// colour buffer ($7850-$7BFF) to colour RAM ($D850): everything but the
// top two status rows
// ----------------------------------------------------------------------------
show_buffers:
    lda #<D7be8                                 // $40fc
    sta zp_fb                                   // $40fe
    sta zp_fd                                   // $4100
    lda #>D7be8                                 // $4102
    sta zp_fc                                   // $4104
    lda #$03                                    // $4106
    sta zp_fe                                   // $4108
    ldx #$04                                    // $410a
    ldy #$68                                    // $410c
L410e:
    lda (zp_fb),y                               // $410e
    sta (zp_fd),y                               // $4110
    iny                                         // $4112
    bne L410e                                   // $4113
    inc zp_fc                                   // $4115
    inc zp_fe                                   // $4117
    dex                                         // $4119
    bne L410e                                   // $411a
    lda #<colour_buffer                         // $411c
    sta zp_fb                                   // $411e
    sta zp_fd                                   // $4120
    lda #>colour_buffer                         // $4122
    sta zp_fc                                   // $4124
    lda #$d8                                    // $4126
    sta zp_fe                                   // $4128
    ldx #$04                                    // $412a
    ldy #$50                                    // $412c
L412e:
    lda (zp_fb),y                               // $412e
    sta (zp_fd),y                               // $4130
    iny                                         // $4132
    bne L412e                                   // $4133
    inc zp_fc                                   // $4135
    inc zp_fe                                   // $4137
    dex                                         // $4139
    bne L412e                                   // $413a
    rts                                         // $413c

// ----------------------------------------------------------------------------
// Fill the colour buffer with the maze's floor colour
// ----------------------------------------------------------------------------
fill_colour_buffer:
    lda #<colour_buffer                         // $413d
    sta zp_fb                                   // $413f
    lda #>colour_buffer                         // $4141
    sta zp_fc                                   // $4143
    ldx maze                                    // $4145
    lda maze_floor_colours,x                    // $4148
    ldx #$04                                    // $414b
    ldy #$00                                    // $414d
L414f:
    sta (zp_fb),y                               // $414f
    iny                                         // $4151
    bne L414f                                   // $4152
    inc zp_fc                                   // $4154
    dex                                         // $4156
    bne L414f                                   // $4157
    jsr colour_frame                            // $4159
    rts                                         // $415c

// ----------------------------------------------------------------------------
// Frame colour for the board frame cells
// ----------------------------------------------------------------------------
colour_frame:
    ldx maze                                    // $415d
    lda maze_frame_colours,x                    // $4160
    sta zp_fd                                   // $4163
    ldx #$17                                    // $4165
    lda #<(colour_buffer+2*40+0)                // $4167
    sta zp_fb                                   // $4169
    lda #>(colour_buffer+2*40+0)                // $416b
    sta zp_fc                                   // $416d
L416f:
    lda zp_fd                                   // $416f
    ldy #$00                                    // $4171
    sta (zp_fb),y                               // $4173
    ldy #$26                                    // $4175
    sta (zp_fb),y                               // $4177
    lda zp_fb                                   // $4179
    clc                                         // $417b
    adc #$28                                    // $417c
    sta zp_fb                                   // $417e
    bcc L4184                                   // $4180
    inc zp_fc                                   // $4182
L4184:
    dex                                         // $4184
    bne L416f                                   // $4185
    ldx #$26                                    // $4187
    lda zp_fd                                   // $4189
L418b:
    sta colour_buffer+2*40+0,x                  // $418b
    sta colour_buffer+24*40+0,x                 // $418e
    dex                                         // $4191
    bpl L418b                                   // $4192
    rts                                         // $4194
maze_floor_colours:
    .byte $0e,$0a,$0c,$0d                       // $4195
maze_frame_colours:
    .byte $0e,$0a,$0c,$0d                       // $4199

// ----------------------------------------------------------------------------
// Colour the gate (colour 15) in the colour buffer
// ----------------------------------------------------------------------------
colour_gates:
    lda #$08                                    // $419d
    sta gate_count                              // $419f
    ldx maze                                    // $41a2
    lda maze_gate_index,x                       // $41a5
    sta gate_index                              // $41a8
    lda #$00                                    // $41ab
    sta gate_gfx_offset                         // $41ad
L41b0:
    ldx gate_index                              // $41b0
    lda gate_table,x                            // $41b3
    sta zp_fd                                   // $41b6
    inx                                         // $41b8
    lda gate_table,x                            // $41b9
    clc                                         // $41bc
    adc #$74                                    // $41bd
    sta zp_fe                                   // $41bf
    inx                                         // $41c1
    lda gate_table,x                            // $41c2
    sta zp_fb                                   // $41c5
    asl                                         // $41c7
    clc                                         // $41c8
    adc zp_fb                                   // $41c9
    sta zp_fb                                   // $41cb
    lda #$02                                    // $41cd
    sta zp_fc                                   // $41cf
L41d1:
    ldy zp_fb                                   // $41d1
    lda gate_cell_layout,y                      // $41d3
    tay                                         // $41d6
    lda #$0f                                    // $41d7
    sta (zp_fd),y                               // $41d9
    inc zp_fb                                   // $41db
    dec zp_fc                                   // $41dd
    bpl L41d1                                   // $41df
    lda gate_index                              // $41e1
    clc                                         // $41e4
    adc #$03                                    // $41e5
    sta gate_index                              // $41e7
    dec gate_count                              // $41ea
    bne L41b0                                   // $41ed
    rts                                         // $41ef
gate_cell_layout:
    .byte $01,$29,$51,$28,$29,$2a,$2a,$51,$52,$29,$51,$52  // $41f0

// ----------------------------------------------------------------------------
// Prepare the next maze and slide it in from the right
// ----------------------------------------------------------------------------
next_maze_slide:
    jsr draw_maze_screen                        // $41fc
    sec                                         // $41ff
    jsr draw_gates                              // $4200
    jsr draw_gate_colours                       // $4203
    jsr fill_colour_buffer                      // $4206
    jsr colour_gates                            // $4209
    lda #$00                                    // $420c
    sta tilt_enabled                            // $420e
    lda #$01                                    // $4211
    sta slide_out_flag                          // $4213
    ldx maze                                    // $4216
    lda #$40                                    // $4219
    clc                                         // $421b
    adc hole_x_by_maze,x                        // $421c
    dex                                         // $421f
    sec                                         // $4220
    sbc hole_x_by_maze,x                        // $4221
    sta hole_wrap                               // $4224
    lda #$00                                    // $4227
    sta slide_speed                             // $4229
    lda #$01                                    // $422c
    sta slide_speed_sign                        // $422e
    lda #$02                                    // $4231
    sta slide_accel                             // $4233
    lda #$01                                    // $4236
    sta slide_dir                               // $4238
    lda #$60                                    // $423b
    sta slide_speed_max                         // $423d
    lda fine_scroll_x                           // $4240
    sta slide_fine                              // $4243
    lda #$00                                    // $4246
    sta slide_fine_frac                         // $4248
    lda #$00                                    // $424b
    sta slide_column                            // $424d
    lda #$01                                    // $4250
    sta slide_state                             // $4252
slide_wait:
    jsr slide_tick                              // $4255
    lda slide_column                            // $4258
    cmp #$28                                    // $425b
    bcc slide_wait                              // $425d
    jsr slide_in                                // $425f
    rts                                         // $4262

// ----------------------------------------------------------------------------
// Slide the maze in, bouncing a few times (slide_bounce steps)
// ----------------------------------------------------------------------------
slide_in:
    lda #$00                                    // $4263
    sta sign_sound_on                           // $4265
    sta slide_bounce                            // $4268
    lda #$08                                    // $426b
    sta SID_V1_CTRL                             // $426d
    sta SID_V2_CTRL                             // $4270
slide_bounce_loop:
    lda #$00                                    // $4273
    sta slide_state                             // $4275
    jsr slide_sound                             // $4278
    ldx slide_bounce                            // $427b
    lda slide_bounce_speeds,x                   // $427e
    sta slide_accel                             // $4281
    lda slide_out_flag                          // $4284
    beq L428f                                   // $4287
    jsr slide_step_out                          // $4289
    jmp L4292                                   // $428c
L428f:
    jsr slide_step_back                         // $428f
L4292:
    inc slide_bounce                            // $4292
    lda slide_bounce                            // $4295
    cmp #$06                                    // $4298
    bcc slide_bounce_loop                       // $429a
    jsr slide_sound                             // $429c
    lda #$00                                    // $429f
    sta slide_state                             // $42a1
    jsr init_hole                               // $42a4
    rts                                         // $42a7
slide_bounce_speeds:
    .byte $04,$07,$0c,$13,$1c,$27,$ff           // $42a8
slide_step_out:
    lda #$80                                    // $42af
    sta slide_speed                             // $42b1
    lda #$00                                    // $42b4
    sta slide_speed_sign                        // $42b6
    lda #$01                                    // $42b9
    sta slide_dir                               // $42bb
    lda #$80                                    // $42be
    sta slide_speed_max                         // $42c0
    lda #$00                                    // $42c3
    sta slide_fine_frac                         // $42c5
    lda #$01                                    // $42c8
    sta slide_state                             // $42ca
L42cd:
    jsr slide_tick                              // $42cd
    lda slide_column                            // $42d0
    cmp #$28                                    // $42d3
    bcc L42cd                                   // $42d5
    lda slide_speed_sign                        // $42d7
    beq L42cd                                   // $42da
    rts                                         // $42dc
slide_step_back:
    lda #$80                                    // $42dd
    sta slide_speed                             // $42df
    lda #$01                                    // $42e2
    sta slide_speed_sign                        // $42e4
    lda #$00                                    // $42e7
    sta slide_dir                               // $42e9
    lda #$80                                    // $42ec
    sta slide_speed_max                         // $42ee
    lda #$00                                    // $42f1
    sta slide_fine_frac                         // $42f3
    lda #$01                                    // $42f6
    sta slide_state                             // $42f8
L42fb:
    jsr slide_tick                              // $42fb
    lda slide_column                            // $42fe
    bpl L42fb                                   // $4301
    lda slide_speed_sign                        // $4303
    bne L42fb                                   // $4306
    rts                                         // $4308

// ----------------------------------------------------------------------------
// One step of the slide: wait a little, then scroll the whole screen one
// column (slide_state 2: right, 3: left) and draw the new column
// ----------------------------------------------------------------------------
slide_tick:
    lda slide_state                             // $4309
    cmp #$02                                    // $430c
    bcc L433b                                   // $430e
    ldx #$06                                    // $4310
slide_delay:
    ldy #$66                                    // $4312
L4314:
    dey                                         // $4314
    beq L431a                                   // $4315
    jmp L4314                                   // $4317
L431a:
    dex                                         // $431a
    bne slide_delay                             // $431b
    jsr slide_column_source                     // $431d
    lda slide_state                             // $4320
    cmp #$02                                    // $4323
    bne L4330                                   // $4325
    jsr scroll_screen_right                     // $4327
    dec slide_column                            // $432a
    jmp L4336                                   // $432d
L4330:
    jsr scroll_screen_left                      // $4330
    inc slide_column                            // $4333
L4336:
    lda #$01                                    // $4336
    sta slide_state                             // $4338
L433b:
    rts                                         // $433b
slide_sound:
    lda #$07                                    // $433c
    ldx #$09                                    // $433e
    ldy #$10                                    // $4340
    sty SID_V2_CTRL                             // $4342
    sty SID_V1_CTRL                             // $4345
    sta SID_V2_FREQ_HI                          // $4348
    sta SID_V1_FREQ_HI                          // $434b
    stx SID_V2_AD                               // $434e
    stx SID_V1_AD                               // $4351
    lda #$00                                    // $4354
    sta SID_V2_FREQ_LO                          // $4356
    sta SID_V1_FREQ_LO                          // $4359
    sta SID_V2_SR                               // $435c
    sta SID_V1_SR                               // $435f
    lda #$11                                    // $4362
    sta SID_V2_CTRL                             // $4364
    sta SID_V1_CTRL                             // $4367
    rts                                         // $436a

// ----------------------------------------------------------------------------
// Slide: accelerate / brake, then fine scroll with $D016 (slide_fine);
// every 8 pixels a whole column is scrolled by slide_tick
// ----------------------------------------------------------------------------
slide_scroll:
    lda slide_state                             // $436b
    bne L4373                                   // $436e
    jmp L43e4                                   // $4370
L4373:
    jsr slide_noise                             // $4373
    lda slide_fine                              // $4376
    sta fine_scroll_x                           // $4379
    jsr slide_accelerate                        // $437c
    lda #$00                                    // $437f
    sta zp_fb                                   // $4381
    lda slide_speed                             // $4383
    ldx #$05                                    // $4386
L4388:
    lsr                                         // $4388
    ror zp_fb                                   // $4389
    dex                                         // $438b
    bne L4388                                   // $438c
    sta zp_fc                                   // $438e
    lda slide_speed_sign                        // $4390
    bne L43bf                                   // $4393
    lda slide_fine_frac                         // $4395
    clc                                         // $4398
    adc zp_fb                                   // $4399
    sta slide_fine_frac                         // $439b
    lda slide_fine                              // $439e
    adc zp_fc                                   // $43a1
    cmp #$08                                    // $43a3
    bcc L43b6                                   // $43a5
    sec                                         // $43a7
    sbc #$08                                    // $43a8
    ldx slide_state                             // $43aa
    cpx #$01                                    // $43ad
    bne L43b6                                   // $43af
    ldx #$02                                    // $43b1
    stx slide_state                             // $43b3
L43b6:
    sta slide_fine                              // $43b6
    jsr hole_slide_right                        // $43b9
    jmp L43e4                                   // $43bc
L43bf:
    lda slide_fine_frac                         // $43bf
    sec                                         // $43c2
    sbc zp_fb                                   // $43c3
    sta slide_fine_frac                         // $43c5
    lda slide_fine                              // $43c8
    sbc zp_fc                                   // $43cb
    bcs L43de                                   // $43cd
    clc                                         // $43cf
    adc #$08                                    // $43d0
    ldx slide_state                             // $43d2
    cpx #$01                                    // $43d5
    bne L43de                                   // $43d7
    ldx #$03                                    // $43d9
    stx slide_state                             // $43db
L43de:
    sta slide_fine                              // $43de
    jsr hole_slide_left                         // $43e1
L43e4:
    rts                                         // $43e4
slide_accelerate:
    lda slide_speed_sign                        // $43e5
    eor slide_dir                               // $43e8
    bne L4402                                   // $43eb
    lda slide_speed                             // $43ed
    clc                                         // $43f0
    adc slide_accel                             // $43f1
    cmp slide_speed_max                         // $43f4
    bcc L43fc                                   // $43f7
    lda slide_speed_max                         // $43f9
L43fc:
    sta slide_speed                             // $43fc
    jmp L4418                                   // $43ff
L4402:
    lda slide_speed                             // $4402
    sec                                         // $4405
    sbc slide_accel                             // $4406
    bcs L4415                                   // $4409
    lda slide_speed_sign                        // $440b
    eor #$01                                    // $440e
    sta slide_speed_sign                        // $4410
    lda #$00                                    // $4413
L4415:
    sta slide_speed                             // $4415
L4418:
    rts                                         // $4418

// ----------------------------------------------------------------------------
// Scroll screen and colour RAM rows 2-24 one column to the left
// ----------------------------------------------------------------------------
scroll_screen_left:
    ldx #$50                                    // $4419
L441b:
    lda screen+1,x                              // $441b
    sta screen,x                                // $441e
    lda COLOR_RAM+1,x                           // $4421
    sta COLOR_RAM,x                             // $4424
    inx                                         // $4427
    bne L441b                                   // $4428
L442a:
    lda screen+6*40+17,x                        // $442a
    sta screen+6*40+16,x                        // $442d
    lda COLOR_RAM+6*40+17,x                     // $4430
    sta COLOR_RAM+6*40+16,x                     // $4433
    inx                                         // $4436
    bne L442a                                   // $4437
L4439:
    lda screen+12*40+33,x                       // $4439
    sta screen+12*40+32,x                       // $443c
    lda COLOR_RAM+12*40+33,x                    // $443f
    sta COLOR_RAM+12*40+32,x                    // $4442
    inx                                         // $4445
    bne L4439                                   // $4446
L4448:
    lda screen+19*40+9,x                        // $4448
    sta screen+19*40+8,x                        // $444b
    lda COLOR_RAM+19*40+9,x                     // $444e
    sta COLOR_RAM+19*40+8,x                     // $4451
    inx                                         // $4454
    cpx #$e8                                    // $4455
    bne L4448                                   // $4457
    lda #$27                                    // $4459
    sta L4498+1                                 // $445b
    sta L449d+1                                 // $445e
    jsr slide_copy_column                       // $4461
    rts                                         // $4464

// ----------------------------------------------------------------------------
// Set the source (buffer column) and screen addresses for slide_copy_column
// ----------------------------------------------------------------------------
slide_column_source:
    ldx slide_column                            // $4465
    lda slide_state                             // $4468
    sec                                         // $446b
    sbc #$02                                    // $446c
    eor slide_out_flag                          // $446e
    beq L4475                                   // $4471
    ldx #<(screen_buffer+39)                    // $4473
L4475:
    stx zp_fb                                   // $4475
    stx zp_fd                                   // $4477
    lda #>(screen_buffer+39)                    // $4479
    sta zp_fc                                   // $447b
    lda #$78                                    // $447d
    sta zp_fe                                   // $447f
    lda #$04                                    // $4481
    sta L4498+2                                 // $4483
    sta L4902+2                                 // $4486
    lda #$d8                                    // $4489
    sta L449d+2                                 // $448b
    sta L4907+2                                 // $448e
    rts                                         // $4491

// ----------------------------------------------------------------------------
// Copy one column (23 rows) from the buffers to the screen / colour RAM
// ----------------------------------------------------------------------------
slide_copy_column:
    ldx #$17                                    // $4492
    ldy #$50                                    // $4494
L4496:
    lda (zp_fb),y                               // $4496
L4498:
    sta $ffff,y                                 // $4498
    lda (zp_fd),y                               // $449b
L449d:
    sta $ffff,y                                 // $449d
    tya                                         // $44a0
    clc                                         // $44a1
    adc #$28                                    // $44a2
    tay                                         // $44a4
    bcc L44b1                                   // $44a5
    inc zp_fc                                   // $44a7
    inc zp_fe                                   // $44a9
    inc L4498+2                                 // $44ab
    inc L449d+2                                 // $44ae
L44b1:
    dex                                         // $44b1
    bne L4496                                   // $44b2
    rts                                         // $44b4

// ----------------------------------------------------------------------------
// After a game: if the score beats the high score, copy it, scroll it
// into the high score display and play a sound
// ----------------------------------------------------------------------------
check_hiscore:
    lda #$01                                    // $44b5
    sta no_restart                              // $44b7
    sed                                         // $44ba
    lda hiscore                                 // $44bb
    sec                                         // $44be
    sbc score                                   // $44bf
    lda hiscore+1                               // $44c2
    sbc score+1                                 // $44c5
    lda hiscore+2                               // $44c8
    sbc score+2                                 // $44cb
    cld                                         // $44ce
    bcc L44de                                   // $44cf
    lda game_over                               // $44d1
    beq L44db                                   // $44d4
    lda #$1e                                    // $44d6
    jsr wait_frames                             // $44d8
L44db:
    jmp check_hiscore_done                      // $44db
L44de:
    lda score                                   // $44de
    sta hiscore                                 // $44e1
    lda score+1                                 // $44e4
    sta hiscore+1                               // $44e7
    lda score+2                                 // $44ea
    sta hiscore+2                               // $44ed
    jsr sid_off                                 // $44f0
    lda #$f0                                    // $44f3
    sta SID_V2_SR                               // $44f5
    lda #$11                                    // $44f8
    sta SID_V2_CTRL                             // $44fa
    lda #$01                                    // $44fd
    sta scroll_hiscore_step                     // $44ff
    sta blip_sound                              // $4502
hiscore_scroll_wait:
    lda scroll_hiscore_step                     // $4505
    bne hiscore_scroll_wait                     // $4508
    lda #$00                                    // $450a
    sta blip_sound                              // $450c
    sta roll_sound_off                          // $450f
    sta SID_V2_CTRL                             // $4512
    clc                                         // $4515
    jsr gate_sound                              // $4516
    lda #$1e                                    // $4519
    jsr wait_frames                             // $451b
check_hiscore_done:
    lda #$00                                    // $451e
    lda no_restart                              // $4520
    rts                                         // $4523

// ----------------------------------------------------------------------------
// New game: level 1 (or level 8, maze 2 in demo mode), score 0
// ----------------------------------------------------------------------------
init_game:
    ldx #$00                                    // $4524
    ldy #$00                                    // $4526
    lda demo_mode                               // $4528  demo or (unused) $CF89: start at level 8, maze 2
    ora cf89_unused                             // $452b
    beq L4534                                   // $452e
    ldx #$07                                    // $4530
    ldy #$02                                    // $4532
L4534:
    stx level                                   // $4534  level
    sty maze                                    // $4537  maze
    lda #$00                                    // $453a
    sta score                                   // $453c
    sta score+1                                 // $453f
    sta score+2                                 // $4542
    ldx level                                   // $4545
    cpx #$04                                    // $4548
    bcc L454e                                   // $454a
    ldx #$04                                    // $454c
L454e:
    stx speed_class                             // $454e
    lda tilt_rates,x                            // $4551
    sta tilt_rate                               // $4554
    jsr init_hole                               // $4557  exit hole of the first maze
    lda #$b8                                    // $455a  exit hole sprite frame
    sta hole_sprite                             // $455c
    rts                                         // $455f
tilt_rates:
    .byte $07,$08,$08,$09,$09                   // $4560

// ----------------------------------------------------------------------------
// Put the ball at the start position of the maze
// ----------------------------------------------------------------------------
place_ball_start:
    lda maze                                    // $4565
    asl                                         // $4568
    clc                                         // $4569
    adc maze                                    // $456a
    tax                                         // $456d
    lda ball_start_positions,x                  // $456e
    sta ball_x                                  // $4571
    inx                                         // $4574
    lda ball_start_positions,x                  // $4575
    sta ball_x_hi                               // $4578
    inx                                         // $457b
    lda ball_start_positions,x                  // $457c
    sta ball_y                                  // $457f
    lda #$80                                    // $4582
    sta ball_x_frac                             // $4584
    sta ball_y_frac                             // $4587
    rts                                         // $458a
ball_start_positions:
    .byte $36,$00,$d0                           // $458b
    .byte $22,$01,$d0                           // $458e
    .byte $20,$01,$62                           // $4591
    .byte $34,$00,$62                           // $4594

// ----------------------------------------------------------------------------
// Play one maze (one ball): set up, let the ball appear and wait for
// fire, then run until the ball drops into the exit hole or rolls off the
// touches a wall. Speed, tilt rate and ball size grow with the level.
// ----------------------------------------------------------------------------
play_level:
    lda #$01                                    // $4597  power drains with each clunk, BACKUP allowed
    sta power_drain_on                          // $4599
    sta backup_allowed                          // $459c
    lda VIC_SPR_ENABLE                          // $459f  sprites 1-4 off
    and #$e1                                    // $45a2
    sta VIC_SPR_ENABLE                          // $45a4
    ldx level                                   // $45a7  speed class and tilt rate from the level (max 4)
    cpx #$04                                    // $45aa
    bcc L45b0                                   // $45ac
    ldx #$04                                    // $45ae
L45b0:
    stx speed_class                             // $45b0
    lda tilt_rates,x                            // $45b3
    sta tilt_rate                               // $45b6
    lda level                                   // $45b9  ball size = level index - 3, limited to 1-6: the ball grows from level 6 on
    sec                                         // $45bc
    sbc #$03                                    // $45bd
    bcc L45c5                                   // $45bf
    cmp #$01                                    // $45c1
    bcs L45ca                                   // $45c3
L45c5:
    lda #$01                                    // $45c5
    jmp L45d0                                   // $45c7
L45ca:
    cmp #$06                                    // $45ca
    bcc L45d0                                   // $45cc
    lda #$06                                    // $45ce
L45d0:
    sta ball_size                               // $45d0
    jsr draw_maze_screen                        // $45d3  maze to the buffers, ball to its start
    jsr place_ball_start                        // $45d6
    jsr clear_char_2318                         // $45d9
    jsr init_ball_sprites                       // $45dc
    lda new_ball_size                           // $45df  new level and a bigger ball: dissolve the old one first
    beq L45fa                                   // $45e2
    lda #$00                                    // $45e4
    sta new_ball_size                           // $45e6
    lda ball_size                               // $45e9
    cmp #$01                                    // $45ec
    beq L45fa                                   // $45ee
    lda level                                   // $45f0
    cmp #$0a                                    // $45f3
    bcs L45fa                                   // $45f5
    jsr ball_dissolve                           // $45f7
L45fa:
    jsr ball_appear                             // $45fa  ball appears, wait for fire
    lda VIC_SPR_ENABLE                          // $45fd  shading sprite off
    and #$fe                                    // $4600
    sta VIC_SPR_ENABLE                          // $4602
    lda VIC_SPR_BG_COLL                         // $4605  clear the sprite-background collision latch
    lda #$00                                    // $4608
    sta ball_waiting                            // $460a
    sta mark_count                              // $460d
    sta shine_state                             // $4610
    jsr draw_ball_glint                         // $4613
    lda #$dd                                    // $4616  shine sprite frame
    sta sprite_ptrs+1                           // $4618
    lda #$03                                    // $461b
    sta count_marks_delay                       // $461d
    lda #$01                                    // $4620  all game updates on
    sta glint_on                                // $4622
    sta marking_on                              // $4625
    sta tilt_enabled                            // $4628
    sta controls_enabled                        // $462b
    sta steering_on                             // $462e
    sta fire_enabled                            // $4631
    lda #$00                                    // $4634
    sta ball_in_hole                            // $4636
    sta ball_lost                               // $4639
    lda #$01                                    // $463c
    sta demo_stops_at_end                       // $463e
play_level_loop:
    lda #$01                                    // $4641
    jsr wait_frames                             // $4643
    jsr update_tilt_graphics                    // $4646  the frame work runs in the IRQ; here only the tilt graphics
    clc                                         // $4649
    jsr draw_gates                              // $464a
    lda ball_in_hole                            // $464d  until in the hole or lost
    ora ball_lost                               // $4650
    beq play_level_loop                         // $4653
    lda ball_in_hole                            // $4655  in the hole: next maze
    beq L4660                                   // $4658
    jsr level_done                              // $465a
    jmp L4663                                   // $465d
L4660:
    jsr ball_lost_sequence                      // $4660  touched a wall
L4663:
    rts                                         // $4663

// ----------------------------------------------------------------------------
// Params: A = number of frames to wait (counted down by the raster IRQ)
// ----------------------------------------------------------------------------
wait_frames:
    sta wait_counter                            // $4664
L4667:
    lda wait_counter                            // $4667
    bne L4667                                   // $466a
    rts                                         // $466c

// ----------------------------------------------------------------------------
// Silence: clear SID registers $D400-$D414
// ----------------------------------------------------------------------------
sid_off:
    ldx #$14                                    // $466d
    lda #$00                                    // $466f
L4671:
    sta SID_V1_FREQ_LO,x                        // $4671
    dex                                         // $4674
    bpl L4671                                   // $4675
    rts                                         // $4677

// ----------------------------------------------------------------------------
// The ball is in the exit hole: drop it in, shake the board, count the
// bonus, then slide to the next maze (after maze 3: next level)
// ----------------------------------------------------------------------------
level_done:
    lda demo_mode                               // $4678
    beq L4685                                   // $467b
    sec                                         // $467d
    jsr edge_highlight_v                        // $467e
    sec                                         // $4681
    jsr edge_highlight_h                        // $4682
L4685:
    jsr ball_drop_in_hole                       // $4685
    lda #$00                                    // $4688
    sta marking_on                              // $468a
    lda #$0a                                    // $468d
    jsr wait_frames                             // $468f
    jsr shake_board                             // $4692
    jsr level_bonus                             // $4695
    lda demo_mode                               // $4698
    beq L46a5                                   // $469b
    lda #$32                                    // $469d
    jsr wait_frames                             // $469f
    jmp L46eb                                   // $46a2
L46a5:
    inc maze                                    // $46a5
    jsr init_level_sign                         // $46a8
    jsr level_sign_slide_in                     // $46ab
    lda maze                                    // $46ae
    cmp #$04                                    // $46b1
    bcs L46bb                                   // $46b3
    jsr next_maze_slide                         // $46b5
    jmp L46e8                                   // $46b8
L46bb:
    jsr next_level_slide                        // $46bb
    lda #$00                                    // $46be
    sta sign_spin_speed                         // $46c0
    sta roll_sound_off                          // $46c3
    lda #$14                                    // $46c6
    jsr wait_frames                             // $46c8
    lda #$00                                    // $46cb
    sta maze                                    // $46cd
    lda #$00                                    // $46d0
    sta two_tone_step                           // $46d2
    lda #$01                                    // $46d5
    sta power_refill                            // $46d7
    sta two_tone_timer                          // $46da
    sta scroll_level_step                       // $46dd
    sta new_ball_size                           // $46e0
L46e3:
    lda two_tone_timer                          // $46e3
    bne L46e3                                   // $46e6
L46e8:
    jsr level_sign_slide_out                    // $46e8
L46eb:
    rts                                         // $46eb

// ----------------------------------------------------------------------------
// The ball touched a wall: sound, flash, then level the board and count
// the bonus; if that was the BACKUP power: game over
// ----------------------------------------------------------------------------
ball_lost_sequence:
    jsr mask_ball_sprite                        // $46ec
    jsr sid_off                                 // $46ef
    lda #$d0                                    // $46f2
    sta SID_V2_SR                               // $46f4
    lda #$15                                    // $46f7
    sta SID_V2_CTRL                             // $46f9
    lda #$00                                    // $46fc
    sta flash_phase                             // $46fe
    lda #$01                                    // $4701
    sta flash_step                              // $4703
L4706:
    lda flash_step                              // $4706
    bne L4706                                   // $4709
    jsr sid_off                                 // $470b
    lda #$e0                                    // $470e
    sta SID_V2_SR                               // $4710
    lda #$11                                    // $4713
    sta SID_V2_CTRL                             // $4715
    lda #$01                                    // $4718
    sta VIC_BG2                                 // $471a
    lda #$14                                    // $471d
    jsr wait_frames                             // $471f
    lda VIC_SPR_ENABLE                          // $4722
    and #$e1                                    // $4725
    sta VIC_SPR_ENABLE                          // $4727
    lda game_over                               // $472a
    bne L4766                                   // $472d
    lda #$01                                    // $472f
    sta tilt_enabled                            // $4731
    sta fire_enabled                            // $4734
    lda #$1e                                    // $4737
    sta controls                                // $4739
L473c:
    lda #$01                                    // $473c
    jsr wait_frames                             // $473e
    jsr update_tilt_graphics                    // $4741
    clc                                         // $4744
    jsr draw_gates                              // $4745
    lda tilt_shift_x                            // $4748
    cmp #$04                                    // $474b
    bne L473c                                   // $474d
    lda tilt_shift_y                            // $474f
    cmp #$08                                    // $4752
    bne L473c                                   // $4754
    lda gate_anim                               // $4756
    bne L473c                                   // $4759
    sec                                         // $475b
    jsr edge_highlight_v                        // $475c
    sec                                         // $475f
    jsr edge_highlight_h                        // $4760
    jmp L477d                                   // $4763
L4766:
    lda #$01                                    // $4766
    sta fire_enabled                            // $4768
L476b:
    clc                                         // $476b
    jsr draw_gates                              // $476c
    lda #$01                                    // $476f
    jsr wait_frames                             // $4771
    lda gate_anim                               // $4774
    bne L476b                                   // $4777
    clc                                         // $4779
    jsr draw_gates                              // $477a
L477d:
    lda demo_mode                               // $477d
    bne L47a4                                   // $4780
    jsr colour_marks                            // $4782
    jsr set_char_2318                           // $4785
    jsr set_glyph_lost                          // $4788
    lda #$00                                    // $478b
    jsr colour_status_marks                     // $478d
    ldx #$01                                    // $4790
    lda game_over                               // $4792
    beq L4799                                   // $4795
    ldx #$0f                                    // $4797
L4799:
    stx VIC_BG2                                 // $4799
    lda #$14                                    // $479c
    jsr game_over_jingle                        // $479e
    jsr level_bonus                             // $47a1
L47a4:
    rts                                         // $47a4

// ----------------------------------------------------------------------------
// Count the floor marks back (count_marks, IRQ) for bonus points and
// power, until all counters are done
// ----------------------------------------------------------------------------
level_bonus:
    jsr set_bonus_glyph                         // $47a5
    jsr freeze_edge_highlight                   // $47a8
    lda #$01                                    // $47ab
    sta roll_sound_off                          // $47ad
    sta bonus_sound_on                          // $47b0
    sta count_marks_on                          // $47b3
    jsr sid_off                                 // $47b6
    lda #$00                                    // $47b9
    sta SID_RES_FILT                            // $47bb
    lda #$d0                                    // $47be
    sta SID_V3_SR                               // $47c0
    lda #$11                                    // $47c3
    sta SID_V3_CTRL                             // $47c5
L47c8:
    lda count_marks_on                          // $47c8
    ora bonus_left                              // $47cb
    ora two_tone_timer                          // $47ce
    bne L47c8                                   // $47d1
    lda #$19                                    // $47d3
    jsr wait_frames                             // $47d5
    lda #$00                                    // $47d8
    sta bonus_sound_on                          // $47da
    sta roll_sound_off                          // $47dd
    jsr show_music_glyph                        // $47e0
    lda #$00                                    // $47e3
    jsr colour_status_marks                     // $47e5
    jsr sid_off                                 // $47e8
    lda #$44                                    // $47eb
    sta SID_RES_FILT                            // $47ed
    rts                                         // $47f0
set_bonus_glyph:
    ldx #$07                                    // $47f1
    lda ball_in_hole                            // $47f3
    beq L47fa                                   // $47f6
    ldx #$0f                                    // $47f8
L47fa:
    ldy #$07                                    // $47fa
L47fc:
    lda bonus_glyphs,x                          // $47fc
    sta char($b2),y                             // $47ff
    dex                                         // $4802
    dey                                         // $4803
    bpl L47fc                                   // $4804
    rts                                         // $4806
bonus_glyphs:
// char $00  ($4807)
    .byte %11111100                             // $4807  ######..
    .byte %10000110                             // $4808  #....##.
    .byte %11000011                             // $4809  ##....##
    .byte %01100001                             // $480a  .##....#
    .byte %10000000                             // $480b  #.......
    .byte %11000011                             // $480c  ##....##
    .byte %01100001                             // $480d  .##....#
    .byte %00111111                             // $480e  ..######
// char $01  ($480f)
    .byte %11111100                             // $480f  ######..
    .byte %10000110                             // $4810  #....##.
    .byte %11000011                             // $4811  ##....##
    .byte %01100001                             // $4812  .##....#
    .byte %10000000                             // $4813  #.......
    .byte %11000011                             // $4814  ##....##
    .byte %01100001                             // $4815  .##....#
    .byte %00111111                             // $4816  ..######
level_settle:
    lda #$1e                                    // $4817
    sta controls                                // $4819
    lda #$01                                    // $481c
    sta fire_enabled                            // $481e
    sta tilt_enabled                            // $4821
    sta clunk_state                             // $4824
L4827:
    jsr update_tilt_graphics                    // $4827
    clc                                         // $482a
    jsr draw_gates                              // $482b
    lda #$01                                    // $482e
    jsr wait_frames                             // $4830
    lda gate_anim                               // $4833
    ora clunk_state                             // $4836
    bne L4827                                   // $4839
    rts                                         // $483b

// ----------------------------------------------------------------------------
// All four mazes done: slide them past once more (mazes 2, 1, 0), then
// level + 1 and maze 0
// ----------------------------------------------------------------------------
next_level_slide:
    lda #$00                                    // $483c
    sta tilt_enabled                            // $483e
    lda #$00                                    // $4841
    sta slide_out_flag                          // $4843
    lda #$02                                    // $4846
    sta maze                                    // $4848
L484b:
    lda maze                                    // $484b
    bne L4853                                   // $484e
    inc level                                   // $4850
L4853:
    jsr draw_maze_screen                        // $4853
    sec                                         // $4856
    jsr draw_gates                              // $4857
    jsr draw_gate_colours                       // $485a
    jsr fill_colour_buffer                      // $485d
    jsr colour_gates                            // $4860
    ldx maze                                    // $4863
    lda #$40                                    // $4866
    sec                                         // $4868
    sbc hole_x_by_maze,x                        // $4869
    inx                                         // $486c
    clc                                         // $486d
    adc hole_x_by_maze,x                        // $486e
    sta hole_wrap                               // $4871
    lda #$00                                    // $4874
    sta slide_speed                             // $4876
    lda #$00                                    // $4879
    sta slide_speed_sign                        // $487b
    lda #$05                                    // $487e
    sta slide_accel                             // $4880
    lda #$00                                    // $4883
    sta slide_dir                               // $4885
    lda #$80                                    // $4888
    sta slide_speed_max                         // $488a
    lda fine_scroll_x                           // $488d
    sta slide_fine                              // $4890
    lda #$00                                    // $4893
    sta slide_fine_frac                         // $4895
    lda #$27                                    // $4898
    sta slide_column                            // $489a
    lda #$01                                    // $489d
    sta slide_state                             // $489f
L48a2:
    jsr slide_tick                              // $48a2
    lda slide_column                            // $48a5
    bpl L48a2                                   // $48a8
    lda #$00                                    // $48aa
    sta slide_state                             // $48ac
    ldx maze                                    // $48af
    beq L48b7                                   // $48b2
    jsr init_hole                               // $48b4
L48b7:
    dec maze                                    // $48b7
    bpl L484b                                   // $48ba
    inc maze                                    // $48bc
    jsr slide_in                                // $48bf
    rts                                         // $48c2

// ----------------------------------------------------------------------------
// Scroll screen and colour RAM rows 2-24 one column to the right
// ----------------------------------------------------------------------------
scroll_screen_right:
    lda #$00                                    // $48c3
    sta L4902+1                                 // $48c5
    sta L4907+1                                 // $48c8
    ldy #$50                                    // $48cb
    sty L48f1+1                                 // $48cd
    sty L48f7+1                                 // $48d0
    lda #$51                                    // $48d3
    sta L48f4+1                                 // $48d5
    sta L48fa+1                                 // $48d8
    lda #$04                                    // $48db
    sta L48f1+2                                 // $48dd
    sta L48f4+2                                 // $48e0
    lda #$d8                                    // $48e3
    sta L48f7+2                                 // $48e5
    sta L48fa+2                                 // $48e8
    lda #$17                                    // $48eb
    sta zp_ff                                   // $48ed
L48ef:
    ldx #$26                                    // $48ef
L48f1:
    lda screen+2*40+0,x                         // $48f1
L48f4:
    sta L0451,x                                 // $48f4
L48f7:
    lda COLOR_RAM+2*40+0,x                      // $48f7
L48fa:
    sta COLOR_RAM+2*40+1,x                      // $48fa
    dex                                         // $48fd
    bpl L48f1                                   // $48fe
    lda (zp_fb),y                               // $4900
L4902:
    sta $ffff,y                                 // $4902
    lda (zp_fd),y                               // $4905
L4907:
    sta $ffff,y                                 // $4907
    tya                                         // $490a
    clc                                         // $490b
    adc #$28                                    // $490c
    tay                                         // $490e
    sta L48f1+1                                 // $490f
    sta L48f7+1                                 // $4912
    bcc L492d                                   // $4915
    inc L48f1+2                                 // $4917
    inc L48f4+2                                 // $491a
    inc L48f7+2                                 // $491d
    inc L48fa+2                                 // $4920
    inc zp_fc                                   // $4923
    inc zp_fe                                   // $4925
    inc L4902+2                                 // $4927
    inc L4907+2                                 // $492a
L492d:
    clc                                         // $492d
    adc #$01                                    // $492e
    sta L48f4+1                                 // $4930
    sta L48fa+1                                 // $4933
    dec zp_ff                                   // $4936
    bne L48ef                                   // $4938
    rts                                         // $493a

// ----------------------------------------------------------------------------
// Start of a game: draw maze 0, set up sprites and colours, status line,
// first slide-in
// ----------------------------------------------------------------------------
start_first_maze:
    jsr draw_maze_screen                        // $493b
    sec                                         // $493e
    jsr draw_gates                              // $493f
    jsr draw_gate_colours                       // $4942
    jsr fill_colour_buffer                      // $4945
    jsr colour_gates                            // $4948
    lda #$08                                    // $494b
    sta screen_on                               // $494d
    lda #$01                                    // $4950
    jsr wait_frames                             // $4952
    jsr swap_title_sprites                      // $4955
    lda #$00                                    // $4958
    sta VIC_SPR_ENABLE                          // $495a
    sta VIC_SPR_EXPAND_Y                        // $495d
    sta VIC_SPR_EXPAND_X                        // $4960
    ldx demo_mode                               // $4963
    bne L496b                                   // $4966
    sta VIC_SPR_MULTICOLOR                      // $4968
L496b:
    lda #$00                                    // $496b
    sta VIC_SPR1_COL                            // $496d
    lda #$01                                    // $4970
    sta VIC_SPR3_COL                            // $4972
    lda #$00                                    // $4975
    sta VIC_SPR4_COL                            // $4977
    lda #$0f                                    // $497a
    sta VIC_SPR6_COL                            // $497c
    lda #$00                                    // $497f
    sta VIC_SPR7_COL                            // $4981
    lda #$00                                    // $4984
    sta title_mode                              // $4986
    lda #<chars_1d00                            // $4989
    sta tilt_enabled                            // $498b
    lda #>chars_1d00                            // $498e
    sta controls                                // $4990
    lda #$80                                    // $4993
    sta tilt_angle_x                            // $4995
    sta tilt_angle_x_old                        // $4998
    lda #$ff                                    // $499b
    sta tilt_angle_y                            // $499d
    sta tilt_angle_y_old                        // $49a0
    lda #$00                                    // $49a3
    sta tilt_dx                                 // $49a5
    sta tilt_dy                                 // $49a8
    sta sound_tilt_dx                           // $49ab
    sta sound_tilt_dy                           // $49ae
    sta tilt_shift_x_old                        // $49b1
    sta tilt_shift_y_old                        // $49b4
    lda #$01                                    // $49b7
    sta tilt_enabled                            // $49b9
    lda #$01                                    // $49bc
    jsr wait_frames                             // $49be
    lda #$00                                    // $49c1
    sta SID_V2_CTRL                             // $49c3
    lda VIC_SPR_ENABLE                          // $49c6
    ora #$c0                                    // $49c9
    ldx demo_mode                               // $49cb
    beq L49d2                                   // $49ce
    ora #$a0                                    // $49d0
L49d2:
    sta VIC_SPR_ENABLE                          // $49d2
    lda #$c0                                    // $49d5
    sta VIC_SPR_PRIORITY                        // $49d7
    lda #$00                                    // $49da
    sta VIC_BG1                                 // $49dc
    lda #$0f                                    // $49df
    sta VIC_BG2                                 // $49e1
    jsr draw_power_bar                          // $49e4
    jsr colour_power_bar                        // $49e7
    jsr init_frame_flash                        // $49ea
    jsr show_buffers                            // $49ed
    jsr update_tilt_graphics                    // $49f0
    jsr update_tilt_graphics                    // $49f3
    lda #$18                                    // $49f6
    sta screen_on                               // $49f8
    jsr level_jingle                            // $49fb
    lda #$01                                    // $49fe
    sta power_refill                            // $4a00
    sta scroll_score_step                       // $4a03
    sta scroll_level_step                       // $4a06
    lda #$07                                    // $4a09
    sta bg2_restore_timer                       // $4a0b
    jsr level_settle                            // $4a0e
    rts                                         // $4a11

// ----------------------------------------------------------------------------
// The board shakes: tilt the maze to the corners a few times
// ----------------------------------------------------------------------------
shake_board:
    lda #$01                                    // $4a12
    sta shaking                                 // $4a14
    lda #$02                                    // $4a17
    sta shake_count                             // $4a19
    lda #$00                                    // $4a1c
    sta controls_enabled                        // $4a1e
    lda #$01                                    // $4a21
    sta tilt_enabled                            // $4a23
    lda #$0e                                    // $4a26
    sta tilt_rate                               // $4a28
    lda #$1d                                    // $4a2b
    sta controls                                // $4a2d
    jsr sid_off                                 // $4a30
    lda #$e0                                    // $4a33
    sta SID_V2_SR                               // $4a35
    lda #$11                                    // $4a38
    sta SID_V2_CTRL                             // $4a3a
L4a3d:
    lda #$01                                    // $4a3d
    jsr wait_frames                             // $4a3f
    jsr update_tilt_graphics                    // $4a42
    ldx tilt_dx                                 // $4a45
    inx                                         // $4a48
    lda shake_shift_targets,x                   // $4a49
    cmp tilt_shift_x                            // $4a4c
    bne L4a3d                                   // $4a4f
    ldx tilt_dy                                 // $4a51
    inx                                         // $4a54
    lda shake_shift_targets,x                   // $4a55
    cmp tilt_shift_y                            // $4a58
    bne L4a3d                                   // $4a5b
    lda controls                                // $4a5d
    cmp #$1e                                    // $4a60
    bne L4a6d                                   // $4a62
    dec shake_count                             // $4a64
    beq L4a75                                   // $4a67
    lda #$1d                                    // $4a69
    bne L4a6f                                   // $4a6b
L4a6d:
    lda #$1e                                    // $4a6d
L4a6f:
    sta controls                                // $4a6f
    jmp L4a3d                                   // $4a72
L4a75:
    sec                                         // $4a75
    jsr edge_highlight_v                        // $4a76
    sec                                         // $4a79
    jsr edge_highlight_h                        // $4a7a
    jsr colour_marks                            // $4a7d
    jsr set_char_2318                           // $4a80
    jsr draw_power_bar                          // $4a83
    jsr colour_power_bar                        // $4a86
    jsr set_glyph_done                          // $4a89
    lda #$00                                    // $4a8c
    jsr colour_status_marks                     // $4a8e
    lda #$19                                    // $4a91
    jsr wait_frames                             // $4a93
    lda #$00                                    // $4a96
    sta shaking                                 // $4a98
    rts                                         // $4a9b
shake_shift_targets:
    .byte $08,$04,$00                           // $4a9c

// ----------------------------------------------------------------------------
// Params: A = points (BCD low byte), X = BCD middle byte
// Adds to the score and redraws the six score digits (characters $E6-$EB)
// ----------------------------------------------------------------------------
add_score:
    stx zp_fb                                   // $4a9f
    sed                                         // $4aa1
    clc                                         // $4aa2
    adc score                                   // $4aa3
    sta score                                   // $4aa6
    lda score+1                                 // $4aa9
    adc zp_fb                                   // $4aac
    sta score+1                                 // $4aae
    bcc L4ab4                                   // $4ab1
    nop                                         // $4ab3
L4ab4:
    lda score+2                                 // $4ab4
    adc #$00                                    // $4ab7
    sta score+2                                 // $4ab9
    cld                                         // $4abc
    lda score+2                                 // $4abd
    lsr                                         // $4ac0
    lsr                                         // $4ac1
    lsr                                         // $4ac2
    lsr                                         // $4ac3
    ldx #$00                                    // $4ac4
    jsr draw_score_digit                        // $4ac6
    lda score+2                                 // $4ac9
    and #$0f                                    // $4acc
    ldx #$08                                    // $4ace
    jsr draw_score_digit                        // $4ad0
    lda score+1                                 // $4ad3
    lsr                                         // $4ad6
    lsr                                         // $4ad7
    lsr                                         // $4ad8
    lsr                                         // $4ad9
    ldx #$10                                    // $4ada
    jsr draw_score_digit                        // $4adc
    lda score+1                                 // $4adf
    and #$0f                                    // $4ae2
    ldx #$18                                    // $4ae4
    jsr draw_score_digit                        // $4ae6
    lda score                                   // $4ae9
    lsr                                         // $4aec
    lsr                                         // $4aed
    lsr                                         // $4aee
    lsr                                         // $4aef
    ldx #$20                                    // $4af0
    jsr draw_score_digit                        // $4af2
    lda score                                   // $4af5
    and #$0f                                    // $4af8
    ldx #$28                                    // $4afa
    jsr draw_score_digit                        // $4afc
    rts                                         // $4aff

// ----------------------------------------------------------------------------
// Params: A = digit 0-9, X = offset of the digit character - copies its glyph
// ----------------------------------------------------------------------------
draw_score_digit:
    asl                                         // $4b00
    asl                                         // $4b01
    asl                                         // $4b02
    tay                                         // $4b03
    lda #$07                                    // $4b04
    sta zp_fb                                   // $4b06
L4b08:
    lda digit_glyphs,y                          // $4b08
    sta char($e6),x                             // $4b0b
    iny                                         // $4b0e
    inx                                         // $4b0f
    dec zp_fb                                   // $4b10
    bpl L4b08                                   // $4b12
    rts                                         // $4b14

// ----------------------------------------------------------------------------
// Score scroll effect: the digits roll up one pixel per call
// ----------------------------------------------------------------------------
scroll_score:
    lda scroll_score_step                       // $4b15
    beq L4b59                                   // $4b18
    lda scroll_pause                            // $4b1a
    bne L4b59                                   // $4b1d
    ldx #$00                                    // $4b1f
L4b21:
    lda char($e6)+1,x                           // $4b21  scroll the six digits one pixel up
    sta char($e6),x                             // $4b24
    inx                                         // $4b27
    cpx #$2f                                    // $4b28
    bne L4b21                                   // $4b2a
    lda #$00                                    // $4b2c
    ldx scroll_score_step                       // $4b2e
    dex                                         // $4b31
    beq L4b38                                   // $4b32
    dex                                         // $4b34
    lda digit_glyphs,x                          // $4b35
L4b38:
    sta zp_fb                                   // $4b38
    ldx #$07                                    // $4b3a
L4b3c:
    lda zp_fb                                   // $4b3c
    sta char($e6),x                             // $4b3e
    txa                                         // $4b41
    clc                                         // $4b42
    adc #$08                                    // $4b43
    tax                                         // $4b45
    cmp #$30                                    // $4b46
    bcc L4b3c                                   // $4b48
    inc scroll_score_step                       // $4b4a
    lda scroll_score_step                       // $4b4d
    cmp #$0a                                    // $4b50
    bcc L4b59                                   // $4b52
    lda #$00                                    // $4b54
    sta scroll_score_step                       // $4b56
L4b59:
    rts                                         // $4b59

// ----------------------------------------------------------------------------
// High score scroll effect: the new high score rolls in
// ----------------------------------------------------------------------------
scroll_hiscore:
    lda scroll_hiscore_step                     // $4b5a
    beq L4ba1                                   // $4b5d
    lda scroll_pause                            // $4b5f
    bne L4ba1                                   // $4b62
    ldx #$00                                    // $4b64
L4b66:
    lda char($f0)+1,x                           // $4b66
    sta char($f0),x                             // $4b69
    inx                                         // $4b6c
    cpx #$2f                                    // $4b6d
    bne L4b66                                   // $4b6f
    ldy scroll_hiscore_step                     // $4b71
    dey                                         // $4b74
    sty zp_fa                                   // $4b75
    dey                                         // $4b77
    ldx #$07                                    // $4b78
L4b7a:
    lda zp_fa                                   // $4b7a
    beq L4b81                                   // $4b7c
    lda char($e6),y                             // $4b7e
L4b81:
    sta char($f0),x                             // $4b81
    tya                                         // $4b84
    clc                                         // $4b85
    adc #$08                                    // $4b86
    tay                                         // $4b88
    txa                                         // $4b89
    clc                                         // $4b8a
    adc #$08                                    // $4b8b
    tax                                         // $4b8d
    cmp #$30                                    // $4b8e
    bcc L4b7a                                   // $4b90
    inc scroll_hiscore_step                     // $4b92
    lda scroll_hiscore_step                     // $4b95
    cmp #$0a                                    // $4b98
    bcc L4ba1                                   // $4b9a
    lda #$00                                    // $4b9c
    sta scroll_hiscore_step                     // $4b9e
L4ba1:
    rts                                         // $4ba1

// ----------------------------------------------------------------------------
// Level number scroll effect
// ----------------------------------------------------------------------------
scroll_level:
    lda scroll_level_step                       // $4ba2
    beq L4bac                                   // $4ba5
    lda scroll_pause                            // $4ba7
    beq L4baf                                   // $4baa
L4bac:
    jmp L4c3d                                   // $4bac
L4baf:
    lda scroll_level_step                       // $4baf
    cmp #$01                                    // $4bb2
    bne L4c04                                   // $4bb4
    ldx #$07                                    // $4bb6
    lda #$00                                    // $4bb8
L4bba:
    sta char($f9),x                             // $4bba
    dex                                         // $4bbd
    bpl L4bba                                   // $4bbe
    lda level                                   // $4bc0
    clc                                         // $4bc3
    adc #$01                                    // $4bc4
    ldx #$ff                                    // $4bc6
L4bc8:
    inx                                         // $4bc8
    sec                                         // $4bc9
    sbc #$0a                                    // $4bca
    bcs L4bc8                                   // $4bcc
    clc                                         // $4bce
    adc #$0a                                    // $4bcf
    sta zp_fb                                   // $4bd1
    ldy #$07                                    // $4bd3
    txa                                         // $4bd5
    beq L4bec                                   // $4bd6
    asl                                         // $4bd8
    asl                                         // $4bd9
    asl                                         // $4bda
    ora #$07                                    // $4bdb
    tax                                         // $4bdd
    ldy #$07                                    // $4bde
L4be0:
    lda digit_glyphs,x                          // $4be0
    sta char($f8),y                             // $4be3
    dex                                         // $4be6
    dey                                         // $4be7
    bpl L4be0                                   // $4be8
    ldy #$0f                                    // $4bea
L4bec:
    lda zp_fb                                   // $4bec
    asl                                         // $4bee
    asl                                         // $4bef
    asl                                         // $4bf0
    ora #$07                                    // $4bf1
    tax                                         // $4bf3
    lda #$07                                    // $4bf4
    sta zp_fc                                   // $4bf6
L4bf8:
    lda digit_glyphs,x                          // $4bf8
    sta char($f8),y                             // $4bfb
    dex                                         // $4bfe
    dey                                         // $4bff
    dec zp_fc                                   // $4c00
    bpl L4bf8                                   // $4c02
L4c04:
    ldx #$00                                    // $4c04
L4c06:
    lda char($ee)+1,x                           // $4c06
    sta char($ee),x                             // $4c09
    inx                                         // $4c0c
    cpx #$0f                                    // $4c0d
    bne L4c06                                   // $4c0f
    ldy scroll_level_step                       // $4c11
    dey                                         // $4c14
    sty zp_fa                                   // $4c15
    dey                                         // $4c17
    ldx #$07                                    // $4c18
    lda zp_fa                                   // $4c1a
    beq L4c21                                   // $4c1c
    lda char($f8),y                             // $4c1e
L4c21:
    sta char($ee),x                             // $4c21
    lda zp_fa                                   // $4c24
    beq L4c2b                                   // $4c26
    lda char($f9),y                             // $4c28
L4c2b:
    sta char($ef),x                             // $4c2b
    inc scroll_level_step                       // $4c2e
    lda scroll_level_step                       // $4c31
    cmp #$0a                                    // $4c34
    bcc L4c3d                                   // $4c36
    lda #$00                                    // $4c38
    sta scroll_level_step                       // $4c3a
L4c3d:
    rts                                         // $4c3d
digit_glyphs:
// char $00  ($4c3e)
    .byte %00111100                             // $4c3e  ..####..
    .byte %01100110                             // $4c3f  .##..##.
    .byte %01100110                             // $4c40  .##..##.
    .byte %01100110                             // $4c41  .##..##.
    .byte %01100110                             // $4c42  .##..##.
    .byte %01100110                             // $4c43  .##..##.
    .byte %01100110                             // $4c44  .##..##.
    .byte %00111100                             // $4c45  ..####..
// char $01  ($4c46)
    .byte %00011000                             // $4c46  ...##...
    .byte %00011000                             // $4c47  ...##...
    .byte %01111000                             // $4c48  .####...
    .byte %00011000                             // $4c49  ...##...
    .byte %00011000                             // $4c4a  ...##...
    .byte %00011000                             // $4c4b  ...##...
    .byte %00011000                             // $4c4c  ...##...
    .byte %01111110                             // $4c4d  .######.
// char $02  ($4c4e)
    .byte %00111100                             // $4c4e  ..####..
    .byte %01100110                             // $4c4f  .##..##.
    .byte %01100110                             // $4c50  .##..##.
    .byte %00001100                             // $4c51  ....##..
    .byte %00011000                             // $4c52  ...##...
    .byte %00110000                             // $4c53  ..##....
    .byte %01100000                             // $4c54  .##.....
    .byte %01111110                             // $4c55  .######.
// char $03  ($4c56)
    .byte %01111110                             // $4c56  .######.
    .byte %00000110                             // $4c57  .....##.
    .byte %00001100                             // $4c58  ....##..
    .byte %00011100                             // $4c59  ...###..
    .byte %00000110                             // $4c5a  .....##.
    .byte %00000110                             // $4c5b  .....##.
    .byte %01100110                             // $4c5c  .##..##.
    .byte %00111100                             // $4c5d  ..####..
// char $04  ($4c5e)
    .byte %01100000                             // $4c5e  .##.....
    .byte %01100000                             // $4c5f  .##.....
    .byte %01100000                             // $4c60  .##.....
    .byte %01101100                             // $4c61  .##.##..
    .byte %01101100                             // $4c62  .##.##..
    .byte %01111110                             // $4c63  .######.
    .byte %00001100                             // $4c64  ....##..
    .byte %00001100                             // $4c65  ....##..
// char $05  ($4c66)
    .byte %01111110                             // $4c66  .######.
    .byte %01100000                             // $4c67  .##.....
    .byte %01100000                             // $4c68  .##.....
    .byte %01111100                             // $4c69  .#####..
    .byte %00000110                             // $4c6a  .....##.
    .byte %00000110                             // $4c6b  .....##.
    .byte %01100110                             // $4c6c  .##..##.
    .byte %00111100                             // $4c6d  ..####..
// char $06  ($4c6e)
    .byte %00111100                             // $4c6e  ..####..
    .byte %01100110                             // $4c6f  .##..##.
    .byte %01100000                             // $4c70  .##.....
    .byte %01111100                             // $4c71  .#####..
    .byte %01100110                             // $4c72  .##..##.
    .byte %01100110                             // $4c73  .##..##.
    .byte %01100110                             // $4c74  .##..##.
    .byte %00111100                             // $4c75  ..####..
// char $07  ($4c76)
    .byte %01111110                             // $4c76  .######.
    .byte %01100110                             // $4c77  .##..##.
    .byte %00000110                             // $4c78  .....##.
    .byte %00001100                             // $4c79  ....##..
    .byte %00011000                             // $4c7a  ...##...
    .byte %00011000                             // $4c7b  ...##...
    .byte %00011000                             // $4c7c  ...##...
    .byte %00011000                             // $4c7d  ...##...
// char $08  ($4c7e)
    .byte %00111100                             // $4c7e  ..####..
    .byte %01100110                             // $4c7f  .##..##.
    .byte %01100110                             // $4c80  .##..##.
    .byte %00111100                             // $4c81  ..####..
    .byte %01100110                             // $4c82  .##..##.
    .byte %01100110                             // $4c83  .##..##.
    .byte %01100110                             // $4c84  .##..##.
    .byte %00111100                             // $4c85  ..####..
// char $09  ($4c86)
    .byte %00111100                             // $4c86  ..####..
    .byte %01100110                             // $4c87  .##..##.
    .byte %01100110                             // $4c88  .##..##.
    .byte %01100110                             // $4c89  .##..##.
    .byte %00111110                             // $4c8a  ..#####.
    .byte %00000110                             // $4c8b  .....##.
    .byte %01100110                             // $4c8c  .##..##.
    .byte %00111100                             // $4c8d  ..####..

// ----------------------------------------------------------------------------
// Exit hole position for the current maze
// ----------------------------------------------------------------------------
init_hole:
    ldx maze                                    // $4c8e
    lda hole_x_by_maze,x                        // $4c91
    sta hole_x                                  // $4c94
    lda hole_y_by_maze,x                        // $4c97
    sta hole_y                                  // $4c9a
    lda #$00                                    // $4c9d
    sta hole_x_hi                               // $4c9f
    lda #$04                                    // $4ca2
    sta fine_scroll_x                           // $4ca4
    rts                                         // $4ca7

// ----------------------------------------------------------------------------
// Exit hole: sprites 6 and 7 at hole_x/hole_y plus the tilt level
// ----------------------------------------------------------------------------
place_hole_sprites:
    lda hole_x                                  // $4ca8
    clc                                         // $4cab
    adc tilt_level_x                            // $4cac
    sec                                         // $4caf
    sbc #$04                                    // $4cb0
    sta hole_spr_x                              // $4cb2
    sta VIC_SPR7_X                              // $4cb5
    sta VIC_SPR6_X                              // $4cb8
    lda hole_y                                  // $4cbb
    clc                                         // $4cbe
    adc tilt_level_y                            // $4cbf
    sec                                         // $4cc2
    sbc #$04                                    // $4cc3
    sta hole_spr_y                              // $4cc5
    sta VIC_SPR7_Y                              // $4cc8
    sta VIC_SPR6_Y                              // $4ccb
    lda VIC_SPR_X_MSB                           // $4cce
    and #$3f                                    // $4cd1
    ldx hole_x_hi                               // $4cd3
    beq L4cda                                   // $4cd6
    ora #$c0                                    // $4cd8
L4cda:
    sta VIC_SPR_X_MSB                           // $4cda
    lda hole_sprite                             // $4cdd
    sta sprite_ptrs+7                           // $4ce0
    ldx #$de                                    // $4ce3
    stx sprite_ptrs+6                           // $4ce5
    rts                                         // $4ce8

// ----------------------------------------------------------------------------
// During the slide: move the hole with the maze (to the right)
// ----------------------------------------------------------------------------
hole_slide_right:
    lda slide_fine                              // $4ce9
    sec                                         // $4cec
    sbc fine_scroll_x                           // $4ced
    bcs L4cf4                                   // $4cf0
    adc #$08                                    // $4cf2
L4cf4:
    clc                                         // $4cf4
    adc hole_x                                  // $4cf5
    sta hole_x                                  // $4cf8
    bcc L4d00                                   // $4cfb
    inc hole_x_hi                               // $4cfd
L4d00:
    lda hole_x_hi                               // $4d00
    cmp #$01                                    // $4d03
    bne L4d29                                   // $4d05
    lda hole_x                                  // $4d07
    cmp #$48                                    // $4d0a
    bcc L4d29                                   // $4d0c
    lda hole_x                                  // $4d0e
    sec                                         // $4d11
    sbc hole_wrap                               // $4d12
    sta hole_x                                  // $4d15
    lda hole_x_hi                               // $4d18
    sbc #$01                                    // $4d1b
    sta hole_x_hi                               // $4d1d
    ldx maze                                    // $4d20
    lda hole_y_by_maze,x                        // $4d23
    sta hole_y                                  // $4d26
L4d29:
    rts                                         // $4d29

// ----------------------------------------------------------------------------
// During the slide: move the hole with the maze (to the left)
// ----------------------------------------------------------------------------
hole_slide_left:
    lda fine_scroll_x                           // $4d2a
    sec                                         // $4d2d
    sbc slide_fine                              // $4d2e
    bcs L4d35                                   // $4d31
    adc #$08                                    // $4d33
L4d35:
    sta zp_ff                                   // $4d35
    lda hole_x                                  // $4d37
    sec                                         // $4d3a
    sbc zp_ff                                   // $4d3b
    sta hole_x                                  // $4d3d
    bcs L4d45                                   // $4d40
    dec hole_x_hi                               // $4d42
L4d45:
    lda hole_x_hi                               // $4d45
    bmi L4d53                                   // $4d48
    bne L4d6e                                   // $4d4a
    lda hole_x                                  // $4d4c
    cmp #$10                                    // $4d4f
    bcs L4d6e                                   // $4d51
L4d53:
    lda hole_x                                  // $4d53
    clc                                         // $4d56
    adc hole_wrap                               // $4d57
    sta hole_x                                  // $4d5a
    lda hole_x_hi                               // $4d5d
    adc #$01                                    // $4d60
    sta hole_x_hi                               // $4d62
    ldx maze                                    // $4d65
    lda hole_y_by_maze,x                        // $4d68
    sta hole_y                                  // $4d6b
L4d6e:
    rts                                         // $4d6e
hole_x_by_maze:
    .byte $9c,$dc,$f4,$dc                       // $4d6f
hole_y_by_maze:
    .byte $78,$7f,$b0,$98                       // $4d73

// ----------------------------------------------------------------------------
// Pull the ball velocity toward the hole centre (used while it drops in)
// ----------------------------------------------------------------------------
pull_ball_to_hole:
    lda ball_vx                                 // $4d77
    ldx hole_spr_x                              // $4d7a
    ldy ball_x                                  // $4d7d
    jsr pull_axis                               // $4d80
    sta ball_vx                                 // $4d83
    lda ball_vy                                 // $4d86
    ldx hole_spr_y                              // $4d89
    ldy ball_y                                  // $4d8c
    jsr pull_axis                               // $4d8f
    sta ball_vy                                 // $4d92
    rts                                         // $4d95
pull_axis:
    sta zp_fa                                   // $4d96
    sty zp_ff                                   // $4d98
    txa                                         // $4d9a
    sec                                         // $4d9b
    sbc zp_ff                                   // $4d9c
    sta zp_ff                                   // $4d9e
    lda zp_fa                                   // $4da0
    bpl L4da9                                   // $4da2
    eor #$ff                                    // $4da4
    clc                                         // $4da6
    adc #$01                                    // $4da7
L4da9:
    tax                                         // $4da9
    ldy #$e6                                    // $4daa
    jsr multiply                                // $4dac
    tya                                         // $4daf
    ldx zp_fa                                   // $4db0
    bpl L4db9                                   // $4db2
    eor #$ff                                    // $4db4
    clc                                         // $4db6
    adc #$01                                    // $4db7
L4db9:
    sta zp_fa                                   // $4db9
    clv                                         // $4dbb
    lda zp_fa                                   // $4dbc
    clc                                         // $4dbe
    adc zp_ff                                   // $4dbf
    bvc L4dcb                                   // $4dc1
    bmi L4dc9                                   // $4dc3
    lda #$80                                    // $4dc5
    bne L4dcb                                   // $4dc7
L4dc9:
    lda #$7f                                    // $4dc9
L4dcb:
    rts                                         // $4dcb

// ----------------------------------------------------------------------------
// The ball drops into the exit hole: the ball is pulled to the centre,
// shrinks (sprite frames down to $A0) and the falling sound plays
// ----------------------------------------------------------------------------
ball_drop_in_hole:
    jsr sid_off                                 // $4dcc
    lda VIC_SPR_ENABLE                          // $4dcf
    and #$e9                                    // $4dd2
    sta VIC_SPR_ENABLE                          // $4dd4
    ldx #$14                                    // $4dd7
    stx fall_timer                              // $4dd9
    ldx #$0f                                    // $4ddc
    stx fall_delay                              // $4dde
L4de1:
    lda #$01                                    // $4de1
    jsr wait_frames                             // $4de3
    clc                                         // $4de6
    jsr draw_gates                              // $4de7
    jsr pull_ball_to_hole                       // $4dea
    lda fall_delay                              // $4ded
    bne L4df8                                   // $4df0
    jsr fall_sound_step                         // $4df2
    jmp L4e00                                   // $4df5
L4df8:
    dec fall_delay                              // $4df8
    bne L4e00                                   // $4dfb
    jsr fall_sound_start                        // $4dfd
L4e00:
    dec fall_timer                              // $4e00
    bne L4de1                                   // $4e03
    ldx #$0c                                    // $4e05
    stx fall_timer                              // $4e07
    dec sprite_ptrs+3                           // $4e0a  smaller ball sprite
    lda sprite_ptrs+3                           // $4e0d
    cmp #$a0                                    // $4e10
    bne L4de1                                   // $4e12
    lda #$00                                    // $4e14
    sta ball_vx                                 // $4e16
    sta ball_vy                                 // $4e19
    lda VIC_SPR_ENABLE                          // $4e1c
    and #$f7                                    // $4e1f
    sta VIC_SPR_ENABLE                          // $4e21
    rts                                         // $4e24
fall_sound_step:
    ldx #$fa                                    // $4e25
    ldy fall_freq_step                          // $4e27
    jsr multiply                                // $4e2a
    sty zp_ff                                   // $4e2d
    ldx #$fa                                    // $4e2f
    ldy fall_freq_step_hi                       // $4e31
    jsr multiply                                // $4e34
    txa                                         // $4e37
    clc                                         // $4e38
    adc zp_ff                                   // $4e39
    sta fall_freq_step                          // $4e3b
    tya                                         // $4e3e
    adc #$00                                    // $4e3f
    sta fall_freq_step_hi                       // $4e41
    lda fall_freq                               // $4e44
    sec                                         // $4e47
    sbc fall_freq_step                          // $4e48
    sta fall_freq                               // $4e4b
    sta SID_V2_FREQ_LO                          // $4e4e
    lda fall_freq_hi                            // $4e51
    sbc fall_freq_step_hi                       // $4e54
    sta fall_freq_hi                            // $4e57
    sta SID_V2_FREQ_HI                          // $4e5a
    rts                                         // $4e5d
fall_sound_start:
    lda #$00                                    // $4e5e
    sta fall_freq_step                          // $4e60
    sta fall_freq                               // $4e63
    lda #$e6                                    // $4e66
    sta fall_freq_hi                            // $4e68
    lda #$05                                    // $4e6b
    sta fall_freq_step_hi                       // $4e6d
    lda ball_size                               // $4e70
    lsr                                         // $4e73
    lsr                                         // $4e74
    clc                                         // $4e75
    adc #$09                                    // $4e76
    cmp #$0f                                    // $4e78
    bcc L4e7e                                   // $4e7a
    lda #$0f                                    // $4e7c
L4e7e:
    clc                                         // $4e7e
    adc #$a0                                    // $4e7f
    sta SID_V2_AD                               // $4e81
    lda #$11                                    // $4e84
    sta SID_V2_CTRL                             // $4e86
    rts                                         // $4e89

// ----------------------------------------------------------------------------
// Is the ball over the exit hole? C = 1 yes (distance within the radius
// table, per row)
// ----------------------------------------------------------------------------
ball_over_hole:
    lda ball_y                                  // $4e8a
    sec                                         // $4e8d
    sbc hole_y                                  // $4e8e
    bcs L4e98                                   // $4e91
    eor #$ff                                    // $4e93
    clc                                         // $4e95
    adc #$01                                    // $4e96
L4e98:
    sta zp_ff                                   // $4e98
    ldy #$00                                    // $4e9a
    lda hole_radius_table,y                     // $4e9c
    cmp zp_ff                                   // $4e9f
    bcc L4ed5                                   // $4ea1
    lda ball_x                                  // $4ea3
    sec                                         // $4ea6
    sbc hole_x                                  // $4ea7
    sta zp_fb                                   // $4eaa
    lda ball_x_hi                               // $4eac
    sbc hole_x_hi                               // $4eaf
    sta zp_fc                                   // $4eb2
    bcs L4ec7                                   // $4eb4
    lda zp_fb                                   // $4eb6
    eor #$ff                                    // $4eb8
    clc                                         // $4eba
    adc #$01                                    // $4ebb
    sta zp_fb                                   // $4ebd
    lda zp_fc                                   // $4ebf
    eor #$ff                                    // $4ec1
    adc #$00                                    // $4ec3
    sta zp_fc                                   // $4ec5
L4ec7:
    lda zp_fc                                   // $4ec7
    bne L4ed5                                   // $4ec9
    ldy zp_ff                                   // $4ecb
    lda hole_radius_table,y                     // $4ecd
    cmp zp_fb                                   // $4ed0
    jmp L4ed6                                   // $4ed2
L4ed5:
    clc                                         // $4ed5
L4ed6:
    rts                                         // $4ed6
hole_radius_table:
    .byte $0e,$0e,$0e,$0e,$0d,$0d,$0d,$0c,$0c,$0b,$0a,$09,$08,$06,$03  // $4ed7

// ----------------------------------------------------------------------------
// Start the shine (sprite 1) from the tilt angles
// ----------------------------------------------------------------------------
init_shine:
    ldx #$07                                    // $4ee6
    lda tilt_angle_x                            // $4ee8
    sec                                         // $4eeb
    sbc #$80                                    // $4eec
    bpl L4ef2                                   // $4eee
    eor #$ff                                    // $4ef0
L4ef2:
    sta zp_fb                                   // $4ef2
    lda tilt_angle_y                            // $4ef4
    sec                                         // $4ef7
    sbc #$80                                    // $4ef8
    bpl L4efe                                   // $4efa
    eor #$ff                                    // $4efc
L4efe:
    sta zp_fc                                   // $4efe
    lda zp_fc                                   // $4f00
    sec                                         // $4f02
    sbc zp_fb                                   // $4f03
    bcs L4f0c                                   // $4f05
    eor #$ff                                    // $4f07
    clc                                         // $4f09
    adc #$01                                    // $4f0a
L4f0c:
    clc                                         // $4f0c
    adc zp_fb                                   // $4f0d
    bcs L4f1b                                   // $4f0f
    adc zp_fc                                   // $4f11
    bcs L4f1b                                   // $4f13
    lsr                                         // $4f15
    lsr                                         // $4f16
    lsr                                         // $4f17
    lsr                                         // $4f18
    lsr                                         // $4f19
    tax                                         // $4f1a
L4f1b:
    inx                                         // $4f1b
    cpx #$02                                    // $4f1c
    bcs L4f22                                   // $4f1e
    ldx #$02                                    // $4f20
L4f22:
    stx zp_ff                                   // $4f22
    lsr zp_fb                                   // $4f24
    lsr zp_fc                                   // $4f26
    ldx ball_size                               // $4f28
    cpx #$02                                    // $4f2b
    bcs L4f33                                   // $4f2d
    lsr zp_fb                                   // $4f2f
    lsr zp_fc                                   // $4f31
L4f33:
    lda #$7f                                    // $4f33
    sec                                         // $4f35
    sbc zp_fb                                   // $4f36
    sta shine_x                                 // $4f38
    lda #$7f                                    // $4f3b
    sec                                         // $4f3d
    sbc zp_fc                                   // $4f3e
    sta shine_y                                 // $4f40
    ldx #$00                                    // $4f43
    lda tilt_angle_x                            // $4f45
    bpl L4f4b                                   // $4f48
    inx                                         // $4f4a
L4f4b:
    stx shine_quadrant_x                        // $4f4b
    ldx #$00                                    // $4f4e
    lda tilt_angle_y                            // $4f50
    bpl L4f56                                   // $4f53
    inx                                         // $4f55
L4f56:
    stx shine_quadrant_y                        // $4f56
    rts                                         // $4f59

// ----------------------------------------------------------------------------
// Ball shading (sprite 0, drawn at $31C0): a crescent on the side away
// from the light, from the tilt angles
// ----------------------------------------------------------------------------
draw_shading:
    ldx tilt_angle_x                            // $4f5a
    ldy tilt_angle_y                            // $4f5d
    cpx #$80                                    // $4f60
    bne L4f6f                                   // $4f62
    lda #$00                                    // $4f64
    cpy #$00                                    // $4f66
    bpl L4f6c                                   // $4f68
    lda #$01                                    // $4f6a
L4f6c:
    jmp L4f94                                   // $4f6c
L4f6f:
    cpy #$80                                    // $4f6f
    bne L4f7e                                   // $4f71
    lda #$02                                    // $4f73
    cpx #$00                                    // $4f75
    bpl L4f7b                                   // $4f77
    lda #$03                                    // $4f79
L4f7b:
    jmp L4f94                                   // $4f7b
L4f7e:
    txa                                         // $4f7e
    bpl L4f8c                                   // $4f7f
    lda #$06                                    // $4f81
    cpy #$00                                    // $4f83
    bpl L4f89                                   // $4f85
    lda #$05                                    // $4f87
L4f89:
    jmp L4f94                                   // $4f89
L4f8c:
    lda #$04                                    // $4f8c
    cpy #$00                                    // $4f8e
    bpl L4f94                                   // $4f90
    lda #$07                                    // $4f92
L4f94:
    tax                                         // $4f94
    ldy zp_ff                                   // $4f95
    and #$01                                    // $4f97
    beq L4f9d                                   // $4f99
    ldy #$02                                    // $4f9b
L4f9d:
    sty zp_fa                                   // $4f9d
    cpx #$02                                    // $4f9f
    bcs L4fb5                                   // $4fa1
    lda zp_ff                                   // $4fa3
    jsr shading_rows_left                       // $4fa5
    lda #$0b                                    // $4fa8
    sec                                         // $4faa
    sbc zp_fa                                   // $4fab
    tay                                         // $4fad
    ldx #$09                                    // $4fae
    lda #$a0                                    // $4fb0
    jmp L4ff8                                   // $4fb2
L4fb5:
    cpx #$04                                    // $4fb5
    bcs L4fcb                                   // $4fb7
    lda zp_ff                                   // $4fb9
    jsr shading_rows_top                        // $4fbb
    lda #$0d                                    // $4fbe
    sec                                         // $4fc0
    sbc zp_fa                                   // $4fc1
    tax                                         // $4fc3
    ldy #$06                                    // $4fc4
    lda #$a5                                    // $4fc6
    jmp L4ff8                                   // $4fc8
L4fcb:
    cpx #$06                                    // $4fcb
    bcs L4fe5                                   // $4fcd
    lda zp_ff                                   // $4fcf
    jsr shading_rows_right                      // $4fd1
    lda #$0d                                    // $4fd4
    sec                                         // $4fd6
    sbc zp_fa                                   // $4fd7
    tax                                         // $4fd9
    lda #$0b                                    // $4fda
    sec                                         // $4fdc
    sbc zp_fa                                   // $4fdd
    tay                                         // $4fdf
    lda #$a5                                    // $4fe0
    jmp L4ff8                                   // $4fe2
L4fe5:
    lda zp_ff                                   // $4fe5
    jsr shading_rows_bottom                     // $4fe7
    lda #$03                                    // $4fea
    clc                                         // $4fec
    adc zp_fa                                   // $4fed
    tax                                         // $4fef
    lda #$0b                                    // $4ff0
    sec                                         // $4ff2
    sbc zp_fa                                   // $4ff3
    tay                                         // $4ff5
    lda #$a5                                    // $4ff6
L4ff8:
    sta sprite_ptrs+1                           // $4ff8
    txa                                         // $4ffb
    clc                                         // $4ffc
    adc VIC_SPR1_X                              // $4ffd
    sta VIC_SPR0_X                              // $5000
    lda VIC_SPR_X_MSB                           // $5003
    bcs L5013                                   // $5006
    and #$fe                                    // $5008
    tax                                         // $500a
    lda VIC_SPR_X_MSB                           // $500b
    and #$02                                    // $500e
    beq L5016                                   // $5010
    txa                                         // $5012
L5013:
    ora #$01                                    // $5013
    tax                                         // $5015
L5016:
    stx VIC_SPR_X_MSB                           // $5016
    tya                                         // $5019
    clc                                         // $501a
    adc VIC_SPR1_Y                              // $501b
    sta VIC_SPR0_Y                              // $501e
    rts                                         // $5021
shading_rows_left:
    tay                                         // $5022
    beq L5032                                   // $5023
    ldx #$00                                    // $5025
    lda #$38                                    // $5027
L5029:
    sta sprite($c7),x                           // $5029
    inx                                         // $502c
    inx                                         // $502d
    inx                                         // $502e
    dey                                         // $502f
    bne L5029                                   // $5030
L5032:
    rts                                         // $5032
shading_rows_top:
    tay                                         // $5033
    beq L5043                                   // $5034
    lda #$00                                    // $5036
L5038:
    sec                                         // $5038
    ror                                         // $5039
    dey                                         // $503a
    bne L5038                                   // $503b
    sta sprite($c7)+9                           // $503d
    sta sprite($c7)+12                          // $5040
L5043:
    rts                                         // $5043
shading_rows_right:
    tay                                         // $5044
    beq L506d                                   // $5045
    ldx #$00                                    // $5047
    dey                                         // $5049
    bne L5050                                   // $504a
    lda #$80                                    // $504c
    bne L506a                                   // $504e
L5050:
    lda #$c0                                    // $5050
    sta sprite($c7),x                           // $5052
    sta zp_fb                                   // $5055
    lda #$e0                                    // $5057
L5059:
    inx                                         // $5059
    inx                                         // $505a
    inx                                         // $505b
    dey                                         // $505c
    beq L5068                                   // $505d
    sta sprite($c7),x                           // $505f
    lsr                                         // $5062
    lsr zp_fb                                   // $5063
    jmp L5059                                   // $5065
L5068:
    lda zp_fb                                   // $5068
L506a:
    sta sprite($c7),x                           // $506a
L506d:
    rts                                         // $506d
shading_rows_bottom:
    tay                                         // $506e
    beq L5097                                   // $506f
    ldx #$00                                    // $5071
    dey                                         // $5073
    bne L507a                                   // $5074
    lda #$01                                    // $5076
    bne L5094                                   // $5078
L507a:
    lda #$03                                    // $507a
    sta sprite($c7),x                           // $507c
    sta zp_fb                                   // $507f
    lda #$07                                    // $5081
L5083:
    inx                                         // $5083
    inx                                         // $5084
    inx                                         // $5085
    dey                                         // $5086
    beq L5092                                   // $5087
    sta sprite($c7),x                           // $5089
    asl                                         // $508c
    asl zp_fb                                   // $508d
    jmp L5083                                   // $508f
L5092:
    lda zp_fb                                   // $5092
L5094:
    sta sprite($c7),x                           // $5094
L5097:
    rts                                         // $5097
clear_shading:
    ldx #$15                                    // $5098
    lda #$00                                    // $509a
L509c:
    sta sprite($c7),x                           // $509c
    dex                                         // $509f
    dex                                         // $50a0
    dex                                         // $50a1
    bpl L509c                                   // $50a2
    rts                                         // $50a4

// ----------------------------------------------------------------------------
// Set up the ball sprites: 0 shading, 1 shine, 2 and 3 ball, 4 shadow on the floor
// ----------------------------------------------------------------------------
init_ball_sprites:
    lda #$01                                    // $50a5
    jsr wait_frames                             // $50a7
    lda VIC_SPR_ENABLE                          // $50aa
    and #$e0                                    // $50ad
    sta VIC_SPR_ENABLE                          // $50af
    lda #$dc                                    // $50b2
    sta sprite_ptrs+2                           // $50b4
    lda #$0c                                    // $50b7
    sta VIC_SPR2_COL                            // $50b9
    lda #$00                                    // $50bc
    sta VIC_SPR1_COL                            // $50be
    lda VIC_SPR_PRIORITY                        // $50c1
    ora #$14                                    // $50c4
    sta VIC_SPR_PRIORITY                        // $50c6
    lda VIC_SPR_X_MSB                           // $50c9
    and #$fe                                    // $50cc
    sta VIC_SPR_X_MSB                           // $50ce
    lda #$c7                                    // $50d1
    sta sprite_ptrs                             // $50d3
    lda #$05                                    // $50d6
    sta VIC_SPR0_COL                            // $50d8
    lda #$00                                    // $50db
    sta ball_waiting                            // $50dd
    sta glint_on                                // $50e0
    sta tilt_enabled                            // $50e3
    sta steering_on                             // $50e6
    sta fire_enabled                            // $50e9
    sta controls_enabled                        // $50ec
    jsr init_shine                              // $50ef
    jsr move_shine                              // $50f2
    lda VIC_SPR_ENABLE                          // $50f5
    and #$fd                                    // $50f8
    sta VIC_SPR_ENABLE                          // $50fa
    jsr draw_shading                            // $50fd
    jsr clear_shading                           // $5100
    jsr pick_ball_frame                         // $5103
    jsr place_ball_shadow                       // $5106
    jsr mask_ball_sprite                        // $5109
    lda #$02                                    // $510c
    jsr wait_frames                             // $510e
    lda VIC_SPR_ENABLE                          // $5111
    ora #$1f                                    // $5114
    sta VIC_SPR_ENABLE                          // $5116
    rts                                         // $5119
update_shading:
    jsr init_shine                              // $511a
    jsr clear_shading                           // $511d
    jsr draw_shading                            // $5120
    rts                                         // $5123

// ----------------------------------------------------------------------------
// The ball appears (the shading grows), then waits until fire is
// pressed, then the shading shrinks again and the level starts
// ----------------------------------------------------------------------------
ball_appear:
    jsr appear_sound                            // $5124
    lda #$01                                    // $5127
    sta blip_sound                              // $5129
    lda #$0f                                    // $512c
    jsr wait_frames                             // $512e
    lda #$00                                    // $5131
    sta zp_ff                                   // $5133
L5135:
    lda #$03                                    // $5135
    jsr wait_frames                             // $5137
    jsr clear_shading                           // $513a
    jsr draw_shading                            // $513d
    inc zp_ff                                   // $5140
    lda zp_ff                                   // $5142
    cmp #$09                                    // $5144
    bcc L5135                                   // $5146
    lda #$00                                    // $5148
    sta blip_sound                              // $514a
    sta SID_V2_FREQ_HI                          // $514d
    sec                                         // $5150
    jsr gate_sound                              // $5151
    lda #$01                                    // $5154
    sta tilt_enabled                            // $5156
    sta controls_enabled                        // $5159
    sta ball_waiting                            // $515c
wait_fire_to_start:
    lda #$01                                    // $515f
    jsr wait_frames                             // $5161
    jsr update_tilt_graphics                    // $5164
    lda clunk_state                             // $5167
    bne wait_fire_to_start                      // $516a
    lda controls                                // $516c
    and #$10                                    // $516f
    bne wait_fire_to_start                      // $5171
    lda #$00                                    // $5173
    sta ball_waiting                            // $5175
    sta tilt_enabled                            // $5178
    sta controls_enabled                        // $517b
    jsr appear_sound                            // $517e
    lda #$01                                    // $5181
    sta blip_sound                              // $5183
    lda #$08                                    // $5186
    sta zp_ff                                   // $5188
L518a:
    lda #$03                                    // $518a
    jsr wait_frames                             // $518c
    jsr clear_shading                           // $518f
    jsr draw_shading                            // $5192
    dec zp_ff                                   // $5195
    bpl L518a                                   // $5197
    lda #$0f                                    // $5199
    jsr wait_frames                             // $519b
    lda #$00                                    // $519e
    sta blip_sound                              // $51a0
    sta SID_V2_CTRL                             // $51a3
    clc                                         // $51a6
    jsr gate_sound                              // $51a7
    rts                                         // $51aa
appear_sound:
    lda #$00                                    // $51ab
    sta SID_V2_CTRL                             // $51ad
    sta SID_V2_FREQ_HI                          // $51b0
    sta SID_V2_FREQ_LO                          // $51b3
    sta SID_V2_AD                               // $51b6
    lda #$f0                                    // $51b9
    sta SID_V2_SR                               // $51bb
    lda #$11                                    // $51be
    sta SID_V2_CTRL                             // $51c0
    rts                                         // $51c3
appear_sound_step:
    ldx blip_sound                              // $51c4
    beq L51f0                                   // $51c7
    dex                                         // $51c9
    bne L51e1                                   // $51ca
    ldx #$03                                    // $51cc
    lda #$0f                                    // $51ce
    ldy scroll_hiscore_step                     // $51d0
    bne L51de                                   // $51d3
    lda #$08                                    // $51d5
    ldy level_sign_on                           // $51d7
    beq L51de                                   // $51da
    lda #$09                                    // $51dc
L51de:
    sta SID_V2_FREQ_HI                          // $51de
L51e1:
    stx blip_sound                              // $51e1
    cpx #$01                                    // $51e4
    bne L51f0                                   // $51e6
    lda #$00                                    // $51e8
    sta SID_V2_FREQ_HI                          // $51ea
    sta SID_V2_FREQ_LO                          // $51ed
L51f0:
    rts                                         // $51f0

// ----------------------------------------------------------------------------
// The ball dissolves (end of a game): pixels of the ball sprite are
// switched off at random (SID voice 3 noise as random numbers)
// ----------------------------------------------------------------------------
ball_dissolve:
    jsr sid_off                                 // $51f1
    lda VIC_SPR_ENABLE                          // $51f4
    and #$f9                                    // $51f7
    sta VIC_SPR_ENABLE                          // $51f9
    lda sprite_ptrs+3                           // $51fc
    sta gate_count                              // $51ff
    sec                                         // $5202
    sbc #$02                                    // $5203
    sta sprite_ptrs+3                           // $5205
    sta sprite_ptrs+4                           // $5208
    lda #$14                                    // $520b
    jsr wait_frames                             // $520d
    ldx #$00                                    // $5210
    stx dissolve_time                           // $5212
    stx dissolve_step                           // $5215
    lda gate_count                              // $5218
    sta zp_fe                                   // $521b
    lda #$00                                    // $521d
    lsr zp_fe                                   // $521f
    ror                                         // $5221
    lsr zp_fe                                   // $5222
    ror                                         // $5224
    sta zp_fd                                   // $5225
    sec                                         // $5227
    sbc #$80                                    // $5228
    sta zp_fb                                   // $522a
    lda zp_fe                                   // $522c
    sbc #$00                                    // $522e
    sta zp_fc                                   // $5230
    lda #$c8                                    // $5232
    sta sprite_ptrs+3                           // $5234
    sta sprite_ptrs+4                           // $5237
    lda #$01                                    // $523a
    sta roll_sound_off                          // $523c
    lda #$80                                    // $523f
    sta SID_V3_CTRL                             // $5241
    lda #$ff                                    // $5244
    sta SID_V3_FREQ_HI                          // $5246
    lda #$00                                    // $5249
    sta zp_fa                                   // $524b
    lda #$00                                    // $524d
    sta gate_index                              // $524f
L5252:
    dec zp_fa                                   // $5252
L5254:
    ldy #$3e                                    // $5254
L5256:
    lda (zp_fb),y                               // $5256
    eor (zp_fd),y                               // $5258
    sta zp_ff                                   // $525a
    beq L5276                                   // $525c
    ldx #$08                                    // $525e
L5260:
    lda zp_ff                                   // $5260
    rol                                         // $5262
    bcc L5271                                   // $5263
    tya                                         // $5265
    ldy #$14                                    // $5266
L5268:
    dey                                         // $5268
    bne L5268                                   // $5269
    tay                                         // $526b
    lda SID_OSC3                                // $526c
    cmp zp_fa                                   // $526f
L5271:
    rol zp_ff                                   // $5271
    dex                                         // $5273
    bne L5260                                   // $5274
L5276:
    lda (zp_fb),y                               // $5276
    ora zp_ff                                   // $5278
    sta sprite($c8),y                           // $527a
    dey                                         // $527d
    bpl L5256                                   // $527e
    lda zp_fa                                   // $5280
    bne L5292                                   // $5282
    lda gate_count                              // $5284
    sta sprite_ptrs+3                           // $5287
    sta sprite_ptrs+4                           // $528a
    lda #$00                                    // $528d
    sta roll_sound_off                          // $528f
L5292:
    jsr dissolve_frame                          // $5292
    bcs L52a5                                   // $5295
    dec gate_index                              // $5297
    bpl L5254                                   // $529a
    lda #$01                                    // $529c
    sta gate_index                              // $529e
    lda zp_fa                                   // $52a1
    bne L5252                                   // $52a3
L52a5:
    lda VIC_SPR_ENABLE                          // $52a5
    ora #$06                                    // $52a8
    sta VIC_SPR_ENABLE                          // $52aa
    lda #$01                                    // $52ad
    sta VIC_SPR3_COL                            // $52af
    lda #$14                                    // $52b2
    jsr wait_frames                             // $52b4
    rts                                         // $52b7
build_chars_2420:
    ldy #$07                                    // $52b8
L52ba:
    lda char($25),y                             // $52ba
    sta zp_fa                                   // $52bd
    lsr                                         // $52bf
    ora zp_fa                                   // $52c0
    eor #$ff                                    // $52c2
    tax                                         // $52c4
    and char($0a),y                             // $52c5
    ora zp_fa                                   // $52c8
    sta char($84),y                             // $52ca
    txa                                         // $52cd
    and char($0e),y                             // $52ce
    ora zp_fa                                   // $52d1
    sta char($85),y                             // $52d3
    lda char($27),y                             // $52d6
    sta zp_fa                                   // $52d9
    lsr                                         // $52db
    ora zp_fa                                   // $52dc
    eor #$ff                                    // $52de
    tax                                         // $52e0
    and char($0e),y                             // $52e1
    ora zp_fa                                   // $52e4
    sta char($86),y                             // $52e6
    txa                                         // $52e9
    and char($02),y                             // $52ea
    ora zp_fa                                   // $52ed
    sta char($87),y                             // $52ef
    lda char($23),y                             // $52f2
    sta zp_fa                                   // $52f5
    lsr                                         // $52f7
    ora zp_fa                                   // $52f8
    eor #$ff                                    // $52fa
    tax                                         // $52fc
    and char($02),y                             // $52fd
    ora zp_fa                                   // $5300
    sta char($88),y                             // $5302
    txa                                         // $5305
    and char($06),y                             // $5306
    ora zp_fa                                   // $5309
    sta char($89),y                             // $530b
    lda char($29),y                             // $530e
    sta zp_fa                                   // $5311
    lsr                                         // $5313
    ora zp_fa                                   // $5314
    eor #$ff                                    // $5316
    tax                                         // $5318
    and char($06),y                             // $5319
    ora zp_fa                                   // $531c
    sta char($8a),y                             // $531e
    txa                                         // $5321
    and char($0a),y                             // $5322
    ora zp_fa                                   // $5325
    sta char($8b),y                             // $5327
    dey                                         // $532a
    bpl L52ba                                   // $532b
    rts                                         // $532d
init_frame_flash:
    lda #$01                                    // $532e
    sta frame_flash_sides                       // $5330
    lda #$00                                    // $5333
    sta frame_flash_corner                      // $5335
    ldx #$5f                                    // $5338
L533a:
    ldy #$07                                    // $533a
L533c:
    lda char($00),y                             // $533c
    sta char($8c),x                             // $533f
    dex                                         // $5342
    dey                                         // $5343
    bpl L533c                                   // $5344
    txa                                         // $5346
    bpl L533a                                   // $5347
    rts                                         // $5349

// ----------------------------------------------------------------------------
// Light up the board frame edge (characters $2460-$2477 and two
// screen cells) while the board is tilted fully toward that side
// ----------------------------------------------------------------------------
frame_flash_left:
    lda frame_flash_sides                       // $534a
    ldx tilt_shift_x                            // $534d
    cpx #$04                                    // $5350
    bne L536e                                   // $5352
    ldx tilt_shift_y                            // $5354
    cpx #$08                                    // $5357
    bne L536e                                   // $5359
    ldx tilt_dx                                 // $535b
    bne L536e                                   // $535e
    and #$01                                    // $5360
    bne L53a0                                   // $5362
    ldy #$01                                    // $5364
    lda frame_flash_sides                       // $5366
    ora #$01                                    // $5369
    jmp L5379                                   // $536b
L536e:
    and #$01                                    // $536e
    beq L53a0                                   // $5370
    ldy #$00                                    // $5372
    lda frame_flash_sides                       // $5374
    and #$fe                                    // $5377
L5379:
    sta frame_flash_sides                       // $5379
    ldx #$01                                    // $537c
L537e:
    lda #$55                                    // $537e
    cpy #$00                                    // $5380
    bne L5387                                   // $5382
    lda char($00),x                             // $5384
L5387:
    sta char($8c),x                             // $5387
    sta char($8d),x                             // $538a
    sta char($8e),x                             // $538d
    dex                                         // $5390
    bpl L537e                                   // $5391
    ldx #$00                                    // $5393
    tya                                         // $5395
    beq L539a                                   // $5396
    ldx #$6c                                    // $5398
L539a:
    stx screen+4*40+2                           // $539a
    stx screen+4*40+36                          // $539d
L53a0:
    rts                                         // $53a0
frame_flash_bottom:
    lda frame_flash_sides                       // $53a1
    ldx tilt_shift_x                            // $53a4
    cpx #$04                                    // $53a7
    bne L53c3                                   // $53a9
    ldx tilt_shift_y                            // $53ab
    bne L53c3                                   // $53ae
    ldx tilt_dx                                 // $53b0
    bne L53c3                                   // $53b3
    and #$04                                    // $53b5
    bne L53f7                                   // $53b7
    ldy #$01                                    // $53b9
    lda frame_flash_sides                       // $53bb
    ora #$04                                    // $53be
    jmp L53ce                                   // $53c0
L53c3:
    and #$04                                    // $53c3
    beq L53f7                                   // $53c5
    ldy #$00                                    // $53c7
    lda frame_flash_sides                       // $53c9
    and #$fb                                    // $53cc
L53ce:
    sta frame_flash_sides                       // $53ce
    ldx #$06                                    // $53d1
L53d3:
    lda #$55                                    // $53d3
    cpy #$00                                    // $53d5
    bne L53dc                                   // $53d7
    lda char($00),x                             // $53d9
L53dc:
    sta char($92),x                             // $53dc
    sta char($93),x                             // $53df
    sta char($94),x                             // $53e2
    inx                                         // $53e5
    cpx #$08                                    // $53e6
    bcc L53d3                                   // $53e8
    ldx #$00                                    // $53ea
    tya                                         // $53ec
    beq L53f1                                   // $53ed
    ldx #$65                                    // $53ef
L53f1:
    stx screen+22*40+2                          // $53f1
    stx screen+22*40+36                         // $53f4
L53f7:
    rts                                         // $53f7
frame_flash_top:
    lda frame_flash_sides                       // $53f8
    ldx tilt_shift_y                            // $53fb
    cpx #$04                                    // $53fe
    bne L541c                                   // $5400
    ldx tilt_shift_x                            // $5402
    cpx #$08                                    // $5405
    bne L541c                                   // $5407
    ldx tilt_dy                                 // $5409
    bne L541c                                   // $540c
    and #$08                                    // $540e
    bne L544b                                   // $5410
    ldy #$01                                    // $5412
    lda frame_flash_sides                       // $5414
    ora #$08                                    // $5417
    jmp L5427                                   // $5419
L541c:
    and #$08                                    // $541c
    beq L544b                                   // $541e
    ldy #$00                                    // $5420
    lda frame_flash_sides                       // $5422
    and #$f7                                    // $5425
L5427:
    sta frame_flash_sides                       // $5427
    ldx #$00                                    // $542a
    tya                                         // $542c
    beq L5431                                   // $542d
    ldx #$72                                    // $542f
L5431:
    stx screen+4*40+2                           // $5431
    stx screen+22*40+2                          // $5434
    ldx #$00                                    // $5437
L5439:
    lda D544c,y                                 // $5439
    sta char($95),x                             // $543c
    inx                                         // $543f
    lda D544e,y                                 // $5440
    sta char($95),x                             // $5443
    inx                                         // $5446
    cpx #$18                                    // $5447
    bcc L5439                                   // $5449
L544b:
    rts                                         // $544b
D544c:
    .byte $ee,$6e                               // $544c
D544e:
    .byte $bb,$7b                               // $544e
frame_flash_right:
    lda frame_flash_sides                       // $5450
    ldx tilt_shift_y                            // $5453
    cpx #$04                                    // $5456
    bne L5472                                   // $5458
    ldx tilt_shift_x                            // $545a
    bne L5472                                   // $545d
    ldx tilt_dy                                 // $545f
    bne L5472                                   // $5462
    and #$02                                    // $5464
    bne L54a1                                   // $5466
    ldy #$01                                    // $5468
    lda frame_flash_sides                       // $546a
    ora #$02                                    // $546d
    jmp L547d                                   // $546f
L5472:
    and #$02                                    // $5472
    beq L54a1                                   // $5474
    ldy #$00                                    // $5476
    lda frame_flash_sides                       // $5478
    and #$fd                                    // $547b
L547d:
    sta frame_flash_sides                       // $547d
    ldx #$00                                    // $5480
    tya                                         // $5482
    beq L5487                                   // $5483
    ldx #$75                                    // $5485
L5487:
    stx screen+4*40+36                          // $5487
    stx screen+22*40+36                         // $548a
    ldx #$00                                    // $548d
L548f:
    lda D54a2,y                                 // $548f
    sta char($8f),x                             // $5492
    inx                                         // $5495
    lda D54a4,y                                 // $5496
    sta char($8f),x                             // $5499
    inx                                         // $549c
    cpx #$18                                    // $549d
    bcc L548f                                   // $549f
L54a1:
    rts                                         // $54a1
D54a2:
    .byte $ee,$ed                               // $54a2
D54a4:
    .byte $bb,$b9                               // $54a4
frame_flash_vertical:
    lda frame_flash_sides                       // $54a6
    ldx tilt_shift_y                            // $54a9
    cpx #$04                                    // $54ac
    bne L54c3                                   // $54ae
    ldx tilt_dy                                 // $54b0
    bne L54c3                                   // $54b3
    ora #$20                                    // $54b5
    sta frame_flash_sides                       // $54b7
    ldx tilt_shift_x                            // $54ba
    lda D54f6,x                                 // $54bd
    jmp L54d1                                   // $54c0
L54c3:
    and #$20                                    // $54c3
    beq L54f5                                   // $54c5
    lda frame_flash_sides                       // $54c7
    and #$df                                    // $54ca
    sta frame_flash_sides                       // $54cc
    lda #$00                                    // $54cf
L54d1:
    ldx #$00                                    // $54d1
    ldy #$00                                    // $54d3
    cmp #$01                                    // $54d5
    beq L54dd                                   // $54d7
    ldx #$bb                                    // $54d9
    ldy #$ee                                    // $54db
L54dd:
    stx char($8e)+7                             // $54dd
    sty char($92)                               // $54e0
    ldx #$00                                    // $54e3
    ldy #$00                                    // $54e5
    cmp #$02                                    // $54e7
    beq L54ef                                   // $54e9
    ldx #$bb                                    // $54eb
    ldy #$ee                                    // $54ed
L54ef:
    stx char($8c)+7                             // $54ef
    sty char($94)                               // $54f2
L54f5:
    rts                                         // $54f5
D54f6:
    .byte $02,$02,$02,$00,$00,$00,$01,$01,$01   // $54f6
frame_flash_horizontal:
    lda frame_flash_sides                       // $54ff
    ldx tilt_shift_x                            // $5502
    cpx #$04                                    // $5505
    bne L551d                                   // $5507
    ldx tilt_dx                                 // $5509
    bne L551d                                   // $550c
    ora #$10                                    // $550e
    sta frame_flash_sides                       // $5510
    ldx tilt_shift_y                            // $5513
    lda D54f6,x                                 // $5516
    tay                                         // $5519
    jmp L552b                                   // $551a
L551d:
    and #$10                                    // $551d
    beq L555e                                   // $551f
    lda frame_flash_sides                       // $5521
    and #$ef                                    // $5524
    sta frame_flash_sides                       // $5526
    ldy #$00                                    // $5529
L552b:
    cpy frame_flash_corner                      // $552b
    beq L555e                                   // $552e
    sty frame_flash_corner                      // $5530
    ldx #$00                                    // $5533
L5535:
    lda char($00),x                             // $5535
    and D5562,y                                 // $5538
    sta char($97),x                             // $553b
    lda char($00),x                             // $553e
    and D555f,y                                 // $5541
    sta char($8f),x                             // $5544
    lda char($00),x                             // $5547
    and D5568,y                                 // $554a
    sta char($95),x                             // $554d
    lda char($00),x                             // $5550
    and D5565,y                                 // $5553
    sta char($91),x                             // $5556
    inx                                         // $5559
    cpx #$08                                    // $555a
    bcc L5535                                   // $555c
L555e:
    rts                                         // $555e
D555f:
    .byte $ff,$ff,$3f                           // $555f
D5562:
    .byte $ff,$ff,$fc                           // $5562
D5565:
    .byte $ff,$3f,$ff                           // $5565
D5568:
    .byte $ff,$fc,$ff                           // $5568

// ----------------------------------------------------------------------------
// Title screen. The TILT logo rocks back and forth (title_irq). Fire
// starts a game; F7, or $0F03 title frames (over a minute) without input,
// start the demo; M toggles the music.
// ----------------------------------------------------------------------------
title_screen:
    lda scroll_hiscore_step                     // $556b
    ora scroll_level_step                       // $556e
    ora scroll_score_step                       // $5571
    bne title_screen                            // $5574
    jsr sid_off                                 // $5576
    lda #$0c                                    // $5579
    sta SID_V1_FREQ_HI                          // $557b
    lda #$08                                    // $557e
    sta SID_V1_AD                               // $5580
    lda #$21                                    // $5583
    sta SID_V1_CTRL                             // $5585
    lda #$ff                                    // $5588
    sta music_command                           // $558a
    lda #$00                                    // $558d
    sta music_playing                           // $558f
    sta m_key_up                                // $5592
    sta title_idle                              // $5595
    sta title_idle+1                            // $5598
    lda #$00                                    // $559b
    sta power_lo                                // $559d
    sta power_hi                                // $55a0
    sta game_over                               // $55a3
    sta power_drain_on                          // $55a6
    sta backup_allowed                          // $55a9
    sta demo_stops_at_end                       // $55ac
    sta demo_playing                            // $55af
    sta cf89_unused                             // $55b2
    sta title_fine_scroll                       // $55b5
    lda #$27                                    // $55b8
    sta title_text_pos                          // $55ba
    lda #$0b                                    // $55bd
    sta title_delay                             // $55bf
    jsr clear_buffers                           // $55c2
    jsr draw_logo_letters                       // $55c5
    lda #$08                                    // $55c8
    sta screen_on                               // $55ca
    lda #$01                                    // $55cd
    jsr wait_frames                             // $55cf
    lda #$01                                    // $55d2
    sta title_mode                              // $55d4
    lda #$00                                    // $55d7
    sta demo_mode                               // $55d9
    sta tilt_angle_y                            // $55dc
    sta tilt_shift_y_old                        // $55df
    lda #$0f                                    // $55e2
    sta title_rock_pause                        // $55e4
    lda #$04                                    // $55e7
    sta fine_scroll_x                           // $55e9
    lda #$08                                    // $55ec
    sta tilt_level_y                            // $55ee
    lda #$00                                    // $55f1
    sta title_rock_dir                          // $55f3
    lda #$01                                    // $55f6
    jsr wait_frames                             // $55f8
    lda #$00                                    // $55fb
    sta VIC_SPR_ENABLE                          // $55fd
    sta VIC_SPR_MULTICOLOR                      // $5600
    sta VIC_SPR_EXPAND_Y                        // $5603
    sta VIC_SPR_EXPAND_X                        // $5606
    lda #$07                                    // $5609
    sta VIC_BG1                                 // $560b
    lda #$0e                                    // $560e
    sta VIC_BG2                                 // $5610
    jsr swap_title_sprites                      // $5613
    jsr title_sprites_layout                    // $5616
    jsr show_power_off                          // $5619
    jsr build_logo_masks                        // $561c
    jsr show_buffers                            // $561f
title_loop_frame:
    lda #$01                                    // $5622
    jsr wait_frames                             // $5624
    jsr draw_logo                               // $5627
    jsr title_music_key                         // $562a
    jsr title_scroll_text                       // $562d
    lda #$18                                    // $5630
    sta screen_on                               // $5632
    inc title_idle                              // $5635
    bne L563d                                   // $5638
    inc title_idle+1                            // $563a
L563d:
    lda title_delay                             // $563d
    beq L5648                                   // $5640
    dec title_delay                             // $5642
    jmp title_loop_frame                        // $5645
L5648:
    jsr read_controls                           // $5648  fire?
    and #$10                                    // $564b
    beq title_done                              // $564d
    lda #$fe                                    // $564f
    sta CIA1_PRA                                // $5651
    lda CIA1_PRB                                // $5654  F7?
    cmp #$f7                                    // $5657
    beq title_start_demo                        // $5659
    lda title_idle                              // $565b  $0F03 title frames without input?
    cmp #$03                                    // $565e
    lda title_idle+1                            // $5660
    sbc #$0f                                    // $5663
    bcs title_start_demo                        // $5665
    jmp title_loop_frame                        // $5667
title_start_demo:
    jsr start_demo                              // $566a
title_done:
    jsr sid_off                                 // $566d
    lda #$00                                    // $5670
    sta no_restart                              // $5672
    lda #$08                                    // $5675
    sta screen_on                               // $5677
    lda #$1f                                    // $567a
    sta SID_MODE_VOL                            // $567c
    lda #$44                                    // $567f
    sta SID_RES_FILT                            // $5681
    rts                                         // $5684

// ----------------------------------------------------------------------------
// Title, in the raster IRQ: rock the logo (tilt angle Y) up and down
// ----------------------------------------------------------------------------
title_irq:
    jsr title_scroll_step                       // $5685
    lda title_rock_pause                        // $5688
    beq L5692                                   // $568b
    dec title_rock_pause                        // $568d
    bne L56bd                                   // $5690
L5692:
    ldy #$00                                    // $5692
    lda tilt_angle_y                            // $5694
    ldx title_rock_dir                          // $5697
    bne L56a9                                   // $569a
    clc                                         // $569c
    adc #$07                                    // $569d
    bcc L56b4                                   // $569f
    ldx #$01                                    // $56a1
    ldy #$0c                                    // $56a3
    lda #$ff                                    // $56a5
    bne L56b4                                   // $56a7
L56a9:
    sec                                         // $56a9
    sbc #$07                                    // $56aa
    bcs L56b4                                   // $56ac
    ldx #$00                                    // $56ae
    ldy #$0c                                    // $56b0
    lda #$00                                    // $56b2
L56b4:
    sta tilt_angle_y                            // $56b4
    stx title_rock_dir                          // $56b7
    sty title_rock_pause                        // $56ba
L56bd:
    lda tilt_angle_y                            // $56bd
    ldx #$09                                    // $56c0
L56c2:
    dex                                         // $56c2
    sec                                         // $56c3
    sbc #$1c                                    // $56c4
    bcs L56c2                                   // $56c6
    txa                                         // $56c8
    bpl L56cd                                   // $56c9
    ldx #$00                                    // $56cb
L56cd:
    stx tilt_level_y                            // $56cd
    lda tilt_level_shift_y,x                    // $56d0
    sta fine_scroll_y                           // $56d3
    rts                                         // $56d6
build_logo_masks:
    lda #$05                                    // $56d7
    sta zp_fa                                   // $56d9
    ldx #$2f                                    // $56db
L56dd:
    ldy zp_fa                                   // $56dd
    lda D56f7,y                                 // $56df
    sta zp_ff                                   // $56e2
    ldy #$07                                    // $56e4
L56e6:
    lda char($00),y                             // $56e6
    and zp_ff                                   // $56e9
    sta char($36),x                             // $56eb
    dex                                         // $56ee
    dey                                         // $56ef
    bpl L56e6                                   // $56f0
    dec zp_fa                                   // $56f2
    bpl L56dd                                   // $56f4
    rts                                         // $56f6
D56f7:
    .byte $3f,$0f,$03,$fc,$f0,$c0               // $56f7

// ----------------------------------------------------------------------------
// Title logo: build the edge characters for the current tilt
// ----------------------------------------------------------------------------
draw_logo:
    lda tilt_level_y                            // $56fd
    sta tilt_shift_y                            // $5700
    cmp tilt_shift_y_old                        // $5703
    beq L5708                                   // $5706
L5708:
    jsr logo_fill_21e0                          // $5708
    jsr logo_fill_2200                          // $570b
    jsr logo_fill_21f8                          // $570e
    jsr logo_fill_21f0                          // $5711
    jsr logo_fill_21e8                          // $5714
    jsr logo_edge_left                          // $5717
    jsr logo_edge_right                         // $571a
    jsr logo_corners_i                          // $571d
    jsr logo_pick_l_chars                       // $5720
    jsr logo_shade_l_1                          // $5723
    jsr logo_shade_l_2                          // $5726
    jsr logo_shade_l_3                          // $5729
    jsr logo_part_5c7c                          // $572c
    jsr logo_part_5c98                          // $572f
    jsr logo_part_5d59                          // $5732
    jsr logo_part_5cc5                          // $5735
    jsr logo_part_5d8c                          // $5738
    jsr logo_part_5cdf                          // $573b
    jsr logo_part_5d1d                          // $573e
    jsr logo_pick_t_char                        // $5741
    jsr logo_shade_t                            // $5744
    jsr logo_t_char_low                         // $5747
    jsr logo_corners_t                          // $574a
    lda tilt_shift_y                            // $574d
    sta tilt_shift_y_old                        // $5750
    rts                                         // $5753
clear_buffers:
    lda #<screen_buffer                         // $5754
    sta zp_fb                                   // $5756
    sta zp_fd                                   // $5758
    lda #>screen_buffer                         // $575a
    sta zp_fc                                   // $575c
    lda #$78                                    // $575e
    sta zp_fe                                   // $5760
    ldx #$04                                    // $5762
    ldy #$00                                    // $5764
L5766:
    lda #$20                                    // $5766
    sta (zp_fb),y                               // $5768
    lda #$0e                                    // $576a
    sta (zp_fd),y                               // $576c
    iny                                         // $576e
    bne L5766                                   // $576f
    inc zp_fc                                   // $5771
    inc zp_fe                                   // $5773
    dex                                         // $5775
    bne L5766                                   // $5776
    rts                                         // $5778

// ----------------------------------------------------------------------------
// Draw the four 8x9 character letters of the TILT logo into the screen buffer
// ----------------------------------------------------------------------------
draw_logo_letters:
    ldx #$f4                                    // $5779
    ldy #$7c                                    // $577b
    stx zp_fb                                   // $577d
    sty zp_fc                                   // $577f
    ldx #$c8                                    // $5781
    ldy #$57                                    // $5783
    stx L5797+1                                 // $5785
    sty L5797+2                                 // $5788
    lda #$04                                    // $578b
    sta zp_fa                                   // $578d
    ldx #$00                                    // $578f
L5791:
    lda #$09                                    // $5791
    sta zp_ff                                   // $5793
L5795:
    ldy #$00                                    // $5795
L5797:
    lda $ffff,x                                 // $5797
    sta (zp_fb),y                               // $579a
    inx                                         // $579c
    bne L57a2                                   // $579d
    inc L5797+2                                 // $579f
L57a2:
    iny                                         // $57a2
    cpy #$08                                    // $57a3
    bcc L5797                                   // $57a5
    lda zp_fb                                   // $57a7
    clc                                         // $57a9
    adc #$28                                    // $57aa
    sta zp_fb                                   // $57ac
    bcc L57b2                                   // $57ae
    inc zp_fc                                   // $57b0
L57b2:
    dec zp_ff                                   // $57b2
    bne L5795                                   // $57b4
    lda zp_fb                                   // $57b6
    sec                                         // $57b8
    sbc #$60                                    // $57b9
    sta zp_fb                                   // $57bb
    lda zp_fc                                   // $57bd
    sbc #$01                                    // $57bf
    sta zp_fc                                   // $57c1
    dec zp_fa                                   // $57c3
    bne L5791                                   // $57c5
    rts                                         // $57c7
logo_letter_chars:
    .byte $3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$4a,$4b,$40,$40,$40,$40,$40,$40  // $57c8
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$4c,$4d,$3f,$00,$00,$3f,$3f,$3f  // $57d8
    .byte $20,$20,$20,$00,$00,$20,$20,$20,$20,$20,$20,$00,$00,$20,$20,$20  // $57e8
    .byte $20,$20,$20,$00,$00,$20,$20,$20,$20,$20,$20,$41,$41,$20,$20,$20  // $57f8
    .byte $20,$20,$20,$3d,$3d,$20,$20,$20,$20,$20,$3c,$3c,$3c,$3c,$20,$20  // $5808
    .byte $52,$20,$58,$40,$40,$40,$20,$20,$20,$20,$00,$00,$00,$00,$20,$20  // $5818
    .byte $53,$20,$59,$00,$00,$3f,$20,$20,$20,$20,$20,$00,$00,$20,$20,$20  // $5828
    .byte $20,$20,$5b,$00,$00,$3e,$20,$20,$20,$20,$00,$00,$00,$00,$20,$20  // $5838
    .byte $20,$20,$5a,$41,$41,$41,$20,$20,$20,$20,$3d,$3d,$3d,$3d,$20,$20  // $5848
    .byte $3c,$3c,$20,$20,$20,$20,$20,$3c,$40,$40,$20,$20,$20,$20,$54,$40  // $5858
    .byte $00,$00,$20,$20,$20,$20,$20,$00,$00,$00,$20,$20,$20,$20,$55,$3f  // $5868
    .byte $00,$00,$20,$20,$20,$20,$20,$20,$00,$00,$3e,$3e,$3e,$3e,$3e,$5f  // $5878
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$41,$41,$41,$41,$41,$41,$41,$5e  // $5888
    .byte $3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$20  // $5898
    .byte $40,$40,$40,$40,$40,$4f,$4e,$20,$00,$00,$00,$00,$00,$00,$00,$20  // $58a8
    .byte $3f,$3f,$00,$00,$3f,$51,$50,$20,$20,$20,$00,$00,$20,$20,$20,$20  // $58b8
    .byte $20,$20,$00,$00,$20,$20,$20,$20,$20,$20,$00,$00,$20,$20,$20,$20  // $58c8
    .byte $20,$20,$41,$41,$20,$20,$20,$20,$20,$20,$3d,$3d,$20,$20,$20,$20  // $58d8
logo_edge_left:
    ldx #$6f                                    // $58e8
    ldy #$05                                    // $58ea
    stx zp_fb                                   // $58ec
    sty zp_fc                                   // $58ee
    ldx #$87                                    // $58f0
    ldy #$05                                    // $58f2
    stx zp_fd                                   // $58f4
    sty zp_fe                                   // $58f6
    lda tilt_shift_y                            // $58f8
    asl                                         // $58fb
    asl                                         // $58fc
    asl                                         // $58fd
    tax                                         // $58fe
    lda #$05                                    // $58ff
    sta zp_ff                                   // $5901
    ldy #$00                                    // $5903
L5905:
    lda logo_edge_left_chars,x                  // $5905
    sta (zp_fb),y                               // $5908
    jsr logo_shade_char                         // $590a
    sta (zp_fd),y                               // $590d
    tya                                         // $590f
    clc                                         // $5910
    adc #$28                                    // $5911
    tay                                         // $5913
    bcc L591a                                   // $5914
    inc zp_fc                                   // $5916
    inc zp_fe                                   // $5918
L591a:
    inx                                         // $591a
    dec zp_ff                                   // $591b
    bne L5905                                   // $591d
    rts                                         // $591f
logo_edge_right:
    ldx #$71                                    // $5920
    ldy #$05                                    // $5922
    stx zp_fb                                   // $5924
    sty zp_fc                                   // $5926
    ldx #$85                                    // $5928
    ldy #$05                                    // $592a
    stx zp_fd                                   // $592c
    sty zp_fe                                   // $592e
    lda tilt_shift_y                            // $5930
    asl                                         // $5933
    asl                                         // $5934
    asl                                         // $5935
    tax                                         // $5936
    lda #$05                                    // $5937
    sta zp_ff                                   // $5939
    ldy #$00                                    // $593b
L593d:
    lda logo_edge_right_chars,x                 // $593d
    sta (zp_fb),y                               // $5940
    jsr logo_shade_char                         // $5942
    sta (zp_fd),y                               // $5945
    tya                                         // $5947
    clc                                         // $5948
    adc #$28                                    // $5949
    tay                                         // $594b
    bcc L5952                                   // $594c
    inc zp_fc                                   // $594e
    inc zp_fe                                   // $5950
L5952:
    inx                                         // $5952
    dec zp_ff                                   // $5953
    bne L593d                                   // $5955
    rts                                         // $5957

// ----------------------------------------------------------------------------
// Shade a logo edge character: codes below $39 + 3, others - 3
// ----------------------------------------------------------------------------
logo_shade_char:
    cmp #$00                                    // $5958
    beq L596a                                   // $595a
    cmp #$20                                    // $595c
    beq L596a                                   // $595e
    cmp #$39                                    // $5960
    bcs L5968                                   // $5962
    adc #$03                                    // $5964
    bne L596a                                   // $5966
L5968:
    sbc #$03                                    // $5968
L596a:
    rts                                         // $596a
logo_edge_left_chars:
    .byte $36,$37,$38,$20,$20,$00,$00,$00,$00,$36,$37,$38,$38,$00,$00,$00  // $596b
    .byte $00,$36,$36,$37,$37,$00,$00,$00,$00,$00,$36,$36,$36,$00,$00,$00  // $597b
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$36,$36,$00,$00,$00,$00,$00,$00  // $598b
    .byte $37,$37,$36,$00,$00,$00,$00,$00,$38,$37,$36,$00,$00,$00,$00,$00  // $599b
    .byte $20,$38,$37,$36,$00,$00,$00,$00       // $59ab
logo_edge_right_chars:
    .byte $3b,$3b,$3a,$3a,$3a,$00,$00,$00,$3b,$3b,$3a,$3a,$3a,$00,$00,$00  // $59b3
    .byte $20,$20,$3b,$3b,$3b,$00,$00,$00,$20,$20,$20,$20,$20,$00,$00,$00  // $59c3
    .byte $20,$20,$20,$20,$20,$00,$00,$00,$3b,$3b,$20,$20,$20,$00,$00,$00  // $59d3
    .byte $3b,$3b,$3b,$20,$20,$00,$00,$00,$3a,$3a,$3b,$20,$20,$00,$00,$00  // $59e3
    .byte $3a,$3a,$3b,$20,$20,$00,$00,$00       // $59f3

// ----------------------------------------------------------------------------
// Title logo helpers (called by draw_logo): build the edge and shading
// characters $21E0-$22FF of the four letters for the current tilt
// (tilt_shift_y 0-8), the same way build_wall_chars does for the maze
// ----------------------------------------------------------------------------
logo_fill_21e0:
    lda tilt_shift_y                            // $59fb
    asl                                         // $59fe
    cmp #$08                                    // $59ff
    bcc L5a05                                   // $5a01
    lda #$08                                    // $5a03
L5a05:
    sta zp_ff                                   // $5a05
    lda #$00                                    // $5a07
    ldx #$00                                    // $5a09
L5a0b:
    cpx zp_ff                                   // $5a0b
    bne L5a11                                   // $5a0d
    lda #$55                                    // $5a0f
L5a11:
    sta char($3c),x                             // $5a11
    inx                                         // $5a14
    cpx #$08                                    // $5a15
    bcc L5a0b                                   // $5a17
    rts                                         // $5a19
logo_fill_21e8:
    lda tilt_shift_y                            // $5a1a
    asl                                         // $5a1d
    sec                                         // $5a1e
    sbc #$09                                    // $5a1f
    bcs L5a25                                   // $5a21
    lda #$ff                                    // $5a23
L5a25:
    sta zp_ff                                   // $5a25
    lda #$00                                    // $5a27
    ldx #$07                                    // $5a29
L5a2b:
    cpx zp_ff                                   // $5a2b
    bne L5a31                                   // $5a2d
    lda #$55                                    // $5a2f
L5a31:
    sta char($3d),x                             // $5a31
    dex                                         // $5a34
    bpl L5a2b                                   // $5a35
    rts                                         // $5a37
logo_fill_21f0:
    lda tilt_shift_y                            // $5a38
    clc                                         // $5a3b
    adc #$04                                    // $5a3c
    cmp #$08                                    // $5a3e
    bcc L5a44                                   // $5a40
    lda #$08                                    // $5a42
L5a44:
    sta zp_ff                                   // $5a44
    lda #$00                                    // $5a46
    ldx #$00                                    // $5a48
L5a4a:
    sta char($3e),x                             // $5a4a
    inx                                         // $5a4d
    cpx zp_ff                                   // $5a4e
    bne L5a54                                   // $5a50
    lda #$55                                    // $5a52
L5a54:
    cpx #$08                                    // $5a54
    bcc L5a4a                                   // $5a56
    rts                                         // $5a58
logo_fill_21f8:
    lda tilt_shift_y                            // $5a59
    sec                                         // $5a5c
    sbc #$04                                    // $5a5d
    bcs L5a63                                   // $5a5f
    lda #$00                                    // $5a61
L5a63:
    sta zp_ff                                   // $5a63
    lda #$00                                    // $5a65
    ldx #$07                                    // $5a67
L5a69:
    sta char($3f),x                             // $5a69
    cpx zp_ff                                   // $5a6c
    bne L5a72                                   // $5a6e
    lda #$55                                    // $5a70
L5a72:
    dex                                         // $5a72
    bpl L5a69                                   // $5a73
    rts                                         // $5a75
logo_fill_2200:
    ldx #$0f                                    // $5a76
    lda #$00                                    // $5a78
L5a7a:
    sta char($40),x                             // $5a7a
    dex                                         // $5a7d
    bpl L5a7a                                   // $5a7e
    lda tilt_shift_y                            // $5a80
    sec                                         // $5a83
    sbc #$04                                    // $5a84
    bcs L5a8a                                   // $5a86
    lda #$00                                    // $5a88
L5a8a:
    asl                                         // $5a8a
    cmp #$08                                    // $5a8b
    bcs L5a9b                                   // $5a8d
    tax                                         // $5a8f
L5a90:
    lda char($00),x                             // $5a90
    sta char($40),x                             // $5a93
    inx                                         // $5a96
    cpx #$08                                    // $5a97
    bcc L5a90                                   // $5a99
L5a9b:
    lda tilt_shift_y                            // $5a9b
    asl                                         // $5a9e
    cmp #$08                                    // $5a9f
    bcc L5aa5                                   // $5aa1
    lda #$08                                    // $5aa3
L5aa5:
    tax                                         // $5aa5
    dex                                         // $5aa6
    bmi L5ab2                                   // $5aa7
L5aa9:
    lda char($00),x                             // $5aa9
    sta char($41),x                             // $5aac
    dex                                         // $5aaf
    bpl L5aa9                                   // $5ab0
L5ab2:
    rts                                         // $5ab2
logo_corners_t:
    lda screen+13*40+7                          // $5ab3
    jsr char_addr_fb                            // $5ab6
    lda screen+13*40+9                          // $5ab9
    jsr char_addr_fd                            // $5abc
    ldy #$07                                    // $5abf
L5ac1:
    lda (zp_fb),y                               // $5ac1
    and char($41),y                             // $5ac3
    sta char($42),y                             // $5ac6
    lda (zp_fd),y                               // $5ac9
    and char($41),y                             // $5acb
    sta char($43),y                             // $5ace
    dey                                         // $5ad1
    bpl L5ac1                                   // $5ad2
    lda screen+13*40+31                         // $5ad4
    jsr char_addr_fb                            // $5ad7
    lda screen+13*40+29                         // $5ada
    jsr char_addr_fd                            // $5add
    ldy #$07                                    // $5ae0
L5ae2:
    lda (zp_fb),y                               // $5ae2
    and char($41),y                             // $5ae4
    sta char($44),y                             // $5ae7
    lda (zp_fd),y                               // $5aea
    and char($41),y                             // $5aec
    sta char($45),y                             // $5aef
    dey                                         // $5af2
    bpl L5ae2                                   // $5af3
    lda #$42                                    // $5af5
    sta screen+13*40+7                          // $5af7
    lda #$43                                    // $5afa
    sta screen+13*40+9                          // $5afc
    lda #$44                                    // $5aff
    sta screen+13*40+31                         // $5b01
    lda #$45                                    // $5b04
    sta screen+13*40+29                         // $5b06
    rts                                         // $5b09
logo_corners_i:
    lda screen+9*40+7                           // $5b0a
    jsr char_addr_fb                            // $5b0d
    lda screen+9*40+9                           // $5b10
    jsr char_addr_fd                            // $5b13
    ldy #$07                                    // $5b16
L5b18:
    lda (zp_fb),y                               // $5b18
    sta zp_fa                                   // $5b1a
    lsr                                         // $5b1c
    ora zp_fa                                   // $5b1d
    eor #$ff                                    // $5b1f
    and char($3f),y                             // $5b21
    ora zp_fa                                   // $5b24
    sta char($46),y                             // $5b26
    lda (zp_fd),y                               // $5b29
    sta zp_fa                                   // $5b2b
    lsr                                         // $5b2d
    ora zp_fa                                   // $5b2e
    eor #$ff                                    // $5b30
    and char($3f),y                             // $5b32
    ora zp_fa                                   // $5b35
    sta char($47),y                             // $5b37
    dey                                         // $5b3a
    bpl L5b18                                   // $5b3b
    lda screen+9*40+31                          // $5b3d
    jsr char_addr_fb                            // $5b40
    lda screen+9*40+29                          // $5b43
    jsr char_addr_fd                            // $5b46
    ldy #$07                                    // $5b49
L5b4b:
    lda (zp_fb),y                               // $5b4b
    sta zp_fa                                   // $5b4d
    lsr                                         // $5b4f
    ora zp_fa                                   // $5b50
    eor #$ff                                    // $5b52
    and char($3f),y                             // $5b54
    ora zp_fa                                   // $5b57
    sta char($48),y                             // $5b59
    lda (zp_fd),y                               // $5b5c
    sta zp_fa                                   // $5b5e
    lsr                                         // $5b60
    ora zp_fa                                   // $5b61
    eor #$ff                                    // $5b63
    and char($3f),y                             // $5b65
    ora zp_fa                                   // $5b68
    sta char($49),y                             // $5b6a
    dey                                         // $5b6d
    bpl L5b4b                                   // $5b6e
    lda #$46                                    // $5b70
    sta screen+9*40+7                           // $5b72
    lda #$47                                    // $5b75
    sta screen+9*40+9                           // $5b77
    lda #$48                                    // $5b7a
    sta screen+9*40+31                          // $5b7c
    lda #$49                                    // $5b7f
    sta screen+9*40+29                          // $5b81
    rts                                         // $5b84
logo_pick_l_chars:
    ldx tilt_shift_y                            // $5b85
    lda logo_l_chars_1,x                        // $5b88
    sta screen+8*40+4                           // $5b8b
    jsr logo_shade_char                         // $5b8e
    sta screen+8*40+34                          // $5b91
    lda logo_l_chars_2,x                        // $5b94
    sta screen+8*40+5                           // $5b97
    jsr logo_shade_char                         // $5b9a
    sta screen+8*40+33                          // $5b9d
    lda logo_l_chars_3,x                        // $5ba0
    sta screen+8*40+12                          // $5ba3
    jsr logo_shade_char                         // $5ba6
    sta screen+8*40+26                          // $5ba9
    rts                                         // $5bac
logo_l_chars_1:
    .byte $00,$00,$00,$00,$00,$36,$38,$20,$20   // $5bad
logo_l_chars_2:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$37   // $5bb6
logo_l_chars_3:
    .byte $20,$20,$20,$20,$20,$3b,$3b,$3a,$3a   // $5bbf
logo_shade_l_1:
    lda screen+8*40+4                           // $5bc8
    jsr char_addr_fb                            // $5bcb
    lda screen+8*40+5                           // $5bce
    jsr char_addr_fd                            // $5bd1
    ldy #$07                                    // $5bd4
L5bd6:
    lda (zp_fb),y                               // $5bd6
    and char($40),y                             // $5bd8
    sta char($4a),y                             // $5bdb
    lda (zp_fb),y                               // $5bde
    sta zp_fa                                   // $5be0
    lsr                                         // $5be2
    ora zp_fa                                   // $5be3
    and char($3f),y                             // $5be5
    sta char($4c),y                             // $5be8
    lda (zp_fd),y                               // $5beb
    and char($40),y                             // $5bed
    sta char($4b),y                             // $5bf0
    lda (zp_fd),y                               // $5bf3
    sta zp_fa                                   // $5bf5
    lsr                                         // $5bf7
    ora zp_fa                                   // $5bf8
    and char($3f),y                             // $5bfa
    sta char($4d),y                             // $5bfd
    dey                                         // $5c00
    bpl L5bd6                                   // $5c01
    rts                                         // $5c03
logo_shade_l_2:
    lda screen+8*40+34                          // $5c04
    jsr char_addr_fb                            // $5c07
    lda screen+8*40+33                          // $5c0a
    jsr char_addr_fd                            // $5c0d
    ldy #$07                                    // $5c10
L5c12:
    lda (zp_fb),y                               // $5c12
    and char($40),y                             // $5c14
    sta char($4e),y                             // $5c17
    lda (zp_fb),y                               // $5c1a
    sta zp_fa                                   // $5c1c
    lsr                                         // $5c1e
    ora zp_fa                                   // $5c1f
    and char($3f),y                             // $5c21
    sta char($50),y                             // $5c24
    lda (zp_fd),y                               // $5c27
    and char($40),y                             // $5c29
    sta char($4f),y                             // $5c2c
    lda (zp_fd),y                               // $5c2f
    sta zp_fa                                   // $5c31
    lsr                                         // $5c33
    ora zp_fa                                   // $5c34
    and char($3f),y                             // $5c36
    sta char($51),y                             // $5c39
    dey                                         // $5c3c
    bpl L5c12                                   // $5c3d
    rts                                         // $5c3f
logo_shade_l_3:
    lda screen+8*40+12                          // $5c40
    jsr char_addr_fb                            // $5c43
    lda screen+8*40+26                          // $5c46
    jsr char_addr_fd                            // $5c49
    ldy #$07                                    // $5c4c
L5c4e:
    lda (zp_fb),y                               // $5c4e
    and char($40),y                             // $5c50
    sta char($52),y                             // $5c53
    lda (zp_fb),y                               // $5c56
    sta zp_fa                                   // $5c58
    lsr                                         // $5c5a
    ora zp_fa                                   // $5c5b
    and char($3f),y                             // $5c5d
    sta char($53),y                             // $5c60
    lda (zp_fd),y                               // $5c63
    and char($40),y                             // $5c65
    sta char($54),y                             // $5c68
    lda (zp_fd),y                               // $5c6b
    sta zp_fa                                   // $5c6d
    lsr                                         // $5c6f
    ora zp_fa                                   // $5c70
    and char($3f),y                             // $5c72
    sta char($55),y                             // $5c75
    dey                                         // $5c78
    bpl L5c4e                                   // $5c79
    rts                                         // $5c7b
logo_part_5c7c:
    ldx tilt_shift_y                            // $5c7c
    cpx #$02                                    // $5c7f
    bcs L5c97                                   // $5c81
    lda #$36                                    // $5c83
    sta screen+8*40+4                           // $5c85
    lda #$3b                                    // $5c88
    sta screen+8*40+12                          // $5c8a
    lda #$39                                    // $5c8d
    sta screen+8*40+34                          // $5c8f
    lda #$38                                    // $5c92
    sta screen+8*40+26                          // $5c94
L5c97:
    rts                                         // $5c97
logo_part_5c98:
    lda tilt_shift_y                            // $5c98
    ldx #$00                                    // $5c9b
    cmp #$03                                    // $5c9d
    bcc L5ca9                                   // $5c9f
    ldx #$03                                    // $5ca1
    cmp #$06                                    // $5ca3
    bcc L5ca9                                   // $5ca5
    ldx #$06                                    // $5ca7
L5ca9:
    ldy #$00                                    // $5ca9
L5cab:
    lda D5cbc,x                                 // $5cab
    sta screen+9*40+15,y                        // $5cae
    inx                                         // $5cb1
    tya                                         // $5cb2
    clc                                         // $5cb3
    adc #$28                                    // $5cb4
    tay                                         // $5cb6
    cpy #$78                                    // $5cb7
    bcc L5cab                                   // $5cb9
    rts                                         // $5cbb
D5cbc:
    .byte $00,$36,$36,$00,$00,$00,$36,$00,$00   // $5cbc
logo_part_5cc5:
    lda tilt_shift_y                            // $5cc5
    ldx #$00                                    // $5cc8
    cmp #$06                                    // $5cca
    bcc L5cd0                                   // $5ccc
    ldx #$36                                    // $5cce
L5cd0:
    stx screen+8*40+14                          // $5cd0
    ldx #$00                                    // $5cd3
    cmp #$03                                    // $5cd5
    bcs L5cdb                                   // $5cd7
    ldx #$36                                    // $5cd9
L5cdb:
    stx screen+12*40+14                         // $5cdb
    rts                                         // $5cde
logo_part_5cdf:
    lda screen+9*40+15                          // $5cdf
    jsr char_addr_fb                            // $5ce2
    lda screen+11*40+15                         // $5ce5
    jsr char_addr_fd                            // $5ce8
    ldy #$07                                    // $5ceb
L5ced:
    lda (zp_fb),y                               // $5ced
    sta zp_fa                                   // $5cef
    lsr                                         // $5cf1
    ora zp_fa                                   // $5cf2
    eor #$ff                                    // $5cf4
    and char($3f),y                             // $5cf6
    ora zp_fa                                   // $5cf9
    sta char($56),y                             // $5cfb
    lda (zp_fd),y                               // $5cfe
    sta zp_fa                                   // $5d00
    lsr                                         // $5d02
    ora zp_fa                                   // $5d03
    eor #$ff                                    // $5d05
    and char($3e),y                             // $5d07
    ora zp_fa                                   // $5d0a
    sta char($57),y                             // $5d0c
    dey                                         // $5d0f
    bpl L5ced                                   // $5d10
    lda #$56                                    // $5d12
    sta screen+9*40+15                          // $5d14
    lda #$57                                    // $5d17
    sta screen+11*40+15                         // $5d19
    rts                                         // $5d1c
logo_part_5d1d:
    lda screen+8*40+14                          // $5d1d
    jsr char_addr_fb                            // $5d20
    lda screen+12*40+14                         // $5d23
    jsr char_addr_fd                            // $5d26
    ldy #$07                                    // $5d29
L5d2b:
    lda (zp_fb),y                               // $5d2b
    and char($40),y                             // $5d2d
    sta char($58),y                             // $5d30
    lda (zp_fb),y                               // $5d33
    sta zp_ff                                   // $5d35
    lsr                                         // $5d37
    ora zp_ff                                   // $5d38
    and char($3f),y                             // $5d3a
    sta char($59),y                             // $5d3d
    lda (zp_fd),y                               // $5d40
    and char($41),y                             // $5d42
    sta char($5a),y                             // $5d45
    lda (zp_fd),y                               // $5d48
    sta zp_ff                                   // $5d4a
    lsr                                         // $5d4c
    ora zp_ff                                   // $5d4d
    and char($3e),y                             // $5d4f
    sta char($5b),y                             // $5d52
    dey                                         // $5d55
    bpl L5d2b                                   // $5d56
    rts                                         // $5d58
logo_part_5d59:
    lda tilt_shift_y                            // $5d59
    ldx #$00                                    // $5d5c
    cmp #$03                                    // $5d5e
    bcc L5d6a                                   // $5d60
    ldx #$05                                    // $5d62
    cmp #$06                                    // $5d64
    bcc L5d6a                                   // $5d66
    ldx #$0a                                    // $5d68
L5d6a:
    ldy #$00                                    // $5d6a
L5d6c:
    lda D5d7d,x                                 // $5d6c
    sta screen+7*40+21,y                        // $5d6f
    inx                                         // $5d72
    tya                                         // $5d73
    clc                                         // $5d74
    adc #$28                                    // $5d75
    tay                                         // $5d77
    cpy #$c8                                    // $5d78
    bcc L5d6c                                   // $5d7a
    rts                                         // $5d7c
D5d7d:
    .byte $00,$00,$00,$39,$39,$00,$00,$00,$00,$00,$39,$39,$39,$00,$00  // $5d7d
logo_part_5d8c:
    lda screen+7*40+21                          // $5d8c
    jsr char_addr_fb                            // $5d8f
    lda screen+11*40+21                         // $5d92
    jsr char_addr_fd                            // $5d95
    ldy #$07                                    // $5d98
L5d9a:
    lda (zp_fb),y                               // $5d9a
    and char($40),y                             // $5d9c
    sta char($5c),y                             // $5d9f
    lda (zp_fd),y                               // $5da2
    sta zp_ff                                   // $5da4
    lsr                                         // $5da6
    ora zp_ff                                   // $5da7
    eor #$ff                                    // $5da9
    and char($3e),y                             // $5dab
    ora zp_ff                                   // $5dae
    sta char($5d),y                             // $5db0
    dey                                         // $5db3
    bpl L5d9a                                   // $5db4
    lda #$5c                                    // $5db6
    sta screen+7*40+21                          // $5db8
    lda #$5d                                    // $5dbb
    sta screen+11*40+21                         // $5dbd
    rts                                         // $5dc0
logo_pick_t_char:
    ldx tilt_shift_y                            // $5dc1
    lda logo_t_chars,x                          // $5dc4
    sta screen+12*40+27                         // $5dc7
    rts                                         // $5dca
logo_t_chars:
    .byte $3a,$3a,$39,$39,$00,$00,$00,$00,$00   // $5dcb
logo_shade_t:
    lda screen+12*40+27                         // $5dd4
    jsr char_addr_fb                            // $5dd7
    ldy #$07                                    // $5dda
L5ddc:
    lda (zp_fb),y                               // $5ddc
    and char($41),y                             // $5dde
    sta char($5e),y                             // $5de1
    lda (zp_fb),y                               // $5de4
    sta zp_ff                                   // $5de6
    lsr                                         // $5de8
    ora zp_ff                                   // $5de9
    and char($3e),y                             // $5deb
    sta char($5f),y                             // $5dee
    dey                                         // $5df1
    bpl L5ddc                                   // $5df2
    rts                                         // $5df4
logo_t_char_low:
    ldx tilt_shift_y                            // $5df5
    cpx #$07                                    // $5df8
    bcc L5e01                                   // $5dfa
    lda #$39                                    // $5dfc
    sta screen+12*40+27                         // $5dfe
L5e01:
    rts                                         // $5e01
title_scroll_step:
    dec title_fine_scroll                       // $5e02
    bpl L5e19                                   // $5e05
    lda #$07                                    // $5e07
    sta title_fine_scroll                       // $5e09
    ldx title_text_pos                          // $5e0c
    inx                                         // $5e0f
    cpx #$74                                    // $5e10
    bcc L5e16                                   // $5e12
    ldx #$00                                    // $5e14
L5e16:
    stx title_text_pos                          // $5e16
L5e19:
    rts                                         // $5e19

// ----------------------------------------------------------------------------
// Scroll the copyright / instructions text along the bottom rows
// ----------------------------------------------------------------------------
title_scroll_text:
    lda #$07                                    // $5e1a
    sta zp_fc                                   // $5e1c
    sta zp_fe                                   // $5e1e
    ldx #$70                                    // $5e20
    ldy #$98                                    // $5e22
    lda fine_scroll_y                           // $5e24
    cmp #$03                                    // $5e27
    bne L5e32                                   // $5e29
    stx zp_fd                                   // $5e2b
    sty zp_fb                                   // $5e2d
    jmp L5e36                                   // $5e2f
L5e32:
    stx zp_fb                                   // $5e32
    sty zp_fd                                   // $5e34
L5e36:
    ldx title_text_pos                          // $5e36
    ldy #$27                                    // $5e39
L5e3b:
    lda #$20                                    // $5e3b
    sta (zp_fd),y                               // $5e3d
    lda title_text,x                            // $5e3f
    cmp #$d1                                    // $5e42
    bne L5e4a                                   // $5e44
    lda #$51                                    // $5e46
    bne L5e4c                                   // $5e48
L5e4a:
    and #$3f                                    // $5e4a
L5e4c:
    sta (zp_fb),y                               // $5e4c
    lda #$00                                    // $5e4e
    bcs L5e60                                   // $5e50
    lda #$01                                    // $5e52
    cpx #$38                                    // $5e54
    bcs L5e60                                   // $5e56
    lda #$07                                    // $5e58
    cpx #$1d                                    // $5e5a
    bcs L5e60                                   // $5e5c
    lda #$07                                    // $5e5e
L5e60:
    sta COLOR_RAM+22*40+0,y                     // $5e60
    sta COLOR_RAM+23*40+0,y                     // $5e63
    dex                                         // $5e66
    bpl L5e6b                                   // $5e67
    ldx #$73                                    // $5e69
L5e6b:
    dey                                         // $5e6b
    bpl L5e3b                                   // $5e6c
    rts                                         // $5e6e
title_text:
    .byte $d1,$20,$43,$4f,$50,$59,$52,$49,$47,$48,$54,$20,$43,$4f,$44,$45  // $5e6f  ". ......... ...."
    .byte $4d,$41,$53,$54,$45,$52,$53,$20,$31,$39,$39,$30,$20,$d1,$20,$50  // $5e7f  "....... 1990 . ."
    .byte $52,$4f,$47,$52,$41,$4d,$20,$42,$59,$20,$53,$54,$45,$56,$45,$20  // $5e8f  "...... .. ..... "
    .byte $57,$41,$4c,$54,$45,$52,$53,$20,$d1,$20,$50,$52,$45,$53,$53,$20  // $5e9f  "....... . ..... "
    .byte $46,$49,$52,$45,$20,$54,$4f,$20,$50,$4c,$41,$59,$20,$d1,$20,$50  // $5eaf  ".... .. .... . ."
    .byte $52,$45,$53,$53,$20,$46,$37,$20,$46,$4f,$52,$20,$44,$45,$4d,$4f  // $5ebf  ".... .7 ... ...."
    .byte $20,$4d,$4f,$44,$45,$20,$d1,$20,$46,$31,$20,$54,$4f,$20,$52,$45  // $5ecf  " .... . .1 .. .."
    .byte $53,$45,$54,$20                       // $5edf  "... "

// ----------------------------------------------------------------------------
// M key: music on / off. Also starts the title tune when the logo is level
// ----------------------------------------------------------------------------
title_music_key:
    lda #$ef                                    // $5ee3
    sta CIA1_PRA                                // $5ee5
    lda CIA1_PRB                                // $5ee8
    cmp #$ef                                    // $5eeb
    bne L5f36                                   // $5eed
    lda m_key_up                                // $5eef
    beq L5f3b                                   // $5ef2
    lda #$00                                    // $5ef4
    sta m_key_up                                // $5ef6
    sta music_playing                           // $5ef9
    sta title_idle                              // $5efc
    sta title_idle+1                            // $5eff
    lda #$ff                                    // $5f02
    sta music_command                           // $5f04
    lda cefa_flag                               // $5f07
    eor #$01                                    // $5f0a
    and #$01                                    // $5f0c
    sta cefa_flag                               // $5f0e
    jsr show_music_glyph                        // $5f11
    jsr sid_off                                 // $5f14
    lda #$0f                                    // $5f17
    sta SID_MODE_VOL                            // $5f19
    lda #$00                                    // $5f1c
    sta SID_RES_FILT                            // $5f1e
    lda #$06                                    // $5f21
    sta SID_V1_AD                               // $5f23
    lda #$32                                    // $5f26
    sta SID_V1_FREQ_HI                          // $5f28
    sta SID_V1_FREQ_LO                          // $5f2b
    lda #$21                                    // $5f2e
    sta SID_V1_CTRL                             // $5f30
    jmp L5f3b                                   // $5f33
L5f36:
    lda #$01                                    // $5f36
    sta m_key_up                                // $5f38
L5f3b:
    lda cefa_flag                               // $5f3b
    beq L5f5d                                   // $5f3e
    lda music_playing                           // $5f40
    bne L5f5d                                   // $5f43
    lda tilt_angle_y                            // $5f45
    cmp #$03                                    // $5f48
    beq L5f50                                   // $5f4a
    cmp #$fc                                    // $5f4c
    bne L5f5d                                   // $5f4e
L5f50:
    lda #$01                                    // $5f50
    sta music_command                           // $5f52
    lda #$00                                    // $5f55
    sta title_idle                              // $5f57
    sta title_idle+1                            // $5f5a
L5f5d:
    jsr music_play                              // $5f5d
    rts                                         // $5f60

// ----------------------------------------------------------------------------
// Level start jingle (tune 3), only when the music is on
// ----------------------------------------------------------------------------
level_jingle:
    lda demo_mode                               // $5f61
    bne L5fa1                                   // $5f64
    lda cefa_flag                               // $5f66
    beq L5fa1                                   // $5f69
    lda #$01                                    // $5f6b
    sta roll_sound_off                          // $5f6d
    lda #$80                                    // $5f70
    sta jingle_timer                            // $5f72
    lda #$03                                    // $5f75
    sta music_command                           // $5f77
L5f7a:
    lda #$01                                    // $5f7a
    jsr wait_frames                             // $5f7c
    jsr music_play                              // $5f7f
    lda #$04                                    // $5f82
    sta SID_MODE_VOL                            // $5f84
    dec jingle_timer                            // $5f87
    bne L5f7a                                   // $5f8a
    jsr sid_off                                 // $5f8c
    lda #$1f                                    // $5f8f
    sta SID_MODE_VOL                            // $5f91
    lda #$44                                    // $5f94
    sta SID_RES_FILT                            // $5f96
    lda #$00                                    // $5f99
    sta roll_sound_off                          // $5f9b
    jmp L5fa6                                   // $5f9e
L5fa1:
    lda #$19                                    // $5fa1
    jsr wait_frames                             // $5fa3
L5fa6:
    rts                                         // $5fa6

// ----------------------------------------------------------------------------
// Game over jingle (tune 4) - disabled: both branches skip it
// ----------------------------------------------------------------------------
game_over_jingle:
    lda game_over                               // $5fa7
    beq L5fe7                                   // $5faa
    bne L5fe7                                   // $5fac  always: the jingle below is never played
    jsr show_power_off                          // $5fae
    lda #$01                                    // $5fb1
    sta roll_sound_off                          // $5fb3
    lda #$80                                    // $5fb6
    sta jingle_timer                            // $5fb8
    lda #$04                                    // $5fbb
    sta music_command                           // $5fbd
L5fc0:
    lda #$01                                    // $5fc0
    jsr wait_frames                             // $5fc2
    jsr music_play                              // $5fc5
    lda #$04                                    // $5fc8
    sta SID_MODE_VOL                            // $5fca
    dec jingle_timer                            // $5fcd
    bne L5fc0                                   // $5fd0
    jsr sid_off                                 // $5fd2
    lda #$1f                                    // $5fd5
    sta SID_MODE_VOL                            // $5fd7
    lda #$44                                    // $5fda
    sta SID_RES_FILT                            // $5fdc
    lda #$00                                    // $5fdf
    sta roll_sound_off                          // $5fe1
    jmp L5fec                                   // $5fe4
L5fe7:
    lda #$14                                    // $5fe7
    jsr wait_frames                             // $5fe9
L5fec:
    rts                                         // $5fec

// ----------------------------------------------------------------------------
// Raster interrupt (CINV). Twelve raster lines (irq_lines) per frame:
// step 0 (line $2A) runs the frame work, steps 1-11 split the colours and
// set the fine scroll for the board. CIA interrupts go to the KERNAL.
// ----------------------------------------------------------------------------
irq_handler:
    lda VIC_IRQ_STATUS                          // $5fed  raster interrupt?
    and #$01                                    // $5ff0
    bne irq_raster                              // $5ff2
    jmp KERNAL_IRQ                              // $5ff4  not the raster: KERNAL IRQ (keyboard, clock)
irq_raster:
    sta VIC_IRQ_STATUS                          // $5ff7  acknowledge
    ldx irq_step                                // $5ffa  next step of the chain (0-11)
    inx                                         // $5ffd
    cpx #$0c                                    // $5ffe
    bcc L6004                                   // $6000
    ldx #$00                                    // $6002
L6004:
    stx irq_step                                // $6004
    lda irq_lines,x                             // $6007  raster line of the next interrupt
    sta VIC_RASTER                              // $600a
    txa                                         // $600d
    beq irq_top                                 // $600e
    jsr irq_split                               // $6010  steps 1-11: colour splits
    jmp KERNAL_IRQ_EXIT                         // $6013

// ----------------------------------------------------------------------------
// Step 0, top of the screen: frame counter for wait_frames, F1 = restart
// (not during the title / a jingle), then the game or title frame work
// ----------------------------------------------------------------------------
irq_top:
    lda wait_counter                            // $6016  step 0: count down wait_frames
    beq L601e                                   // $6019
    dec wait_counter                            // $601b
L601e:
    lda #$ff                                    // $601e  F1 pressed?
    sta CIA1_DDRA                               // $6020
    lda #$fe                                    // $6023
    sta CIA1_PRA                                // $6025
    lda CIA1_PRB                                // $6028
    cmp #$ef                                    // $602b
    bne irq_frame_work                          // $602d
    lda title_mode                              // $602f
    ora no_restart                              // $6032
    bne irq_frame_work                          // $6035
    ldx #$fe                                    // $6037  F1: restart the game
    sei                                         // $6039
    txs                                         // $603a
    cld                                         // $603b
    lda #$01                                    // $603c
    sta CIA1_CRA                                // $603e
    jmp main_loop                               // $6041
irq_frame_work:
    ldx #$07                                    // $6044  save $F8-$FF: the frame work may interrupt code using them
L6046:
    lda zp_f8,x                                 // $6046
    pha                                         // $6048
    dex                                         // $6049
    bpl L6046                                   // $604a
    lda #$03                                    // $604c  screen on/off
    ora screen_on                               // $604e
    sta VIC_CTRL1                               // $6051
    lda #$c8                                    // $6054  40 columns, no fine scroll (status line)
    sta VIC_CTRL2                               // $6056
    lda #$18                                    // $6059  screen $0400, font $2000
    sta VIC_MEMSETUP                            // $605b
    lda title_mode                              // $605e
    beq L6069                                   // $6061
    jsr title_irq                               // $6063  title screen
    jmp irq_restore                             // $6066
L6069:
    jsr frame_logic                             // $6069  playing
irq_restore:
    ldx #$00                                    // $606c
L606e:
    pla                                         // $606e
    sta zp_f8,x                                 // $606f
    inx                                         // $6071
    cpx #$08                                    // $6072
    bne L606e                                   // $6074
    jmp KERNAL_IRQ_EXIT                         // $6076

// ----------------------------------------------------------------------------
// Raster steps 1-11: border / background colour bands for the status
// line and the board frame, and the hardware fine scroll of the maze
// ($D011 / $D016 = cf0f / cf0e) that makes it shift with the tilt
// ----------------------------------------------------------------------------
irq_split:
    cmp #$01                                    // $6079
    bne L608b                                   // $607b
    ldx #$05                                    // $607d
L607f:
    dex                                         // $607f
    bpl L607f                                   // $6080
    lda #$08                                    // $6082
    sta VIC_BORDER                              // $6084
    sta VIC_BG0                                 // $6087
    rts                                         // $608a
L608b:
    cmp #$02                                    // $608b
    bne L609d                                   // $608d
    ldx #$04                                    // $608f
L6091:
    dex                                         // $6091
    bpl L6091                                   // $6092
    lda #$09                                    // $6094
    sta VIC_BORDER                              // $6096
    sta VIC_BG0                                 // $6099
    rts                                         // $609c
L609d:
    cmp #$03                                    // $609d
    bne L60d4                                   // $609f
    ldx #$03                                    // $60a1
L60a3:
    dex                                         // $60a3
    bpl L60a3                                   // $60a4
    lda fine_scroll_y                           // $60a6
    ora screen_on                               // $60a9
    tay                                         // $60ac
    lda fine_scroll_x                           // $60ad
    ora #$d0                                    // $60b0
    ldx #$08                                    // $60b2
    stx VIC_BG0                                 // $60b4
    stx VIC_BORDER                              // $60b7
    sty VIC_CTRL1                               // $60ba
    ldx #$d0                                    // $60bd
    lda fine_scroll_x                           // $60bf
    ora slide_state                             // $60c2
    ora title_mode                              // $60c5
    bne L60cc                                   // $60c8
    ldx #$d8                                    // $60ca
L60cc:
    txa                                         // $60cc
    ora fine_scroll_x                           // $60cd
    sta VIC_CTRL2                               // $60d0
    rts                                         // $60d3
L60d4:
    cmp #$04                                    // $60d4
    bne L60f4                                   // $60d6
    ldx #$04                                    // $60d8
    lda fine_scroll_y                           // $60da
    bne L60e2                                   // $60dd
    sec                                         // $60df
    bcs L60e8                                   // $60e0
L60e2:
    cmp #$06                                    // $60e2
    bcs L60e8                                   // $60e4
    ldx #$0c                                    // $60e6
L60e8:
    dex                                         // $60e8
    bpl L60e8                                   // $60e9
    lda #$00                                    // $60eb
    sta VIC_BORDER                              // $60ed
    sta VIC_BG0                                 // $60f0
    rts                                         // $60f3
L60f4:
    cmp #$05                                    // $60f4
    bne L6105                                   // $60f6
    lda #$00                                    // $60f8
    ldx title_mode                              // $60fa
    bne L6101                                   // $60fd
    lda #$09                                    // $60ff
L6101:
    sta VIC_BG0                                 // $6101
    rts                                         // $6104
L6105:
    cmp #$06                                    // $6105
    bne L612a                                   // $6107
    ldx demo_mode                               // $6109
    beq L6129                                   // $610c
    jsr place_hole_sprites                      // $610e
    lda VIC_SPR_PRIORITY                        // $6111
    ora #$80                                    // $6114
    sta VIC_SPR_PRIORITY                        // $6116
    lda VIC_SPR_MULTICOLOR                      // $6119
    and #$7f                                    // $611c
    sta VIC_SPR_MULTICOLOR                      // $611e
    lda #$00                                    // $6121
    sta VIC_SPR_EXPAND_Y                        // $6123
    sta VIC_SPR_EXPAND_X                        // $6126
L6129:
    rts                                         // $6129
L612a:
    cmp #$07                                    // $612a
    bne L614b                                   // $612c
    ldx title_mode                              // $612e
    beq L614a                                   // $6131
    ldx #$2b                                    // $6133
L6135:
    dex                                         // $6135
    bne L6135                                   // $6136
    ldx #$15                                    // $6138
    ldy #$1b                                    // $613a
    lda #$c0                                    // $613c
    ora title_fine_scroll                       // $613e
    stx VIC_MEMSETUP                            // $6141
    sty VIC_CTRL1                               // $6144
    sta VIC_CTRL2                               // $6147
L614a:
    rts                                         // $614a
L614b:
    cmp #$08                                    // $614b
    bne L6162                                   // $614d
    ldx title_mode                              // $614f
    beq L6161                                   // $6152
    ldx #$02                                    // $6154
L6156:
    dex                                         // $6156
    bne L6156                                   // $6157
    lda #$08                                    // $6159
    sta VIC_BORDER                              // $615b
    sta VIC_BG0                                 // $615e
L6161:
    rts                                         // $6161
L6162:
    cmp #$09                                    // $6162
    bne L6179                                   // $6164
    ldx title_mode                              // $6166
    beq L6178                                   // $6169
    ldx #$0a                                    // $616b
L616d:
    dex                                         // $616d
    bne L616d                                   // $616e
    lda #$09                                    // $6170
    sta VIC_BORDER                              // $6172
    sta VIC_BG0                                 // $6175
L6178:
    rts                                         // $6178
L6179:
    cmp #$0a                                    // $6179
    bne L6192                                   // $617b
    lda #$00                                    // $617d
    ldx title_mode                              // $617f
    beq L618b                                   // $6182
    ldx #$08                                    // $6184
L6186:
    dex                                         // $6186
    bne L6186                                   // $6187
    lda #$08                                    // $6189
L618b:
    sta VIC_BORDER                              // $618b
    sta VIC_BG0                                 // $618e
    rts                                         // $6191
L6192:
    cmp #$0b                                    // $6192
    bne L61a8                                   // $6194
    ldx title_mode                              // $6196
    beq L61a8                                   // $6199
    ldx #$08                                    // $619b
L619d:
    dex                                         // $619d
    bne L619d                                   // $619e
    lda #$0c                                    // $61a0
    sta VIC_BORDER                              // $61a2
    sta VIC_BG0                                 // $61a5
L61a8:
    rts                                         // $61a8
irq_lines:
    .byte $2a,$31,$39,$3e,$53,$69,$c7,$e1,$e7,$f0,$f6,$fa,$ff,$ff  // $61a9

// ----------------------------------------------------------------------------
// Frame work while playing (in the raster IRQ): controls (or the demo
// recording), ball lost / in the hole, then all per-frame updates
// ----------------------------------------------------------------------------
frame_logic:
    lda dev_mode                                // $61b7  developer mode: show the developer maze
    beq L61bf                                   // $61ba
    jsr dev_mode_screen                         // $61bc
L61bf:
    lda demo_mode                               // $61bf
    bne L61d1                                   // $61c2
    lda controls_enabled                        // $61c4
    beq L61d1                                   // $61c7
    jsr read_controls                           // $61c9  not in demo mode: read the joystick
    and #$1f                                    // $61cc
    sta controls                                // $61ce
L61d1:
    jsr demo_play                               // $61d1  demo mode: controls from the recording
    lda controls                                // $61d4  keep a copy
    sta controls_copy                           // $61d7
    lda ball_lost                               // $61da  ball already in the hole / lost: no checks
    ora ball_in_hole                            // $61dd
    bne frame_update                            // $61e0
    lda VIC_SPR_BG_COLL                         // $61e2  ball sprite (3) touches foreground pixels (a wall or a closed gate)
    and #$08                                    // $61e5
    beq L6225                                   // $61e7
    lda #$01                                    // $61e9  ball lost: stop everything
    sta ball_lost                               // $61eb
    lda #$00                                    // $61ee
    sta ball_vx                                 // $61f0
    sta ball_vy                                 // $61f3
    sta controls_enabled                        // $61f6
    sta tilt_enabled                            // $61f9
    sta fire_enabled                            // $61fc
    sta steering_on                             // $61ff
    sta marking_on                              // $6202
    sta backup_allowed                          // $6205
    lda #$1f                                    // $6208  controls: nothing pressed
    sta controls                                // $620a
    lda backup_power                            // $620d  that was the backup power: game over
    beq L6222                                   // $6210
    lda #$00                                    // $6212
    sta backup_power                            // $6214
    sta SID_V2_CTRL                             // $6217
    lda #$01                                    // $621a
    sta game_over                               // $621c
    jsr show_power_off                          // $621f
L6222:
    jmp frame_update                            // $6222
L6225:
    jsr ball_over_hole                          // $6225  ball in the exit hole?
    bcc frame_update                            // $6228
    lda #$01                                    // $622a  ball in the hole: stop steering, no more power drain
    sta ball_in_hole                            // $622c
    lda #$00                                    // $622f
    sta controls_enabled                        // $6231
    sta tilt_enabled                            // $6234
    sta steering_on                             // $6237
    sta count_marks_delay                       // $623a
    sta power_drain_on                          // $623d
    lda #$1f                                    // $6240
    sta controls                                // $6242
    lda backup_power                            // $6245  was on backup power: back to a normal bar
    beq frame_update                            // $6248
    lda #$00                                    // $624a
    sta backup_power                            // $624c
    sta SID_V2_CTRL                             // $624f
    jsr show_backup                             // $6252
frame_update:
    dec scroll_pause                            // $6255  counter for the slow status line effects
    bpl L625f                                   // $6258
    lda #$05                                    // $625a
    sta scroll_pause                            // $625c
L625f:
    lda bg2_restore_timer                       // $625f  restore multicolour 2 after a flash
    beq L626e                                   // $6262
    dec bg2_restore_timer                       // $6264
    bne L626e                                   // $6267
    lda #$01                                    // $6269
    sta VIC_BG2                                 // $626b
L626e:
    jsr flash_backup                            // $626e  status line effects
    jsr refill_power                            // $6271
    jsr drain_power                             // $6274
    jsr scroll_score                            // $6277
    jsr scroll_hiscore                          // $627a
    jsr scroll_level                            // $627d
    jsr level_sign_spin                         // $6280  level sign
    jsr flash_lost                              // $6283  flash after a lost ball
    jsr steer_ball                              // $6286  ball physics
    jsr move_ball                               // $6289
    lda tilt_enabled                            // $628c  tilt: angles, sounds, ball sprite
    beq L62a0                                   // $628f
    jsr ease_tilt                               // $6291
    jsr tilt_clunk_sound                        // $6294
    jsr diagonal_sound                          // $6297
    jsr pick_ball_frame                         // $629a
    jsr place_ball_shadow                       // $629d
L62a0:
    lda roll_sound_off                          // $62a0
    bne L62a8                                   // $62a3
    jsr roll_sound                              // $62a5
L62a8:
    jsr bonus_count_sound                       // $62a8  bonus count sound
    lda marking_on                              // $62ab  floor marks under the ball
    beq L62b3                                   // $62ae
    jsr mark_floor                              // $62b0
L62b3:
    lda steering_on                             // $62b3  shine moves with the ball
    ora ball_waiting                            // $62b6
    beq L62be                                   // $62b9
    jsr move_shine                              // $62bb
L62be:
    jsr appear_sound_step                       // $62be
    lda ball_waiting                            // $62c1
    beq L62c9                                   // $62c4
    jsr update_shading                          // $62c6
L62c9:
    lda fire_enabled                            // $62c9  fire opens the gates
    beq L62d1                                   // $62cc
    jsr fire_gates                              // $62ce
L62d1:
    lda demo_mode                               // $62d1  demo: joystick sprite
    beq L62d9                                   // $62d4
    jsr demo_joystick_sprite                    // $62d6
L62d9:
    ldx demo_mode                               // $62d9  exit hole sprites
    bne L62e1                                   // $62dc
    jsr place_hole_sprites                      // $62de
L62e1:
    jsr slide_scroll                            // $62e1  maze slide
    jsr count_marks                             // $62e4  end of level: count the marks
    jsr gate_hit_anim                           // $62e7  gate / bumper animations
    jsr bumper_hit_anim                         // $62ea
    jsr two_tone_sound                          // $62ed  two-tone sound
    lda level_sign_on                           // $62f0
    bne L6318                                   // $62f3
    lda ball_x                                  // $62f5  ball sprites 2 and 3 at the ball position
    sta VIC_SPR3_X                              // $62f8
    sta VIC_SPR2_X                              // $62fb
    lda ball_y                                  // $62fe
    sta VIC_SPR3_Y                              // $6301
    sta VIC_SPR2_Y                              // $6304
    lda VIC_SPR_X_MSB                           // $6307
    ldx ball_x_hi                               // $630a
    beq L6313                                   // $630d
    ora #$0c                                    // $630f
    bne L6315                                   // $6311
L6313:
    and #$f3                                    // $6313
L6315:
    sta VIC_SPR_X_MSB                           // $6315
L6318:
    lda dev_mode                                // $6318
    beq L6320                                   // $631b
    jsr update_tilt_graphics                    // $631d
L6320:
    rts                                         // $6320

// ----------------------------------------------------------------------------
// Tilt graphics: when the perspective shift changed, rebuild every
// character that depends on it (walls, frame, corners, junctions, hole)
// ----------------------------------------------------------------------------
update_tilt_graphics:
    jsr update_edge_highlight                   // $6321  light the edges the board leans on
    lda tilt_level_x                            // $6324  perspective shift = tilt level
    sta tilt_shift_x                            // $6327
    lda tilt_level_y                            // $632a
    sta tilt_shift_y                            // $632d
    lda tilt_shift_x                            // $6330  unchanged: nothing to rebuild
    cmp tilt_shift_x_old                        // $6333
    bne L6343                                   // $6336
    lda tilt_shift_y                            // $6338
    cmp tilt_shift_y_old                        // $633b
    bne L6343                                   // $633e
    jmp update_tilt_done                        // $6340
L6343:
    ldx tilt_shift_x                            // $6343
    stx zp_fb                                   // $6346
    ldx tilt_shift_y                            // $6348
    stx zp_fc                                   // $634b
    jsr build_wall_chars                        // $634d
    clc                                         // $6350
    jsr edge_highlight_v                        // $6351
    clc                                         // $6354
    jsr edge_highlight_h                        // $6355
    jsr build_chars_2508                        // $6358
    jsr draw_frame_top                          // $635b
    jsr frame_flash_left                        // $635e
    jsr draw_frame_left                         // $6361
    jsr frame_flash_top                         // $6364
    jsr draw_frame_right                        // $6367
    jsr frame_flash_right                       // $636a
    jsr draw_frame_bottom                       // $636d
    jsr frame_flash_bottom                      // $6370
    jsr build_frame_corners                     // $6373
    jsr frame_flash_vertical                    // $6376
    jsr frame_flash_horizontal                  // $6379
    ldx tilt_shift_x                            // $637c
    stx zp_fb                                   // $637f
    ldx tilt_shift_y                            // $6381
    stx zp_fc                                   // $6384
    jsr build_corner_chars                      // $6386
    jsr build_corner_chars2                     // $6389
    jsr build_corner_chars3                     // $638c
    jsr build_chars_2420                        // $638f
    jsr build_junction_chars                    // $6392
    jsr build_junction_chars2                   // $6395
    jsr build_junction_chars3                   // $6398
    jsr build_chars_24c0                        // $639b
    jsr build_hole_chars                        // $639e
    jsr build_hole_chars2                       // $63a1
    jsr pick_hole_sprite                        // $63a4
    jsr mask_hole_sprite                        // $63a7  hole sprite masked to the tilt
    lda #$01                                    // $63aa  ball sprite needs masking again
    sta ball_frame_changed                      // $63ac
update_tilt_done:
    ldx tilt_shift_x                            // $63af
    stx tilt_shift_x_old                        // $63b2
    ldx tilt_shift_y                            // $63b5
    stx tilt_shift_y_old                        // $63b8
    lda steering_on                             // $63bb
    ora ball_waiting                            // $63be
    beq L63d0                                   // $63c1
    lda ball_frame_changed                      // $63c3
    beq L63d0                                   // $63c6
    lda #$00                                    // $63c8
    sta ball_frame_changed                      // $63ca
    jsr mask_ball_sprite                        // $63cd
L63d0:
    rts                                         // $63d0

// ----------------------------------------------------------------------------
// Level sign: the spinning "LEVEL" sprites (0, 1, 4, 5) between levels
// ----------------------------------------------------------------------------
init_level_sign:
    lda VIC_SPR_ENABLE                          // $63d1
    and #$cc                                    // $63d4
    sta VIC_SPR_ENABLE                          // $63d6
    lda VIC_SPR_PRIORITY                        // $63d9
    and #$cc                                    // $63dc
    sta VIC_SPR_PRIORITY                        // $63de
    lda #$00                                    // $63e1
    sta tilt_enabled                            // $63e3
    sta fire_enabled                            // $63e6
    jsr sid_off                                 // $63e9
    lda #$00                                    // $63ec
    sta sign_spin_speed                         // $63ee
    lda #$50                                    // $63f1
    sta sign_spin                               // $63f3
    lda #$01                                    // $63f6
    sta level_sign_on                           // $63f8
    lda #$80                                    // $63fb
    sta SID_V1_SR                               // $63fd
    lda #$04                                    // $6400
    sta SID_V1_PW_HI                            // $6402
    lda #$41                                    // $6405
    sta SID_V1_CTRL                             // $6407
    lda #$f0                                    // $640a
    sta SID_V2_SR                               // $640c
    lda #$11                                    // $640f
    sta SID_V2_CTRL                             // $6411
    lda #$07                                    // $6414
    sta sign_x_left                             // $6416
    lda #$4f                                    // $6419
    sta sign_x_right                            // $641b
    lda #$d6                                    // $641e
    sta sign_y                                  // $6420
    lda VIC_SPR_X_MSB                           // $6423
    and #$ee                                    // $6426
    ora #$22                                    // $6428
    sta VIC_SPR_X_MSB                           // $642a
    lda #$db                                    // $642d
    sta sprite_ptrs+4                           // $642f
    sta sprite_ptrs+5                           // $6432
    lda #$07                                    // $6435
    sta VIC_SPR4_COL                            // $6437
    sta VIC_SPR5_COL                            // $643a
    lda #$07                                    // $643d
    sta VIC_SPR_MC0                             // $643f
    lda VIC_SPR_MULTICOLOR                      // $6442
    ora #$33                                    // $6445
    sta VIC_SPR_MULTICOLOR                      // $6447
    lda VIC_SPR_EXPAND_X                        // $644a
    ora #$20                                    // $644d
    sta VIC_SPR_EXPAND_X                        // $644f
    lda #$00                                    // $6452
    sta roll_sound_off                          // $6454
    lda #$01                                    // $6457
    sta sign_sound_on                           // $6459
    lda #$01                                    // $645c
    jsr wait_frames                             // $645e
    lda VIC_SPR_ENABLE                          // $6461
    ora #$33                                    // $6464
    sta VIC_SPR_ENABLE                          // $6466
    rts                                         // $6469
level_sign_spin:
    lda slide_state                             // $646a
    beq L6481                                   // $646d
    lda slide_speed                             // $646f
    lsr                                         // $6472
    lsr                                         // $6473
    ldx slide_speed_sign                        // $6474
    bne L647e                                   // $6477
    eor #$ff                                    // $6479
    clc                                         // $647b
    adc #$01                                    // $647c
L647e:
    sta sign_spin_speed                         // $647e
L6481:
    lda level_sign_on                           // $6481
    bne L6489                                   // $6484
    jmp L64f7                                   // $6486
L6489:
    lda sign_spin                               // $6489
    clc                                         // $648c
    adc sign_spin_speed                         // $648d
    sta sign_spin                               // $6490
    and #$7f                                    // $6493
    lsr                                         // $6495
    lsr                                         // $6496
    lsr                                         // $6497
    lsr                                         // $6498
    lsr                                         // $6499
    clc                                         // $649a
    adc #$c9                                    // $649b
    sta sprite_ptrs                             // $649d
    clc                                         // $64a0
    adc #$04                                    // $64a1
    sta sprite_ptrs+1                           // $64a3
    ldx #$00                                    // $64a6
    ldy #$02                                    // $64a8
    lda sign_spin                               // $64aa
    bpl L64b3                                   // $64ad
    ldx #$02                                    // $64af
    ldy #$00                                    // $64b1
L64b3:
    stx VIC_SPR0_COL                            // $64b3
    stx VIC_SPR1_COL                            // $64b6
    sty VIC_SPR_MC1                             // $64b9
    lda sign_x_left                             // $64bc
    sta VIC_SPR0_X                              // $64bf
    lda sign_x_right                            // $64c2
    sta VIC_SPR1_X                              // $64c5
    lda sign_y                                  // $64c8
    sta VIC_SPR0_Y                              // $64cb
    sta VIC_SPR1_Y                              // $64ce
    jsr level_sign_place                        // $64d1
    ldx sign_sound_on                           // $64d4
    beq L64f7                                   // $64d7
    lda #$00                                    // $64d9
    sta zp_fa                                   // $64db
    lda sign_spin_speed                         // $64dd
    bpl L64e7                                   // $64e0
    eor #$ff                                    // $64e2
    clc                                         // $64e4
    adc #$01                                    // $64e5
L64e7:
    ldx #$03                                    // $64e7
L64e9:
    lsr                                         // $64e9
    ror zp_fa                                   // $64ea
    dex                                         // $64ec
    bne L64e9                                   // $64ed
    sta SID_V1_FREQ_HI                          // $64ef
    lda zp_fa                                   // $64f2
    sta SID_V1_FREQ_LO                          // $64f4
L64f7:
    rts                                         // $64f7
level_sign_place:
    lda sign_x_left                             // $64f8
    cmp #$18                                    // $64fb
    bcs L6504                                   // $64fd
    ldx #$00                                    // $64ff
    jmp L651b                                   // $6501
L6504:
    cmp #$30                                    // $6504
    bcs L650f                                   // $6506
    sec                                         // $6508
    sbc #$18                                    // $6509
    tax                                         // $650b
    jmp L651b                                   // $650c
L650f:
    sec                                         // $650f
    sbc #$30                                    // $6510
    tax                                         // $6512
    lda VIC_SPR_EXPAND_X                        // $6513
    ora #$10                                    // $6516
    jmp L6520                                   // $6518
L651b:
    lda VIC_SPR_EXPAND_X                        // $651b
    and #$ef                                    // $651e
L6520:
    sta VIC_SPR_EXPAND_X                        // $6520
    stx VIC_SPR4_X                              // $6523
    lda sign_x_right                            // $6526
    clc                                         // $6529
    adc #$18                                    // $652a
    sta VIC_SPR5_X                              // $652c
    lda sign_y                                  // $652f
    sta VIC_SPR4_Y                              // $6532
    sta VIC_SPR5_Y                              // $6535
    rts                                         // $6538

// ----------------------------------------------------------------------------
// Slide the level sign in and back; the sprites spin with the slide speed
// ----------------------------------------------------------------------------
level_sign_slide_in:
    ldx #$e0                                    // $6539
    lda maze                                    // $653b
    cmp #$04                                    // $653e
    bcs L6544                                   // $6540
    ldx #$18                                    // $6542
L6544:
    stx zp_fa                                   // $6544
    lda #$01                                    // $6546
    sta blip_sound                              // $6548
L654b:
    lda #$01                                    // $654b
    jsr wait_frames                             // $654d
    inc sign_x_left                             // $6550
    dec sign_x_right                            // $6553
    lda sign_x_right                            // $6556
    cmp #$09                                    // $6559
    bcs L654b                                   // $655b
    lda #$00                                    // $655d
    sta blip_sound                              // $655f
    sta SID_V2_FREQ_HI                          // $6562
    sec                                         // $6565
    jsr gate_sound                              // $6566
L6569:
    lda #$05                                    // $6569
    jsr wait_frames                             // $656b
    lda zp_fa                                   // $656e
    bpl L6578                                   // $6570
    dec sign_spin_speed                         // $6572
    jmp L657b                                   // $6575
L6578:
    inc sign_spin_speed                         // $6578
L657b:
    cmp sign_spin_speed                         // $657b
    bne L6569                                   // $657e
    lda #$14                                    // $6580
    jsr wait_frames                             // $6582
    lda #$01                                    // $6585
    sta blip_sound                              // $6587
L658a:
    lda #$04                                    // $658a
    jsr wait_frames                             // $658c
    inc sign_y                                  // $658f
    lda sign_y                                  // $6592
    cmp #$dd                                    // $6595
    bcc L658a                                   // $6597
    lda #$00                                    // $6599
    sta blip_sound                              // $659b
    sta SID_V2_FREQ_HI                          // $659e
    lda #$01                                    // $65a1
    sta roll_sound_off                          // $65a3
    rts                                         // $65a6
level_sign_slide_out:
    lda #$00                                    // $65a7
    sta sign_spin_speed                         // $65a9
    sta roll_sound_off                          // $65ac
    lda #$1e                                    // $65af
    jsr wait_frames                             // $65b1
    jsr sid_off                                 // $65b4
    lda #$f0                                    // $65b7
    sta SID_V2_SR                               // $65b9
    lda #$11                                    // $65bc
    sta SID_V2_CTRL                             // $65be
    lda #$01                                    // $65c1
    sta blip_sound                              // $65c3
L65c6:
    lda #$04                                    // $65c6
    jsr wait_frames                             // $65c8
    dec sign_y                                  // $65cb
    lda sign_y                                  // $65ce
    cmp #$d6                                    // $65d1
    bne L65c6                                   // $65d3
    lda #$00                                    // $65d5
    sta blip_sound                              // $65d7
    sta SID_V2_FREQ_HI                          // $65da
    lda #$14                                    // $65dd
    jsr wait_frames                             // $65df
    lda #$01                                    // $65e2
    sta blip_sound                              // $65e4
L65e7:
    lda #$01                                    // $65e7
    jsr wait_frames                             // $65e9
    inc sign_x_right                            // $65ec
    dec sign_x_left                             // $65ef
    lda sign_x_right                            // $65f2
    cmp #$4f                                    // $65f5
    bne L65e7                                   // $65f7
    lda #$00                                    // $65f9
    sta blip_sound                              // $65fb
    sta SID_V2_FREQ_HI                          // $65fe
    lda #$14                                    // $6601
    jsr wait_frames                             // $6603
    lda #$00                                    // $6606
    sta level_sign_on                           // $6608
    lda VIC_SPR_ENABLE                          // $660b
    and #$cc                                    // $660e
    sta VIC_SPR_ENABLE                          // $6610
    lda VIC_SPR_MULTICOLOR                      // $6613
    and #$cc                                    // $6616
    sta VIC_SPR_MULTICOLOR                      // $6618
    lda VIC_SPR_EXPAND_X                        // $661b
    and #$cc                                    // $661e
    sta VIC_SPR_EXPAND_X                        // $6620
    lda #$00                                    // $6623
    sta VIC_SPR4_COL                            // $6625
    rts                                         // $6628
slide_noise:
    lda #$09                                    // $6629
    sta SID_V3_FREQ_HI                          // $662b
    lda #$32                                    // $662e
    sta SID_FC_HI                               // $6630
    lda slide_speed                             // $6633
    asl                                         // $6636
    ldx sign_sound_on                           // $6637
    beq L6642                                   // $663a
    ldx slide_out_flag                          // $663c
    beq L6642                                   // $663f
    asl                                         // $6641
L6642:
    bcc L6646                                   // $6642
    lda #$ff                                    // $6644
L6646:
    and #$f0                                    // $6646
    sta zp_fa                                   // $6648
    sta SID_V3_SR                               // $664a
    lda slide_noise_old                         // $664d
    cmp zp_fa                                   // $6650
    bcs L6659                                   // $6652
    lda #$80                                    // $6654
    sta SID_V3_CTRL                             // $6656
L6659:
    lda #$81                                    // $6659
    sta SID_V3_CTRL                             // $665b
    lda zp_fa                                   // $665e
    sta slide_noise_old                         // $6660
    rts                                         // $6663

// ----------------------------------------------------------------------------
// Demo mode: plays the recording at demo_controls; a joystick sprite
// (5) shows the moves
// ----------------------------------------------------------------------------
start_demo:
    lda #$00                                    // $6664
    sta VIC_SPR_ENABLE                          // $6666
    sta demo_step                               // $6669
    lda #$01                                    // $666c
    sta demo_step_frames                        // $666e
    sta demo_mode                               // $6671
    sta demo_playing                            // $6674
    lda #$a0                                    // $6677
    sta VIC_SPR_MULTICOLOR                      // $6679
    lda #$0e                                    // $667c
    sta VIC_SPR_MC1                             // $667e
    lda #$01                                    // $6681
    sta VIC_SPR_MC0                             // $6683
    lda #$06                                    // $6686
    sta VIC_SPR5_COL                            // $6688
    lda #$00                                    // $668b
    sta VIC_SPR7_COL                            // $668d
    lda VIC_SPR_X_MSB                           // $6690
    and #$5f                                    // $6693
    sta VIC_SPR_X_MSB                           // $6695
    lda #$a0                                    // $6698
    sta VIC_SPR5_X                              // $669a
    lda #$44                                    // $669d
    sta VIC_SPR5_Y                              // $669f
    lda #$d5                                    // $66a2
    sta sprite_ptrs+5                           // $66a4
    rts                                         // $66a7
    .byte $ad,$89,$cf,$f0,$3f,$ad,$4d,$cf,$0d,$4e,$cf,$2d,$8d,$cf,$f0,$0b  // $66a8
    .byte $a9,$00,$8d,$89,$cf,$8d,$8a,$cf,$4c,$d2,$66,$ad,$54,$cf,$cd,$8c  // $66b8
    .byte $cf,$d0,$07,$ad,$8a,$cf,$c9,$ff,$d0,$17,$ae,$8b,$cf,$ad,$8c,$cf  // $66c8
    .byte $9d,$00,$1c,$ad,$8a,$cf,$9d,$80,$1c,$ee,$8b,$cf,$a9,$00,$8d,$8a  // $66d8
    .byte $cf,$ee,$8a,$cf,$60                   // $66e8

// ----------------------------------------------------------------------------
// Demo: next recorded control step when the current one has run out.
// The recording stops when the ball is in the hole or lost.
// ----------------------------------------------------------------------------
demo_play:
    lda demo_playing                            // $66ed
    beq L671e                                   // $66f0
    dec demo_step_frames                        // $66f2
    bne L6709                                   // $66f5
    ldx demo_step                               // $66f7
    lda demo_controls,x                         // $66fa
    sta controls                                // $66fd
    lda demo_durations,x                        // $6700
    sta demo_step_frames                        // $6703
    inc demo_step                               // $6706
L6709:
    lda demo_step_frames                        // $6709
    beq L6719                                   // $670c
    lda ball_in_hole                            // $670e
    ora ball_lost                               // $6711
    and demo_stops_at_end                       // $6714
    beq L671e                                   // $6717
L6719:
    lda #$00                                    // $6719
    sta demo_playing                            // $671b
L671e:
    rts                                         // $671e
demo_joystick_sprite:
    ldx demo_step                               // $671f
    cpx #$03                                    // $6722
    bcc L674e                                   // $6724
    cpx #$10                                    // $6726
    bcc L672f                                   // $6728
    lda ball_in_hole                            // $672a
    bne L674e                                   // $672d
L672f:
    lda controls                                // $672f
    and #$0f                                    // $6732
    eor #$0f                                    // $6734
    tax                                         // $6736
    lda joystick_frames,x                       // $6737
    clc                                         // $673a
    adc #$d1                                    // $673b
    sta sprite_ptrs+5                           // $673d
    ldx #$06                                    // $6740
    lda controls                                // $6742
    and #$10                                    // $6745
    bne L674b                                   // $6747
    ldx #$0e                                    // $6749
L674b:
    stx VIC_SPR5_COL                            // $674b
L674e:
    lda #$9a                                    // $674e
    sta VIC_SPR7_X                              // $6750
    lda #$41                                    // $6753
    sta VIC_SPR7_Y                              // $6755
    lda #$da                                    // $6758
    sta sprite_ptrs+7                           // $675a
    lda VIC_SPR_PRIORITY                        // $675d
    and #$7f                                    // $6760
    sta VIC_SPR_PRIORITY                        // $6762
    lda VIC_SPR_MULTICOLOR                      // $6765
    ora #$80                                    // $6768
    sta VIC_SPR_MULTICOLOR                      // $676a
    lda #$80                                    // $676d
    sta VIC_SPR_EXPAND_Y                        // $676f
    sta VIC_SPR_EXPAND_X                        // $6772
    rts                                         // $6775
joystick_frames:
    .byte $04,$01,$07,$04,$03,$00,$06,$04,$05,$02,$08,$05,$04,$01,$07,$04  // $6776
build_chars_24c0:
    ldy #$07                                    // $6786
L6788:
    lda char($23),y                             // $6788
    sta zp_fa                                   // $678b
    lsr                                         // $678d
    ora zp_fa                                   // $678e
    eor #$ff                                    // $6790
    and char($31),y                             // $6792
    ora zp_fa                                   // $6795
    sta char($98),y                             // $6797
    lda char($27),y                             // $679a
    sta zp_fa                                   // $679d
    lsr                                         // $679f
    ora zp_fa                                   // $67a0
    eor #$ff                                    // $67a2
    and char($34),y                             // $67a4
    ora zp_fa                                   // $67a7
    sta char($99),y                             // $67a9
    dey                                         // $67ac
    bpl L6788                                   // $67ad
    rts                                         // $67af
shine_off_sound:
    lda #$00                                    // $67b0
    sta shine_state                             // $67b2
    lda #$0f                                    // $67b5
    sta SID_V3_FREQ_HI                          // $67b7
    lda #$80                                    // $67ba
    sta SID_V3_CTRL                             // $67bc
    lda #$00                                    // $67bf
    sta SID_V3_FREQ_LO                          // $67c1
    sta SID_V3_AD                               // $67c4
    lda #$40                                    // $67c7
    sta SID_V3_SR                               // $67c9
    lda #$04                                    // $67cc
    sta roll_volume_old                         // $67ce
    lda #$3f                                    // $67d1
    sta SID_MODE_VOL                            // $67d3
    lda #$6e                                    // $67d6
    sta SID_FC_HI                               // $67d8
    lda #$81                                    // $67db
    sta SID_V3_CTRL                             // $67dd
    rts                                         // $67e0

// ----------------------------------------------------------------------------
// Colour the gate that are off
// ----------------------------------------------------------------------------
draw_gate_colours:
    ldx maze                                    // $67e1
    lda maze_gate_index,x                       // $67e4
    sta zp_fb                                   // $67e7
    lda #$08                                    // $67e9
    sta zp_ff                                   // $67eb
    lda gate_mask                               // $67ed
    sta zp_fa                                   // $67f0
L67f2:
    ror zp_fa                                   // $67f2
    bcs L6826                                   // $67f4
    ldx zp_fb                                   // $67f6
    lda gate_table,x                            // $67f8
    sta zp_fd                                   // $67fb
    inx                                         // $67fd
    lda gate_table,x                            // $67fe
    clc                                         // $6801
    adc #$78                                    // $6802
    sta zp_fe                                   // $6804
    inx                                         // $6806
    ldy #$00                                    // $6807
    lda gate_table,x                            // $6809
    beq L6810                                   // $680c
    ldy #$03                                    // $680e
L6810:
    sty zp_f9                                   // $6810
    lda #$02                                    // $6812
    sta zp_fc                                   // $6814
    ldx zp_f9                                   // $6816
L6818:
    lda gate_cell_layout,x                      // $6818
    tay                                         // $681b
    lda gate_colour_table,x                     // $681c
    sta (zp_fd),y                               // $681f
    inx                                         // $6821
    dec zp_fc                                   // $6822
    bpl L6818                                   // $6824
L6826:
    lda zp_fb                                   // $6826
    clc                                         // $6828
    adc #$03                                    // $6829
    sta zp_fb                                   // $682b
    dec zp_ff                                   // $682d
    bne L67f2                                   // $682f
    rts                                         // $6831
gate_colour_table:
    .byte $fd,$fe,$ff,$fa,$fb,$fc,$9d,$9e,$9f,$9a,$9b,$9c,$0a,$20,$02,$06  // $6832
    .byte $20,$0e                               // $6842

// ----------------------------------------------------------------------------
// Light the edges of the walls the board leans on (characters $27D0+)
// ----------------------------------------------------------------------------
update_edge_highlight:
    lda edge_highlight_on                       // $6844
    bne L685e                                   // $6847
    lda clunk_state                             // $6849
    beq L6856                                   // $684c
    ldx speed_class                             // $684e
    cmp clunk_highlight_delay,x                 // $6851
    bcc L685e                                   // $6854
L6856:
    sec                                         // $6856
    jsr edge_highlight_v                        // $6857
    sec                                         // $685a
    jsr edge_highlight_h                        // $685b
L685e:
    rts                                         // $685e
clunk_highlight_delay:
    .byte $86,$85,$84,$83,$82                   // $685f
edge_highlight_v:
    lda #$01                                    // $6864
    bcs L686a                                   // $6866
    lda #$00                                    // $6868
L686a:
    sta edge_highlight_on                       // $686a
    ldx tilt_shift_x                            // $686d
    lda D68ea,x                                 // $6870
    sta zp_fb                                   // $6873
    lda D68f3,x                                 // $6875
    sta zp_fc                                   // $6878
    bcc L6880                                   // $687a
    asl zp_fb                                   // $687c
    asl zp_fc                                   // $687e
L6880:
    ldx tilt_shift_y                            // $6880
    lda D68d8,x                                 // $6883
    sta zp_fd                                   // $6886
    lda D68e1,x                                 // $6888
    sta zp_fe                                   // $688b
    lda D68fc,x                                 // $688d
    sta zp_f8                                   // $6890
    lda D6905,x                                 // $6892
    sta zp_f9                                   // $6895
    lda D690e,x                                 // $6897
    sta zp_fa                                   // $689a
    lda D6917,x                                 // $689c
    sta zp_ff                                   // $689f
    ldx #$01                                    // $68a1
L68a3:
    lda char($09)+7,x                           // $68a3
    cpx #$09                                    // $68a6
    bcc L68b3                                   // $68a8
    lda #$00                                    // $68aa
    cpx #$11                                    // $68ac
    bcc L68b3                                   // $68ae
    lda corner_pixels+511,x                     // $68b0
L68b3:
    cpx zp_fd                                   // $68b3
    bcc L68cf                                   // $68b5
    cpx zp_fe                                   // $68b7
    bcs L68cf                                   // $68b9
    cpx zp_f8                                   // $68bb
    beq L68cd                                   // $68bd
    cpx zp_f9                                   // $68bf
    beq L68cd                                   // $68c1
    ora zp_fc                                   // $68c3
    cpx zp_fa                                   // $68c5
    bcc L68cf                                   // $68c7
    cpx zp_ff                                   // $68c9
    bcs L68cf                                   // $68cb
L68cd:
    ora zp_fb                                   // $68cd
L68cf:
    sta char($fc)+7,x                           // $68cf
    inx                                         // $68d2
    cpx #$19                                    // $68d3
    bcc L68a3                                   // $68d5
    rts                                         // $68d7
D68d8:
    .byte $00,$00,$01,$03,$05,$07,$09,$0b,$0d   // $68d8
D68e1:
    .byte $0d,$0f,$11,$13,$15,$17,$19,$19,$19   // $68e1
D68ea:
    .byte $10,$10,$14,$14,$14,$14,$14,$04,$04   // $68ea
D68f3:
    .byte $44,$44,$41,$41,$41,$41,$41,$11,$11   // $68f3
D68fc:
    .byte $00,$00,$02,$04,$06,$08,$0a,$0c,$0e   // $68fc
D6905:
    .byte $0b,$0d,$0f,$11,$13,$15,$17,$19,$19   // $6905
D690e:
    .byte $00,$01,$03,$05,$07,$09,$0b,$0d,$0f   // $690e
D6917:
    .byte $0b,$0d,$0f,$11,$13,$15,$17,$19,$19   // $6917
edge_highlight_h:
    ldx tilt_shift_x                            // $6920
    lda D69b0,x                                 // $6923
    sta zp_f8                                   // $6926
    lda D69b9,x                                 // $6928
    sta zp_f9                                   // $692b
    lda D69c2,x                                 // $692d
    sta zp_fa                                   // $6930
    lda D69cb,x                                 // $6932
    sta zp_fb                                   // $6935
    lda D69d4,x                                 // $6937
    sta zp_fc                                   // $693a
    lda D69dd,x                                 // $693c
    sta zp_fd                                   // $693f
    bcc L694f                                   // $6941
    asl zp_f8                                   // $6943
    asl zp_f9                                   // $6945
    asl zp_fa                                   // $6947
    asl zp_fb                                   // $6949
    asl zp_fc                                   // $694b
    asl zp_fd                                   // $694d
L694f:
    ldx tilt_shift_y                            // $694f
    lda D699e,x                                 // $6952
    sta zp_fe                                   // $6955
    lda D69a7,x                                 // $6957
    sta zp_ff                                   // $695a
    ldx #$07                                    // $695c
L695e:
    ldy #$00                                    // $695e
    lda char($06),x                             // $6960
    cpx zp_fe                                   // $6963
    bcc L697a                                   // $6965
    beq L6976                                   // $6967
    cpx zp_ff                                   // $6969
    beq L6976                                   // $696b
    bcs L697a                                   // $696d
    ldy zp_fc                                   // $696f
    ora zp_fb                                   // $6971
    jmp L697a                                   // $6973
L6976:
    ldy zp_f9                                   // $6976
    ora zp_f8                                   // $6978
L697a:
    sta char($fa),x                             // $697a
    tya                                         // $697d
    sta char($fb),x                             // $697e
    lda char($0e),x                             // $6981
    cpx zp_fe                                   // $6984
    bcc L6997                                   // $6986
    beq L6995                                   // $6988
    cpx zp_ff                                   // $698a
    beq L6995                                   // $698c
    bcs L6997                                   // $698e
    ora zp_fd                                   // $6990
    jmp L6997                                   // $6992
L6995:
    ora zp_fa                                   // $6995
L6997:
    sta char($fc),x                             // $6997
    dex                                         // $699a
    bpl L695e                                   // $699b
    rts                                         // $699d
D699e:
    .byte $00,$00,$00,$00,$01,$01,$02,$02,$03   // $699e
D69a7:
    .byte $04,$05,$05,$06,$07,$07,$07,$07,$07   // $69a7
D69b0:
    .byte $55,$55,$15,$45,$11,$04,$01,$00,$00   // $69b0
D69b9:
    .byte $44,$51,$54,$55,$55,$55,$15,$45,$11   // $69b9
D69c2:
    .byte $00,$00,$40,$10,$44,$51,$54,$55,$55   // $69c2
D69cb:
    .byte $55,$55,$55,$15,$05,$01,$00,$00,$00   // $69cb
D69d4:
    .byte $50,$54,$55,$55,$55,$55,$55,$15,$05   // $69d4
D69dd:
    .byte $00,$00,$00,$40,$50,$54,$55,$55,$55   // $69dd

// ----------------------------------------------------------------------------
// End of level, in the IRQ: take the floor marks off one by one; each
// gives power. A mark that is no longer a mark character (a gate
// was drawn over it, or cells $FB / $FE) scores that block instead.
// ----------------------------------------------------------------------------
count_marks:
    lda count_marks_on                          // $69e6
    beq L69ff                                   // $69e9
    dec count_marks_on                          // $69eb
    bne L69ff                                   // $69ee
    lda #$02                                    // $69f0
    sta count_marks_on                          // $69f2
    ldx mark_count                              // $69f5
    bne L6a02                                   // $69f8
    lda #$00                                    // $69fa
    sta count_marks_on                          // $69fc
L69ff:
    jmp L6a65                                   // $69ff
L6a02:
    dex                                         // $6a02
    stx mark_count                              // $6a03
    lda colour_buffer,x                         // $6a06
    sta zp_fd                                   // $6a09
    lda colour_buffer+6*40+16,x                 // $6a0b
    sta zp_fe                                   // $6a0e
    ldy #$00                                    // $6a10
    lda (zp_fd),y                               // $6a12
    cmp #$63                                    // $6a14
    beq L6a1c                                   // $6a16
    cmp #$b2                                    // $6a18
    bne L6a23                                   // $6a1a
L6a1c:
    lda #$20                                    // $6a1c
    sta (zp_fd),y                               // $6a1e
    jmp L6a2b                                   // $6a20
L6a23:
    ldx count_marks_delay                       // $6a23
    bne L6a2b                                   // $6a26
    jsr unmark_special                          // $6a28
L6a2b:
    ldx mark_count                              // $6a2b
    beq L6a47                                   // $6a2e
    dex                                         // $6a30
    lda colour_buffer,x                         // $6a31
    sta zp_fd                                   // $6a34
    lda colour_buffer+6*40+16,x                 // $6a36
    sta zp_fe                                   // $6a39
    ldy #$00                                    // $6a3b
    lda (zp_fd),y                               // $6a3d
    cmp #$63                                    // $6a3f
    bne L6a47                                   // $6a41
    lda #$b2                                    // $6a43
    sta (zp_fd),y                               // $6a45
L6a47:
    lda count_marks_delay                       // $6a47
    bne L6a5d                                   // $6a4a
    lda game_over                               // $6a4c
    bne L6a5d                                   // $6a4f
    lda #$12                                    // $6a51
    ldx ball_in_hole                            // $6a53
    beq L6a5a                                   // $6a56
    lda #$28                                    // $6a58
L6a5a:
    jsr add_power                               // $6a5a
L6a5d:
    lda count_marks_delay                       // $6a5d
    beq L6a65                                   // $6a60
    dec count_marks_delay                       // $6a62
L6a65:
    rts                                         // $6a65
unmark_special:
    cmp #$fb                                    // $6a66
    beq L6a6e                                   // $6a68
    cmp #$fe                                    // $6a6a
    bne L6a74                                   // $6a6c
L6a6e:
    jsr bumper_hit                              // $6a6e
    jmp L6a8f                                   // $6a71
L6a74:
    cmp #$00                                    // $6a74
    bne L6a7d                                   // $6a76
    lda #$29                                    // $6a78
    jmp L6a8c                                   // $6a7a
L6a7d:
    cmp #$29                                    // $6a7d
    bne L6a86                                   // $6a7f
    lda #$52                                    // $6a81
    jmp L6a8c                                   // $6a83
L6a86:
    cmp #$25                                    // $6a86
    bne L6a8f                                   // $6a88
    lda #$51                                    // $6a8a
L6a8c:
    jsr gate_hit                                // $6a8c
L6a8f:
    rts                                         // $6a8f
bonus_count_sound:
    lda bonus_sound_on                          // $6a90
    bne L6a98                                   // $6a93
    jmp L6b16                                   // $6a95
L6a98:
    lda bonus_left                              // $6a98
    bne L6aa5                                   // $6a9b
    sta bonus_flash                             // $6a9d
    lda #$00                                    // $6aa0
    jmp L6ab8                                   // $6aa2
L6aa5:
    ldx bonus_flash                             // $6aa5
    dex                                         // $6aa8
    bpl L6aad                                   // $6aa9
    ldx #$01                                    // $6aab
L6aad:
    stx bonus_flash                             // $6aad
    lda #$01                                    // $6ab0
    cpx #$01                                    // $6ab2
    bcs L6ab8                                   // $6ab4
    lda #$0c                                    // $6ab6
L6ab8:
    jsr colour_status_marks                     // $6ab8
    lda scroll_pause                            // $6abb
    and #$01                                    // $6abe
    bne L6ad9                                   // $6ac0
    lda count_marks_on                          // $6ac2
    beq L6b0c                                   // $6ac5
    ldx #$8f                                    // $6ac7
    ldy #$0a                                    // $6ac9
    lda ball_in_hole                            // $6acb
    beq L6ad4                                   // $6ace
    ldx #$18                                    // $6ad0
    ldy #$0e                                    // $6ad2
L6ad4:
    lda #$11                                    // $6ad4
    jmp L6b00                                   // $6ad6
L6ad9:
    lda bonus_left                              // $6ad9
    beq L6b0c                                   // $6adc
    dec bonus_left                              // $6ade
    lda #$50                                    // $6ae1
    ldx #$00                                    // $6ae3
    ldy ball_in_hole                            // $6ae5
    beq L6aee                                   // $6ae8
    lda #$00                                    // $6aea
    ldx #$01                                    // $6aec
L6aee:
    jsr add_score                               // $6aee
    ldx #$a5                                    // $6af1
    ldy #$1f                                    // $6af3
    lda ball_in_hole                            // $6af5
    beq L6afe                                   // $6af8
    ldx #$3e                                    // $6afa
    ldy #$2a                                    // $6afc
L6afe:
    lda #$11                                    // $6afe
L6b00:
    stx SID_V3_FREQ_LO                          // $6b00
    sty SID_V3_FREQ_HI                          // $6b03
    sta SID_V3_CTRL                             // $6b06
    jmp L6b16                                   // $6b09
L6b0c:
    lda #$00                                    // $6b0c
    sta SID_V3_FREQ_LO                          // $6b0e
    lda #$00                                    // $6b11
    sta SID_V3_FREQ_HI                          // $6b13
L6b16:
    rts                                         // $6b16

// ----------------------------------------------------------------------------
// Params: zp_fd/zp_fe = screen address, A = offset
// Find the gate at that address: C = 0 found (zp_fa = table index,
// zp_ff = its bit), C = 1 not found
// ----------------------------------------------------------------------------
find_gate:
    sta zp_fa                                   // $6b17
    lda zp_fd                                   // $6b19
    sec                                         // $6b1b
    sbc zp_fa                                   // $6b1c
    sta zp_fb                                   // $6b1e
    lda zp_fe                                   // $6b20
    sbc #$00                                    // $6b22
    sta zp_fc                                   // $6b24
    ldx maze                                    // $6b26
    lda maze_gate_index,x                       // $6b29
    sta zp_fa                                   // $6b2c
    lda #$01                                    // $6b2e
    sta zp_ff                                   // $6b30
    ldy #$08                                    // $6b32
L6b34:
    ldx zp_fa                                   // $6b34
    lda gate_table,x                            // $6b36
    cmp zp_fb                                   // $6b39
    bne L6b45                                   // $6b3b
    inx                                         // $6b3d
    lda gate_table,x                            // $6b3e
    cmp zp_fc                                   // $6b41
    beq L6b54                                   // $6b43
L6b45:
    lda zp_fa                                   // $6b45
    clc                                         // $6b47
    adc #$03                                    // $6b48
    sta zp_fa                                   // $6b4a
    asl zp_ff                                   // $6b4c
    dey                                         // $6b4e
    bne L6b34                                   // $6b4f
    sec                                         // $6b51
    bcs L6b55                                   // $6b52
L6b54:
    clc                                         // $6b54
L6b55:
    rts                                         // $6b55

// ----------------------------------------------------------------------------
// A gate was hit by the mark count: remove it from the mask, animate and score it
// ----------------------------------------------------------------------------
gate_hit:
    jsr find_gate                               // $6b56
    bcs L6b8b                                   // $6b59
    lda zp_ff                                   // $6b5b
    eor #$ff                                    // $6b5d
    and gate_mask                               // $6b5f
    sta gate_mask                               // $6b62
    lda zp_fa                                   // $6b65
    ldx gate_hit_timer                          // $6b67
    beq L6b7b                                   // $6b6a
    pha                                         // $6b6c
    lda #$04                                    // $6b6d
    sta gate_hit_frame                          // $6b6f
    lda #$01                                    // $6b72
    sta gate_hit_timer                          // $6b74
    jsr gate_hit_anim                           // $6b77
    pla                                         // $6b7a
L6b7b:
    sta gate_hit_index                          // $6b7b
    lda #$00                                    // $6b7e
    sta gate_hit_frame                          // $6b80
    lda #$01                                    // $6b83
    sta gate_hit_timer                          // $6b85
    jsr gate_hit_sound                          // $6b88
L6b8b:
    rts                                         // $6b8b
gate_hit_sound:
    lda #$00                                    // $6b8c
    sta SID_V2_CTRL                             // $6b8e
    sta SID_V2_SR                               // $6b91
    sta SID_V2_FREQ_LO                          // $6b94
    lda #$04                                    // $6b97
    sta SID_V2_AD                               // $6b99
    lda #$ff                                    // $6b9c
    sta SID_V2_FREQ_HI                          // $6b9e
    lda #$81                                    // $6ba1
    sta SID_V2_CTRL                             // $6ba3
    rts                                         // $6ba6

// ----------------------------------------------------------------------------
// A bumper ($FB / $FE cell) was hit: animate it and add bonus
// ----------------------------------------------------------------------------
bumper_hit:
    lda #$29                                    // $6ba7
    jsr find_gate                               // $6ba9
    bcs L6c07                                   // $6bac
    lda zp_fa                                   // $6bae
    ldx bumper_timer                            // $6bb0
    beq L6bbf                                   // $6bb3
    pha                                         // $6bb5
    lda #$01                                    // $6bb6
    sta bumper_timer                            // $6bb8
    jsr bumper_hit_anim                         // $6bbb
    pla                                         // $6bbe
L6bbf:
    sta bumper_index                            // $6bbf
    lda #$10                                    // $6bc2
    sta bumper_timer                            // $6bc4
    lda #$00                                    // $6bc7
    sta SID_V2_CTRL                             // $6bc9
    sta SID_V2_AD                               // $6bcc
    sta SID_V2_PW_LO                            // $6bcf
    sta SID_V2_PW_HI                            // $6bd2
    lda #$50                                    // $6bd5
    sta SID_V2_SR                               // $6bd7
    lda #$41                                    // $6bda
    sta SID_V2_CTRL                             // $6bdc
    ldx #$15                                    // $6bdf
    ldy #$1f                                    // $6be1
    lda ball_in_hole                            // $6be3
    beq L6bec                                   // $6be6
    ldx #$1c                                    // $6be8
    ldy #$31                                    // $6bea
L6bec:
    stx SID_V2_FREQ_HI                          // $6bec
    sty SID_V2_FREQ_LO                          // $6bef
    lda #$02                                    // $6bf2
    jsr bonus_power                             // $6bf4
    lda #$0a                                    // $6bf7
    ldx ball_in_hole                            // $6bf9
    bne L6c00                                   // $6bfc
    lda #$0a                                    // $6bfe
L6c00:
    clc                                         // $6c00
    adc bonus_left                              // $6c01
    sta bonus_left                              // $6c04
L6c07:
    rts                                         // $6c07
gate_hit_anim:
    lda gate_hit_timer                          // $6c08
    beq L6c61                                   // $6c0b
    dec gate_hit_timer                          // $6c0d
    bne L6c61                                   // $6c10
    lda #$01                                    // $6c12
    ldx ball_in_hole                            // $6c14
    bne L6c1b                                   // $6c17
    lda #$02                                    // $6c19
L6c1b:
    sta gate_hit_timer                          // $6c1b
    inc gate_hit_frame                          // $6c1e
    lda gate_hit_frame                          // $6c21
    cmp #$05                                    // $6c24
    bcc L6c45                                   // $6c26
    jsr gate_hit_anim_sound                     // $6c28
    ldx #$00                                    // $6c2b
    stx gate_hit_timer                          // $6c2d
    lda #$01                                    // $6c30
    jsr bonus_power                             // $6c32
    lda #$05                                    // $6c35
    ldx ball_in_hole                            // $6c37
    bne L6c3e                                   // $6c3a
    lda #$05                                    // $6c3c
L6c3e:
    clc                                         // $6c3e
    adc bonus_left                              // $6c3f
    sta bonus_left                              // $6c42
L6c45:
    lda gate_hit_frame                          // $6c45
    asl                                         // $6c48
    sta zp_fb                                   // $6c49
    asl                                         // $6c4b
    asl                                         // $6c4c
    clc                                         // $6c4d
    adc zp_fb                                   // $6c4e
    sta gate_gfx_offset                         // $6c50
    lda #$00                                    // $6c53
    sta gate_page_add                           // $6c55
    lda gate_hit_index                          // $6c58
    sta gate_index                              // $6c5b
    jsr draw_gate                               // $6c5e
L6c61:
    rts                                         // $6c61
gate_hit_anim_sound:
    lda #$00                                    // $6c62
    sta SID_V1_CTRL                             // $6c64
    sta SID_V1_SR                               // $6c67
    sta SID_V1_FREQ_LO                          // $6c6a
    lda #$09                                    // $6c6d
    sta SID_V1_AD                               // $6c6f
    lda #$64                                    // $6c72
    sta SID_V1_FREQ_HI                          // $6c74
    lda #$81                                    // $6c77
    sta SID_V1_CTRL                             // $6c79
    rts                                         // $6c7c
bumper_hit_anim:
    lda bumper_timer                            // $6c7d
    bne L6c85                                   // $6c80
    jmp L6cf5                                   // $6c82
L6c85:
    dec bumper_timer                            // $6c85
    bne L6c9a                                   // $6c88
    lda #$05                                    // $6c8a
    ldx ball_in_hole                            // $6c8c
    bne L6c93                                   // $6c8f
    lda #$05                                    // $6c91
L6c93:
    clc                                         // $6c93
    adc bonus_left                              // $6c94
    lda bonus_left                              // $6c97
L6c9a:
    ldx bumper_index                            // $6c9a
    lda gate_table,x                            // $6c9d
    sta zp_fb                                   // $6ca0
    inx                                         // $6ca2
    lda gate_table,x                            // $6ca3
    sta zp_fc                                   // $6ca6
    inx                                         // $6ca8
    ldy gate_table,x                            // $6ca9
    sty zp_fa                                   // $6cac
    lda bumper_timer                            // $6cae
    bne L6cbc                                   // $6cb1
    iny                                         // $6cb3
    iny                                         // $6cb4
    iny                                         // $6cb5
    iny                                         // $6cb6
    lda #$00                                    // $6cb7
    jmp L6cc8                                   // $6cb9
L6cbc:
    and #$03                                    // $6cbc
    cmp #$01                                    // $6cbe
    bcc L6cc4                                   // $6cc0
    iny                                         // $6cc2
    iny                                         // $6cc3
L6cc4:
    tax                                         // $6cc4
    lda D6cf6,x                                 // $6cc5
L6cc8:
    sta SID_V2_PW_HI                            // $6cc8
    tya                                         // $6ccb
    sta zp_f8                                   // $6ccc
    asl                                         // $6cce
    clc                                         // $6ccf
    adc zp_f8                                   // $6cd0
    sta zp_f8                                   // $6cd2
    lda zp_fa                                   // $6cd4
    asl                                         // $6cd6
    clc                                         // $6cd7
    adc zp_fa                                   // $6cd8
    sta zp_fa                                   // $6cda
    lda #$02                                    // $6cdc
    sta zp_f9                                   // $6cde
L6ce0:
    ldy zp_fa                                   // $6ce0
    lda gate_cell_layout,y                      // $6ce2
    tay                                         // $6ce5
    ldx zp_f8                                   // $6ce6
    lda gate_colour_table,x                     // $6ce8
    sta (zp_fb),y                               // $6ceb
    inc zp_fa                                   // $6ced
    inc zp_f8                                   // $6cef
    dec zp_f9                                   // $6cf1
    bpl L6ce0                                   // $6cf3
L6cf5:
    rts                                         // $6cf5
D6cf6:
    .byte $08,$07,$06,$05                       // $6cf6
freeze_edge_highlight:
    lda #$01                                    // $6cfa
    jsr wait_frames                             // $6cfc
    lda edge_highlight_on                       // $6cff
    clc                                         // $6d02
    pha                                         // $6d03
    bne L6d07                                   // $6d04
    sec                                         // $6d06
L6d07:
    php                                         // $6d07
    jsr edge_highlight_v                        // $6d08
    plp                                         // $6d0b
    jsr edge_highlight_h                        // $6d0c
    ldx #$2f                                    // $6d0f
L6d11:
    lda char($fa),x                             // $6d11
    sta char($9a),x                             // $6d14
    dex                                         // $6d17
    bpl L6d11                                   // $6d18
    clc                                         // $6d1a
    pla                                         // $6d1b
    beq L6d1f                                   // $6d1c
    sec                                         // $6d1e
L6d1f:
    php                                         // $6d1f
    jsr edge_highlight_v                        // $6d20
    plp                                         // $6d23
    jsr edge_highlight_h                        // $6d24
    rts                                         // $6d27
flash_lost:
    lda flash_step                              // $6d28
    beq L6d90                                   // $6d2b
    dec flash_phase                             // $6d2d
    bpl L6d3a                                   // $6d30
    lda #$02                                    // $6d32
    sta flash_phase                             // $6d34
    inc flash_step                              // $6d37
L6d3a:
    ldx flash_phase                             // $6d3a
    lda #$00                                    // $6d3d
    cpx #$00                                    // $6d3f
    beq L6d51                                   // $6d41
    lda #$01                                    // $6d43
    cpx #$02                                    // $6d45
    beq L6d51                                   // $6d47
    ldy maze                                    // $6d49
    lda maze_floor_colours,y                    // $6d4c
    and #$07                                    // $6d4f
L6d51:
    ldy flash_step                              // $6d51
    cpy #$10                                    // $6d54
    bne L6d63                                   // $6d56
    cpx #$00                                    // $6d58
    bne L6d61                                   // $6d5a
    ldy #$00                                    // $6d5c
    sty flash_step                              // $6d5e
L6d61:
    lda #$01                                    // $6d61
L6d63:
    sta VIC_BG2                                 // $6d63
    cpx #$02                                    // $6d66
    bne L6d7e                                   // $6d68
    lda #$64                                    // $6d6a
    sta SID_V2_FREQ_HI                          // $6d6c
    lda #$70                                    // $6d6f
    sta SID_V1_FREQ_HI                          // $6d71
    lda #$00                                    // $6d74
    sta SID_V2_FREQ_LO                          // $6d76
    lda #$00                                    // $6d79
    sta SID_V1_FREQ_LO                          // $6d7b
L6d7e:
    cpx #$00                                    // $6d7e
    bne L6d90                                   // $6d80
    lda #$00                                    // $6d82
    sta SID_V2_FREQ_HI                          // $6d84
    sta SID_V1_FREQ_HI                          // $6d87
    sta SID_V2_FREQ_LO                          // $6d8a
    sta SID_V1_FREQ_LO                          // $6d8d
L6d90:
    rts                                         // $6d90

// ----------------------------------------------------------------------------
// Mask the ball sprite (3) against the tilt: copy it to $3700 with the
// part that is behind the board edge cut off
// ----------------------------------------------------------------------------
mask_ball_sprite:
    ldx tilt_shift_x                            // $6d91
    lda D6e59,x                                 // $6d94
    sta zp_f8                                   // $6d97
    ldx tilt_shift_y                            // $6d99
    lda D6e59,x                                 // $6d9c
    sta zp_f9                                   // $6d9f
    lda sprite_ptrs+3                           // $6da1
    jsr build_sprite_mask                       // $6da4
    lda zp_fa                                   // $6da7
    beq L6db5                                   // $6da9
L6dab:
    lda (zp_fb),y                               // $6dab
    sta sprite($dc),y                           // $6dad
    iny                                         // $6db0
    cpy zp_fa                                   // $6db1
    bcc L6dab                                   // $6db3
L6db5:
    lda (zp_fb),y                               // $6db5
    and sprite_mask_buffer,x                    // $6db7
    sta sprite($dc),y                           // $6dba
    inx                                         // $6dbd
    iny                                         // $6dbe
    cpy zp_ff                                   // $6dbf
    bcc L6db5                                   // $6dc1
    cpy #$3f                                    // $6dc3
    bcs L6dd1                                   // $6dc5
L6dc7:
    lda (zp_fb),y                               // $6dc7
    sta sprite($dc),y                           // $6dc9
    iny                                         // $6dcc
    cpy #$3f                                    // $6dcd
    bcc L6dc7                                   // $6dcf
L6dd1:
    rts                                         // $6dd1

// ----------------------------------------------------------------------------
// Params: A = sprite pointer. Build an inverted copy of the sprite at
// $3880 shifted by the tilt (zp_f8 X, zp_f9 Y); returns the rows to mask
// ----------------------------------------------------------------------------
build_sprite_mask:
    ldx #$00                                    // $6dd2
    stx zp_fb                                   // $6dd4
    lsr                                         // $6dd6
    ror zp_fb                                   // $6dd7
    lsr                                         // $6dd9
    ror zp_fb                                   // $6dda
    sta zp_fc                                   // $6ddc
    ldy #$3e                                    // $6dde
L6de0:
    lda (zp_fb),y                               // $6de0
    eor #$ff                                    // $6de2
    sta sprite_mask_buffer,y                    // $6de4
    dey                                         // $6de7
    bpl L6de0                                   // $6de8
    lda zp_f8                                   // $6dea
    cmp #$04                                    // $6dec
    beq L6e28                                   // $6dee
    bcs L6e10                                   // $6df0
    sta zp_fa                                   // $6df2
    lda #$04                                    // $6df4
    sec                                         // $6df6
    sbc zp_fa                                   // $6df7
    tay                                         // $6df9
L6dfa:
    ldx #$3c                                    // $6dfa
L6dfc:
    sec                                         // $6dfc
    ror sprite_mask_buffer,x                    // $6dfd
    ror sprite_mask_buffer+1,x                  // $6e00
    ror sprite_mask_buffer+2,x                  // $6e03
    dex                                         // $6e06
    dex                                         // $6e07
    dex                                         // $6e08
    bpl L6dfc                                   // $6e09
    dey                                         // $6e0b
    bne L6dfa                                   // $6e0c
    beq L6e28                                   // $6e0e
L6e10:
    sec                                         // $6e10
    sbc #$04                                    // $6e11
    tay                                         // $6e13
L6e14:
    ldx #$3c                                    // $6e14
L6e16:
    sec                                         // $6e16
    rol sprite_mask_buffer+2,x                  // $6e17
    rol sprite_mask_buffer+1,x                  // $6e1a
    rol sprite_mask_buffer,x                    // $6e1d
    dex                                         // $6e20
    dex                                         // $6e21
    dex                                         // $6e22
    bpl L6e16                                   // $6e23
    dey                                         // $6e25
    bne L6e14                                   // $6e26
L6e28:
    ldx #$00                                    // $6e28
    ldy #$3f                                    // $6e2a
    lda zp_f9                                   // $6e2c
    cmp #$04                                    // $6e2e
    beq L6e44                                   // $6e30
    bcs L6e3c                                   // $6e32
    tax                                         // $6e34
    lda D6e51,x                                 // $6e35
    tax                                         // $6e38
    jmp L6e44                                   // $6e39
L6e3c:
    sec                                         // $6e3c
    sbc #$05                                    // $6e3d
    tay                                         // $6e3f
    lda D6e55,y                                 // $6e40
    tay                                         // $6e43
L6e44:
    stx zp_fa                                   // $6e44
    sty zp_ff                                   // $6e46
    lda #$3f                                    // $6e48
    sec                                         // $6e4a
    sbc zp_ff                                   // $6e4b
    tax                                         // $6e4d
    ldy #$00                                    // $6e4e
    rts                                         // $6e50
D6e51:
    .byte $0c,$09,$06,$03                       // $6e51
D6e55:
    .byte $3c,$39,$36,$33                       // $6e55
D6e59:
    .byte $02,$03,$03,$04,$04,$04,$05,$05,$06   // $6e59

// ----------------------------------------------------------------------------
// Two-tone sound (steps counted by $CFA8), after the last maze of a level
// ----------------------------------------------------------------------------
two_tone_sound:
    ldx two_tone_timer                          // $6e62
    beq L6ebd                                   // $6e65
    dex                                         // $6e67
    bne L6eba                                   // $6e68
    lda two_tone_step                           // $6e6a
    bne L6e8d                                   // $6e6d
    ldx #$00                                    // $6e6f
    stx SID_V1_CTRL                             // $6e71
    stx SID_V1_AD                               // $6e74
    stx SID_V2_CTRL                             // $6e77
    stx SID_V2_AD                               // $6e7a
    ldx #$70                                    // $6e7d
    stx SID_V1_SR                               // $6e7f
    stx SID_V2_SR                               // $6e82
    ldx #$21                                    // $6e85
    stx SID_V1_CTRL                             // $6e87
    stx SID_V2_CTRL                             // $6e8a
L6e8d:
    ldx #$00                                    // $6e8d
    ldy #$00                                    // $6e8f
    and #$01                                    // $6e91
    beq L6e99                                   // $6e93
    ldx #$31                                    // $6e95
    ldy #$1c                                    // $6e97
L6e99:
    stx SID_V1_FREQ_LO                          // $6e99
    sty SID_V1_FREQ_HI                          // $6e9c
    ldx #$00                                    // $6e9f
    ldy #$00                                    // $6ea1
    and #$01                                    // $6ea3
    beq L6eab                                   // $6ea5
    ldx #$78                                    // $6ea7
    ldy #$1c                                    // $6ea9
L6eab:
    stx SID_V2_FREQ_LO                          // $6eab
    sty SID_V2_FREQ_HI                          // $6eae
    ldy two_tone_step                           // $6eb1
    ldx D6ebe,y                                 // $6eb4
    inc two_tone_step                           // $6eb7
L6eba:
    stx two_tone_timer                          // $6eba
L6ebd:
    rts                                         // $6ebd
D6ebe:
    .byte $02,$06,$06,$05,$01,$06,$06,$05,$01,$06,$00  // $6ebe

// ----------------------------------------------------------------------------
// Ball glint (sprite data at $3759): a small highlight moved with the shine
// ----------------------------------------------------------------------------
draw_ball_glint:
    ldx #$0c                                    // $6ec9
    lda #$00                                    // $6ecb
L6ecd:
    sta sprite($dd)+25,x                        // $6ecd
    dex                                         // $6ed0
    dex                                         // $6ed1
    dex                                         // $6ed2
    bpl L6ecd                                   // $6ed3
    lda shine_quadrant_x                        // $6ed5
    cmp #$02                                    // $6ed8
    bcs L6ee3                                   // $6eda
    lda shine_quadrant_y                        // $6edc
    cmp #$02                                    // $6edf
    bcc L6ee6                                   // $6ee1
L6ee3:
    jmp L6fca                                   // $6ee3
L6ee6:
    ldx #$04                                    // $6ee6
L6ee8:
    lda D6fe1,x                                 // $6ee8
    sta D6fee,x                                 // $6eeb
    dex                                         // $6eee
    bpl L6ee8                                   // $6eef
    lda shine_x                                 // $6ef1
    ldx shine_quadrant_x                        // $6ef4
    jsr glint_step                              // $6ef7
    stx zp_f8                                   // $6efa
    lda shine_y                                 // $6efc
    ldx shine_quadrant_y                        // $6eff
    jsr glint_step                              // $6f02
    stx zp_f9                                   // $6f05
    lda zp_f8                                   // $6f07
    beq L6f2a                                   // $6f09
    bmi L6f1b                                   // $6f0b
    tay                                         // $6f0d
L6f0e:
    ldx #$04                                    // $6f0e
L6f10:
    lsr D6fee,x                                 // $6f10
    dex                                         // $6f13
    bpl L6f10                                   // $6f14
    dey                                         // $6f16
    bne L6f0e                                   // $6f17
    beq L6f2a                                   // $6f19
L6f1b:
    eor #$ff                                    // $6f1b
    tay                                         // $6f1d
    iny                                         // $6f1e
L6f1f:
    ldx #$04                                    // $6f1f
L6f21:
    asl D6fee,x                                 // $6f21
    dex                                         // $6f24
    bpl L6f21                                   // $6f25
    dey                                         // $6f27
    bne L6f1f                                   // $6f28
L6f2a:
    ldx #$00                                    // $6f2a
    ldy #$05                                    // $6f2c
    lda zp_f9                                   // $6f2e
    beq L6f3c                                   // $6f30
    bmi L6f38                                   // $6f32
    tax                                         // $6f34
    jmp L6f3c                                   // $6f35
L6f38:
    clc                                         // $6f38
    adc #$05                                    // $6f39
    tay                                         // $6f3b
L6f3c:
    stx zp_fa                                   // $6f3c
    sty zp_ff                                   // $6f3e
    lda #$05                                    // $6f40
    sec                                         // $6f42
    sbc zp_ff                                   // $6f43
    tax                                         // $6f45
    ldy #$00                                    // $6f46
    lda zp_fa                                   // $6f48
    beq L6f56                                   // $6f4a
    lda #$00                                    // $6f4c
L6f4e:
    sta D6fe6,y                                 // $6f4e
    iny                                         // $6f51
    cpy zp_fa                                   // $6f52
    bcc L6f4e                                   // $6f54
L6f56:
    lda D6fee,x                                 // $6f56
    and D6fe1,y                                 // $6f59
    sta D6fe6,y                                 // $6f5c
    inx                                         // $6f5f
    iny                                         // $6f60
    cpy zp_ff                                   // $6f61
    bcc L6f56                                   // $6f63
    cpy #$05                                    // $6f65
    bcs L6f73                                   // $6f67
    lda #$00                                    // $6f69
L6f6b:
    sta D6fe6,y                                 // $6f6b
    iny                                         // $6f6e
    cpy #$05                                    // $6f6f
    bcc L6f6b                                   // $6f71
L6f73:
    lda zp_f8                                   // $6f73
    bpl L6f8d                                   // $6f75
    eor #$ff                                    // $6f77
    clc                                         // $6f79
    adc #$01                                    // $6f7a
    lsr                                         // $6f7c
    beq L6f9c                                   // $6f7d
    tay                                         // $6f7f
L6f80:
    ldx #$04                                    // $6f80
L6f82:
    lsr D6fe6,x                                 // $6f82
    dex                                         // $6f85
    bpl L6f82                                   // $6f86
    dey                                         // $6f88
    bne L6f80                                   // $6f89
    beq L6f9c                                   // $6f8b
L6f8d:
    lsr                                         // $6f8d
    beq L6f9c                                   // $6f8e
    tay                                         // $6f90
L6f91:
    ldx #$04                                    // $6f91
L6f93:
    asl D6fe6,x                                 // $6f93
    dex                                         // $6f96
    bpl L6f93                                   // $6f97
    dey                                         // $6f99
    bne L6f91                                   // $6f9a
L6f9c:
    ldx #$00                                    // $6f9c
    ldy #$00                                    // $6f9e
    lda zp_f9                                   // $6fa0
    beq L6fb8                                   // $6fa2
    bmi L6fab                                   // $6fa4
    lsr                                         // $6fa6
    tay                                         // $6fa7
    jmp L6fb8                                   // $6fa8
L6fab:
    eor #$ff                                    // $6fab
    clc                                         // $6fad
    adc #$01                                    // $6fae
    lsr                                         // $6fb0
    sta zp_fa                                   // $6fb1
    asl                                         // $6fb3
    clc                                         // $6fb4
    adc zp_fa                                   // $6fb5
    tax                                         // $6fb7
L6fb8:
    lda D6fe6,y                                 // $6fb8
    sta sprite($dd)+25,x                        // $6fbb
    inx                                         // $6fbe
    inx                                         // $6fbf
    inx                                         // $6fc0
    iny                                         // $6fc1
    cpy #$05                                    // $6fc2
    bcs L6fca                                   // $6fc4
    cpx #$0f                                    // $6fc6
    bcc L6fb8                                   // $6fc8
L6fca:
    rts                                         // $6fca
glint_step:
    beq L6fd2                                   // $6fcb
    eor #$ff                                    // $6fcd
    sec                                         // $6fcf
    sbc #$01                                    // $6fd0
L6fd2:
    ldx #$fd                                    // $6fd2
    sec                                         // $6fd4
L6fd5:
    inx                                         // $6fd5
    sbc #$33                                    // $6fd6
    bcs L6fd5                                   // $6fd8
    cpx #$03                                    // $6fda
    bne L6fe0                                   // $6fdc
    ldx #$02                                    // $6fde
L6fe0:
    rts                                         // $6fe0
D6fe1:
    .byte $1c,$3e,$3e,$3e,$1c                   // $6fe1
D6fe6:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       // $6fe6
D6fee:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       // $6fee
clear_char_2318:
    ldx #$07                                    // $6ff6
    lda #$00                                    // $6ff8
L6ffa:
    sta char($63),x                             // $6ffa
    dex                                         // $6ffd
    bpl L6ffa                                   // $6ffe
    rts                                         // $7000

// ----------------------------------------------------------------------------
// One frame of the ball dissolve: cycle the ball colour (sprite 3);
// returns C = 1 once the dissolve is complete (zp_fa = 0)
// ----------------------------------------------------------------------------
dissolve_frame:
    lda #$01                                    // $7001
    jsr wait_frames                             // $7003
    dec dissolve_time                           // $7006
    bpl L7063                                   // $7009
    ldx dissolve_step                           // $700b
    dex                                         // $700e
    bpl L7013                                   // $700f
    ldx #$05                                    // $7011
L7013:
    stx dissolve_step                           // $7013
    lda dissolve_durations,x                    // $7016
    sta dissolve_time                           // $7019
    lda dissolve_colours,x                      // $701c
    sta VIC_SPR3_COL                            // $701f
    cpx #$00                                    // $7022
    bne L702d                                   // $7024
    lda zp_fa                                   // $7026
    bne L702d                                   // $7028
    sec                                         // $702a
    bcs L706b                                   // $702b
L702d:
    cpx #$03                                    // $702d
    bne L7063                                   // $702f
    lda #$08                                    // $7031
    sta SID_V1_CTRL                             // $7033
    sta SID_V2_CTRL                             // $7036
    lda #$09                                    // $7039
    sta SID_V1_FREQ_HI                          // $703b
    sta SID_V2_FREQ_HI                          // $703e
    lda #$00                                    // $7041
    sta SID_V1_FREQ_LO                          // $7043
    lda #$28                                    // $7046
    sta SID_V2_FREQ_LO                          // $7048
    lda #$69                                    // $704b
    sta SID_V1_AD                               // $704d
    sta SID_V2_AD                               // $7050
    lda #$00                                    // $7053
    sta SID_V1_SR                               // $7055
    sta SID_V2_SR                               // $7058
    lda #$11                                    // $705b
    sta SID_V1_CTRL                             // $705d
    sta SID_V2_CTRL                             // $7060
L7063:
    lda zp_fa                                   // $7063
    bne L706a                                   // $7065
    jmp dissolve_frame                          // $7067
L706a:
    clc                                         // $706a
L706b:
    rts                                         // $706b
dissolve_durations:
    .byte $32,$02,$02,$02,$02,$02               // $706c
dissolve_colours:
    .byte $01,$0f,$0c,$0b,$0c,$0f               // $7072

// ----------------------------------------------------------------------------
// Machine init: zero the variables, status line, fonts, sprites, SID,
// raster IRQ (CINV = irq_handler), NMI (RESTORE) = nmi_handler
// ----------------------------------------------------------------------------
init_machine:
    sei                                         // $7078
    lda #$36                                    // $7079
    sta $01                                     // $707b
    lda #$00                                    // $707d
    sta VIC_BORDER                              // $707f
    lda #$0b                                    // $7082
    sta VIC_CTRL1                               // $7084
    lda #$00                                    // $7087
    ldx #$00                                    // $7089
L708b:
    sta ball_vx,x                               // $708b
    inx                                         // $708e
    bne L708b                                   // $708f
    lda #$ff                                    // $7091
    sta CIA1_DDRA                               // $7093
    lda #$01                                    // $7096
    sta no_restart                              // $7098
    lda #$08                                    // $709b
    sta screen_on                               // $709d
    lda #$07                                    // $70a0
    sta tilt_rate                               // $70a2
    ldx #$77                                    // $70a5
    lda #$20                                    // $70a7
L70a9:
    sta screen,x                                // $70a9
    dex                                         // $70ac
    bpl L70a9                                   // $70ad
    ldx #$27                                    // $70af
    lda #$01                                    // $70b1
L70b3:
    sta COLOR_RAM,x                             // $70b3
    dex                                         // $70b6
    bpl L70b3                                   // $70b7
    ldx #$ca                                    // $70b9
    ldy #$00                                    // $70bb
L70bd:
    jsr put_status_char                         // $70bd
    cpx #$cf                                    // $70c0
    bcc L70bd                                   // $70c2
    ldy #$0c                                    // $70c4
L70c6:
    jsr put_status_char                         // $70c6
    cpx #$d4                                    // $70c9
    bcc L70c6                                   // $70cb
    ldy #$18                                    // $70cd
L70cf:
    jsr put_status_char                         // $70cf
    cpx #$d9                                    // $70d2
    bcc L70cf                                   // $70d4
    ldy #$20                                    // $70d6
L70d8:
    jsr put_status_char                         // $70d8
    cpx #$db                                    // $70db
    bcc L70d8                                   // $70dd
    ldx #$4f                                    // $70df
L70e1:
    ldy #$07                                    // $70e1
L70e3:
    lda digit_glyphs,y                          // $70e3
    sta char($e6),x                             // $70e6
    dex                                         // $70e9
    dey                                         // $70ea
    bpl L70e3                                   // $70eb
    txa                                         // $70ed
    bpl L70e1                                   // $70ee
    ldx #$07                                    // $70f0
    lda #$00                                    // $70f2
L70f4:
    sta char($ec),x                             // $70f4
    sta char($ef),x                             // $70f7
    dex                                         // $70fa
    bpl L70f4                                   // $70fb
    ldy #$05                                    // $70fd
    ldx #$eb                                    // $70ff
L7101:
    txa                                         // $7101
    sta screen+5,y                              // $7102
    dex                                         // $7105
    dey                                         // $7106
    bpl L7101                                   // $7107
    ldy #$05                                    // $7109
    ldx #$f5                                    // $710b
L710d:
    txa                                         // $710d
    sta screen+34,y                             // $710e
    dex                                         // $7111
    dey                                         // $7112
    bpl L710d                                   // $7113
    lda #$ee                                    // $7115
    sta screen+29                               // $7117
    lda #$ef                                    // $711a
    sta screen+30                               // $711c
    jsr build_power_glyphs                      // $711f
    lda #$b4                                    // $7122
    sta screen+11                               // $7124
    sta screen+23                               // $7127
    sta screen+31                               // $712a
    jsr show_music_glyph                        // $712d
    lda #$00                                    // $7130
    jsr colour_status_marks                     // $7132
    ldx #$2f                                    // $7135
L7137:
    lda status_glyphs_25f0,x                    // $7137
    sta char($be),x                             // $713a
    dex                                         // $713d
    bpl L7137                                   // $713e
    ldx #$1f                                    // $7140
L7142:
    lda status_glyphs_2620,x                    // $7142
    sta char($c4),x                             // $7145
    dex                                         // $7148
    bpl L7142                                   // $7149
    lda dev_mode                                // $714b
    beq L7196                                   // $714e
    lda #$18                                    // $7150
    sta screen_on                               // $7152
    jsr init_game                               // $7155
    lda dev_maze                                // $7158
    sta maze                                    // $715b
    jsr draw_maze_screen                        // $715e
    jsr fill_colour_buffer                      // $7161
    jsr show_buffers                            // $7164
    lda #$01                                    // $7167
    sta tilt_enabled                            // $7169
    sta controls_enabled                        // $716c
    lda #$80                                    // $716f
    sta $028a                                   // $7171
    ldx #$1c                                    // $7174
L7176:
    lda $d6,x                                   // $7176  developer mode: save $D6-$F2 to $02E0
    sta $02e0,x                                 // $7178
    dex                                         // $717b
    bpl L7176                                   // $717c
    ldx #$18                                    // $717e
L7180:
    lda $da,x                                   // $7180
    and #$7f                                    // $7182
    sta $da,x                                   // $7184
    dex                                         // $7186
    bmi L7192                                   // $7187
    lda $da,x                                   // $7189
    ora #$80                                    // $718b
    sta $da,x                                   // $718d
    dex                                         // $718f
    bpl L7180                                   // $7190
L7192:
    lda #$ff                                    // $7192
    sta $d6                                     // $7194
L7196:
    lda #$18                                    // $7196
    sta VIC_MEMSETUP                            // $7198
    lda #$d8                                    // $719b
    sta VIC_CTRL2                               // $719d
    lda #$c0                                    // $71a0
    sta VIC_SPR_PRIORITY                        // $71a2
    lda #$00                                    // $71a5
    sta VIC_BG1                                 // $71a7
    lda #$01                                    // $71aa
    sta VIC_BG2                                 // $71ac
    lda #$ff                                    // $71af
    sta VIC_SPR_ENABLE                          // $71b1
    lda #$00                                    // $71b4
    sta VIC_SPR1_COL                            // $71b6
    lda #$01                                    // $71b9
    sta VIC_SPR3_COL                            // $71bb
    lda #$00                                    // $71be
    sta VIC_SPR4_COL                            // $71c0
    lda #$0f                                    // $71c3
    sta VIC_SPR6_COL                            // $71c5
    lda #$00                                    // $71c8
    sta VIC_SPR7_COL                            // $71ca
    lda #$00                                    // $71cd
    ldx #$3e                                    // $71cf
L71d1:
    sta sprite($c7),x                           // $71d1
    sta sprite($de),x                           // $71d4
    sta sprite($dd),x                           // $71d7
    dex                                         // $71da
    bpl L71d1                                   // $71db
    jsr sid_off                                 // $71dd
    lda #$44                                    // $71e0
    sta SID_RES_FILT                            // $71e2
    lda #$1f                                    // $71e5
    sta SID_MODE_VOL                            // $71e7
    ldx #$7f                                    // $71ea
    lda #$00                                    // $71ec
L71ee:
    sta char($01),x                             // $71ee
    dex                                         // $71f1
    bpl L71ee                                   // $71f2
    ldx #$07                                    // $71f4
L71f6:
    lda #$bb                                    // $71f6
    sta char($00),x                             // $71f8
    dex                                         // $71fb
    lda #$ee                                    // $71fc
    sta char($00),x                             // $71fe
    dex                                         // $7201
    bpl L71f6                                   // $7202
    ldx #$07                                    // $7204
L7206:
    lda char($00),x                             // $7206
    sta char($7c),x                             // $7209
    sta char($7e),x                             // $720c
    sta char($80),x                             // $720f
    sta char($82),x                             // $7212
    lda #$00                                    // $7215
    sta char($20),x                             // $7217
    sta char($b1),x                             // $721a
    sta char($b3),x                             // $721d
    lda #$55                                    // $7220
    sta char($a0),x                             // $7222
    dex                                         // $7225
    bpl L7206                                   // $7226
    lda #<irq_handler                           // $7228
    sta CINV                                    // $722a  raster IRQ -> irq_handler
    lda #>irq_handler                           // $722d
    sta CINV_HI                                 // $722f
    lda #$f1                                    // $7232
    sta VIC_IRQ_ENABLE                          // $7234
    lda #$00                                    // $7237
    sta CIA1_CRA                                // $7239
    sta VIC_RASTER                              // $723c
    lda #<nmi_handler                           // $723f
    sta NMINV                                   // $7241  NMI -> nmi_handler
    lda #>nmi_handler                           // $7244
    sta NMINV_HI                                // $7246
    ldx #$81                                    // $7249
    ldy #$ea                                    // $724b
    stx CBINV                                   // $724d  BRK -> $EA81 (KERNAL IRQ exit)
    sty CBINV_HI                                // $7250
    lda #$2a                                    // $7253  first raster IRQ at line $2A
    sta VIC_RASTER                              // $7255
    lda #$01                                    // $7258
    sta fine_scroll_y                           // $725a
    lda VIC_IRQ_STATUS                          // $725d
    sta VIC_IRQ_STATUS                          // $7260
    cli                                         // $7263

// ----------------------------------------------------------------------------
// Developer mode: print a CHR$(19) (HOME) and loop in CHRIN, so the
// BASIC editor keeps running while the game runs in the IRQ
// ----------------------------------------------------------------------------
    lda dev_mode                                // $7264
    beq L7282                                   // $7267
    lda #$13                                    // $7269
    jsr $f1ca                                   // $726b
dev_mode_basic:
    jsr CHRIN                                   // $726e
    jmp dev_mode_basic                          // $7271

// ----------------------------------------------------------------------------
// Never called: BASIC ROM back on, CLRCHN, then JMP $9BB3 (not part of
// this program - probably a leftover developer exit)
// ----------------------------------------------------------------------------
dev_exit_unused:
    lda #$37                                    // $7274
    sta $01                                     // $7276
    jsr CLRCHN                                  // $7278
    cld                                         // $727b
    cli                                         // $727c
    lda #$58                                    // $727d
    jmp $9bb3                                   // $727f
L7282:
    rts                                         // $7282

// ----------------------------------------------------------------------------
// Status line: screen code X at column Y, colour 7; X+1, Y+1
// ----------------------------------------------------------------------------
put_status_char:
    txa                                         // $7283
    sta screen,y                                // $7284
    lda #$07                                    // $7287
    sta COLOR_RAM,y                             // $7289
    inx                                         // $728c
    iny                                         // $728d
    rts                                         // $728e

// ----------------------------------------------------------------------------
// NMI (RESTORE key): counted in $CFB7, otherwise ignored
// ----------------------------------------------------------------------------
nmi_handler:
    inc nmi_count                               // $728f
    rti                                         // $7292
music_on_off_glyphs:
// char $b4  ($7293)
    .byte %00000000                             // $7293  ........
    .byte %00111100                             // $7294  ..####..
    .byte %00000000                             // $7295  ........
    .byte %11111111                             // $7296  ########
    .byte %00000000                             // $7297  ........
    .byte %11111111                             // $7298  ########
    .byte %00000000                             // $7299  ........
    .byte %00111100                             // $729a  ..####..
// char $b5  ($729b)
    .byte %00001000                             // $729b  ....#...
    .byte %00001100                             // $729c  ....##..
    .byte %00001010                             // $729d  ....#.#.
    .byte %00001001                             // $729e  ....#..#
    .byte %00001001                             // $729f  ....#..#
    .byte %01111000                             // $72a0  .####...
    .byte %11111000                             // $72a1  #####...
    .byte %01110000                             // $72a2  .###....
colour_power_bar:
    ldx #$05                                    // $72a3
L72a5:
    lda power_bar_colours,x                     // $72a5
    sta COLOR_RAM+17,x                          // $72a8
    dex                                         // $72ab
    bpl L72a5                                   // $72ac
    rts                                         // $72ae
power_bar_colours:
    .byte $00,$0e,$03,$0d,$07,$01               // $72af
mask_hole_sprite:
    ldx tilt_shift_x                            // $72b5
    lda D72f6,x                                 // $72b8
    sta zp_f8                                   // $72bb
    ldx tilt_shift_y                            // $72bd
    lda D72f6,x                                 // $72c0
    sta zp_f9                                   // $72c3
    lda hole_sprite                             // $72c5
    jsr build_sprite_mask                       // $72c8
    lda zp_fa                                   // $72cb
    beq L72d9                                   // $72cd
L72cf:
    lda (zp_fb),y                               // $72cf
    sta sprite($de),y                           // $72d1
    iny                                         // $72d4
    cpy zp_fa                                   // $72d5
    bcc L72cf                                   // $72d7
L72d9:
    lda (zp_fb),y                               // $72d9
    and sprite_mask_buffer,x                    // $72db
    sta sprite($de),y                           // $72de
    inx                                         // $72e1
    iny                                         // $72e2
    cpy zp_ff                                   // $72e3
    bcc L72d9                                   // $72e5
    cpy #$3f                                    // $72e7
    bcs L72f5                                   // $72e9
L72eb:
    lda (zp_fb),y                               // $72eb
    sta sprite($de),y                           // $72ed
    iny                                         // $72f0
    cpy #$3f                                    // $72f1
    bcc L72eb                                   // $72f3
L72f5:
    rts                                         // $72f5
D72f6:
    .byte $07,$06,$05,$05,$04,$04,$03,$02,$01   // $72f6

// ----------------------------------------------------------------------------
// POWER bar: six characters at $0411. power_hi ($CFB2) = 0-$30: full
// characters ($BC) for each 8, then a part character ($B4 + rest)
// ----------------------------------------------------------------------------
draw_power_bar:
    ldx #$05                                    // $72ff
    lda #$20                                    // $7301
L7303:
    sta screen+17,x                             // $7303
    dex                                         // $7306
    bpl L7303                                   // $7307
    lda power_hi                                // $7309
    lsr                                         // $730c
    lsr                                         // $730d
    lsr                                         // $730e
    tax                                         // $730f
    tay                                         // $7310
    beq L731c                                   // $7311
    dex                                         // $7313
    lda #$bc                                    // $7314
L7316:
    sta screen+17,x                             // $7316
    dex                                         // $7319
    bpl L7316                                   // $731a
L731c:
    lda power_hi                                // $731c
    and #$07                                    // $731f
    beq L7329                                   // $7321
    clc                                         // $7323
    adc #$b4                                    // $7324
    sta screen+17,y                             // $7326
L7329:
    rts                                         // $7329

// ----------------------------------------------------------------------------
// Params: A = signed change of the power (fraction units). Keeps
// power within 0 - $30:00 and redraws the bar
// ----------------------------------------------------------------------------
add_power:
    tax                                         // $732a
    bmi L7342                                   // $732b
    clc                                         // $732d
    adc power_lo                                // $732e
    tax                                         // $7331
    lda power_hi                                // $7332
    adc #$00                                    // $7335
    cmp #$30                                    // $7337
    bcc L7352                                   // $7339
    ldx #$00                                    // $733b
    lda #$30                                    // $733d
    jmp L7352                                   // $733f
L7342:
    clc                                         // $7342
    adc power_lo                                // $7343
    tax                                         // $7346
    lda power_hi                                // $7347
    sbc #$00                                    // $734a
    bpl L7352                                   // $734c
    ldx #$00                                    // $734e
    lda #$00                                    // $7350
L7352:
    stx power_lo                                // $7352
    sta power_hi                                // $7355
    jsr draw_power_bar                          // $7358
    rts                                         // $735b

// ----------------------------------------------------------------------------
// Refill the power bar one step per frame up to full (new game)
// ----------------------------------------------------------------------------
refill_power:
    lda power_refill                            // $735c
    beq L737e                                   // $735f
    lda power_hi                                // $7361
    cmp #$30                                    // $7364
    bcs L736e                                   // $7366
    inc power_hi                                // $7368
    jmp L737b                                   // $736b
L736e:
    lda #$00                                    // $736e
    sta power_refill                            // $7370
    sta power_lo                                // $7373
    lda #$30                                    // $7376
    sta power_hi                                // $7378
L737b:
    jsr draw_power_bar                          // $737b
L737e:
    rts                                         // $737e

// ----------------------------------------------------------------------------
// Each tilt "clunk" costs power. When it runs out while the ball is
// still rolling: BACKUP power (show_backup) - the next loss ends the game
// ----------------------------------------------------------------------------
drain_power:
    lda power_drain_on                          // $737f
    beq L73ca                                   // $7382
    lda tilt_enabled                            // $7384
    beq L73ca                                   // $7387
    lda clunk_state                             // $7389
    beq L73ca                                   // $738c
    lda #$f2                                    // $738e
    jsr add_power                               // $7390
    lda backup_allowed                          // $7393
    beq L73ca                                   // $7396
    lda power_hi                                // $7398
    bne L73ca                                   // $739b
    jsr show_backup                             // $739d
    lda #$01                                    // $73a0
    sta backup_power                            // $73a2
    sta backup_flash_step                       // $73a5
    lda #$28                                    // $73a8
    sta backup_alarm_freq                       // $73aa
    lda #$00                                    // $73ad
    sta power_drain_on                          // $73af
    lda #$00                                    // $73b2
    sta SID_V1_CTRL                             // $73b4
    sta SID_V1_FREQ_LO                          // $73b7
    sta SID_V1_FREQ_HI                          // $73ba
    sta SID_V1_AD                               // $73bd
    lda #$30                                    // $73c0
    sta SID_V1_SR                               // $73c2
    lda #$21                                    // $73c5
    sta SID_V1_CTRL                             // $73c7
L73ca:
    rts                                         // $73ca
build_power_glyphs:
    ldx #$3f                                    // $73cb
    lda #$00                                    // $73cd
L73cf:
    sta char($b5),x                             // $73cf
    dex                                         // $73d2
    bpl L73cf                                   // $73d3
    lda #$02                                    // $73d5
    sta zp_fa                                   // $73d7
    lda #$80                                    // $73d9
    sta zp_ff                                   // $73db
L73dd:
    ldx zp_fa                                   // $73dd
    ldy #$05                                    // $73df
    lda zp_ff                                   // $73e1
L73e3:
    sta char($b5),x                             // $73e3
    inx                                         // $73e6
    dey                                         // $73e7
    bne L73e3                                   // $73e8
    lda zp_fa                                   // $73ea
    clc                                         // $73ec
    adc #$08                                    // $73ed
    sta zp_fa                                   // $73ef
    sec                                         // $73f1
    ror zp_ff                                   // $73f2
    bcc L73dd                                   // $73f4
    rts                                         // $73f6

// ----------------------------------------------------------------------------
// Colour the floor marks: colour RAM of each mark = 1 (in hole) or 0
// ----------------------------------------------------------------------------
colour_marks:
    lda #$00                                    // $73f7
    ldx ball_in_hole                            // $73f9
    beq L7400                                   // $73fc
    lda #$01                                    // $73fe
L7400:
    sta zp_fa                                   // $7400
    ldy #$00                                    // $7402
    ldx mark_count                              // $7404
    beq L7429                                   // $7407
L7409:
    dex                                         // $7409
    lda colour_buffer,x                         // $740a
    sta zp_fd                                   // $740d
    lda colour_buffer+6*40+16,x                 // $740f
    sta zp_fe                                   // $7412
    lda (zp_fd),y                               // $7414
    cmp #$63                                    // $7416
    bne L7425                                   // $7418
    lda zp_fe                                   // $741a
    clc                                         // $741c
    adc #$d4                                    // $741d
    sta zp_fe                                   // $741f
    lda zp_fa                                   // $7421
    sta (zp_fd),y                               // $7423
L7425:
    cpx #$00                                    // $7425
    bne L7409                                   // $7427
L7429:
    rts                                         // $7429
set_char_2318:
    ldx #$07                                    // $742a
L742c:
    lda D7436,x                                 // $742c
    sta char($63),x                             // $742f
    dex                                         // $7432
    bpl L742c                                   // $7433
    rts                                         // $7435
D7436:
// char $63  ($7436)
    .byte %00000000                             // $7436  ........
    .byte %01111000                             // $7437  .####...
    .byte %00111100                             // $7438  ..####..
    .byte %00011110                             // $7439  ...####.
    .byte %01111111                             // $743a  .#######
    .byte %00111100                             // $743b  ..####..
    .byte %00011110                             // $743c  ...####.
    .byte %00001111                             // $743d  ....####

// ----------------------------------------------------------------------------
// Flash the "BACKUP" text and sound its alarm
// ----------------------------------------------------------------------------
flash_backup:
    ldx backup_power                            // $743e
    beq L7475                                   // $7441
    dex                                         // $7443
    bne L7464                                   // $7444
    ldy backup_flash_step                       // $7446
    dey                                         // $7449
    bpl L7453                                   // $744a
    ldy #$05                                    // $744c
    lda #$19                                    // $744e
    sta backup_alarm_freq                       // $7450
L7453:
    sty backup_flash_step                       // $7453
    ldx #$05                                    // $7456
    lda D7476,y                                 // $7458
L745b:
    sta COLOR_RAM+17,x                          // $745b
    dex                                         // $745e
    bpl L745b                                   // $745f
    ldx D747c,y                                 // $7461
L7464:
    stx backup_power                            // $7464
    lda backup_flash_step                       // $7467
    beq L746f                                   // $746a
    inc backup_alarm_freq                       // $746c
L746f:
    lda backup_alarm_freq                       // $746f
    sta SID_V1_FREQ_HI                          // $7472
L7475:
    rts                                         // $7475
D7476:
    .byte $01,$0f,$0c,$0b,$0c,$0f               // $7476
D747c:
    .byte $10,$03,$03,$03,$03,$03               // $747c

// ----------------------------------------------------------------------------
// Show "BACKUP" in the power bar (characters $BE-$C3)
// ----------------------------------------------------------------------------
show_backup:
    ldx #$05                                    // $7482
    ldy #$c3                                    // $7484
L7486:
    tya                                         // $7486
    sta screen+17,x                             // $7487
    lda #$01                                    // $748a
    sta COLOR_RAM+17,x                          // $748c
    dey                                         // $748f
    dex                                         // $7490
    bpl L7486                                   // $7491
    rts                                         // $7493
status_glyphs_25f0:
// char $be  ($7494)
    .byte %00000000                             // $7494  ........
    .byte %11111111                             // $7495  ########
    .byte %10000011                             // $7496  #.....##
    .byte %10011001                             // $7497  #..##..#
    .byte %10000011                             // $7498  #.....##
    .byte %10011001                             // $7499  #..##..#
    .byte %10000011                             // $749a  #.....##
    .byte %11111111                             // $749b  ########
// char $bf  ($749c)
    .byte %00000000                             // $749c  ........
    .byte %11111111                             // $749d  ########
    .byte %11000011                             // $749e  ##....##
    .byte %10011001                             // $749f  #..##..#
    .byte %10000001                             // $74a0  #......#
    .byte %10011001                             // $74a1  #..##..#
    .byte %10011001                             // $74a2  #..##..#
    .byte %11111111                             // $74a3  ########
// char $c0  ($74a4)
    .byte %00000000                             // $74a4  ........
    .byte %11111111                             // $74a5  ########
    .byte %11000011                             // $74a6  ##....##
    .byte %10011001                             // $74a7  #..##..#
    .byte %10011111                             // $74a8  #..#####
    .byte %10011001                             // $74a9  #..##..#
    .byte %11000011                             // $74aa  ##....##
    .byte %11111111                             // $74ab  ########
// char $c1  ($74ac)
    .byte %00000000                             // $74ac  ........
    .byte %11111111                             // $74ad  ########
    .byte %10011001                             // $74ae  #..##..#
    .byte %10010011                             // $74af  #..#..##
    .byte %10000111                             // $74b0  #....###
    .byte %10010011                             // $74b1  #..#..##
    .byte %10011001                             // $74b2  #..##..#
    .byte %11111111                             // $74b3  ########
// char $c2  ($74b4)
    .byte %00000000                             // $74b4  ........
    .byte %11111111                             // $74b5  ########
    .byte %10011001                             // $74b6  #..##..#
    .byte %10011001                             // $74b7  #..##..#
    .byte %10011001                             // $74b8  #..##..#
    .byte %10011001                             // $74b9  #..##..#
    .byte %11000011                             // $74ba  ##....##
    .byte %11111111                             // $74bb  ########
// char $c3  ($74bc)
    .byte %00000000                             // $74bc  ........
    .byte %11111111                             // $74bd  ########
    .byte %10000011                             // $74be  #.....##
    .byte %10011001                             // $74bf  #..##..#
    .byte %10000011                             // $74c0  #.....##
    .byte %10011111                             // $74c1  #..#####
    .byte %10011111                             // $74c2  #..#####
    .byte %11111111                             // $74c3  ########

// ----------------------------------------------------------------------------
// Show "OFF" in the power bar
// ----------------------------------------------------------------------------
show_power_off:
    ldx #$05                                    // $74c4
L74c6:
    lda power_off_text,x                        // $74c6
    sta screen+17,x                             // $74c9
    lda #$01                                    // $74cc
    sta COLOR_RAM+17,x                          // $74ce
    dex                                         // $74d1
    bpl L74c6                                   // $74d2
    rts                                         // $74d4
power_off_text:
    .byte $c6,$c4,$c5,$c5,$c7,$20               // $74d5  "..... "
status_glyphs_2620:
// char $c4  ($74db)
    .byte %00000000                             // $74db  ........
    .byte %11111111                             // $74dc  ########
    .byte %11000011                             // $74dd  ##....##
    .byte %10011001                             // $74de  #..##..#
    .byte %10011001                             // $74df  #..##..#
    .byte %10011001                             // $74e0  #..##..#
    .byte %11000011                             // $74e1  ##....##
    .byte %11111111                             // $74e2  ########
// char $c5  ($74e3)
    .byte %00000000                             // $74e3  ........
    .byte %11111111                             // $74e4  ########
    .byte %10000001                             // $74e5  #......#
    .byte %10011111                             // $74e6  #..#####
    .byte %10000111                             // $74e7  #....###
    .byte %10011111                             // $74e8  #..#####
    .byte %10011111                             // $74e9  #..#####
    .byte %11111111                             // $74ea  ########
// char $c6  ($74eb)
    .byte %00000000                             // $74eb  ........
    .byte %00000001                             // $74ec  .......#
    .byte %00000011                             // $74ed  ......##
    .byte %00000011                             // $74ee  ......##
    .byte %00000011                             // $74ef  ......##
    .byte %00000011                             // $74f0  ......##
    .byte %00000011                             // $74f1  ......##
    .byte %00000001                             // $74f2  .......#
// char $c7  ($74f3)
    .byte %00000000                             // $74f3  ........
    .byte %10000000                             // $74f4  #.......
    .byte %11000000                             // $74f5  ##......
    .byte %11000000                             // $74f6  ##......
    .byte %11000000                             // $74f7  ##......
    .byte %11000000                             // $74f8  ##......
    .byte %11000000                             // $74f9  ##......
    .byte %10000000                             // $74fa  #.......

// ----------------------------------------------------------------------------
// Bonus: A = power to add (doubled if the ball went into the hole)
// ----------------------------------------------------------------------------
bonus_power:
    ldx game_over                               // $74fb
    bne L751e                                   // $74fe
    ldx ball_in_hole                            // $7500
    beq L7506                                   // $7503
    asl                                         // $7505
L7506:
    clc                                         // $7506
    adc #$01                                    // $7507
    clc                                         // $7509
    adc power_hi                                // $750a
    cmp #$30                                    // $750d
    bcc L7518                                   // $750f
    ldx #$00                                    // $7511
    stx power_lo                                // $7513
    lda #$30                                    // $7516
L7518:
    sta power_hi                                // $7518
    jsr draw_power_bar                          // $751b
L751e:
    rts                                         // $751e

// ----------------------------------------------------------------------------
// Status line music glyph: note (on) or crossed note (off)
// ----------------------------------------------------------------------------
show_music_glyph:
    ldy #$07                                    // $751f
    lda cefa_flag                               // $7521
    beq L7528                                   // $7524
    ldy #$0f                                    // $7526
L7528:
    ldx #$07                                    // $7528
L752a:
    lda music_on_off_glyphs,y                   // $752a
    sta char($b4),x                             // $752d
    dey                                         // $7530
    dex                                         // $7531
    bpl L752a                                   // $7532
    rts                                         // $7534
set_glyph_lost:
    ldx #$07                                    // $7535
L7537:
    lda D7541,x                                 // $7537
    sta char($b4),x                             // $753a
    dex                                         // $753d
    bpl L7537                                   // $753e
    rts                                         // $7540
D7541:
// char $b4  ($7541)
    .byte %00000010                             // $7541  ......#.
    .byte %00001110                             // $7542  ....###.
    .byte %00000010                             // $7543  ......#.
    .byte %10010010                             // $7544  #..#..#.
    .byte %01100010                             // $7545  .##...#.
    .byte %10010010                             // $7546  #..#..#.
    .byte %00000010                             // $7547  ......#.
    .byte %00001111                             // $7548  ....####
set_glyph_done:
    ldx #$07                                    // $7549
L754b:
    lda D7555,x                                 // $754b
    sta char($b4),x                             // $754e
    dex                                         // $7551
    bpl L754b                                   // $7552
    rts                                         // $7554
D7555:
// char $b4  ($7555)
    .byte %00011110                             // $7555  ...####.
    .byte %00000001                             // $7556  .......#
    .byte %10010001                             // $7557  #..#...#
    .byte %01100001                             // $7558  .##....#
    .byte %10010010                             // $7559  #..#..#.
    .byte %00000100                             // $755a  .....#..
    .byte %00001000                             // $755b  ....#...
    .byte %00011111                             // $755c  ...#####
colour_status_marks:
    sta COLOR_RAM+11                            // $755d
    sta COLOR_RAM+23                            // $7560
    sta COLOR_RAM+31                            // $7563
    rts                                         // $7566

// ----------------------------------------------------------------------------
// Short sound when a diagonal tilt is held
// ----------------------------------------------------------------------------
diagonal_sound:
    ldx diagonal_sound_timer                    // $7567
    beq L7593                                   // $756a
    dec diagonal_sound_timer                    // $756c
    cpx #$02                                    // $756f
    bne L7582                                   // $7571
    lda #$46                                    // $7573
    sta SID_V2_FREQ_HI                          // $7575
    lda #$00                                    // $7578
    sta SID_V2_FREQ_LO                          // $757a
    lda #$21                                    // $757d
    sta SID_V2_CTRL                             // $757f
L7582:
    cpx #$01                                    // $7582
    bne L7593                                   // $7584
    lda #$11                                    // $7586
    sta SID_V2_CTRL                             // $7588
    lda #$00                                    // $758b
    sta SID_V2_FREQ_LO                          // $758d
    sta SID_V2_FREQ_HI                          // $7590
L7593:
    rts                                         // $7593

// ----------------------------------------------------------------------------
// Font for the status line ($2650-$26D7, characters $CA-$DA). The
// tamper check overwrites the first glyph here if the checksum is wrong.
// ----------------------------------------------------------------------------
status_font:
// char $ca  ($7594)
    .byte %00000000                             // $7594  ........
    .byte %00000000                             // $7595  ........
    .byte %00111110                             // $7596  ..#####.
    .byte %01100000                             // $7597  .##.....
    .byte %00111100                             // $7598  ..####..
    .byte %00000110                             // $7599  .....##.
    .byte %01111100                             // $759a  .#####..
    .byte %00000000                             // $759b  ........
// char $cb  ($759c)
    .byte %00000000                             // $759c  ........
    .byte %00000000                             // $759d  ........
    .byte %00111100                             // $759e  ..####..
    .byte %01100000                             // $759f  .##.....
    .byte %01100000                             // $75a0  .##.....
    .byte %01100000                             // $75a1  .##.....
    .byte %00111100                             // $75a2  ..####..
    .byte %00000000                             // $75a3  ........
// char $cc  ($75a4)
    .byte %00000000                             // $75a4  ........
    .byte %00000000                             // $75a5  ........
    .byte %01111000                             // $75a6  .####...
    .byte %11001100                             // $75a7  ##..##..
    .byte %11001100                             // $75a8  ##..##..
    .byte %11001100                             // $75a9  ##..##..
    .byte %01111000                             // $75aa  .####...
    .byte %00000000                             // $75ab  ........
// char $cd  ($75ac)
    .byte %00000000                             // $75ac  ........
    .byte %00000000                             // $75ad  ........
    .byte %11111000                             // $75ae  #####...
    .byte %11001100                             // $75af  ##..##..
    .byte %11111000                             // $75b0  #####...
    .byte %11011000                             // $75b1  ##.##...
    .byte %11001100                             // $75b2  ##..##..
    .byte %00000000                             // $75b3  ........
// char $ce  ($75b4)
    .byte %00000000                             // $75b4  ........
    .byte %00000000                             // $75b5  ........
    .byte %11111100                             // $75b6  ######..
    .byte %11000000                             // $75b7  ##......
    .byte %11110000                             // $75b8  ####....
    .byte %11000000                             // $75b9  ##......
    .byte %11111100                             // $75ba  ######..
    .byte %00000000                             // $75bb  ........
// char $cf  ($75bc)
    .byte %00000000                             // $75bc  ........
    .byte %00000000                             // $75bd  ........
    .byte %01111100                             // $75be  .#####..
    .byte %01100110                             // $75bf  .##..##.
    .byte %01111100                             // $75c0  .#####..
    .byte %01100000                             // $75c1  .##.....
    .byte %01100000                             // $75c2  .##.....
    .byte %00000000                             // $75c3  ........
// char $d0  ($75c4)
    .byte %00000000                             // $75c4  ........
    .byte %00000000                             // $75c5  ........
    .byte %00111100                             // $75c6  ..####..
    .byte %01100110                             // $75c7  .##..##.
    .byte %01100110                             // $75c8  .##..##.
    .byte %01100110                             // $75c9  .##..##.
    .byte %00111100                             // $75ca  ..####..
    .byte %00000000                             // $75cb  ........
// char $d1  ($75cc)
    .byte %00000000                             // $75cc  ........
    .byte %00000000                             // $75cd  ........
    .byte %01100011                             // $75ce  .##...##
    .byte %01100011                             // $75cf  .##...##
    .byte %01101011                             // $75d0  .##.#.##
    .byte %01111111                             // $75d1  .#######
    .byte %00110110                             // $75d2  ..##.##.
    .byte %00000000                             // $75d3  ........
// char $d2  ($75d4)
    .byte %00000000                             // $75d4  ........
    .byte %00000000                             // $75d5  ........
    .byte %00111111                             // $75d6  ..######
    .byte %00110000                             // $75d7  ..##....
    .byte %00111100                             // $75d8  ..####..
    .byte %00110000                             // $75d9  ..##....
    .byte %00111111                             // $75da  ..######
    .byte %00000000                             // $75db  ........
// char $d3  ($75dc)
    .byte %00000000                             // $75dc  ........
    .byte %00000000                             // $75dd  ........
    .byte %00111110                             // $75de  ..#####.
    .byte %00110011                             // $75df  ..##..##
    .byte %00111110                             // $75e0  ..#####.
    .byte %00110110                             // $75e1  ..##.##.
    .byte %00110011                             // $75e2  ..##..##
    .byte %00000000                             // $75e3  ........
// char $d4  ($75e4)
    .byte %00000000                             // $75e4  ........
    .byte %00000000                             // $75e5  ........
    .byte %01100000                             // $75e6  .##.....
    .byte %01100000                             // $75e7  .##.....
    .byte %01100000                             // $75e8  .##.....
    .byte %01100000                             // $75e9  .##.....
    .byte %01111110                             // $75ea  .######.
    .byte %00000000                             // $75eb  ........
// char $d5  ($75ec)
    .byte %00000000                             // $75ec  ........
    .byte %00000000                             // $75ed  ........
    .byte %01111110                             // $75ee  .######.
    .byte %01100000                             // $75ef  .##.....
    .byte %01111000                             // $75f0  .####...
    .byte %01100000                             // $75f1  .##.....
    .byte %01111110                             // $75f2  .######.
    .byte %00000000                             // $75f3  ........
// char $d6  ($75f4)
    .byte %00000000                             // $75f4  ........
    .byte %00000000                             // $75f5  ........
    .byte %01100110                             // $75f6  .##..##.
    .byte %01100110                             // $75f7  .##..##.
    .byte %01100110                             // $75f8  .##..##.
    .byte %00111100                             // $75f9  ..####..
    .byte %00011000                             // $75fa  ...##...
    .byte %00000000                             // $75fb  ........
// char $d7  ($75fc)
    .byte %00000000                             // $75fc  ........
    .byte %00000000                             // $75fd  ........
    .byte %01111110                             // $75fe  .######.
    .byte %01100000                             // $75ff  .##.....
    .byte %01111000                             // $7600  .####...
    .byte %01100000                             // $7601  .##.....
    .byte %01111110                             // $7602  .######.
    .byte %00000000                             // $7603  ........
// char $d8  ($7604)
    .byte %00000000                             // $7604  ........
    .byte %00000000                             // $7605  ........
    .byte %01100000                             // $7606  .##.....
    .byte %01100000                             // $7607  .##.....
    .byte %01100000                             // $7608  .##.....
    .byte %01100000                             // $7609  .##.....
    .byte %01111110                             // $760a  .######.
    .byte %00000000                             // $760b  ........
// char $d9  ($760c)
    .byte %00000000                             // $760c  ........
    .byte %00000000                             // $760d  ........
    .byte %01100110                             // $760e  .##..##.
    .byte %01100110                             // $760f  .##..##.
    .byte %01111110                             // $7610  .######.
    .byte %01100110                             // $7611  .##..##.
    .byte %01100110                             // $7612  .##..##.
    .byte %00000000                             // $7613  ........
// char $da  ($7614)
    .byte %00000000                             // $7614  ........
    .byte %00000000                             // $7615  ........
    .byte %00111100                             // $7616  ..####..
    .byte %00011000                             // $7617  ...##...
    .byte %00011000                             // $7618  ...##...
    .byte %00011000                             // $7619  ...##...
    .byte %00111100                             // $761a  ..####..
    .byte %00000000                             // $761b  ........

// ----------------------------------------------------------------------------
// Title screen: seven sprites ($A0-$A6) arranged as the big ball picture
// ----------------------------------------------------------------------------
title_sprites_layout:
    lda #$a2                                    // $761c
    sta VIC_SPR0_Y                              // $761e
    clc                                         // $7621
    adc #$15                                    // $7622
    sta VIC_SPR1_Y                              // $7624
    sta VIC_SPR2_Y                              // $7627
    sta VIC_SPR3_Y                              // $762a
    clc                                         // $762d
    adc #$15                                    // $762e
    sta VIC_SPR4_Y                              // $7630
    sta VIC_SPR5_Y                              // $7633
    sta VIC_SPR6_Y                              // $7636
    lda #$07                                    // $7639
    sta VIC_SPR1_X                              // $763b
    sta VIC_SPR4_X                              // $763e
    clc                                         // $7641
    adc #$18                                    // $7642
    sta VIC_SPR0_X                              // $7644
    sta VIC_SPR2_X                              // $7647
    sta VIC_SPR5_X                              // $764a
    clc                                         // $764d
    adc #$18                                    // $764e
    sta VIC_SPR3_X                              // $7650
    sta VIC_SPR6_X                              // $7653
    lda #$ff                                    // $7656
    sta VIC_SPR_X_MSB                           // $7658
    lda #$7f                                    // $765b
    sta VIC_SPR_ENABLE                          // $765d
    sta VIC_SPR_MULTICOLOR                      // $7660
    lda #$00                                    // $7663
    sta VIC_SPR_EXPAND_Y                        // $7665
    sta VIC_SPR_EXPAND_X                        // $7668
    sta VIC_SPR_PRIORITY                        // $766b
    lda #$07                                    // $766e
    sta VIC_SPR_MC0                             // $7670
    lda #$0e                                    // $7673
    sta VIC_SPR_MC1                             // $7675
    ldy #$a0                                    // $7678
    ldx #$00                                    // $767a
L767c:
    lda #$06                                    // $767c
    sta VIC_SPR0_COL,x                          // $767e
    tya                                         // $7681
    iny                                         // $7682
    sta sprite_ptrs,x                           // $7683
    inx                                         // $7686
    cpx #$08                                    // $7687
    bcc L767c                                   // $7689
    rts                                         // $768b

// ----------------------------------------------------------------------------
// Swap $2800-$29FF with title_sprites ($8D00-$8EFF)
// ----------------------------------------------------------------------------
swap_title_sprites:
    ldx #$00                                    // $768c
L768e:
    lda sprite($a0),x                           // $768e
    tay                                         // $7691
    lda title_sprites,x                         // $7692
    sta sprite($a0),x                           // $7695
    tya                                         // $7698
    sta title_sprites,x                         // $7699
    lda sprite($a4),x                           // $769c
    tay                                         // $769f
    lda D8e00,x                                 // $76a0
    sta sprite($a4),x                           // $76a3
    tya                                         // $76a6
    sta D8e00,x                                 // $76a7
    inx                                         // $76aa
    bne L768e                                   // $76ab
    rts                                         // $76ad
unused_76ae:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$f4,$ff,$ff,$ff  // $76ae
    .byte $df,$00,$00,$00,$00,$00,$cf,$00,$00,$00,$00,$00,$cf,$00,$09,$00  // $76be
    .byte $cf,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $76ce
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $76de
    .byte $00,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cc,$00,$00,$00  // $76ee
    .byte $00,$00,$83,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $76fe
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$cf,$ff,$ff,$ff,$ff  // $770e
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$df,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $771e
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$f4,$ff,$ff,$ff  // $772e
    .byte $df,$00,$00,$00,$00,$00,$cf,$00,$00,$00,$00,$00,$cf,$00,$09,$00  // $773e
    .byte $cf,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $774e
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $775e
    .byte $00,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cc,$00,$00,$00  // $776e
    .byte $00,$00,$8b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $777e
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$cf,$ff,$ff,$ff,$ff  // $778e
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$df,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $779e
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$7c,$ff,$ff,$ff  // $77ae
    .byte $df,$40,$00,$00,$00,$00,$cf,$00,$00,$00,$00,$00,$cf,$00,$01,$00  // $77be
    .byte $cf,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $77ce
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $77de
    .byte $00,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cc,$00,$00,$00  // $77ee
    .byte $00,$00                               // $77fe

    #import "mazes_2_3.asm"

    #import "music.asm"

// ============================================================================
// junk_8f00  ($8f00-$9fff)
// Not used: leftover RAM contents (a 256 byte KERNAL fragment, repeated)
// ============================================================================
* = $8f00 "junk_8f00"
junk_8f00:
    .import binary "bin/junk_8f00.bin"
    .assert "junk_8f00 size", * - junk_8f00, $1100

// ============================================================================
// maze_screens  ($a000-$afff)
// The four maze screens, 1K each, copied here at start-up
// ($2000-$27FF -> $A000, $7800-$7FFF -> $A800). The bytes here are leftovers.
// ============================================================================
* = $a000 "maze_screens"
maze_screens:
    .import binary "bin/maze_screens.bin"
    .assert "maze_screens size", * - maze_screens, $1000

// ============================================================================
// junk_b000  ($b000-$cdff)
// Not used: leftover RAM contents
// ============================================================================
* = $b000 "junk_b000"
junk_b000:
    .import binary "bin/junk_b000.bin"
    .assert "junk_b000 size", * - junk_b000, $1e00

// ============================================================================
// variables  ($ce00-$cfff)
// Game variables ($CE00-$CFFF, see the labels at the top of the file).
// The game sets them before use; the bytes here are leftovers.
// ============================================================================
* = $ce00 "variables"
variables:
    .import binary "bin/variables.bin"
    .assert "variables size", * - variables, $0200

// ============================================================================
// ram_d000  ($d000-$dfff)
// RAM under the I/O area: not used, leftovers
// ============================================================================
* = $d000 "ram_d000"
ram_d000:
    .import binary "bin/ram_d000.bin"
    .assert "ram_d000 size", * - ram_d000, $1000

// ============================================================================
// ram_e000  ($e000-$ffff)
// RAM under the KERNAL ROM: not used, leftovers (an unrelated picture)
// ============================================================================
* = $e000 "ram_e000"
ram_e000:
    .import binary "bin/ram_e000.bin"
    .assert "ram_e000 size", * - ram_e000, $2000

