// ============================================================================
// music.asm - Music driver and data, title screen sprites
// Included from tilt.asm. Addresses $8000-$8eff
// ============================================================================

// ----------------------------------------------------------------------------
// Music command, written by the game, read by music_play every frame:
//   0       stop the music
//   1-5     start tune n (1 title, 3 level start, 4 game over)
//   $FF     keep playing (music_play writes $FF back after each call)
// ----------------------------------------------------------------------------
music_command:
    .byte $00                                   // $8000

// ----------------------------------------------------------------------------
// Music driver: call once per frame. Three voices; each voice reads a
// sequence of patterns. Pattern bytes:
//   $FF          end of pattern: next pattern of the sequence
//   $FE          end of the tune: stop
//   $FD vol      set $D418
//   $F0-$FC      speed (low nybble)
//   $C0-$DF      instrument (low 5 bits)
//   $80-$BF      note length (low 6 bits)
//   $7B n d      portamento to note n, speed d
//   $7A d        delay before vibrato
//   $00-$5F      note (+ transpose of the sequence); 0 = rest
// ----------------------------------------------------------------------------
music_play:
    lda music_command                           // $8001
    bne music_start_tune                        // $8004
    sta music_playing                           // $8006
    jsr music_sid_clear                         // $8009
music_done:
    jmp L8472                                   // $800c
music_start_tune:
    cmp #$06                                    // $800f
    bcs music_tick                              // $8011
    sbc #$00                                    // $8013
    asl                                         // $8015
    sta L801a+1                                 // $8016
    asl                                         // $8019
L801a:
    adc #$00                                    // $801a
    tay                                         // $801c
    ldx #$00                                    // $801d
L801f:
    lda tune_table,y                            // $801f
    sta mus_seq_lo,x                            // $8022
    iny                                         // $8025
    lda tune_table,y                            // $8026
    sta mus_seq_hi,x                            // $8029
    iny                                         // $802c
    inx                                         // $802d
    cpx #$03                                    // $802e
    bne L801f                                   // $8030
    ldx #$02                                    // $8032
L8034:
    lda #$00                                    // $8034
    sta mus_length_count,x                      // $8036
    sta mus_porta_state,x                       // $8039
    sta mus_seq_pos,x                           // $803c
    jsr music_next_pattern                      // $803f
    dex                                         // $8042
    bpl L8034                                   // $8043
    jsr music_init                              // $8045
    lda #$01                                    // $8048
    sta music_playing                           // $804a
    jmp L8472                                   // $804d
music_tick:
    lda music_playing                           // $8050
    beq music_done                              // $8053
    inc mus_note_age                            // $8055
    inc D86ca                                   // $8058
    inc D86cb                                   // $805b
music_top_voice:                                // tilt-mod: label (ingame_music.asm sets the operand)
    ldx #$02                                    // $805e
    stx music_voice                             // $8060
music_voice_loop:
    ldx music_voice                             // $8063
    lda voice_reg_offset,x                      // $8066
    sta mus_sid_offset                          // $8069
    lda music_speed_count                       // $806c
    bne L8084                                   // $806f
    dec mus_length_count,x                      // $8071
    bmi music_next_note                         // $8074
    lda mus_slide_up,x                          // $8076
    beq L8095                                   // $8079
    inc mus_note,x                              // $807b
    jsr music_set_freq                          // $807e
    jmp music_voice_end                         // $8081
L8084:
    lda mus_slide_down,x                        // $8084
    beq L8095                                   // $8087
    dec mus_slide_down,x                        // $8089
    dec mus_note,x                              // $808c
    jsr music_set_freq                          // $808f
    jmp music_voice_end                         // $8092
L8095:
    jmp music_effects                           // $8095
music_next_note:
    lda #$00                                    // $8098
    ldy mus_porta_state,x                       // $809a
    cpy #$02                                    // $809d
    beq L80a7                                   // $809f
    sta mus_arp_mask,x                          // $80a1
    sta mus_porta_state,x                       // $80a4
L80a7:
    sta mus_read_pos                            // $80a7
    sta mus_porta_target,x                      // $80aa
    sta mus_slide_up,x                          // $80ad
    lda #$03                                    // $80b0
    sta mus_86c6,x                              // $80b2
    lda mus_pattern_lo,x                        // $80b5
    sta $a7                                     // $80b8
    lda mus_pattern_hi,x                        // $80ba
    sta $a8                                     // $80bd
music_read_pattern:
    ldy mus_read_pos                            // $80bf
    inc mus_read_pos                            // $80c2
    lda ($a7),y                                 // $80c5
    iny                                         // $80c7
    cmp #$ff                                    // $80c8
    bne L80d7                                   // $80ca
    jsr music_next_pattern                      // $80cc
    lda #$00                                    // $80cf
    sta mus_read_pos                            // $80d1
    jmp music_read_pattern                      // $80d4
L80d7:
    cmp #$fe                                    // $80d7
    bne L80e3                                   // $80d9
    lda #$00                                    // $80db
    sta music_command                           // $80dd
    jmp music_play                              // $80e0
L80e3:
    cmp #$fd                                    // $80e3
    bne L80f4                                   // $80e5
    lda ($a7),y                                 // $80e7
    iny                                         // $80e9
    sta SID_MODE_VOL                            // $80ea
    lda ($a7),y                                 // $80ed
    iny                                         // $80ef
    cmp #$ff                                    // $80f0
    beq music_read_pattern                      // $80f2
L80f4:
    cmp #$f0                                    // $80f4
    bcc L8100                                   // $80f6
    and #$0f                                    // $80f8
    sta music_speed                             // $80fa
    lda ($a7),y                                 // $80fd
    iny                                         // $80ff
L8100:
    cmp #$c0                                    // $8100
    bcc L810f                                   // $8102
    and #$1f                                    // $8104
    asl                                         // $8106
    asl                                         // $8107
    asl                                         // $8108
    sta mus_instrument,x                        // $8109
    lda ($a7),y                                 // $810c
    iny                                         // $810e
L810f:
    cmp #$80                                    // $810f
    bcc L811b                                   // $8111
    and #$3f                                    // $8113
    sta mus_length,x                            // $8115
    lda ($a7),y                                 // $8118
    iny                                         // $811a
L811b:
    cmp #$60                                    // $811b
    bcc L814d                                   // $811d
    cmp #$7b                                    // $811f
    bne L8140                                   // $8121
    lda #$00                                    // $8123
    sta mus_arp_mask,x                          // $8125
    lda #$01                                    // $8128
    sta mus_porta_state,x                       // $812a
    lda ($a7),y                                 // $812d
    iny                                         // $812f
    clc                                         // $8130
    adc mus_transpose,x                         // $8131
    sta mus_porta_target,x                      // $8134
    lda ($a7),y                                 // $8137
    iny                                         // $8139
    sta mus_porta_speed,x                       // $813a
    jmp L814a                                   // $813d
L8140:
    cmp #$7a                                    // $8140
    bne L814d                                   // $8142
    lda ($a7),y                                 // $8144
    iny                                         // $8146
    sta mus_vib_delay,x                         // $8147
L814a:
    lda ($a7),y                                 // $814a
    iny                                         // $814c
L814d:
    sty mus_read_pos                            // $814d
    clc                                         // $8150
    adc mus_transpose,x                         // $8151
    sta mus_note,x                              // $8154
    pha                                         // $8157
    ldy mus_instrument,x                        // $8158
    lda #$ff                                    // $815b
    sta mus_note_age,x                          // $815d
    lda instruments+3,y                         // $8160
    sta L8179+1                                 // $8163
    pla                                         // $8166
    beq L8176                                   // $8167
    lda mus_arp_mask,x                          // $8169
    bne L8176                                   // $816c
    lda instruments+6,y                         // $816e
    beq L8176                                   // $8171
    sta mus_arp_mask,x                          // $8173
