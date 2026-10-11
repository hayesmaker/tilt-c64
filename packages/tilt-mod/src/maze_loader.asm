// ============================================================================
// tilt-mod: more mazes, loaded from the cartridge
//
// The original game has four mazes; all its per-maze tables have four entries
// and are indexed by `maze` (0-3). The mod keeps that code unchanged and turns
// the four entries into a ring of slots: maze n is played in slot n & 3. When a
// maze is due, load_maze switches the cartridge back on for a moment and copies
//   - the maze's 1K screen  -> $A000 + slot * $400   (read by draw_maze_screen)
//   - the maze's record     -> entry `slot` of hole_x_by_maze, hole_y_by_maze,
//                              ball_start_positions, maze_floor_colours,
//                              maze_frame_colours, and the slot's gates, gate
//                              count and 16 bit gate masks (gates16.asm)
// A level is maze 0 .. maze_count-1; then the level goes up and maze 0 follows.
//
// The loader lives at $C000: while the cartridge is read ($01 = $37) the
// BASIC ROM covers $A000-$BFFF, so code there would disappear. Writes to the
// $A000 slots still go to the RAM below the ROM.
//
// Cartridge layout (made by tools/mazes.py, packed by cart.asm):
//   bank 10 = directory:  $8000 maze count, $8001 demo maze,
//                         $8002-$8009 "TILTMAZE", $800A start level (0 = level 1),
//                         $8040 + n * 128 = record n
//   banks 11+ = screens, 8 per bank (bank and page are in the record)
// Record (128 bytes):
//   +0 hole X  +1 hole Y  +2/+3 ball start X (low, high)  +4 ball start Y
//   +5 floor colour  +6 frame colour  +7..+11 gate masks, gates 1-8, for level rows 0-4
//   +12..+35 gates 1-8: screen address low, high, orientation
//   +36 screen bank  +37 screen page ($80-$9C)
//   +38..+42 gate masks, gates 9-16, for level rows 0-4
//   +43 number of gates (0-16)
//   +44..+67 gates 9-16
// ============================================================================

.const MAZE_DIR_BANK  = 10
.const DIR_COUNT      = $8000
.const DIR_DEMO       = $8001
.const DIR_START      = $800a
.const DIR_RECORDS    = $8040
.const REC_HOLE_X     = 0
.const REC_HOLE_Y     = 1
.const REC_START      = 2
.const REC_FLOOR      = 5
.const REC_FRAME      = 6
.const REC_MASKS      = 7
.const REC_GATES      = 12
.const REC_BANK       = 36
.const REC_PAGE       = 37
.const REC_MASKS_HI   = 38
.const REC_GATE_COUNT = 43
.const REC_GATES_HI   = 44
.const REC_SIZE       = 128
.const CART_OFF       = $80                 // $DE00 bit 7: cartridge off

maze_number:    .byte 0                     // maze being played (0 .. maze_count-1)
maze_count:     .byte 4                     // mazes per level (from the directory)
demo_maze:      .byte 2                     // maze the demo plays
start_level:    .byte 0                     // level a game starts on (0 = level 1)
level_end:      .byte 0                     // 1 = the last maze of the level is done
record:         .fill REC_SIZE, 0           // copy of the current maze's record

// ----------------------------------------------------------------------------
// Replaces "sty maze" in init_game. Y = 0, or 2 in demo mode.
// ----------------------------------------------------------------------------
mod_init_mazes:
    sty maze_number
    jsr read_directory
    lda demo_mode
    beq !+
    lda demo_maze
    sta maze_number
    jmp !level_set+
!:  lda start_level                         // not the demo: the set's start level
    sta level                               // (init_game has just set level 1)
!level_set:
    lda #$00
    sta level_end
    jmp load_current

// ----------------------------------------------------------------------------
// Replaces "inc maze" in level_done: next maze, or the end of the level
// ----------------------------------------------------------------------------
mod_next_maze:
    inc maze_number
    lda maze_number
    cmp maze_count
    bcc load_current
    lda #$01
    sta level_end
    rts

// ----------------------------------------------------------------------------
// Replaces "inc level" in next_level_slide: level + 1, back to maze 0
// ----------------------------------------------------------------------------
mod_restart_mazes:
    inc level
    lda #$00
    sta maze_number
    sta level_end
    // fall through

