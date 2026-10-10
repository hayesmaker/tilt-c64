"""Annotations: start-up ($080D-$09D7), ball physics ($09D8-$0C32),
tilt graphics: wall-edge characters and the board frame ($0C33-$19B7),
sounds, controls ($19B8-$1B6E)."""

FORMATS = {
    0x0b89: ('rows', 8),
    0x08b0: ('text',),
}

LABELS = {
    # ---- start-up
    0x080d: 'start',
    0x083b: 'save_mazes_loop',
    0x0887: 'checksum',
    0x08b0: 'basic_leftovers',
    0x0980: 'start_game',
    0x0984: 'start_dev_mode',
    0x0986: 'start_common',
    0x09d0: 'tamper_glyph',
    # ---- ball physics
    0x09d8: 'velocity_to_delta',
    0x0a0b: 'move_ball',
    0x0a4d: 'steer_ball',
    0x0b45: 'target_speed',
    0x0b64: 'approach',
    0x0b89: 'target_speed_table',
    0x0bb1: 'calc_accel',
    0x0c2e: 'accel_steps_table',
    # ---- tilt graphics
    0x0c33: 'build_wall_chars',
    0x0cef: 'clear_edges_left',
    0x0d09: 'clear_edges_right',
    0x0d23: 'clear_edges_top',
    0x0d34: 'clear_edges_bottom',
    0x0d45: 'ease_tilt',
    0x0da4: 'pick_hole_sprite',
    0x0dbc: 'tilt_level_shift_x',
    0x0dc5: 'tilt_level_shift_y',
    0x0dce: 'hole_sprite_index',
    0x0dd7: 'hole_sprite_table',
    0x0dff: 'ease_angle',
    0x0e2e: 'edge_chars_left',
    0x0ee0: 'edge_pixels_table',
    0x0f20: 'edge_pixels_table2',
    0x0f60: 'edge_fill_left',
    0x0f65: 'edge_fill_right',
    0x0f6a: 'edge_shade_left',
    0x0faa: 'edge_shade_right',
    0x0fea: 'edge_chars_right',
    0x108e: 'edge_chars_top',
    0x1125: 'edge_fill_top',
    0x1129: 'edge_chars_bottom',
    0x11ba: 'edge_fill_bottom',
    0x11be: 'build_corner_chars',
    0x1292: 'corner_distance',
    0x12c4: 'build_corner_chars2',
    0x1371: 'build_corner_chars3',
    0x13ca: 'build_junction_chars',
    0x14ad: 'build_junction_chars2',
    0x14fb: 'build_junction_chars3',
    0x1596: 'roll_sound',
    0x1647: 'place_ball_shadow',
    0x1687: 'frame_side_shift',
    0x16c1: 'frame_side_table',
    0x16f3: 'draw_frame_bottom',
    0x1736: 'frame_bottom_chars',
    0x173f: 'frame_run_lengths',
    0x1744: 'draw_frame_top',
    0x178b: 'frame_top_chars',
    0x1794: 'draw_frame_left',
    0x17fc: 'frame_run_lengths_v',
    0x1801: 'frame_left_chars',
    0x1806: 'draw_frame_right',
    0x186a: 'frame_right_chars',
    0x186f: 'char_addr_fb',
    0x1882: 'char_addr_fd',
    0x1895: 'build_frame_corners',
    0x192a: 'build_hole_chars',
    0x198e: 'build_hole_chars2',
    0x19b8: 'tilt_clunk_sound',
    0x1a6c: 'tilt_sound_freq',
    0x1a84: 'dev_mode_screen',
    0x1ab6: 'read_controls',
}

