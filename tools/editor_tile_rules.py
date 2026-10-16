"""Make packages/level-editor/src/model/tile-rules.json: which character each maze
cell needs, from the shapes of the cell and its 8 neighbours. The editor's
automatic edges (autotile.ts) use it, including the 45 degree walls.

A cell's shape follows from its character's wall-top (foreground) pixels, which
are the same for every tilt:
  W   wall ($00)
  F   floor (the edge / shadow characters: no wall pixels)
  LL, UR, LR, UL   half wall cells, cut along a diagonal: the wall half is in the
                   lower left, upper right, ... corner ($23 $25 $27 $29 and variants)
  NB, NT, NL, NR   wall with a small notch at the bottom / top / left / right, where
                   two diagonals meet ($7C $7E $80 $82)
The rules are read off the four original mazes (no neighbourhood there needs two
different characters) and mirrored left-right and top-bottom: the game's font is
symmetric that way (character A mirrored at tilt x, y = character B at tilt 8-x, y,
or x, 8-y; the two wall-top colours count as one).

Usage: python3 tools/editor_tile_rules.py   (after tools/editor_assets.py)
"""
import os, json, base64

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, 'packages/level-editor/public/tilt-assets.json')
MAZES = os.path.join(ROOT, 'packages/tilt-mod/mazes/original.json')
OUT = os.path.join(ROOT, 'packages/level-editor/src/model/tile-rules.json')

TOP, BOTTOM, LEFT, RIGHT = 5, 21, 3, 35          # editable cells (maze.ts EDIT)
RAW = {0xb1, 0xb3}                               # floor marks: kept as they are
NB8 = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
HALVES = {'LL': lambda x, y: y > x, 'UR': lambda x, y: y < x,
          'UL': lambda x, y: x + y < 7, 'LR': lambda x, y: x + y > 7}
NOTCH = {'NB': ('UL', 'UR'), 'NT': ('LL', 'LR'), 'NL': ('UR', 'LR'), 'NR': ('UL', 'LL')}
MIRROR = {'H': {'LL': 'LR', 'LR': 'LL', 'UL': 'UR', 'UR': 'UL', 'NL': 'NR', 'NR': 'NL'},
          'V': {'LL': 'UL', 'UL': 'LL', 'LR': 'UR', 'UR': 'LR', 'NT': 'NB', 'NB': 'NT'}}


def load_fonts():
    a = json.load(open(ASSETS))
    return {tuple(map(int, k.split(','))): base64.b64decode(v) for k, v in a['fonts'].items()}


def pixels(font, code):
    """4 x 8 multicolour pixels; the two wall-top colours (%10, %11) as one"""
    return tuple(tuple(min((font[code * 8 + y] >> (6 - 2 * x)) & 3, 2) for x in range(4)) for y in range(8))


def shape_of(fonts, code):
    g = pixels(fonts[(4, 4)], code)
    wall = lambda x, y: g[y][x // 2] == 2
    cover = {h: sum(wall(x, y) for y in range(8) for x in range(8) if f(x, y)) /
             sum(1 for y in range(8) for x in range(8) if f(x, y)) for h, f in HALVES.items()}
    total = sum(wall(x, y) for y in range(8) for x in range(8)) / 64
    if total == 0:
        return 'F'
    if total == 1:
        return 'W'
    full = {h for h, v in cover.items() if v == 1}
    if len(full) == 1:
        return full.pop()
    for n, pair in NOTCH.items():
        if full == set(pair):
            return n
    return None


def mirror_maps(fonts):
    sig = {}
    for c in range(256):
        sig.setdefault(tuple(pixels(fonts[t], c) for t in sorted(fonts)), []).append(c)
    maps = {}
    for w, tilt, flip in (('H', lambda x, y: (8 - x, y), lambda g: tuple(r[::-1] for r in g)),
                          ('V', lambda x, y: (x, 8 - y), lambda g: g[::-1])):
        maps[w] = {}
        for c in range(256):
            s = tuple(flip(pixels(fonts[tilt(*t)], c)) for t in sorted(fonts))
            maps[w][c] = sig.get(s, [])
    return maps


def main():
    fonts = load_fonts()
    shapes = {}
    mazes = json.load(open(MAZES))['mazes']
    screens = [[list(bytes.fromhex(s)) for s in m['screen']] for m in mazes]
    for scr in screens:
        for r in range(TOP, BOTTOM + 1):
            for c in range(LEFT, RIGHT + 1):
                if scr[r][c] not in RAW:
                    shapes[scr[r][c]] = shape_of(fonts, scr[r][c])
    assert None not in shapes.values(), shapes
    inside = lambda r, c: TOP <= r <= BOTTOM and LEFT <= c <= RIGHT

    def key(scr, r, c):
        s = lambda r, c: shapes.get(scr[r][c], 'F') if inside(r, c) else 'W'
        return (s(r, c),) + tuple(s(r + dr, c + dc) for dr, dc in NB8)

    rules = {}
    for scr in screens:
        for r in range(TOP, BOTTOM + 1):
            for c in range(LEFT, RIGHT + 1):
                if scr[r][c] in RAW:
                    continue
                k = key(scr, r, c)
                assert rules.get(k, scr[r][c]) == scr[r][c], k
                rules[k] = scr[r][c]

    mirrors = mirror_maps(fonts)
    def mirror(k, ch, w):
        flip = (lambda dr, dc: (dr, -dc)) if w == 'H' else (lambda dr, dc: (-dr, dc))
        nb = dict(zip(NB8, k[1:]))
        m = lambda s: MIRROR[w].get(s, s)
        k2 = (m(k[0]),) + tuple(m(nb[flip(dr, dc)]) for dr, dc in NB8)
        if ch in (0x00, 0x20):
            return k2, ch
        assert mirrors[w][ch], (hex(ch), w)
        return k2, mirrors[w][ch][0]
    out = dict(rules)
    for k, ch in rules.items():
        for seq in ('H', 'V', 'HV'):
            k2, c2 = k, ch
            for w in seq:
                k2, c2 = mirror(k2, c2, w)
            assert out.get(k2, c2) == c2, k2
            out[k2] = c2
    for ch in out.values():
        shapes.setdefault(ch, shape_of(fonts, ch))
    json.dump({
        'shapes': {'%02x' % c: s for c, s in sorted(shapes.items())},
        'rules': {','.join(k): v for k, v in sorted(out.items())},
    }, open(OUT, 'w'), indent=0)
    print('%d rules (%d from the original mazes), %d characters -> %s' % (len(out), len(rules), len(shapes), OUT))


if __name__ == '__main__':
    main()
