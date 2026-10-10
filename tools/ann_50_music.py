"""Annotations: music driver and data ($8000-$8CFF), title sprites
($8D00-$8EFF)."""

LABELS = {
    0x8000: 'music_command',
    0x8001: 'music_play',
    0x800c: 'music_done',
    0x800f: 'music_start_tune',
    0x8050: 'music_tick',
    0x8063: 'music_voice_loop',
    0x8098: 'music_next_note',
    0x80bf: 'music_read_pattern',
    0x81dd: 'music_effects',
    0x82a1: 'music_vibrato',
    0x8363: 'music_arpeggio',
    0x839e: 'music_portamento',
    0x83ec: 'music_voice_end',
    0x840a: 'music_pulse_sweep',
    0x8478: 'music_sid_clear',
    0x8483: 'music_set_freq',
    0x849e: 'music_build_arpeggio',
    0x84c3: 'music_next_pattern',
    0x84fe: 'music_calc_slide',
    0x8585: 'note_freq_hi',
    0x85e6: 'note_freq_lo',
    0x8647: 'music_init',
    0x8658: 'voice_reg_offset',
    0x865b: 'voice_arp_offset',
    0x865e: 'arp_intervals',
    0x866c: 'music_voice',
    0x866d: 'music_playing',
    0x866e: 'music_speed',
    0x866f: 'music_speed_count',
    0x8669: 'mus_note',
    0x8670: 'mus_seq_pos',
    0x8673: 'mus_freq_lo',
    0x8676: 'mus_freq_hi',
    0x8679: 'mus_pulse_lo',
    0x867c: 'mus_pulse_hi',
    0x867f: 'mus_pattern_lo',
    0x8682: 'mus_pattern_hi',
    0x8685: 'mus_length',
    0x8688: 'mus_length_count',
    0x868b: 'mus_porta_state',
    0x868e: 'mus_arp_mask',
    0x8691: 'mus_transpose',
    0x8694: 'mus_porta_target',
    0x8697: 'mus_porta_speed',
    0x869a: 'mus_porta_step_lo',
    0x869b: 'mus_porta_step_hi',
    0x869c: 'mus_porta_div',
    0x869d: 'mus_slide_up',
    0x86a0: 'mus_slide_down',
    0x86a3: 'mus_pulse_dir',
    0x86a6: 'mus_arp_pos',
    0x86a9: 'mus_vib_depth',
    0x86aa: 'mus_vib_shift',
    0x86ab: 'mus_vib_dir',
    0x86ae: 'mus_vib_pos',
    0x86b1: 'mus_vib_delay',
    0x86b4: 'mus_vib_delay_count',
    0x86b7: 'mus_vib_freq_lo',
    0x86b8: 'mus_vib_freq_hi',
    0x86b9: 'mus_vib_step_lo',
    0x86ba: 'mus_vib_step_hi',
    0x86bb: 'mus_arp_bits',
    0x86bc: 'mus_seq_lo',
    0x86bf: 'mus_seq_hi',
    0x86c2: 'mus_read_pos',
    0x86c3: 'mus_instrument',
    0x86c6: 'mus_86c6',
    0x86c9: 'mus_note_age',
    0x86cc: 'mus_sid_offset',
    0x86cd: 'mus_arp_tables',
    0x86ed: 'drum_tables',
    0x86f5: 'drum_data',
    0x8735: 'tune_table',
    0x8753: 'instruments',
    0x87fb: 'pattern_pointers',
    0x8d00: 'title_sprites',
}

TABLES = {
    0x8585: (0x85e6, 'note_freq_hi'),
    0x85e6: (0x8647, 'note_freq_lo'),
    0x8753: (0x87fb, 'instruments'),
    0x87fb: (0x8800, 'pattern_pointers'),
    0x86ed: (0x86f5, 'drum_tables'),
}

FORMATS = {
    0x8585: ('rows', 12),
    0x85e6: ('rows', 12),
    0x8735: ('words',),
    0x8753: ('rows', 8),
    0x87fb: ('words',),
    0x8d00: ('sprites',),
}

BLOCK_COMMENTS = {
    0x8000: """Music command, written by the game, read by music_play every frame:
  0       stop the music
  1-5     start tune n (1 title, 3 level start, 4 game over)
  $FF     keep playing (music_play writes $FF back after each call)""",
    0x8001: """Music driver: call once per frame. Three voices; each voice reads a
sequence of patterns. Pattern bytes:
  $FF          end of pattern: next pattern of the sequence
  $FE          end of the tune: stop
  $FD vol      set $D418
  $F0-$FC      speed (low nybble)
  $C0-$DF      instrument (low 5 bits)
  $80-$BF      note length (low 6 bits)
  $7B n d      portamento to note n, speed d
  $7A d        delay before vibrato
  $00-$5F      note (+ transpose of the sequence); 0 = rest""",
    0x81dd: 'Per-frame effects while a note is held: drums, vibrato, arpeggio, portamento',
    0x84c3: """Next pattern of a voice's sequence. Sequence bytes: $00-$7F pattern
number, $80-$FE transpose (n - $C0), $FF restart the sequence""",
    0x84fe: 'Portamento: frequency step per frame from the current to the target note',
    0x8585: 'Note frequencies, high bytes (97 notes)',
    0x85e6: 'Note frequencies, low bytes',
    0x8647: 'Silence the SID and stop',
    0x8658: 'Driver variables (per voice: 3 bytes each)',
    0x8735: 'Tunes 1-5: sequence address of voice 1, 2, 3 (low, high pairs)',
    0x8753: """Instruments, 8 bytes each: waveform, AD, SR, pulse width,
vibrato (depth/speed), pulse sweep, arpeggio, flags (1 vibrato, 4/8 drums)""",
    0x87fb: 'Pattern addresses (sequence bytes $00-$7F index this table)',
    0x8d00: """Title screen sprites, swapped with $2800-$29FF by swap_title_sprites
while the title screen runs""",
}


# ---- name every pattern and tune sequence from the pointer tables
def _music_labels():
    import crt
    m = crt.ram_image()
    out = {}
    seqs = set()
    for t in range(5):
        for v in range(3):
            a = 0x8735 + t * 6 + v * 2
            seqs.add(m[a] | m[a + 1] << 8)
            out.setdefault(m[a] | m[a + 1] << 8, 'tune%d_voice%d' % (t + 1, v + 1))
    p = 0x87fb
    n = 0
    first = min(seqs)
    while p < first and p < 0x8800 + 0x200:
        a = m[p] | m[p + 1] << 8
        if not (0x8800 <= a < 0x8d00):
            break
        out.setdefault(a, 'pattern_%02x' % n)
        n += 1
        p += 2
    return out, p


_ml, _pp_end = _music_labels()
LABELS.update(_ml)
TABLES[0x87fb] = (_pp_end, 'pattern_pointers')
TABLES.update({
    0x3880: (0x38c0, 'sprite_mask_buffer'),
    0x1e00: (0x2000, 'corner_pixels'),
})