L8176:
    jsr music_set_freq                          // $8176
L8179:
    lda #$00                                    // $8179
    ldy mus_sid_offset                          // $817b
    pha                                         // $817e
    and #$f0                                    // $817f
    sta mus_pulse_lo,x                          // $8181
    sta SID_V1_PW_LO,y                          // $8184
    pla                                         // $8187
    and #$0f                                    // $8188
    sta mus_pulse_hi,x                          // $818a
    sta SID_V1_PW_HI,y                          // $818d
    lda D8666,x                                 // $8190
    beq L81b4                                   // $8193
    lda mus_instrument,x                        // $8195
    tax                                         // $8198
    lda instruments+1,x                         // $8199
    sta SID_V1_AD,y                             // $819c
    lda instruments+2,x                         // $819f
    sta SID_V1_SR,y                             // $81a2
    lda #$00                                    // $81a5
    sta SID_V1_CTRL,y                           // $81a7
    lda instruments,x                           // $81aa
    and #$f0                                    // $81ad
    ora #$05                                    // $81af
    sta SID_V1_CTRL,y                           // $81b1
L81b4:
    ldx music_voice                             // $81b4
    lda mus_pattern_lo,x                        // $81b7
    clc                                         // $81ba
    adc mus_read_pos                            // $81bb
    sta mus_pattern_lo,x                        // $81be
    bcc L81c6                                   // $81c1
    inc mus_pattern_hi,x                        // $81c3
L81c6:
    lda mus_length,x                            // $81c6
    sta mus_length_count,x                      // $81c9
    lda mus_vib_delay,x                         // $81cc
    sta mus_vib_delay_count,x                   // $81cf
    ldy voice_arp_offset,x                      // $81d2
    iny                                         // $81d5
    tya                                         // $81d6
    sta mus_arp_pos,x                           // $81d7
    jmp music_voice_end                         // $81da

// ----------------------------------------------------------------------------
// Per-frame effects while a note is held: drums, vibrato, arpeggio, portamento
// ----------------------------------------------------------------------------
music_effects:
    lda mus_note,x                              // $81dd
    beq L81ef                                   // $81e0
    ldy mus_instrument,x                        // $81e2
    lda instruments+7,y                         // $81e5
    and #$08                                    // $81e8
    beq L81f2                                   // $81ea
    jmp L8257                                   // $81ec
L81ef:
    jmp music_voice_end                         // $81ef
L81f2:
    lda instruments+7,y                         // $81f2
    and #$04                                    // $81f5
    beq L81fc                                   // $81f7
    jmp L8273                                   // $81f9
L81fc:
    ldy mus_instrument,x                        // $81fc
    lda instruments+7,y                         // $81ff
    ldy mus_sid_offset                          // $8202
    and #$01                                    // $8205
    beq L8254                                   // $8207
    ldy mus_instrument,x                        // $8209
    lda instruments+4,y                         // $820c
    and #$0f                                    // $820f
    asl                                         // $8211
    asl                                         // $8212
    tay                                         // $8213
    lda drum_tables,y                           // $8214
    sta L8235+1                                 // $8217
    lda drum_tables+1,y                         // $821a
    sta L8235+2                                 // $821d
    lda drum_tables+2,y                         // $8220
    sta L8240+1                                 // $8223
    lda drum_tables+3,y                         // $8226
    sta L8240+2                                 // $8229
    lda mus_note_age,x                          // $822c
    cmp #$1f                                    // $822f
    bcs L8254                                   // $8231
    pha                                         // $8233
    tay                                         // $8234
L8235:
    lda D8705,y                                 // $8235
    ldy mus_sid_offset                          // $8238
    sta SID_V1_CTRL,y                           // $823b
    pla                                         // $823e
    tay                                         // $823f
L8240:
    lda drum_data,y                             // $8240
    ldy mus_sid_offset                          // $8243
    clc                                         // $8246
    adc #$0d                                    // $8247
    sta SID_V1_FREQ_HI,y                        // $8249
    lda #$00                                    // $824c
    sta SID_V1_FREQ_LO,y                        // $824e
    jmp music_voice_end                         // $8251
L8254:
    jmp music_vibrato                           // $8254
L8257:
    ldy mus_instrument,x                        // $8257
    lda mus_note_age,x                          // $825a
    cmp #$01                                    // $825d
    bcs L828f                                   // $825f
    lda #$48                                    // $8261
    ldy mus_sid_offset                          // $8263
    sta SID_V1_FREQ_HI,y                        // $8266
    lda #$00                                    // $8269
    sta SID_V1_FREQ_LO,y                        // $826b
    lda #$81                                    // $826e
    jmp L8298                                   // $8270
L8273:
    ldy mus_instrument,x                        // $8273
    lda mus_note_age,x                          // $8276
    cmp #$01                                    // $8279
    bcs L828f                                   // $827b
    lda #$48                                    // $827d
    ldy mus_sid_offset                          // $827f
    sta SID_V1_FREQ_HI,y                        // $8282
    lda #$00                                    // $8285
    sta SID_V1_FREQ_LO,y                        // $8287
    lda #$11                                    // $828a
    jmp L8298                                   // $828c
L828f:
    jsr music_set_freq                          // $828f
    ldy mus_instrument,x                        // $8292
    lda instruments,y                           // $8295
L8298:
    ldy mus_sid_offset                          // $8298
    sta SID_V1_CTRL,y                           // $829b
    jmp music_voice_end                         // $829e
music_vibrato:
    lda mus_porta_state,x                       // $82a1
    bne L82ae                                   // $82a4
    ldy mus_instrument,x                        // $82a6
    lda instruments+4,y                         // $82a9
    bne L82b1                                   // $82ac
L82ae:
    jmp music_arpeggio                          // $82ae
L82b1:
    pha                                         // $82b1
    and #$0f                                    // $82b2
    sta mus_vib_shift                           // $82b4
    pla                                         // $82b7
    lsr                                         // $82b8
    lsr                                         // $82b9
    lsr                                         // $82ba
    lsr                                         // $82bb
    sta mus_vib_depth                           // $82bc
    ldy mus_note,x                              // $82bf
    lda note_freq_lo+1,y                        // $82c2
    sec                                         // $82c5
    sbc note_freq_lo,y                          // $82c6
    sta mus_vib_step_lo                         // $82c9
    lda note_freq_hi+1,y                        // $82cc
    sbc note_freq_hi,y                          // $82cf
    sta mus_vib_step_hi                         // $82d2
L82d5:
    dec mus_vib_shift                           // $82d5
    bmi L82e3                                   // $82d8
    lsr mus_vib_step_hi                         // $82da
    ror mus_vib_step_lo                         // $82dd
    jmp L82d5                                   // $82e0
L82e3:
    lda mus_vib_dir,x                           // $82e3
    bpl L82f2                                   // $82e6
    dec mus_vib_pos,x                           // $82e8
    bne L8300                                   // $82eb
    inc mus_vib_dir,x                           // $82ed
    bpl L8300                                   // $82f0
L82f2:
    inc mus_vib_pos,x                           // $82f2
    lda mus_vib_pos,x                           // $82f5
    cmp mus_vib_depth                           // $82f8
    bcc L8300                                   // $82fb
    dec mus_vib_dir,x                           // $82fd
L8300:
    lda mus_vib_delay_count,x                   // $8300
    beq L830b                                   // $8303
    dec mus_vib_delay_count,x                   // $8305
    jmp music_voice_end                         // $8308
L830b:
    lda mus_freq_lo,x                           // $830b
    sta mus_vib_freq_lo                         // $830e
    lda mus_freq_hi,x                           // $8311
    sta mus_vib_freq_hi                         // $8314
    lda mus_vib_depth                           // $8317
    lsr                                         // $831a
    tay                                         // $831b
