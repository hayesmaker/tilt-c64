"""Annotations: data $1B6F-$38BF (demo recording, tables, maze screens,
sprites), gates $38C0-$3BD4, floor marks $3BD5-$3CF6, ball shading
sprites $3D12-$4028, maze setup $4029-$4263."""

LABELS = {
    0x1b6f: 'unused_1b6f',
    0x1c00: 'demo_controls',
    0x1c80: 'demo_durations',
    0x1d00: 'chars_1d00',
    0x1e00: 'corner_pixels',
    0x3800: 'shine_offset_table',
    0x3880: 'sprite_mask_buffer',
    # gates
    0x38c0: 'build_chars_2508',
    0x38cf: 'draw_gates',
    0x3939: 'draw_gate',
    0x3979: 'gate_masks_by_level',
    0x398d: 'maze_gate_index',
    0x3991: 'gate_table',
    0x39f1: 'gate_cell_offsets',
    0x3a31: 'gate_chars',
    0x3b2d: 'fire_gates',
    0x3b9b: 'gate_anim_start',
    0x3ba0: 'gate_anim_end',
    0x3ba5: 'gate_sound',
    # floor marks
    0x3bd5: 'mark_floor',
    0x3c7e: 'mark_cell',
    0x3cb8: 'mark_cell_counts',
    0x3cc1: 'mark_cell_offsets',
    0x3cf7: 'multiply',
    # ball sprites
    0x3d12: 'pick_ball_frame',
    0x3da1: 'set_ball_frame',
    0x3dbe: 'move_shine',
    0x3fed: 'shine_diagonal',
    0x4019: 'quadrant_sign',
    0x401d: 'quadrant_dir',
    0x4021: 'quadrant_flip_y',
    0x4025: 'quadrant_flip_x',
    # main loop and maze setup
    0x4029: 'main_loop',
    0x402c: 'title_loop',
    0x402f: 'new_game',
    0x4038: 'level_loop',
    0x4048: 'draw_maze_screen',
    0x4086: 'draw_board_frame',
    0x40fc: 'show_buffers',
    0x413d: 'fill_colour_buffer',
    0x415d: 'colour_frame',
    0x4195: 'maze_floor_colours',
    0x4199: 'maze_frame_colours',
    0x419d: 'colour_gates',
    0x41f0: 'gate_cell_layout',
    0x41fc: 'next_maze_slide',
    0x4255: 'slide_wait',
    0x4263: 'slide_in',
}

DATA_RANGES = []

FORMATS = {
    0x1c00: ('rows', 16),
    0x1c80: ('rows', 16),
    0x2000: ('rows', 40),
    0x2400: ('rows', 40),
    0x2800: ('sprites',),
    0x3991: ('rows', 3),
    0x3a31: ('rows', 16),
}