BLOCK_COMMENTS = {
    0x080d: """Start of the TILT program (SYS 2061; the cartridge gets here via $0460)""",
    0x0827: """Copy protection / tamper check: the sum of $0980-$8DFF must be $3FDA:$37
(A:X:Y). If it is not, 'tampered' is set and one character of the font gets
replaced by an 'E' (tamper_glyph) - so changing the code shows up as a wrong
glyph unless the checksum is corrected!""",
    0x083b: """Save the four 1K maze screens ($2000-$27FF and $7800-$7FFF in the loaded
file) to $A000-$AFFF: both areas are reused at run time (character set at
$2000, screen and colour buffers at $7800-$7FFF). draw_maze_screen copies a
maze back from $A000 + maze * $400.""",
    0x085d: """$1D00-$1D9F -> $2320 (characters)""",
    0x0887: """Sum of all bytes $0980-$8DFF: returns A = low byte, X/Y = 16 bit carry count""",
    0x0980: """Game start. $0984 (SYS 2436) is a developer entry: the game then runs
from the raster interrupt and BASIC stays usable.""",
    0x09d8: """Params: A = velocity (signed), C = 1
Returns: $FB/$FC = velocity * 4 (or more: X+1 shifts) as a signed 16 bit
position delta""",
    0x0a0b: """Add the velocity to the ball position (X 24 bit: frac, low, bit 8;
Y 16 bit: frac, position)""",
    0x0a4d: """Read the tilt direction from the controls and steer the ball velocity
toward the target speed for that direction. A diagonal held for a while
is remembered for a few frames (diag_hold_*), so that releasing one
direction a little early does not stop the diagonal roll.""",
    0x0b45: """Params: X = tilt direction of this axis, Y = of the other axis (-1/0/1)
Returns: A = target velocity + $80 for this axis and speed class.
Diagonal tilts give a lower speed per axis (e.g. 68 instead of 96).""",
    0x0b89: """Target velocities + $80, 8 bytes per speed class:
X = -1, 0, +1 (diagonal), unused, X = -1, 0, +1 (straight), unused""",
    0x0b64: """Params: A = velocity (signed), X = target velocity + $80, Y = step
Returns: A moved by at most Y toward the target""",
    0x0bb1: """Split the acceleration over X and Y in proportion to how far each
velocity is from its target, so the ball turns smoothly.""",
    0x0c33: """Build the wall-edge characters ($2008-$20C7) for the current maze
shift: params zp_fb = Y shift 0-8, zp_fc = X shift 0-8 (4 = level).
The maze walls have a lit side face whose width follows the tilt;
these characters hold every combination of edges.""",
    0x0d45: """Ease the tilt angles toward the tilt direction and derive the
perspective shift (tilt_level, cf0e/cf0f)""",
    0x0dff: """Params: A = angle, X = direction (-1/0/1)
Returns: A moved by tilt_rate toward 0, $80 or 255""",
    0x08b0: """Leftover of the developer's BASIC loader (tokenized, $93 = LOAD):
  LOAD "CHAR35-42.MOD",8,1   LOAD "CHAR100-119.MOD",8,1   LOAD "TABLES.MOD",8,1
  LOAD "SPRITES.MOD",8,1     LOAD "COSINE.MOD",8,1        LOAD "DEMO.MOD",8,1
  LOAD "MUSIC.MOD",8,1
The game was put together from these modules. Not used.""",
    0x1596: """Rolling noise: SID voice 3 noise, volume and filter follow the ball speed""",
    0x1647: """Ball shadow (sprite 4, black) = ball position + perspective shift - 4""",
    0x1687: """Params: X, Y = perspective shift 0-8
Returns: X, Y = start/end of the visible side of the board frame""",
    0x16f3: """Draw the board frame sides with the characters for the current tilt
(bottom row $079A, top row $047A, left column $04A1, right column $04C5)""",
    0x186f: """A = character code -> zp_fb/zp_fc = its address in the font at $2000""",
    0x1882: """A = character code -> zp_fd/zp_fe = its address in the font at $2000""",
    0x19b8: """Tilt "clunk" sound when the tilt direction changes (voice 2)""",
    0x1ab6: """Read the controls: joystick in port 2 ANDed with keys on the keyboard.
Returns A = joystick style bits, active low: 0 up, 1 down, 2 left,
3 right, 4 fire. Keys, one "diamond" for each hand:
    right hand:  * up   ; left   RETURN right   right SHIFT down
    left hand:   Q / CTRL up   RUN/STOP left   A right   left SHIFT down
    SPACE fire
Pressing two opposite directions cancels both.""",
}

COMMENTS = {
    0x080e: 'BASIC ROM off',
    0x0812: 'screen off',
    0x081a: 'black border and background',
    0x0822: 'assume tampered',
    0x0836: 'checksum is right',
    0x083d: '8 pages each',
    0x084e: 'self-modifying: next page',
    0x086a: 'reset the stack',
    0x0874: '40 columns, multicolour off',
    0x0879: 'screen $0400, upper case ROM font',
    0x087e: 'VIC bank 0 ($0000-$3FFF)',
    0x0882: 'jmp start_game',
    0x0989: 'tampered: replace a glyph of the font copy',
    0x09b2: 'score display: six "0" glyphs -> $2780-$27AF',
    0x09c2: 'font for the status line -> $2650-$26D7',
    0x09cd: 'go to the main loop',
    0x0827: 'A:X:Y = checksum',
    0x1b4b: 'up and down together: neither',
    0x1b54: 'left and right together: neither',
    0x1b61: 'read joystick port 2 with port A as input',
    0x1abf: 'fire: SPACE',
    0x1acf: 'right: RETURN or A',
    0x1aeb: 'left: ; or RUN/STOP',
    0x1b07: 'down: right SHIFT or left SHIFT',
    0x1b23: 'up: *, or Q / CTRL (ignored while ; or right SHIFT is down)',
    # velocity_to_delta
    0x09d8: 'C=1: shift count 2 (velocity * 4)',
    0x09dc: 'remember the sign',
    0x09e2: 'work with |velocity|',
    0x09ed: 'shift into zp_fb (low) and A (high)',
    0x09f5: 'negative: negate the 16 bit result',
    # move_ball
    0x0a0b: 'X: frac/low += velocity * 4',
    0x0a23: 'carry into bit 8 (sign of the delta decides up or down)',
    0x0a34: 'Y: frac/position += velocity * 4',
    # steer_ball
    0x0a4d: 'remember the old tilt direction',
    0x0a5e: 'X = number of directions pressed',
    0x0a69: 'diagonal: remember it',
    0x0a7e: 'held long enough: diagonal sound once',
    0x0a94: 'one direction after a diagonal: keep the diagonal for 8 frames',
    0x0aa7: 'no direction: restore a recent diagonal',
    0x0ac4: 'set tilt_dx / tilt_dy from the control bits',
    0x0ad0: 'left (bit 2)',
    0x0ada: 'right (bit 3)',
    0x0ae5: 'up (bit 0)',
    0x0aef: 'down (bit 1)',
    0x0afa: 'target speeds for X and Y',
    0x0b10: 'direction changed: new acceleration split',
    0x0b23: 'steering off while the ball appears / drops',
    0x0b28: 'velocity -> target speed by the acceleration',
    # target_speed
    0x0b45: 'other axis -1/+1 -> row 0 (diagonal), 0 -> row 1',
    0x0b56: '8 entries per speed class',
}