L831c:
    dey                                         // $831c
    bmi L8335                                   // $831d
    lda mus_vib_freq_lo                         // $831f
    sec                                         // $8322
    sbc mus_vib_step_lo                         // $8323
    sta mus_vib_freq_lo                         // $8326
    lda mus_vib_freq_hi                         // $8329
    sbc mus_vib_step_hi                         // $832c
    sta mus_vib_freq_hi                         // $832f
    jmp L831c                                   // $8332
L8335:
    ldy mus_vib_pos,x                           // $8335
L8338:
    dey                                         // $8338
    bmi L8351                                   // $8339
    lda mus_vib_freq_lo                         // $833b
    clc                                         // $833e
    adc mus_vib_step_lo                         // $833f
    sta mus_vib_freq_lo                         // $8342
    lda mus_vib_freq_hi                         // $8345
    adc mus_vib_step_hi                         // $8348
    sta mus_vib_freq_hi                         // $834b
    jmp L8338                                   // $834e
L8351:
    ldy mus_sid_offset                          // $8351
    lda mus_vib_freq_lo                         // $8354
    sta SID_V1_FREQ_LO,y                        // $8357
    lda mus_vib_freq_hi                         // $835a
    sta SID_V1_FREQ_HI,y                        // $835d
    jmp music_voice_end                         // $8360
music_arpeggio:
    lda mus_arp_mask,x                          // $8363
    beq music_portamento                        // $8366
    sta mus_arp_bits                            // $8368
    jsr music_build_arpeggio                    // $836b
L836e:
    ldy mus_arp_pos,x                           // $836e
    lda mus_arp_tables,y                        // $8371
    cmp #$ff                                    // $8374
    bne L8381                                   // $8376
    lda voice_arp_offset,x                      // $8378
    sta mus_arp_pos,x                           // $837b
    jmp L836e                                   // $837e
L8381:
    clc                                         // $8381
    adc mus_note,x                              // $8382
    ldy mus_sid_offset                          // $8385
    tax                                         // $8388
    lda note_freq_lo,x                          // $8389
    sta SID_V1_FREQ_LO,y                        // $838c
    lda note_freq_hi,x                          // $838f
    sta SID_V1_FREQ_HI,y                        // $8392
    ldx music_voice                             // $8395
    inc mus_arp_pos,x                           // $8398
    jmp music_voice_end                         // $839b
music_portamento:
    lda mus_porta_target,x                      // $839e
    beq music_voice_end                         // $83a1
    sta music_calc_slide+1                      // $83a3
    lda mus_porta_speed,x                       // $83a6
    pha                                         // $83a9
    and #$0f                                    // $83aa
    sta L83c0+1                                 // $83ac
    sta L854e+1                                 // $83af
    pla                                         // $83b2
    lsr                                         // $83b3
    lsr                                         // $83b4
    lsr                                         // $83b5
    lsr                                         // $83b6
    clc                                         // $83b7
    adc mus_length_count,x                      // $83b8
    cmp mus_length,x                            // $83bb
    bcs music_voice_end                         // $83be
L83c0:
    adc #$00                                    // $83c0
    cmp mus_length,x                            // $83c2
    bcc music_voice_end                         // $83c5
    ldy mus_note,x                              // $83c7
    jsr music_calc_slide                        // $83ca
    ldx music_voice                             // $83cd
    ldy mus_sid_offset                          // $83d0
    lda mus_freq_lo,x                           // $83d3
L83d6:
    clc                                         // $83d6
L83d7:
    adc mus_porta_step_lo                       // $83d7
    sta mus_freq_lo,x                           // $83da
    sta SID_V1_FREQ_LO,y                        // $83dd
    lda mus_freq_hi,x                           // $83e0
L83e3:
    adc mus_porta_step_hi                       // $83e3
    sta mus_freq_hi,x                           // $83e6
    sta SID_V1_FREQ_HI,y                        // $83e9
music_voice_end:
    lda mus_length,x                            // $83ec
    beq music_pulse_sweep                       // $83ef
    lsr                                         // $83f1
    cmp mus_length_count,x                      // $83f2
    bne music_pulse_sweep                       // $83f5
    ldy mus_instrument,x                        // $83f7
    lda instruments,y                           // $83fa
    and #$0f                                    // $83fd
    clc                                         // $83ff
    rol                                         // $8400
    rol                                         // $8401
    rol                                         // $8402
    rol                                         // $8403
    ldy mus_sid_offset                          // $8404
    sta SID_V1_CTRL,y                           // $8407
music_pulse_sweep:
    ldy mus_instrument,x                        // $840a
    lda instruments+5,y                         // $840d
    beq L845f                                   // $8410
    lda mus_pulse_dir,x                         // $8412
    bne L8437                                   // $8415
    lda mus_pulse_lo,x                          // $8417
    clc                                         // $841a
    adc instruments+5,y                         // $841b
    pha                                         // $841e
    sta mus_pulse_lo,x                          // $841f
    lda mus_pulse_hi,x                          // $8422
    adc #$00                                    // $8425
    sta mus_pulse_hi,x                          // $8427
    pha                                         // $842a
    cmp #$0f                                    // $842b
    bcc L8454                                   // $842d
    lda #$01                                    // $842f
    sta mus_pulse_dir,x                         // $8431
    jmp L8454                                   // $8434
L8437:
    lda mus_pulse_lo,x                          // $8437
    sec                                         // $843a
    sbc instruments+5,y                         // $843b
    pha                                         // $843e
    sta mus_pulse_lo,x                          // $843f
    lda mus_pulse_hi,x                          // $8442
    sbc #$00                                    // $8445
    sta mus_pulse_hi,x                          // $8447
    pha                                         // $844a
    cmp #$08                                    // $844b
    bcs L8454                                   // $844d
    lda #$00                                    // $844f
    sta mus_pulse_dir,x                         // $8451
L8454:
    ldy mus_sid_offset                          // $8454
    pla                                         // $8457
    sta SID_V1_PW_HI,y                          // $8458
    pla                                         // $845b
    sta SID_V1_PW_LO,y                          // $845c
L845f:
    dec music_voice                             // $845f
    bmi L8467                                   // $8462
    jmp music_voice_loop                        // $8464
L8467:
    dec music_speed_count                       // $8467
    bpl L8472                                   // $846a
    lda music_speed                             // $846c
    sta music_speed_count                       // $846f
L8472:
    lda #$ff                                    // $8472
    sta music_command                           // $8474
    rts                                         // $8477

// ----------------------------------------------------------------------------
// Clear all SID registers
// ----------------------------------------------------------------------------
music_sid_clear:
    ldy #$18                                    // $8478
    lda #$00                                    // $847a
L847c:
    sta SID_V1_FREQ_LO,y                        // $847c
    dey                                         // $847f
    bpl L847c                                   // $8480
    rts                                         // $8482

// ----------------------------------------------------------------------------
// Set the voice frequency for its current note
// ----------------------------------------------------------------------------
music_set_freq:
    ldy mus_note,x                              // $8483
    lda note_freq_lo,y                          // $8486
    sta mus_freq_lo,x                           // $8489
    pha                                         // $848c
    lda note_freq_hi,y                          // $848d
    sta mus_freq_hi,x                           // $8490
    ldy mus_sid_offset                          // $8493
    sta SID_V1_FREQ_HI,y                        // $8496
    pla                                         // $8499
    sta SID_V1_FREQ_LO,y                        // $849a
    rts                                         // $849d

// ----------------------------------------------------------------------------
// Build the arpeggio note list from the instrument's bit mask
// ----------------------------------------------------------------------------
music_build_arpeggio:
    ldy voice_arp_offset,x                      // $849e
    iny                                         // $84a1
    ldx #$00                                    // $84a2