BLOCK_COMMENTS = {
    0x1c00: """Demo mode recording: the control bits for each step (active low, as
read_controls returns them), and how many frames each step is held
(demo_durations). Played back by demo_play.""",
    0x1d00: 'Characters copied to $2320-$23BF at start-up',
    0x1e00: 'Pixel patterns for the maze corner characters (build_corner_chars)',
    0x2000: """Maze 0 screen (40 x 25 characters) as loaded. Saved to $A000 at
start-up; after that $2000-$27FF is the character set, built at run time.""",
    0x2400: 'Maze 1 screen as loaded (saved to $A400)',
    0x2800: """Game sprites (VIC bank 0, pointers $A0-$DF). The title screen swaps
$2800-$29FF with title_sprites ($8D00) and back (swap_title_sprites).
$31C0 (pointer $C7): ball shading, drawn at run time; $3200 (pointer $C8):
ball dissolve buffer; $3700/$3780: ball / hole sprites masked to the
current tilt.""",
    0x3800: 'Shine offset for each value of shine_x / shine_y',
    0x38c0: '$2508-$2587 = (characters $2008-$2087 << 1) | $55',
    0x38cf: """Draw the gate of the maze.
C = 0: draw the gates whose state changed (gate_frame) into the
       screen buffer at $7C00
C = 1: (re)draw all gates set in the level's mask""",
    0x3939: """Draw one gate: gate_index = entry in gate_table
(3 bytes: screen offset low, high, orientation)""",
    0x3979: """Gate masks: 4 masks per level (one per maze), levels 1-5
(level 5 and up use the last row)""",
    0x398d: 'Index of each maze\'s first entry in gate_table (8 entries of 3 bytes per maze)',
    0x3991: """Gates: 8 per maze. Screen offset (low, high) of the gate
and its orientation (0-3)""",
    0x3b2d: """Fire button: start the gate animation (once per press). The
gates flip over in steps (gate_frame); the sound plays on the way.""",
    0x3ba5: 'Gate sound (voice 3 noise): C = 1 high, C = 0 low',
    0x3bd5: """Mark the floor under the ball: every floor character ($20 or $B3) the
ball covers becomes $63, and its address goes into the mark list at
$7800/$7900 (mark_count entries). At the end of the level the marks are
counted back for bonus points and power (count_marks).""",
    0x3cf7: """Params: X, Y = factors
Returns: Y = high byte, X = low byte of X * Y""",
    0x3d12: """Choose the ball sprite frame for the light direction: the lit side
depends on the tilt and on where the ball is on the board""",
    0x3dbe: """Move the shine (sprite 1) over the ball with the ball's velocity,
bouncing off the edges of the ball; sprite 1 is hidden while it is
off the ball""",
    0x4029: """Main loop""",
    0x4048: """Copy the current maze's screen from $A000 + maze * $400 to the screen
buffer at $7C00, then draw the board frame around it""",
    0x4086: 'Board frame: left / right columns and top / bottom rows with corners',
    0x40fc: """Copy the screen buffer ($7C50-$7FFF) to the screen ($0450) and the
colour buffer ($7850-$7BFF) to colour RAM ($D850): everything but the
top two status rows""",
    0x413d: 'Fill the colour buffer with the maze\'s floor colour',
    0x415d: 'Frame colour for the board frame cells',
    0x419d: 'Colour the gate (colour 15) in the colour buffer',
    0x41fc: """Prepare the next maze and slide it in from the right""",
    0x4263: """Slide the maze in, bouncing a few times (slide_bounce steps)""",
}

COMMENTS = {
    0x4029: 'machine init',
    0x402c: 'after a game: new high score?',
    0x402f: 'title screen (waits for fire, or runs the demo)',
    0x4032: 'game variables',
    0x4035: 'first maze',
    0x4038: 'play one level',
    0x403b: 'demo: back to the title',
    0x4040: 'game over: back to the title',
    0x3c6a: 'floor?',
    0x3c91: 'floor mark character',
}

BLOCK_COMMENTS.update({
    0x38cf: """Draw the gates (the "gates" of the maze: bars across the corridors).
Fire flips them open for a moment (fire_gates).
C = 0: redraw the gates on the screen when gate_frame changed
C = 1: take the gate mask for the level and maze, draw all of them into
       the screen buffer at $7C00""",
    0x3b2d: """Fire button: open the gates. Once per press: the gates flip open over
5 steps (gate_frame 0-5), stay open for a while (shorter on higher
levels: gate_anim_start), then close again by themselves.""",
    0x2000: """Maze 0 screen (40 x 25 characters) as loaded. Saved to $A000 at
start-up; after that $2000-$27FF is the character set, built at run time.
In the mazes: $00 = wall top (multicolour %10/%11 pixels: foreground, so
the ball sprite collides with it), $20 = floor (background), the edge
characters around the walls are rebuilt for every tilt.""",
})
COMMENTS.update({
    0x3b2d: 'fire released: allow the next press',
    0x3b4a: 'new press: start the gate animation',
    0x3b55: 'steps 1-10: opening (gate_frame 0-5)',
    0x3b5e: 'step 11: open, gate sound',
    0x3b6c: 'hold open until step gate_anim_start',
    0x3b75: 'then close: gate_frame back to 0',
    0x3b89: 'closed again: gate sound, done',
})

FORMATS.update({
    0x7800: ('rows', 40),
    0x7c00: ('rows', 40),
})
BLOCK_COMMENTS.update({
    0x2400: 'Maze 1 screen as loaded (saved to $A400)',
    0x7800: """Maze 2 screen as loaded (saved to $A800). At run time $7800-$7BE7 is
the colour buffer, and $7800/$7900 also hold the floor mark list.""",
    0x7c00: """Maze 3 screen as loaded (saved to $AC00). At run time $7C00-$7FE7 is
the screen buffer the mazes are drawn into.""",
})
