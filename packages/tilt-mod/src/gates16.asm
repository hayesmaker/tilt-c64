// ============================================================================
// tilt-mod: up to 16 gates per maze (the original has exactly 8)
//
// The original keeps 8 gates per maze slot in gate_table ($3991, 3 bytes each),
// one mask byte per slot and level row in gate_masks_by_level ($3979), and
// every gate routine loops exactly 8 times over the mask bits. The mod moves
// the gates into the tables below (16 entries per slot, a gate count per slot,
// 16 bit masks) and replaces the routines that loop over the gates:
//
//   draw_gates       $38CF  jmp mod_draw_gates
//   colour_gates     $419D  jmp mod_colour_gates (back into its loop at $41B0)
//   draw_tilt_gates  $67E1  jmp mod_draw_tilt_gates
//   find_gate        $6B17  jmp mod_find_gate
//   gate_hit         $6B5B  jsr mod_clear_gate_bit (16 bit mask)
//   fire_gates       $3B62, $3B89  jsr gate_mask_any (any fire gates?)
//
// draw_gate ($3939) and tilt_gate_hit_anim ($6C9A) read gate_table16 instead
// of gate_table. The old tables are no longer used.
//
// Gate mask bit k = gate k+1's kind on that level: 1 fire gate, 0 tilt gate.
// Gates k >= the slot's gate count do not exist (their mask bits are 0).
// ============================================================================

.const MAX_GATES  = 16
.const GATE_SLOT  = MAX_GATES * 3           // gate_table16 bytes per slot

gate_table16:      .fill 4 * GATE_SLOT, 0   // per slot: screen address low, high, orientation
gate_masks_lo:     .fill 5 * 4, 0           // level row r, slot s at r * 4 + s: gates 1-8
gate_masks_hi:     .fill 5 * 4, 0           //                                      gates 9-16
gate_counts:       .fill 4, 0               // gates in each slot (0-16)
gate_slot_index:   .byte 0, GATE_SLOT, 2 * GATE_SLOT, 3 * GATE_SLOT
gate_mask_hi:      .byte 0                  // gate_mask for gates 9-16
mask_hi_work:      .byte 0
found_bit_hi:      .byte 0                  // find_gate: bit of the found gate, high byte

// ----------------------------------------------------------------------------
// draw_gates for 16 gates (same interface).
// C = 0: redraw the fire gates on the screen when gate_frame changed
// C = 1: take the gate mask for the level and maze, draw the fire gates into
//        the screen buffer at $7C00
// ----------------------------------------------------------------------------
mod_draw_gates:
    lda #$00
    bcc !+
    lda #$78
!:  sta gate_page_add
    bcc !changed+
    lda level                               // level row: level, at most 4
    cmp #$04
    bcc !+
    lda #$04
!:  asl
    asl
    clc
    adc maze
    tax
    lda gate_masks_lo,x
    sta gate_mask
    lda gate_masks_hi,x
    sta gate_mask_hi
    lda #$00
    sta gate_gfx_offset
    sta gate_frame_old
    beq !draw+
!changed:
    lda gate_frame
    cmp gate_frame_old
    sta gate_frame_old
    beq !done+
    asl                                     // gate_gfx_offset = gate_frame * 10
    sta zp_fb
    asl
    asl
    clc
    adc zp_fb
    sta gate_gfx_offset
!draw:
    ldx maze
    lda gate_counts,x
    beq !done+
    sta gate_count
    lda gate_slot_index,x
    sta gate_index
    lda gate_mask
    sta zp_fa
    lda gate_mask_hi
    sta mask_hi_work
!loop:
    lsr mask_hi_work                        // next mask bit -> C
    ror zp_fa
    bcc !+
    jsr draw_gate
!:  lda gate_index
    clc
    adc #$03
    sta gate_index
    dec gate_count
    bne !loop-
!done:
    rts

// ----------------------------------------------------------------------------
// colour_gates for 16 gates: set up the slot's count and first entry, then
// run the original loop
// ----------------------------------------------------------------------------
mod_colour_gates:
    ldx maze
    lda gate_counts,x
    beq !+
    sta gate_count
    lda gate_slot_index,x
    sta gate_index
    lda #$00
    sta gate_gfx_offset
    jmp L41b0
!:  rts

// ----------------------------------------------------------------------------
// draw_tilt_gates for 16 gates: draw the tilt gates (mask bit 0) into the
// screen buffer at $7C00
// ----------------------------------------------------------------------------
mod_draw_tilt_gates:
    ldx maze
    lda gate_counts,x
    beq !done+
    sta zp_ff
    lda gate_slot_index,x
    sta zp_fb
    lda gate_mask
    sta zp_fa
    lda gate_mask_hi
    sta mask_hi_work
!loop:
    lsr mask_hi_work                        // next mask bit -> C
    ror zp_fa
    bcs !next+                              // fire gate: drawn by draw_gates
    ldx zp_fb
    lda gate_table16,x
    sta zp_fd
    inx
    lda gate_table16,x
    clc
    adc #$78
    sta zp_fe
    inx
    ldy #$00                                // orientation 0: vertical bar, else horizontal
    lda gate_table16,x
    beq !+
    ldy #$03
!:  sty zp_f9
    lda #$02
    sta zp_fc
    ldx zp_f9
!cell:
    lda gate_cell_layout,x
    tay
    lda tilt_gate_chars,x
    sta (zp_fd),y
    inx
    dec zp_fc
    bpl !cell-
!next:
    lda zp_fb
    clc
    adc #$03
    sta zp_fb
    dec zp_ff
    bne !loop-
!done:
    rts

// ----------------------------------------------------------------------------
// find_gate for 16 gates (same interface). zp_fd/zp_fe = screen address,
// A = offset. C = 0 found: zp_fa = gate_table16 index, zp_ff / found_bit_hi =
// its mask bit. C = 1 not found.
// ----------------------------------------------------------------------------
mod_find_gate:
    sta zp_fa
    lda zp_fd
    sec
    sbc zp_fa
    sta zp_fb
    lda zp_fe
    sbc #$00
    sta zp_fc
    ldx maze
    lda gate_counts,x
    beq !notfound+
    tay
    lda gate_slot_index,x
    sta zp_fa
    lda #$01
    sta zp_ff
    lda #$00
    sta found_bit_hi
!loop:
    ldx zp_fa
    lda gate_table16,x
    cmp zp_fb
    bne !next+
    inx
    lda gate_table16,x
    cmp zp_fc
    beq !found+
!next:
    lda zp_fa
    clc
    adc #$03
    sta zp_fa
    asl zp_ff
    rol found_bit_hi
    dey
    bne !loop-
!notfound:
    sec
    rts
!found:
    clc
    rts

// ----------------------------------------------------------------------------
// gate_hit: take the found gate (zp_ff / found_bit_hi) out of the mask
// ----------------------------------------------------------------------------
mod_clear_gate_bit:
    lda zp_ff
    eor #$ff
    and gate_mask
    sta gate_mask
    lda found_bit_hi
    eor #$ff
    and gate_mask_hi
    sta gate_mask_hi
    rts

// ----------------------------------------------------------------------------
// fire_gates: Z = 1 when the maze has no fire gates on this level
// ----------------------------------------------------------------------------
gate_mask_any:
    lda gate_mask
    ora gate_mask_hi
    rts