L84a4:
    ror mus_arp_bits                            // $84a4
    bcc L84b0                                   // $84a7
    lda arp_intervals,x                         // $84a9
    sta mus_arp_tables,y                        // $84ac
    iny                                         // $84af
L84b0:
    inx                                         // $84b0
    cpx #$08                                    // $84b1
    bne L84a4                                   // $84b3
    ldx music_voice                             // $84b5
    lda #$ff                                    // $84b8
    sta mus_arp_tables,y                        // $84ba
    lda #$00                                    // $84bd
    sta mus_porta_target,x                      // $84bf
    rts                                         // $84c2

// ----------------------------------------------------------------------------
// Next pattern of a voice's sequence. Sequence bytes: $00-$7F pattern
// number, $80-$FE transpose (n - $C0), $FF restart the sequence
// ----------------------------------------------------------------------------
music_next_pattern:
    lda mus_seq_lo,x                            // $84c3
    sta $a9                                     // $84c6
    lda mus_seq_hi,x                            // $84c8
    sta $aa                                     // $84cb
L84cd:
    ldy mus_seq_pos,x                           // $84cd
    inc mus_seq_pos,x                           // $84d0
    lda ($a9),y                                 // $84d3
    bpl L84eb                                   // $84d5
    cmp #$ff                                    // $84d7
    bne L84e2                                   // $84d9
    lda #$00                                    // $84db
    sta mus_seq_pos,x                           // $84dd
    beq L84cd                                   // $84e0
L84e2:
    clc                                         // $84e2
    adc #$40                                    // $84e3
    sta mus_transpose,x                         // $84e5
    jmp L84cd                                   // $84e8
L84eb:
    asl                                         // $84eb
    tay                                         // $84ec
    lda pattern_pointers,y                      // $84ed
    sta mus_pattern_lo,x                        // $84f0
    sta $a7                                     // $84f3
    lda pattern_pointers+1,y                    // $84f5
    sta mus_pattern_hi,x                        // $84f8
    sta $a8                                     // $84fb
    rts                                         // $84fd

// ----------------------------------------------------------------------------
// Portamento: frequency step per frame from the current to the target note
// ----------------------------------------------------------------------------
music_calc_slide:
    ldx #$00                                    // $84fe
    cpy music_calc_slide+1                      // $8500
    bcs L8528                                   // $8503
    lda #$18                                    // $8505
    sta L83d6                                   // $8507
    lda #$6d                                    // $850a
    sta L83d7                                   // $850c
    sta L83e3                                   // $850f
    sec                                         // $8512
    lda note_freq_lo,x                          // $8513
    sbc note_freq_lo,y                          // $8516
    sta mus_porta_step_lo                       // $8519
    lda note_freq_hi,x                          // $851c
    sbc note_freq_hi,y                          // $851f
    sta mus_porta_step_hi                       // $8522
    jmp L8548                                   // $8525
L8528:
    lda #$38                                    // $8528
    sta L83d6                                   // $852a
    lda #$ed                                    // $852d
    sta L83d7                                   // $852f
    sta L83e3                                   // $8532
    sec                                         // $8535
    lda note_freq_lo,y                          // $8536
    sbc note_freq_lo,x                          // $8539
    sta mus_porta_step_lo                       // $853c
    lda note_freq_hi,y                          // $853f
    sbc note_freq_hi,x                          // $8542
    sta mus_porta_step_hi                       // $8545
L8548:
    ldy music_speed                             // $8548
    lda #$00                                    // $854b
    clc                                         // $854d
L854e:
    adc #$00                                    // $854e
    dey                                         // $8550
    bpl L854e                                   // $8551
    sta mus_porta_div                           // $8553
    clc                                         // $8556
    ldx #$10                                    // $8557
    lda #$00                                    // $8559
L855b:
    rol mus_porta_step_lo                       // $855b
    rol mus_porta_step_hi                       // $855e
    rol                                         // $8561
    bcs L8569                                   // $8562
    cmp mus_porta_div                           // $8564
    bcc L856d                                   // $8567
L8569:
    sbc mus_porta_div                           // $8569
    sec                                         // $856c
L856d:
    dex                                         // $856d
    bne L855b                                   // $856e
    rol mus_porta_step_lo                       // $8570
    rol mus_porta_step_hi                       // $8573
    asl                                         // $8576
    cmp mus_porta_div                           // $8577
    bcc L8584                                   // $857a
    inc mus_porta_step_lo                       // $857c
    bne L8584                                   // $857f
    inc mus_porta_step_hi                       // $8581
L8584:
    rts                                         // $8584

// ----------------------------------------------------------------------------
// Note frequencies, high bytes (97 notes)
// ----------------------------------------------------------------------------
note_freq_hi:
    .byte $00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01  // $8585
    .byte $01,$02,$02,$02,$02,$02,$02,$02,$03,$03,$03,$03  // $8591
    .byte $03,$04,$04,$04,$04,$05,$05,$05,$06,$06,$07,$07  // $859d
    .byte $07,$08,$08,$09,$09,$0a,$0b,$0b,$0c,$0d,$0e,$0e  // $85a9
    .byte $0f,$10,$11,$12,$13,$15,$16,$17,$19,$1a,$1c,$1d  // $85b5
    .byte $1f,$21,$23,$25,$27,$2a,$2c,$2f,$32,$35,$38,$3b  // $85c1
    .byte $3f,$43,$47,$4b,$4f,$54,$59,$5e,$64,$6a,$70,$77  // $85cd
    .byte $7e,$86,$8e,$96,$9f,$a8,$b3,$bd,$c8,$d4,$e1,$ee  // $85d9
    .byte $fd                                   // $85e5

// ----------------------------------------------------------------------------
// Note frequencies, low bytes
// ----------------------------------------------------------------------------
note_freq_lo:
    .byte $00,$0c,$1c,$2d,$3e,$51,$66,$7b,$91,$a9,$c3,$dd  // $85e6
    .byte $fa,$18,$38,$5a,$7d,$a3,$cc,$f6,$23,$5d,$86,$bb  // $85f2
    .byte $f4,$30,$70,$b4,$fb,$47,$98,$ed,$47,$a7,$0c,$77  // $85fe
    .byte $e9,$61,$e1,$68,$f7,$8f,$30,$da,$8f,$4e,$18,$ef  // $860a
    .byte $d2,$c3,$c3,$d1,$ef,$1f,$60,$b5,$1e,$9c,$31,$df  // $8616
    .byte $a5,$87,$86,$a2,$df,$3e,$c1,$6b,$3c,$39,$63,$be  // $8622
    .byte $4b,$0f,$0c,$45,$bf,$7d,$83,$d6,$79,$73,$c7,$7c  // $862e
    .byte $97,$1e,$18,$8b,$7e,$fa,$06,$ac,$f3,$e6,$8f,$f8  // $863a
    .byte $2e                                   // $8646

// ----------------------------------------------------------------------------
// Silence the SID and stop
// ----------------------------------------------------------------------------
music_init:
    jsr music_sid_clear                         // $8647
    lda #$07                                    // $864a
    sta SID_MODE_VOL                            // $864c
    lda #$00                                    // $864f
    sta music_speed_count                       // $8651
    sta music_playing                           // $8654
    rts                                         // $8657

// ----------------------------------------------------------------------------
// Driver variables (per voice: 3 bytes each)
// ----------------------------------------------------------------------------
voice_reg_offset:
    .byte $00,$07,$0e                           // $8658
voice_arp_offset:
    .byte $00,$0a,$14                           // $865b
arp_intervals:
    .byte $03,$04,$05,$07,$08,$09,$0c,$18       // $865e
D8666:
    .byte $01,$01,$01                           // $8666
mus_note:
    .byte $00,$00,$00                           // $8669
music_voice:
    .byte $00                                   // $866c
music_playing:
    .byte $00                                   // $866d
