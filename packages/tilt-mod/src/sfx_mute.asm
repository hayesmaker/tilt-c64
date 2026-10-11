// ============================================================================
// tilt-mod: the sound effects' SID stores, muted while the MUSIC sound mode
// plays (sfx_mute bit 7, see ingame_music.asm). Each "sta / stx / sty SID_..."
// in roll_sound, gate_sound, shine_off_sound, tilt_clunk_sound,
// tilt_sound_freq, diagonal_sound, drain_power and flash_backup is a
// "jsr sfx_<op>_<register>" (same size). The stub keeps A, X, Y and the flags,
// so the routines (and the game state they keep) run as before.
// ============================================================================

.macro muted_store(op, reg) {
    php
    bit sfx_mute
    bmi skip
    plp
    .if (op == "sta") sta reg
    .if (op == "stx") stx reg
    .if (op == "sty") sty reg
    rts
skip:
    plp
    rts
}

sfx_sta_fc_hi: muted_store("sta", SID_FC_HI)
sfx_sta_mode_vol: muted_store("sta", SID_MODE_VOL)
sfx_sta_v1_ad: muted_store("sta", SID_V1_AD)
sfx_sta_v1_ctrl: muted_store("sta", SID_V1_CTRL)
sfx_sta_v1_freq_hi: muted_store("sta", SID_V1_FREQ_HI)
sfx_sta_v1_freq_lo: muted_store("sta", SID_V1_FREQ_LO)
sfx_sta_v1_sr: muted_store("sta", SID_V1_SR)
sfx_sta_v2_ad: muted_store("sta", SID_V2_AD)
sfx_sta_v2_ctrl: muted_store("sta", SID_V2_CTRL)
sfx_sta_v2_freq_hi: muted_store("sta", SID_V2_FREQ_HI)
sfx_sta_v2_freq_lo: muted_store("sta", SID_V2_FREQ_LO)
sfx_sta_v2_sr: muted_store("sta", SID_V2_SR)
sfx_sta_v3_ad: muted_store("sta", SID_V3_AD)
sfx_sta_v3_ctrl: muted_store("sta", SID_V3_CTRL)
sfx_sta_v3_freq_hi: muted_store("sta", SID_V3_FREQ_HI)
sfx_sta_v3_freq_lo: muted_store("sta", SID_V3_FREQ_LO)
sfx_sta_v3_sr: muted_store("sta", SID_V3_SR)
sfx_stx_mode_vol: muted_store("stx", SID_MODE_VOL)
sfx_stx_v2_freq_hi: muted_store("stx", SID_V2_FREQ_HI)
sfx_stx_v2_freq_lo: muted_store("stx", SID_V2_FREQ_LO)
sfx_sty_v2_freq_lo: muted_store("sty", SID_V2_FREQ_LO)