// ----------------------------------------------------------------------------
// maze = maze_number & 3, and load maze_number into that slot
// ----------------------------------------------------------------------------
load_current:
    lda maze_number
    and #$03
    sta maze
    // fall through

// ----------------------------------------------------------------------------
// Load maze maze_number into slot `maze`
// ----------------------------------------------------------------------------
load_maze:
    php
    sei                                     // the IRQ code must not see the ROM at $8000
    lda $01
    pha
    lda #$37                                // ROML ($8000-$9FFF) needs LORAM = HIRAM = 1
    sta $01
    lda #MAZE_DIR_BANK
    sta $de00
    // record address = DIR_RECORDS + maze_number * 128
    lda maze_number
    lsr
    clc
    adc #>DIR_RECORDS
    sta rec_src + 2
    lda maze_number
    lsr
    lda #$00
    ror
    clc
    adc #<DIR_RECORDS
    sta rec_src + 1
    bcc !+
    inc rec_src + 2
!:  ldy #REC_SIZE - 1
rec_src:
    lda $ffff,y                             // self-modified: the record
    sta record,y
    dey
    bpl rec_src
    // screen: 4 pages from the record's bank / page to $A000 + slot * $400
    lda record + REC_BANK
    sta $de00
    lda record + REC_PAGE
    sta scr_src + 2
    lda maze
    asl
    asl
    clc
    adc #>$a000
    sta scr_dst + 2
    ldx #$04
    ldy #$00
scr_src:
    lda $ff00,y                             // self-modified: screen page
scr_dst:
    sta $ff00,y                             // self-modified: slot page
    iny
    bne scr_src
    inc scr_src + 2
    inc scr_dst + 2
    dex
    bne scr_src
    lda #CART_OFF
    sta $de00
    pla
    sta $01
    plp
    // the record into the slot's table entries
    ldx maze
    lda record + REC_HOLE_X
    sta hole_x_by_maze,x
    lda record + REC_HOLE_Y
    sta hole_y_by_maze,x
    lda record + REC_FLOOR
    sta maze_floor_colours,x
    lda record + REC_FRAME
    sta maze_frame_colours,x
    txa                                     // ball start: 3 bytes per slot
    asl
    adc maze
    tax
    lda record + REC_START
    sta ball_start_positions,x
    lda record + REC_START + 1
    sta ball_start_positions + 1,x
    lda record + REC_START + 2
    sta ball_start_positions + 2,x
    ldx maze                                // gate masks: one per level row (0-4)
    ldy #$00
!:  lda record + REC_MASKS,y
    sta gate_masks_lo,x
    lda record + REC_MASKS_HI,y
    sta gate_masks_hi,x
    txa
    clc
    adc #$04
    tax
    iny
    cpy #$05
    bne !-
    ldx maze                                // the slot's gates
    lda record + REC_GATE_COUNT
    sta gate_counts,x
    lda gate_slot_index,x
    tax
    ldy #$00
!:  lda record + REC_GATES,y                // gates 1-8
    sta gate_table16,x
    lda record + REC_GATES_HI,y             // gates 9-16
    sta gate_table16 + 24,x
    inx
    iny
    cpy #24
    bne !-
    rts

// ----------------------------------------------------------------------------
// Read the maze count and the demo maze from the directory bank
// ----------------------------------------------------------------------------
read_directory:
    php
    sei
    lda $01
    pha
    lda #$37
    sta $01
    lda #MAZE_DIR_BANK
    sta $de00
    lda DIR_COUNT
    bne !+
    lda #$01                                // at least one maze
!:  sta maze_count
    lda DIR_DEMO
    sta demo_maze
    lda DIR_START
    sta start_level
    lda #CART_OFF
    sta $de00
    pla
    sta $01
    plp
    rts

// ----------------------------------------------------------------------------
// Replaces "dex / sec / sbc hole_x_by_maze,x" in next_maze_slide:
// A - hole X of the previous maze, which is in slot (maze - 1) & 3
// ----------------------------------------------------------------------------
prev_slot_sbc:
    pha
    lda maze
    sec
    sbc #$01
    and #$03
    tax
    pla
    sec
    sbc hole_x_by_maze,x
    rts