music_speed:
    .byte $01                                   // $866e
music_speed_count:
    .byte $00                                   // $866f
mus_seq_pos:
    .byte $00,$00,$00                           // $8670
mus_freq_lo:
    .byte $00,$00,$00                           // $8673
mus_freq_hi:
    .byte $00,$00,$00                           // $8676
mus_pulse_lo:
    .byte $00,$00,$00                           // $8679
mus_pulse_hi:
    .byte $00,$00,$00                           // $867c
mus_pattern_lo:
    .byte $00,$00,$00                           // $867f
mus_pattern_hi:
    .byte $00,$00,$00                           // $8682
mus_length:
    .byte $00,$00,$00                           // $8685
mus_length_count:
    .byte $00,$00,$00                           // $8688
mus_porta_state:
    .byte $00,$00,$00                           // $868b
mus_arp_mask:
    .byte $00,$00,$00                           // $868e
mus_transpose:
    .byte $00,$00,$00                           // $8691
mus_porta_target:
    .byte $00,$00,$00                           // $8694
mus_porta_speed:
    .byte $00,$00,$00                           // $8697
mus_porta_step_lo:
    .byte $00                                   // $869a
mus_porta_step_hi:
    .byte $00                                   // $869b
mus_porta_div:
    .byte $00                                   // $869c
mus_slide_up:
    .byte $00,$00,$00                           // $869d
mus_slide_down:
    .byte $00,$00,$00                           // $86a0
mus_pulse_dir:
    .byte $00,$00,$00                           // $86a3
mus_arp_pos:
    .byte $00,$00,$00                           // $86a6
mus_vib_depth:
    .byte $00                                   // $86a9
mus_vib_shift:
    .byte $00                                   // $86aa
mus_vib_dir:
    .byte $00,$00,$00                           // $86ab
mus_vib_pos:
    .byte $00,$00,$00                           // $86ae
mus_vib_delay:
    .byte $00,$00,$00                           // $86b1
mus_vib_delay_count:
    .byte $00,$00,$00                           // $86b4
mus_vib_freq_lo:
    .byte $00                                   // $86b7
mus_vib_freq_hi:
    .byte $00                                   // $86b8
mus_vib_step_lo:
    .byte $00                                   // $86b9
mus_vib_step_hi:
    .byte $00                                   // $86ba
mus_arp_bits:
    .byte $00                                   // $86bb
mus_seq_lo:
    .byte $00,$00,$00                           // $86bc
mus_seq_hi:
    .byte $00,$00,$00                           // $86bf
mus_read_pos:
    .byte $00                                   // $86c2
mus_instrument:
    .byte $00,$00,$00                           // $86c3
mus_86c6:
    .byte $03,$03,$03                           // $86c6
mus_note_age:
    .byte $00                                   // $86c9
D86ca:
    .byte $00                                   // $86ca
D86cb:
    .byte $00                                   // $86cb
mus_sid_offset:
    .byte $00                                   // $86cc
mus_arp_tables:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $86cd
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $86dd
drum_tables:
    .byte $05,$87,$f5,$86,$25,$87,$15,$87       // $86ed
drum_data:
    .byte $1a,$01,$ff,$20,$0a,$12,$04,$16,$00,$00,$00,$00,$00,$00,$00,$00  // $86f5
D8705:
    .byte $81,$41,$40,$80,$80,$80,$80,$80,$10,$10,$10,$10,$10,$10,$10,$10  // $8705
    .byte $1f,$ff,$1f,$51,$53,$f9,$24,$33,$f0,$e0,$00,$00,$00,$00,$00,$00  // $8715
    .byte $81,$40,$81,$81,$81,$40,$81,$81,$40,$80,$10,$10,$10,$10,$10,$10  // $8725

// ----------------------------------------------------------------------------
// Tunes 1-5: sequence address of voice 1, 2, 3 (low, high pairs)
// ----------------------------------------------------------------------------
tune_table:
    .word tune1_voice1                          // $8735
    .word tune1_voice2                          // $8737
    .word tune1_voice3                          // $8739
    .word tune2_voice1                          // $873b
    .word tune2_voice2                          // $873d
    .word tune2_voice3                          // $873f
    .word tune3_voice1                          // $8741
    .word tune3_voice2                          // $8743
    .word tune3_voice3                          // $8745
    .word tune4_voice1                          // $8747
    .word tune4_voice2                          // $8749
    .word tune4_voice2                          // $874b
    .word tune5_voice1                          // $874d
    .word tune5_voice2                          // $874f
    .word tune5_voice3                          // $8751

// ----------------------------------------------------------------------------
// Instruments, 8 bytes each: waveform, AD, SR, pulse width,
// vibrato (depth/speed), pulse sweep, arpeggio, flags (1 vibrato, 4/8 drums)
// ----------------------------------------------------------------------------
instruments:
    .byte $00,$00,$00,$00,$00,$00,$00,$00       // $8753
    .byte $44,$03,$f8,$82,$00,$10,$00,$04       // $875b
    .byte $44,$08,$59,$23,$00,$90,$00,$04       // $8763
    .byte $42,$02,$ea,$00,$42,$30,$00,$02       // $876b
    .byte $24,$06,$cd,$03,$41,$05,$00,$00       // $8773
    .byte $44,$04,$78,$08,$00,$46,$4a,$01       // $877b
    .byte $22,$04,$97,$03,$00,$23,$4a,$00       // $8783
    .byte $22,$04,$57,$03,$00,$20,$64,$00       // $878b
    .byte $44,$07,$7b,$08,$42,$00,$00,$04       // $8793
    .byte $44,$04,$7e,$05,$42,$30,$c0,$00       // $879b
    .byte $44,$07,$ad,$08,$41,$00,$00,$00       // $87a3
    .byte $42,$08,$db,$03,$41,$da,$00,$02       // $87ab
    .byte $44,$02,$9d,$06,$41,$60,$00,$00       // $87b3
    .byte $44,$02,$79,$08,$00,$01,$00,$04       // $87bb
    .byte $81,$07,$98,$08,$20,$0a,$00,$01       // $87c3
    .byte $44,$04,$9d,$07,$42,$30,$00,$00       // $87cb
    .byte $44,$03,$49,$08,$41,$40,$00,$04       // $87d3
    .byte $42,$07,$7d,$02,$41,$46,$00,$00       // $87db
    .byte $22,$04,$d7,$03,$00,$23,$4a,$00       // $87e3
    .byte $44,$04,$9d,$01,$42,$08,$00,$00       // $87eb
    .byte $44,$04,$9d,$05,$41,$28,$00,$00       // $87f3

// ----------------------------------------------------------------------------
// Pattern addresses (sequence bytes $00-$7F index this table)
// ----------------------------------------------------------------------------
pattern_pointers:
    .word pattern_00                            // $87fb
    .word pattern_01                            // $87fd
    .word pattern_02                            // $87ff
    .word pattern_03                            // $8801
    .word pattern_04                            // $8803
    .word pattern_05                            // $8805
    .word pattern_06                            // $8807
    .word pattern_07                            // $8809
    .word pattern_08                            // $880b
    .word pattern_09                            // $880d
    .word pattern_0a                            // $880f
    .word pattern_0b                            // $8811
    .word pattern_0c                            // $8813
    .word pattern_0d                            // $8815
    .word pattern_0e                            // $8817
    .word pattern_0f                            // $8819
    .word pattern_10                            // $881b
    .word pattern_11                            // $881d
    .word pattern_12                            // $881f
    .word pattern_13                            // $8821
    .word pattern_14                            // $8823
    .word pattern_15                            // $8825
    .word pattern_16                            // $8827
    .word pattern_17                            // $8829
    .word pattern_18                            // $882b
    .word pattern_19                            // $882d
    .word pattern_1a                            // $882f
    .word pattern_1b                            // $8831
    .word pattern_1c                            // $8833
    .word pattern_1d                            // $8835
    .word pattern_1e                            // $8837
    .word pattern_1f                            // $8839
