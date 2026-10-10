"""Annotations: raster IRQ and frame logic ($5FED-$63D0), status sprites,
demo mode, perspective sprites ($63D1-$6FF5), machine init ($7001-$7293),
power bar and status line ($7293-$76AD)."""

LABELS = {
    # IRQ
    0x5fed: 'irq_handler',
    0x5ff7: 'irq_raster',
    0x6016: 'irq_top',
    0x6044: 'irq_frame_work',
    0x606c: 'irq_restore',
    0x6079: 'irq_split',
    0x61a9: 'irq_lines',
    0x61b7: 'frame_logic',
    0x6255: 'frame_update',
    0x6321: 'update_tilt_graphics',
    0x63af: 'update_tilt_done',
    # status sprites
    0x63d1: 'init_level_sign',
    0x646a: 'level_sign_spin',
    0x64f8: 'level_sign_place',
    0x6539: 'level_sign_slide_in',
    0x65a7: 'level_sign_slide_out',
    0x6629: 'slide_noise',
    # demo
    0x6664: 'start_demo',
    0x66ed: 'demo_play',
    0x671f: 'demo_joystick_sprite',
    0x6776: 'joystick_frames',
    0x6786: 'build_chars_24c0',
    0x67b0: 'shine_off_sound',
    0x67e1: 'draw_gate_colours',
    0x6832: 'gate_colour_table',
    0x6844: 'update_edge_highlight',
    0x685f: 'clunk_highlight_delay',
    0x6864: 'edge_highlight_v',
    0x6920: 'edge_highlight_h',
    0x69e6: 'count_marks',
    0x6a66: 'unmark_special',
    0x6a90: 'bonus_count_sound',
    0x6b17: 'find_gate',
    0x6b56: 'gate_hit',
    0x6b8c: 'gate_hit_sound',
    0x6ba7: 'bumper_hit',
    0x6c08: 'gate_hit_anim',
    0x6c62: 'gate_hit_anim_sound',
    0x6c7d: 'bumper_hit_anim',
    0x6cfa: 'freeze_edge_highlight',
    0x6d28: 'flash_lost',
    0x6d91: 'mask_ball_sprite',
    0x6dd2: 'build_sprite_mask',
    0x6e62: 'two_tone_sound',
    0x6ec9: 'draw_ball_glint',
    0x6fcb: 'glint_step',
    0x6ff6: 'clear_char_2318',
    0x7001: 'dissolve_frame',
    0x706c: 'dissolve_durations',
    0x7072: 'dissolve_colours',
    # init
    0x7078: 'init_machine',
    0x726e: 'dev_mode_basic',
    0x7274: 'dev_exit_unused',
    0x7283: 'put_status_char',
    0x728f: 'nmi_handler',
    0x7293: 'music_on_off_glyphs',
    # power bar
    0x72a3: 'colour_power_bar',
    0x72af: 'power_bar_colours',
    0x72b5: 'mask_hole_sprite',
    0x72ff: 'draw_power_bar',
    0x732a: 'add_power',
    0x735c: 'refill_power',
    0x737f: 'drain_power',
    0x73cb: 'build_power_glyphs',
    0x73f7: 'colour_marks',
    0x742a: 'set_char_2318',
    0x743e: 'flash_backup',
    0x7482: 'show_backup',
    0x7494: 'status_glyphs_25f0',
    0x74c4: 'show_power_off',
    0x74d5: 'power_off_text',
    0x74db: 'status_glyphs_2620',
    0x74fb: 'bonus_power',
    0x751f: 'show_music_glyph',
    0x7535: 'set_glyph_lost',
    0x7549: 'set_glyph_done',
    0x755d: 'colour_status_marks',
    0x7567: 'diagonal_sound',
    0x7594: 'status_font',
    0x761c: 'title_sprites_layout',
    0x768c: 'swap_title_sprites',
    0x76ae: 'unused_76ae',
}

FORMATS = {
    0x7594: ('chars', 0xca),
    0x7494: ('chars', 0xbe),
    0x74db: ('chars', 0xc4),
    0x7293: ('chars', 0xb4),
    0x7436: ('chars', 0x63),
    0x7541: ('chars', 0xb4),
    0x7555: ('chars', 0xb4),
    0x74d5: ('screen', 6),
}

