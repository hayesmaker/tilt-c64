"""Render the four Tilt mazes to docs/mazes/maze0-3.png.

The character set only exists at run time, so the game is started in the
emulator (from build/snapshot.pkl, made by tools/snapshot.py) until level 1
is on screen, and that font is used for all mazes. Marked on top:
  yellow boxes  the 8 gates of the maze (gate_table at $3991)
  pink cross    exit hole (hole_x_by_maze / hole_y_by_maze)
  white cross   ball start (ball_start_positions at $458B)
Usage: python3 tools/mazeview.py [build/tilt.prg]
"""
import sys, os, pickle
sys.path.insert(0, os.path.dirname(__file__))
from render import png

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAZE_SCREENS = (0x2000, 0x2400, 0x7800, 0x7c00)
FLOOR_COLOURS = 0x4195
GATES, GATE_INDEX = 0x3991, 0x398d
HOLE_X, HOLE_Y = 0x4d6f, 0x4d73
BALL_START = 0x458b


def game_font():
    c = pickle.load(open(os.path.join(ROOT, 'build/snapshot.pkl'), 'rb'))['emu']
    f0 = c.frame
    while c.frame - f0 < 900:
        c.joy = 0xef if 300 <= c.frame - f0 < 310 else 0xff     # fire: start a game
        c.run_cycles(5000)
    return bytes(c.m[0x2000:0x2800])


def main():
    prg = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'build/tilt.prg')
    d = open(prg, 'rb').read()
    img = bytearray(65536)
    load = d[0] | d[1] << 8
    img[load:load + len(d) - 2] = d[2:]
    font = game_font()
    out = os.path.join(ROOT, 'docs/mazes')
    os.makedirs(out, exist_ok=True)
    for n, base in enumerate(MAZE_SCREENS):
        colours = [9, 0, 15, img[FLOOR_COLOURS + n] & 7]       # $D021, $D022, $D023, colour RAM
        px = [[0] * 320 for _ in range(200)]
        for y in range(200):
            for cx in range(40):
                ch = img[base + (y // 8) * 40 + cx]
                b = font[ch * 8 + (y & 7)]
                for p in range(4):
                    v = colours[(b >> (6 - 2 * p)) & 3]
                    px[y][cx * 8 + p * 2] = px[y][cx * 8 + p * 2 + 1] = v

        def box(x0, y0, w, h, col):
            for x in range(x0, x0 + w):
                for yy in (y0, y0 + h - 1):
                    if 0 <= x < 320 and 0 <= yy < 200:
                        px[yy][x] = col
            for yy in range(y0, y0 + h):
                for x in (x0, x0 + w - 1):
                    if 0 <= x < 320 and 0 <= yy < 200:
                        px[yy][x] = col

        def cross(x, y, col):
            for k in range(-6, 7):
                for t in (-1, 0, 1):
                    for (a, b) in ((x + k, y + t), (x + t, y + k)):
                        if 0 <= a < 320 and 0 <= b < 200:
                            px[b][a] = col
        g = GATES + img[GATE_INDEX + n]
        for k in range(8):
            off = img[g + k * 3] | img[g + k * 3 + 1] << 8
            off -= 0x0400 if off >= 0x0400 else 0
            box((off % 40) * 8, (off // 40) * 8, 24, 24, 7)
        cross(img[HOLE_X + n] - 24 + 8, img[HOLE_Y + n] - 50 + 8, 10)
        bx = img[BALL_START + n * 3] | img[BALL_START + n * 3 + 1] << 8
        cross(bx - 24 + 8, img[BALL_START + n * 3 + 2] - 50 + 8, 1)
        png(os.path.join(out, 'maze%d.png' % n), 320, 200, px)
        print('wrote docs/mazes/maze%d.png' % n)


if __name__ == '__main__':
    main()