tune1_voice1:
    .byte $c0,$0f,$0f,$0f,$0f,$c0,$00,$c5,$00,$00,$c0,$00,$00,$c5,$00,$00  // $883b
    .byte $c0,$00,$c2,$00,$c7,$00,$c0,$07,$08,$c1,$0d,$c2,$0d,$d0,$0b,$d4  // $884b
    .byte $0b,$da,$0b,$e0,$0b,$c0,$0f,$0f,$c2,$0f,$c5,$00,$c8,$00,$00,$bb  // $885b
    .byte $0f,$cc,$10,$c2,$00,$c7,$00,$00,$c2,$00,$00,$c7,$00,$00,$c2,$00  // $886b
    .byte $c4,$00,$c9,$00,$c2,$07,$08,$ff       // $887b
tune1_voice2:
    .byte $cc,$01,$01,$01,$01,$01,$02,$02,$01,$01,$02,$02,$01,$ce,$01,$02  // $8883
    .byte $c0,$09,$0a,$0e,$0e,$12,$bc,$01,$c0,$03,$bb,$01,$c0,$13,$ce,$01  // $8893
    .byte $02,$02,$01,$01,$02,$02,$01,$d0,$01,$02,$c2,$09,$0a,$ff  // $88a3
tune1_voice3:
    .byte $c0,$03,$03,$03,$03,$c0,$04,$05,$06,$0c,$0c,$0c,$0c,$0c,$0c,$bd  // $88b1
    .byte $0c,$c0,$0c,$0c,$0c,$bb,$0c,$c0,$11,$c2,$04,$05,$06,$ff  // $88c1
tune2_voice1:
    .byte $c0,$14,$be,$14,$b9,$14,$be,$14,$b4,$14,$11,$14,$ad,$14,$b2,$14  // $88cf
    .byte $ff                                   // $88df
tune2_voice2:
    .byte $cc,$15,$ca,$16,$cc,$17,$ca,$16,$c0,$15,$ca,$16,$cc,$17,$ca,$16  // $88e0
    .byte $c0,$19,$cc,$19,$ff                   // $88f0
tune2_voice3:
    .byte $c0,$18,$be,$18,$c5,$18,$be,$18,$ff   // $88f5
tune3_voice1:
    .byte $c0,$1a,$03,$ff                       // $88fe
tune3_voice2:
    .byte $c0,$1b,$03,$ff                       // $8902
tune3_voice3:
    .byte $c0,$1c,$03,$ff                       // $8906
tune4_voice1:
    .byte $c0,$1d,$03,$ff                       // $890a
tune4_voice2:
    .byte $c0,$1e,$03,$ff,$c0,$1f,$03,$ff       // $890e
pattern_00:
    .byte $c1,$81,$13,$13,$1f,$13,$cd,$43,$c1,$1f,$13,$1f,$13,$1f,$1f,$13  // $8916
    .byte $cd,$43,$37,$c1,$13,$1f,$ff           // $8926
pattern_07:
    .byte $c1,$81,$13,$13,$1f,$13,$cd,$37,$c1,$1f,$13,$1f,$18,$18,$24,$18  // $892d
    .byte $cd,$43,$37,$c1,$18,$24,$ff           // $893d
pattern_08:
    .byte $c1,$81,$18,$18,$24,$18,$24,$24,$18,$24,$1f,$1f,$2b,$1f,$2b,$2b  // $8944
    .byte $1f,$2b,$ff                           // $8954
pattern_0f:
    .byte $f2,$c1,$81,$13,$13,$1f,$13,$1f,$c0,$00,$c1,$13,$1f,$13,$1f,$1f  // $8957
    .byte $13,$1f,$1d,$13,$1f,$ff               // $8967
pattern_10:
    .byte $c1,$83,$0e,$1a,$1a,$1c,$11,$1d,$12,$1e,$ff  // $896d
pattern_03:
    .byte $f2,$c0,$9f,$00,$ff                   // $8978
pattern_01:
    .byte $c6,$83,$2b,$2b,$81,$2b,$83,$2b,$81,$2b,$83,$2b,$81,$2b,$83,$2b  // $897d
    .byte $81,$2b,$2b,$1f,$ff                   // $898d
pattern_02:
    .byte $c7,$83,$2b,$2b,$81,$2b,$83,$2b,$81,$2b,$83,$2b,$81,$2b,$83,$2b  // $8992
    .byte $81,$2b,$2b,$1f,$ff                   // $89a2
pattern_09:
    .byte $d2,$83,$43,$43,$81,$43,$83,$43,$81,$43,$83,$3c,$81,$3c,$83,$3c  // $89a7
    .byte $81,$3c,$3c,$30,$ff                   // $89b7
pattern_0a:
    .byte $d2,$83,$3c,$3c,$81,$3c,$83,$3c,$81,$3c,$37,$37,$83,$37,$37,$37  // $89bc
    .byte $ff                                   // $89cc
pattern_0c:
    .byte $c2,$81,$7a,$0c,$2b,$2b,$37,$2b,$37,$37,$2b,$37,$2b,$37,$37,$2b  // $89cd
    .byte $37,$37,$2b,$37,$ff                   // $89dd
pattern_11:
    .byte $ce,$81,$32,$83,$32,$81,$32,$30,$83,$30,$81,$30,$2e,$2e,$2e,$2e  // $89e2
    .byte $2e,$2e,$2e,$2e,$ff                   // $89f2
pattern_04:
    .byte $c4,$81,$7a,$0f,$37,$83,$37,$85,$35,$83,$37,$81,$34,$35,$83,$34  // $89f7
    .byte $81,$32,$85,$37,$97,$34,$83,$00,$83,$37,$3a,$39,$81,$37,$39,$83  // $8a07
    .byte $37,$81,$35,$37,$83,$35,$81,$34,$32,$30,$95,$37,$83,$32,$34,$37  // $8a17
    .byte $ff                                   // $8a27
pattern_05:
    .byte $c8,$81,$7a,$0c,$39,$83,$3b,$81,$39,$83,$3b,$81,$39,$3b,$39,$3b  // $8a28
    .byte $39,$3b,$39,$3b,$39,$ca,$95,$7a,$0e,$37,$c8,$83,$34,$37,$35,$81  // $8a38
    .byte $34,$34,$36,$34,$37,$34,$39,$34,$3a,$34,$3a,$34,$3a,$39,$37,$32  // $8a48
    .byte $d0,$80,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f  // $8a58
    .byte $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f  // $8a68
    .byte $50,$51,$ff                           // $8a78
pattern_06:
    .byte $cf,$81,$7a,$0c,$2d,$2d,$39,$2d,$39,$37,$2d,$39,$2d,$39,$39,$2d  // $8a7b
    .byte $39,$37,$2d,$36,$81,$36,$37,$83,$36,$81,$34,$36,$34,$8d,$32,$83  // $8a8b
    .byte $30,$81,$2f,$30,$83,$2f,$81,$2d,$2f,$2d,$8f,$2b,$81,$00,$81,$37  // $8a9b
    .byte $37,$83,$37,$81,$34,$83,$32,$85,$37,$83,$43,$4f,$ca,$1f,$ff  // $8aab
pattern_0b:
    .byte $d3,$87,$7a,$12,$0c,$10,$ff           // $8aba
pattern_0d:
    .byte $d3,$8f,$7a,$12,$0c,$10,$ff           // $8ac1
pattern_0e:
    .byte $f2,$d1,$bf,$7a,$12,$1f,$ff           // $8ac8