BLOCK_COMMENTS = {
    0x5fed: """Raster interrupt (CINV). Twelve raster lines (irq_lines) per frame:
step 0 (line $2A) runs the frame work, steps 1-11 split the colours and
set the fine scroll for the board. CIA interrupts go to the KERNAL.""",
    0x6016: """Step 0, top of the screen: frame counter for wait_frames, F1 = restart
(not during the title / a jingle), then the game or title frame work""",
    0x6079: """Raster steps 1-11: border / background colour bands for the status
line and the board frame, and the hardware fine scroll of the maze
($D011 / $D016 = cf0f / cf0e) that makes it shift with the tilt""",
    0x61b7: """Frame work while playing (in the raster IRQ): controls (or the demo
recording), ball lost / in the hole, then all per-frame updates""",
    0x6321: """Tilt graphics: when the perspective shift changed, rebuild every
character that depends on it (walls, frame, corners, junctions, hole)""",
    0x63d1: 'Level sign: the spinning "LEVEL" sprites (0, 1, 4, 5) between levels',
    0x6539: 'Slide the level sign in and back; the sprites spin with the slide speed',
    0x6664: """Demo mode: plays the recording at demo_controls; a joystick sprite
(5) shows the moves""",
    0x66ed: """Demo: next recorded control step when the current one has run out.
The recording stops when the ball is in the hole or lost.""",
    0x67e1: 'Colour the gate that are off',
    0x6844: 'Light the edges of the walls the board leans on (characters $27D0+)',
    0x69e6: """End of level, in the IRQ: take the floor marks off one by one; each
gives power. A mark that is no longer a mark character (a gate
was drawn over it, or cells $FB / $FE) scores that block instead.""",
    0x6b17: """Params: zp_fd/zp_fe = screen address, A = offset
Find the gate at that address: C = 0 found (zp_fa = table index,
zp_ff = its bit), C = 1 not found""",
    0x6b56: 'A gate was hit by the mark count: remove it from the mask, animate and score it',
    0x6ba7: 'A bumper ($FB / $FE cell) was hit: animate it and add bonus',
    0x6d91: """Mask the ball sprite (3) against the tilt: copy it to $3700 with the
part that is behind the board edge cut off""",
    0x6dd2: """Params: A = sprite pointer. Build an inverted copy of the sprite at
$3880 shifted by the tilt (zp_f8 X, zp_f9 Y); returns the rows to mask""",
    0x6e62: 'Two-tone sound (steps counted by $CFA8), after the last maze of a level',
    0x6ec9: 'Ball glint (sprite data at $3759): a small highlight moved with the shine',
    0x7001: """One frame of the ball dissolve: cycle the ball colour (sprite 3);
returns C = 1 once the dissolve is complete (zp_fa = 0)""",
    0x7274: """Never called: BASIC ROM back on, CLRCHN, then JMP $9BB3 (not part of
this program - probably a leftover developer exit)""",
    0x7078: """Machine init: zero the variables, status line, fonts, sprites, SID,
raster IRQ (CINV = irq_handler), NMI (RESTORE) = nmi_handler""",
    0x7264: """Developer mode: print a CHR$(19) (HOME) and loop in CHRIN, so the
BASIC editor keeps running while the game runs in the IRQ""",
    0x7283: 'Status line: screen code X at column Y, colour 7; X+1, Y+1',
    0x728f: 'NMI (RESTORE key): counted in $CFB7, otherwise ignored',
    0x72ff: """POWER bar: six characters at $0411. power_hi ($CFB2) = 0-$30: full
characters ($BC) for each 8, then a part character ($B4 + rest)""",
    0x732a: """Params: A = signed change of the power (fraction units). Keeps
power within 0 - $30:00 and redraws the bar""",
    0x735c: 'Refill the power bar one step per frame up to full (new game)',
    0x737f: """Each tilt "clunk" costs power. When it runs out while the ball is
still rolling: BACKUP power (show_backup) - the next loss ends the game""",
    0x73f7: 'Colour the floor marks: colour RAM of each mark = 1 (in hole) or 0',
    0x743e: 'Flash the "BACKUP" text and sound its alarm',
    0x7482: 'Show "BACKUP" in the power bar (characters $BE-$C3)',
    0x74c4: 'Show "OFF" in the power bar',
    0x74fb: 'Bonus: A = power to add (doubled if the ball went into the hole)',
    0x751f: 'Status line music glyph: note (on) or crossed note (off)',
    0x7567: 'Short sound when a diagonal tilt is held',
    0x7594: """Font for the status line ($2650-$26D7, characters $CA-$DA). The
tamper check overwrites the first glyph here if the checksum is wrong.""",
    0x761c: 'Title screen: seven sprites ($A0-$A6) arranged as the big ball picture',
    0x768c: 'Swap $2800-$29FF with title_sprites ($8D00-$8EFF)',
}

COMMENTS = {
    0x5ff4: 'not the raster: KERNAL IRQ (keyboard, clock)',
    0x601e: 'F1 pressed?',
    0x6037: 'F1: restart the game',
    0x604c: 'screen on/off',
    0x6063: 'title screen',
    0x6069: 'playing',
    0x61c9: 'not in demo mode: read the joystick',
    0x620d: 'that was the backup power: game over',
    0x6225: 'ball in the exit hole?',
    0x6286: 'ball physics',
    0x62f5: 'ball sprites 2 and 3 at the ball position',
    0x722a: 'raster IRQ -> irq_handler',
    0x7241: 'NMI -> nmi_handler',
    0x724d: 'BRK -> $EA81 (KERNAL IRQ exit)',
    0x7253: 'first raster IRQ at line $2A',
    0x7176: 'developer mode: save $D6-$F2 to $02E0',
}

ENTRY_POINTS = [0x728f, 0x7274]

RAM_LABELS = {
    0xcfb1: 'power_lo',
    0xcfb2: 'power_hi',
    0xcfb3: 'power_refill',
    0xcfb5: 'power_drain_on',
    0xcfb6: 'backup_power',
    0xcfb7: 'nmi_count',
    0xcf76: 'title_mode',
    0xcf88: 'demo_playing',
    0xcf8a: 'demo_step_frames',
    0xcf8b: 'demo_step',
    0xcf9c: 'count_marks_on',
    0xcfa0: 'bonus_left',
    0xcfa3: 'marking_on',
}
RAM_COMMENTS = {
    0xcfb1: 'power, fraction',
    0xcfb2: 'power 0-$30 (8 per character of the bar)',
    0xcf76: '1 while the title screen runs (selects the IRQ frame work)',
}
