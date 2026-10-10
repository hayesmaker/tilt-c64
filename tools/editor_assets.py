"""Make packages/level-editor/public/tilt-assets.json: the run-time character
sets of the game for every perspective shift (0-8 x 0-8), the game sprites,
and the gate drawing tables. The editor renders mazes with these.

The game is started in the emulator (build/snapshot.pkl, see tools/snapshot.py)
until a maze is on screen; then the tilt is frozen at each shift and the game's
own update_tilt_graphics rebuilds the characters.
Usage: python3 tools/editor_assets.py
"""
import sys, os, pickle, json, base64
sys.path.insert(0, os.path.dirname(__file__))

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'packages/level-editor/public/tilt-assets.json')

# variables / tables (see src/tilt.asm)
TILT_ENABLED, TILT_LEVEL_X, TILT_LEVEL_Y = 0xcf53, 0xcf37, 0xcf38
STEERING_ON, BALL_WAITING = 0xcf50, 0xcf73
GATE_CELLS, GATE_CHARS = 0x39f1, 0x3a31
HOLE_SPRITE = 0xcf6a


def b64(b):
    return base64.b64encode(bytes(b)).decode()


def main():
    c = pickle.load(open(os.path.join(ROOT, 'build/snapshot.pkl'), 'rb'))['emu']
    f0 = c.frame
    while True:                                   # start a game, wait for the first maze
        f = c.frame - f0
        c.joy = 0xef if 300 <= f < 310 or (c.m[BALL_WAITING] and f % 20 < 5) else 0xff
        c.run_cycles(5000)
        if c.m[STEERING_ON] and f > 400:
            break
    c.joy = 0xff
    fonts = {}
    holes = {}
    for y in range(9):
        for x in range(9):
            for _ in range(4):                    # a few frames: the main loop rebuilds the font
                c.m[TILT_ENABLED] = 0
                c.m[STEERING_ON] = 0
                c.m[0xcf00] = c.m[0xcf01] = 0          # ball_vx / ball_vy: keep the ball still
                c.m[TILT_LEVEL_X], c.m[TILT_LEVEL_Y] = x, y
                c.run_cycles(19656)
            fonts['%d,%d' % (x, y)] = b64(c.m[0x2000:0x2800])
            # exit hole: sprite 7 = hole_sprite (frame for this tilt), sprite 6 = its
            # copy masked to the tilt at $3780 (mask_hole_sprite)
            holes['%d,%d' % (x, y)] = [c.m[HOLE_SPRITE], b64(c.m[0x3780:0x37c0])]
    data = {
        'fonts': fonts,
        'holes': holes,
        'sprites': b64(c.m[0x2800:0x3800]),        # pointers $A0-$DF
        'sprite_pointers': list(c.m[0x07f8:0x0800]),
        'gate_cells': list(c.m[GATE_CELLS:GATE_CELLS + 64]),
        'gate_chars': list(c.m[GATE_CHARS:GATE_CHARS + 252]),
        'vic': {'bg1': c.io[0x22] & 15, 'bg2': c.io[0x23] & 15},
        # hardware fine scroll per tilt level (tilt_level_shift_x / _y): $D016 / $D011 bits 0-2
        'scroll_x': list(c.m[0x0dbc:0x0dc5]),
        'scroll_y': list(c.m[0x0dc5:0x0dce]),
    }
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump(data, open(OUT, 'w'))
    print('wrote', OUT, os.path.getsize(OUT), 'bytes')


if __name__ == '__main__':
    main()