pattern_12:
    .byte $cc,$81,$7a,$0f,$43,$83,$43,$85,$41,$83,$43,$81,$40,$41,$83,$40  // $8acf
    .byte $81,$3e,$85,$43,$9f,$1f,$cc,$83,$2d,$81,$2d,$2d,$83,$31,$34,$37  // $8adf
    .byte $3a,$87,$37,$cc,$9f,$21,$ff           // $8aef
pattern_13:
    .byte $ca,$80,$2b,$2c,$2d,$2e,$2f,$30,$31,$32,$33,$34,$35,$36,$37,$38  // $8af6
    .byte $39,$3a,$3b,$3c,$3d,$3e,$3f,$40,$41,$42,$43,$44,$45,$46,$47,$48  // $8b06
    .byte $49,$4a,$ff                           // $8b16
pattern_14:
    .byte $f2,$c7,$81,$34,$34,$34,$34,$34,$83,$34,$34,$81,$34,$83,$34,$81  // $8b19
    .byte $34,$85,$34,$ff                       // $8b29
pattern_15:
    .byte $cd,$81,$2d,$34,$39,$2d,$34,$39,$2d,$34,$39,$2d,$34,$39,$2d,$34  // $8b2d
    .byte $39,$2d,$ff                           // $8b3d
pattern_16:
    .byte $cd,$81,$39,$34,$2d,$39,$34,$2d,$39,$34,$2d,$39,$34,$2d,$39,$34  // $8b40
    .byte $2d,$39,$ff                           // $8b50
pattern_17:
    .byte $cd,$81,$36,$32,$2d,$36,$32,$2d,$36,$32,$2d,$36,$32,$2d,$36,$32  // $8b53
    .byte $2d,$36,$ff                           // $8b63
pattern_18:
    .byte $c1,$81,$7a,$0c,$21,$21,$83,$21,$ce,$81,$2a,$c1,$1c,$1f,$83,$21  // $8b66
    .byte $81,$21,$83,$21,$ce,$81,$45,$c1,$1c,$83,$1f,$ff  // $8b76
pattern_19:
    .byte $d4,$81,$7a,$10,$31,$2d,$32,$2d,$34,$2d,$36,$2d,$34,$32,$2d,$83  // $8b82
    .byte $31,$81,$32,$83,$31,$8f,$2f,$89,$23,$81,$2d,$83,$2b,$81,$2a,$26  // $8b92
    .byte $2b,$26,$2d,$26,$2f,$26,$2d,$2b,$26,$2a,$26,$2b,$83,$2d,$8f,$2b  // $8ba2
    .byte $29,$ff                               // $8bb2
pattern_1a:
    .byte $f2,$c1,$81,$13,$13,$1f,$13,$13,$83,$11,$8f,$13,$81,$00,$ff  // $8bb4
pattern_1b:
    .byte $cb,$81,$7a,$0e,$32,$3e,$34,$40,$35,$41,$36,$42,$8f,$37,$ff  // $8bc3
pattern_1c:
    .byte $c4,$81,$7a,$0c,$37,$37,$43,$37,$41,$85,$3e,$8f,$43,$ff  // $8bd2
pattern_1d:
    .byte $f2,$c4,$9f,$7a,$0c,$13,$ff           // $8be0
pattern_1e:
    .byte $c9,$83,$2b,$81,$2b,$83,$37,$81,$2b,$37,$37,$37,$83,$2b,$89,$37  // $8be7
    .byte $ff                                   // $8bf7
pattern_1f:
    .byte $c1,$83,$13,$81,$13,$83,$1f,$81,$13,$83,$1f,$81,$13,$83,$11,$89  // $8bf8
    .byte $1f,$ff                               // $8c08
tune5_voice1:
    .byte $c0,$19,$ff                           // $8c0a
tune5_voice2:
    .byte $c0,$03,$ff                           // $8c0d
tune5_voice3:
    .byte $c0,$03,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $8c10
    .byte $df,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $8c20
    .byte $8b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$bd,$ff,$ff,$ff,$ff,$9f  // $8c30
    .byte $00,$00,$00,$00,$00,$00,$00,$ff,$ff,$00,$00,$ff,$cd,$00,$cd,$00  // $8c40
    .byte $00,$00,$00,$00,$00,$ff,$00,$00,$cd,$00,$00,$00,$00,$00,$00,$cd  // $8c50
    .byte $00,$00,$00,$cd,$00,$00,$00,$00,$00,$ff,$ff,$ff,$cf,$00,$ef,$00  // $8c60
    .byte $cd,$00,$00,$00,$00,$00,$00,$00,$00,$cd,$00,$00,$00,$00,$fc,$fc  // $8c70
    .byte $cb,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ef,$ff,$ff  // $8c80
    .byte $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $8c90
    .byte $df,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $8ca0
    .byte $83,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$ff,$ff,$ff,$ff,$9f  // $8cb0
    .byte $00,$00,$00,$00,$00,$00,$00,$ff,$ff,$00,$00,$ff,$cd,$00,$cd,$00  // $8cc0
    .byte $00,$00,$00,$00,$00,$ff,$00,$00,$cd,$00,$00,$00,$00,$00,$00,$cd  // $8cd0
    .byte $00,$00,$00,$cd,$00,$00,$00,$00,$00,$ff,$ff,$ff,$cf,$00,$ef,$00  // $8ce0
    .byte $cd,$00,$00,$00,$00,$00,$00,$00,$00,$cd,$00,$00,$00,$00,$f4,$f4  // $8cf0

// ----------------------------------------------------------------------------
// Title screen sprites, swapped with $2800-$29FF by swap_title_sprites
// while the title screen runs
// ----------------------------------------------------------------------------
title_sprites:
// sprite $34  ($8d00)
    .byte %00000000,%00000000,%00000000         // $8d00  ........................
    .byte %00000000,%00000000,%00000000         // $8d03  ........................
    .byte %00000000,%00000000,%00000000         // $8d06  ........................
    .byte %00000000,%00000000,%00000000         // $8d09  ........................
    .byte %00000000,%00000000,%00000000         // $8d0c  ........................
    .byte %00000000,%00000000,%00000000         // $8d0f  ........................
    .byte %00000000,%00000000,%00000000         // $8d12  ........................
    .byte %00000000,%00000000,%00000000         // $8d15  ........................
    .byte %00000000,%00000000,%00000000         // $8d18  ........................
    .byte %00000000,%00000000,%00000000         // $8d1b  ........................
    .byte %00000000,%00000000,%00000000         // $8d1e  ........................
    .byte %00000000,%00000000,%00000000         // $8d21  ........................
    .byte %00000000,%00000000,%00000000         // $8d24  ........................
    .byte %00000000,%00000000,%00000000         // $8d27  ........................
    .byte %00000000,%00000000,%00000000         // $8d2a  ........................
    .byte %00000000,%00000000,%00000000         // $8d2d  ........................
    .byte %00000000,%00000000,%00000000         // $8d30  ........................
    .byte %00000000,%00000000,%00000000         // $8d33  ........................
    .byte %00000000,%00000000,%00000000         // $8d36  ........................
    .byte %00000000,%00000000,%00000000         // $8d39  ........................
    .byte %00010101,%01010101,%00000000         // $8d3c  ...#.#.#.#.#.#.#........
    .byte $00                                   // $8d3f
