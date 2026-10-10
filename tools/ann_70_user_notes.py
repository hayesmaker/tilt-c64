"""Annotations from the user's knowledge of the game (applied last):
- one level = mazes 0-3; then the level goes up and the mazes repeat with a
  bigger ball and a different gate ("trap") layout
- the end-of-maze bonus is doubled when the maze was finished (ball in the
  exit hole) instead of the ball being lost
- the floor marks really do turn into power
The $FB / $FE "bumper" cells are not confirmed by the player's view of the game."""

LABELS = {
    0x6ba7: 'special_cell_hit',
    0x6c7d: 'special_cell_anim',
}
RAM_LABELS = {
    0xcf9d: 'special_cell_timer',
    0xcf9e: 'special_cell_index',
}

BLOCK_COMMENTS = {
    0x3979: """Gate ("trap") layout: 4 masks per level, one per maze. Each loop through
the four mazes uses the next row, so the same mazes come back with
different gates (levels 1-5; level 5 and up use the last row).""",
    0x47a5: """End of a maze: count the floor marks back (count_marks, IRQ) into power
and bonus points. Everything counts double when the maze was finished
(ball in the exit hole) rather than the ball being lost.""",
    0x6a90: """Bonus count: while bonus_left counts down, add 50 points per step, or
100 (x2) when the ball went into the exit hole; sound, flashes the
status marks""",
    0x74fb: 'Bonus: A = power to add, x2 if the ball went into the hole',
    0x69e6: """End of a maze, in the IRQ: take the floor marks off one by one; each
gives power (+$12, or +$28 when the maze was finished). A mark that is
no longer a mark character (a gate was drawn over it, or the special
cells $FB / $FE) scores that object instead.""",
    0x6ba7: """A special cell ($FB / $FE) was found under a mark: animate it and add
to the bonus. (Not confirmed what this is in the game.)""",
    0x6a66: 'A mark that is no longer a floor mark: $FB/$FE = special cell, $00/$29/$25 = part of a gate',
    0x6c7d: 'Animate a special cell (pulse sound), then add to the bonus',
    0x4678: """The ball is in the exit hole: drop it in, shake the board, count the
bonus (x2), then slide to the next maze. After maze 3 the level goes up:
the four mazes repeat with a bigger ball and new gate masks.""",
}
COMMENTS = {
    0x62e7: 'gate / special cell animations',
    0x45b9: 'ball size = level index - 3, limited to 1-6 (grows slowly: hardly visible before level 4-5)',
}
