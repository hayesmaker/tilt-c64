"""Annotations: the two kinds of gate (found with the user's help).

Each maze has 8 gates. The gate mask bit of a level does not remove a gate,
it chooses its kind:
  bit 1: FIRE GATE - a bar drawn by draw_gates; fire flips it open for a moment
  bit 0: TILT GATE - a 3-cell bar of characters $FA-$FF drawn by draw_tilt_gates.
         Those characters are rebuilt from the tilt (build_tilt_gate_chars_v/_h):
         the bar opens while the board is tilting against the gate and closes
         again once the board has settled after a clunk, so passing one needs a
         little wobble against the table's direction.
Replaces the earlier guesses ("gate colours", "edge highlight", "special cells")."""

LABELS = {
    0x67e1: 'draw_tilt_gates',
    0x6832: 'tilt_gate_chars',
    0x6844: 'close_tilt_gates',
    0x685f: 'tilt_gate_close_delay',
    0x6864: 'build_tilt_gate_chars_v',
    0x6920: 'build_tilt_gate_chars_h',
    0x6ba7: 'tilt_gate_hit',
    0x6c7d: 'tilt_gate_hit_anim',
    0x6cfa: 'copy_tilt_gate_chars',
    0x41f0: 'gate_bar_cells',
}
RAM_LABELS = {
    0xcf94: 'tilt_gates_closed',
    0xcf9d: 'tilt_gate_hit_timer',
    0xcf9e: 'tilt_gate_hit_index',
}
RAM_COMMENTS = {
    0xcf94: '1 = tilt gate bars built closed (board settled), 0 = open (board tilting)',
}

BLOCK_COMMENTS = {
    0x3979: """Gate kinds: 4 masks per level row (one per maze slot), level rows 1-5
(level 5 and up use the last row). Bit k = gate k: 1 = fire gate, opened
with fire; 0 = tilt gate, opened by tilting against it (draw_tilt_gates).
Each loop through the mazes uses the next row, so the same gates come back
as a different mix of the two kinds.""",
    0x38cf: """Draw the fire gates (mask bit 1): bars across the corridors that fire
flips open for a moment (fire_gates). The other gates are tilt gates
(draw_tilt_gates).
C = 0: redraw the fire gates on the screen when gate_frame changed
C = 1: take the gate mask for the level and maze, draw all fire gates into
       the screen buffer at $7C00""",
    0x41f0: 'The 3 bar cells of a gate (offsets from its address) for orientations 0-3',
    0x67e1: """Draw the tilt gates (mask bit 0) into the screen buffer: a 3-cell bar of
tilt_gate_chars across the gate (orientation 0: cells 0-2 of
gate_bar_cells, else cells 3-5). The bar characters $FA-$FF change with the
tilt, which is what opens and closes these gates.""",
    0x6832: """Tilt gate bars: $FD-$FF (orientation 0) / $FA-$FC (others); $9D-$9F /
$9A-$9C while a hit tilt gate is animated; $0A $20 $02 / $06 $20 $0E (plain
floor) once it is gone""",
    0x6844: """Once the board has settled after a clunk (clunk_state 0, or past
tilt_gate_close_delay for the speed class), rebuild the tilt gate bars
closed (C = 1). update_tilt_graphics builds them open (C = 0) whenever the
tilt changes.""",
    0x6864: 'Tilt gate bar characters $FD-$FF ($27E8-$27FF) for the tilt; C = 1 closed, C = 0 open',
    0x6920: 'Tilt gate bar characters $FA-$FC ($27D0-$27E7) for the tilt; C = 1 closed, C = 0 open',
    0x69e6: """End of a maze, in the IRQ: take the floor marks off one by one; each
gives power (+$12, or +$28 when the maze was finished). A mark that is no
longer a mark character means a gate was drawn over it: a fire gate
($00/$29/$25) or a tilt gate ($FB/$FE) - that gate is scored and removed.""",
    0x6a66: 'A mark covered by a gate: $FB/$FE = tilt gate, $00/$29/$25 = fire gate',
    0x6ba7: 'A tilt gate ($FB / $FE bar) was passed: animate it away and add to the bonus',
    0x6c7d: 'Animate a passed tilt gate ($9A-$9F, then plain floor), with sound',
    0x6cfa: 'Copy the tilt gate bar characters $FA-$FF to $9A-$9F (for the hit animation)',
}
COMMENTS = {
    0x62e7: 'gate animations (fire gates / tilt gates)',
    0x6321: 'close the tilt gates once the board has settled',
    0x6351: 'tilt gate bars open while the board moves',
}