// sprite $35  ($8d40)
    .byte %00000000,%00000000,%00000001         // $8d40  .......................#
    .byte %00000000,%00000000,%00010101         // $8d43  ...................#.#.#
    .byte %00000000,%00000000,%01010100         // $8d46  .................#.#.#..
    .byte %00000000,%00000001,%01000011         // $8d49  ...............#.#....##
    .byte %00000000,%00000101,%00110011         // $8d4c  .............#.#..##..##
    .byte %00000000,%00010100,%11000100         // $8d4f  ...........#.#..##...#..
    .byte %00000000,%01010011,%11000100         // $8d52  .........#.#..####...#..
    .byte %00000000,%01010011,%00010001         // $8d55  .........#.#..##...#...#
    .byte %00000001,%01001111,%00010001         // $8d58  .......#.#..####...#...#
    .byte %00000001,%01001111,%00010000         // $8d5b  .......#.#..####...#....
    .byte %00000101,%00111100,%01001111         // $8d5e  .....#.#..####...#..####
    .byte %00000101,%00111100,%01001100         // $8d61  .....#.#..####...#..##..
    .byte %00000101,%00111100,%01001100         // $8d64  .....#.#..####...#..##..
    .byte %00000101,%00111100,%01000001         // $8d67  .....#.#..####...#.....#
    .byte %00010100,%11110001,%01000001         // $8d6a  ...#.#..####...#.#.....#
    .byte %00010100,%11110001,%01000001         // $8d6d  ...#.#..####...#.#.....#
    .byte %00010100,%11110001,%01000101         // $8d70  ...#.#..####...#.#...#.#
    .byte %00010100,%11110001,%01010101         // $8d73  ...#.#..####...#.#.#.#.#
    .byte %00010100,%11110001,%01010000         // $8d76  ...#.#..####...#.#.#....
    .byte %00010100,%11110001,%00001100         // $8d79  ...#.#..####...#....##..
    .byte %00010100,%11111100,%11110001         // $8d7c  ...#.#..######..####...#
    .byte $62                                   // $8d7f
// sprite $36  ($8d80)
    .byte %01010101,%01010101,%01010000         // $8d80  .#.#.#.#.#.#.#.#.#.#....
    .byte %01000000,%00000000,%01010101         // $8d83  .#...............#.#.#.#
    .byte %00111111,%11111111,%00000101         // $8d86  ..##############.....#.#
    .byte %11111111,%11111100,%11110000         // $8d89  ##############..####....
    .byte %11111111,%11110001,%00111111         // $8d8c  ############...#..######
    .byte %11111111,%11110001,%00111111         // $8d8f  ############...#..######
    .byte %11111111,%11110001,%00111111         // $8d92  ############...#..######
    .byte %00111111,%11110001,%00110011         // $8d95  ..##########...#..##..##
    .byte %00111111,%11000101,%00000100         // $8d98  ..########...#.#.....#..
    .byte %11001111,%00000100,%11011101         // $8d9b  ##..####.....#..##.###.#
    .byte %00010000,%01010100,%11010001         // $8d9e  ...#.....#.#.#..##.#...#
    .byte %01010100,%01000100,%01010100         // $8da1  .#.#.#...#...#...#.#.#..
    .byte %01000101,%11000100,%01000000         // $8da4  .#...#.###...#...#......
    .byte %11000101,%11000101,%01010101         // $8da7  ##...#.###...#.#.#.#.#.#
    .byte %11001101,%01010101,%01010000         // $8daa  ##..##.#.#.#.#.#.#.#....
    .byte %01010101,%01010000,%00000100         // $8dad  .#.#.#.#.#.#.........#..
    .byte %01010100,%00001111,%11000101         // $8db0  .#.#.#......######...#.#
    .byte %00000011,%11111111,%00010100         // $8db3  ......##########...#.#..
    .byte %00111111,%11111000,%01010100         // $8db6  ..###########....#.#.#..
    .byte %01001111,%11110001,%01000100         // $8db9  .#..########...#.#...#..
    .byte %01111100,%11000101,%00110100         // $8dbc  .#####..##...#.#..##.#..
    .byte $0b                                   // $8dbf
// sprite $37  ($8dc0)
    .byte %00000000,%00000000,%00000000         // $8dc0  ........................
    .byte %00000000,%00000000,%00000000         // $8dc3  ........................
    .byte %01000000,%00000000,%00000000         // $8dc6  .#......................
    .byte %01010000,%00000000,%00000000         // $8dc9  .#.#....................
    .byte %00010100,%00000000,%00000000         // $8dcc  ...#.#..................
    .byte %11000101,%00000000,%00000000         // $8dcf  ##...#.#................
    .byte %11110001,%01000000,%00000000         // $8dd2  ####...#.#..............
    .byte %11110001,%01000000,%00000000         // $8dd5  ####...#.#..............
    .byte %11111100,%01010000,%00000000         // $8dd8  ######...#.#............
    .byte %00111100,%01010000,%00000000         // $8ddb  ..####...#.#............
    .byte %00111100,%00010100,%00000000         // $8dde  ..####.....#.#..........
    .byte %11000001,%00000001,%01010000         // $8de1  ##.....#.......#.#.#....
    .byte %01010101,%01010101,%00000001         // $8de4  .#.#.#.#.#.#.#.#.......#
    .byte %01010001,%01010000,%00000101         // $8de7  .#.#...#.#.#.........#.#
    .byte %00000101,%00000101,%00010100         // $8dea  .....#.#.....#.#...#.#..
    .byte %01000000,%11000100,%01010000         // $8ded  .#......##...#...#.#....
    .byte %00111111,%11010001,%01000000         // $8df0  ..########.#...#.#......
    .byte %11100011,%10010100,%01010000         // $8df3  ###...###..#.#...#.#....
    .byte %10000100,%10010000,%00010100         // $8df6  #....#..#..#.......#.#..
    .byte %00011001,%00010000,%00000101         // $8df9  ...##..#...#.........#.#
    .byte %01000001,%00010000,%01010101         // $8dfc  .#.....#...#.....#.#.#.#
    .byte $20                                   // $8dff
D8e00:
    .byte $14,$cf,$c5,$14,$13,$15,$14,$14,$51,$14,$4d,$41,$14,$44,$41,$14  // $8e00
    .byte $44,$51,$01,$11,$51,$01,$15,$46,$05,$14,$04,$05,$02,$84,$05,$0a  // $8e10
    .byte $85,$15,$0a,$85,$14,$12,$85,$14,$52,$84,$14,$14,$a2,$54,$05,$2a  // $8e20
    .byte $54,$01,$42,$50,$00,$54,$40,$00,$15,$00,$00,$01,$00,$00,$00,$86  // $8e30
    .byte $21,$04,$a4,$05,$45,$24,$84,$41,$45,$84,$48,$45,$18,$45,$48,$11  // $8e40
    .byte $55,$22,$15,$40,$40,$14,$15,$45,$81,$54,$54,$15,$40,$42,$54,$21  // $8e50
    .byte $2a,$52,$a8,$aa,$0a,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa  // $8e60
    .byte $aa,$aa,$a0,$2a,$aa,$05,$40,$00,$55,$55,$55,$50,$15,$55,$00,$86  // $8e70
    .byte $54,$95,$50,$41,$54,$00,$55,$01,$00,$40,$85,$00,$2a,$85,$00,$0a  // $8e80
    .byte $85,$00,$52,$14,$00,$0a,$14,$00,$aa,$14,$00,$aa,$14,$00,$a8,$50  // $8e90
    .byte $00,$a8,$50,$00,$a1,$40,$00,$a1,$40,$00,$85,$00,$00,$14,$00,$00  // $8ea0
    .byte $50,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08  // $8eb0
    .byte $08,$8d,$82,$02,$a9,$04,$8d,$88,$02,$60,$6a,$fc,$cd,$fb,$31,$ea  // $8ec0
    .byte $2c,$f9,$a9,$7f,$8d,$0d,$dc,$8d,$0d,$dd,$8d,$00,$dc,$a9,$08,$8d  // $8ed0
    .byte $0e,$dc,$8d,$0e,$dd,$8d,$0f,$dc,$8d,$0f,$dd,$a2,$00,$8e,$03,$dc  // $8ee0
    .byte $8e,$03,$dd,$8e,$18,$d4,$ca,$8e,$02,$dc,$a9,$07,$8d,$00,$dd,$a9  // $8ef0
