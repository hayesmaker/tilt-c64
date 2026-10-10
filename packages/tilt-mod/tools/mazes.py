"""Tilt maze sets: JSON <-> cartridge banks for tilt-mod.

  python3 tools/mazes.py export [out.json]        the 4 original mazes -> mazes/original.json
  python3 tools/mazes.py build in.json [outdir]   -> outdir/maze_dir.bin (bank 10)
                                                     outdir/maze_banks.bin (banks 11+)

Maze set JSON:
{
  "format": "tilt-mazes", "version": 1,
  "demo_maze": 2,                       maze the demo plays (its recording is made for
                                        original maze 2: keep it there)
  "start_level": 0,                     optional: level a game starts on (0 = level 1);
                                        used to test a maze on a later level
  "mazes": [ {
      "name": "...",
      "screen": [25 strings of 80 hex digits],   40 x 25 screen codes; rows 0-1 are
                                                 covered by the status line
      "hole": [x, y],                   exit hole, sprite coordinates
      "start": [x, y],                  ball start, sprite coordinates (x up to 511)
      "floor_colour": 8-15, "frame_colour": 8-15,
                                        colour RAM values: 8-15 = multicolour characters,
                                        shown in colour value AND 7
      "gates": [ {"col": c, "row": r, "orientation": 0-3} x 8 ],
      "gate_masks": ["10110111", ...]   5 rows (levels 1, 2, 3, 4, 5+), one bit per gate,
                                        gate 8 ... gate 1 (left to right):
                                        1 = fire gate (opened with fire),
                                        0 = tilt gate (opened by tilting against it)
  } ... ]
}
A level plays the mazes in order; the cartridge holds at most MAX_MAZES.
"""
import sys, os, json

HERE = os.path.dirname(os.path.abspath(__file__))
PKG = os.path.dirname(HERE)
ROOT = os.path.dirname(os.path.dirname(PKG))
sys.path.insert(0, os.path.join(ROOT, 'tools'))

MAX_BANKS = 16                    # 128K cartridge
FIRST_SCREEN_BANK = 11
MAX_MAZES = (MAX_BANKS - FIRST_SCREEN_BANK) * 8      # 40
REC_SIZE = 64

# tables in the original game image (see src/tilt.asm)
SCREENS = (0x2000, 0x2400, 0x7800, 0x7c00)
HOLE_X, HOLE_Y = 0x4d6f, 0x4d73
BALL_START = 0x458b
FLOOR, FRAME = 0x4195, 0x4199
GATE_MASKS, GATE_INDEX, GATE_TABLE = 0x3979, 0x398d, 0x3991


def export(out):
    import crt
    m = crt.ram_image()
    mazes = []
    for n in range(4):
        base = SCREENS[n]
        screen = [bytes(m[base + r * 40:base + r * 40 + 40]).hex() for r in range(25)]
        g = GATE_TABLE + m[GATE_INDEX + n]
        gates = []
        for k in range(8):
            a = m[g + k * 3] | m[g + k * 3 + 1] << 8
            o = a - 0x0400
            gates.append({'col': o % 40, 'row': o // 40, 'orientation': m[g + k * 3 + 2]})
        mazes.append({
            'name': 'Original maze %d' % (n + 1),
            'screen': screen,
            'hole': [m[HOLE_X + n], m[HOLE_Y + n]],
            'start': [m[BALL_START + n * 3] | m[BALL_START + n * 3 + 1] << 8, m[BALL_START + n * 3 + 2]],
            'floor_colour': m[FLOOR + n],
            'frame_colour': m[FRAME + n],
            'gates': gates,
            'gate_masks': [format(m[GATE_MASKS + r * 4 + n], '08b') for r in range(5)],
        })
    data = {'format': 'tilt-mazes', 'version': 1, 'demo_maze': 2, 'mazes': mazes}
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, 'w') as f:
        json.dump(data, f, indent=1)
        f.write('\n')
    print('wrote %s (%d mazes)' % (out, len(mazes)))


def check(data):
    mazes = data['mazes']
    if not 1 <= len(mazes) <= MAX_MAZES:
        raise SystemExit('need 1-%d mazes, got %d' % (MAX_MAZES, len(mazes)))
    if not 0 <= data.get('demo_maze', 0) < len(mazes):
        raise SystemExit('demo_maze out of range')
    if not 0 <= data.get('start_level', 0) <= 98:
        raise SystemExit('start_level must be 0-98')
    for i, z in enumerate(mazes):
        where = 'maze %d (%s)' % (i, z.get('name', ''))
        if len(z['screen']) != 25 or any(len(r) != 80 for r in z['screen']):
            raise SystemExit(where + ': screen must be 25 rows of 80 hex digits')
        if len(z['gates']) != 8 or len(z['gate_masks']) != 5:
            raise SystemExit(where + ': needs 8 gates and 5 gate masks')
        for g in z['gates']:
            if not (0 <= g['col'] < 40 and 0 <= g['row'] < 25 and 0 <= g['orientation'] < 4):
                raise SystemExit(where + ': bad gate %r' % g)
        for k in ('floor_colour', 'frame_colour'):
            if not 8 <= z[k] <= 15:
                raise SystemExit(where + ': %s must be 8-15 (multicolour)' % k)
        if not (0 <= z['start'][0] < 512 and 0 <= z['start'][1] < 256 and
                all(0 <= v < 256 for v in z['hole'])):
            raise SystemExit(where + ': bad hole / start position')


def build(src, outdir):
    data = json.load(open(src))
    check(data)
    mazes = data['mazes']
    nbanks = (len(mazes) + 7) // 8
    directory = bytearray(8192)
    directory[0] = len(mazes)
    directory[1] = data.get('demo_maze', 2)
    directory[2:10] = b'TILTMAZE'
    directory[10] = data.get('start_level', 0)
    screens = bytearray(nbanks * 8192)
    for n, z in enumerate(mazes):
        scr = b''.join(bytes.fromhex(r) for r in z['screen'])
        screens[n * 1024:n * 1024 + 1000] = scr
        rec = bytearray(REC_SIZE)
        rec[0], rec[1] = z['hole']
        rec[2], rec[3], rec[4] = z['start'][0] & 255, z['start'][0] >> 8, z['start'][1]
        rec[5], rec[6] = z['floor_colour'], z['frame_colour']
        for r, mask in enumerate(z['gate_masks']):
            rec[7 + r] = int(mask, 2)
        for k, g in enumerate(z['gates']):
            a = 0x0400 + g['row'] * 40 + g['col']
            rec[12 + k * 3:15 + k * 3] = bytes([a & 255, a >> 8, g['orientation']])
        rec[36] = FIRST_SCREEN_BANK + n // 8
        rec[37] = 0x80 + (n % 8) * 4
        directory[0x40 + n * REC_SIZE:0x40 + (n + 1) * REC_SIZE] = rec
    os.makedirs(outdir, exist_ok=True)
    open(os.path.join(outdir, 'maze_dir.bin'), 'wb').write(directory)
    open(os.path.join(outdir, 'maze_banks.bin'), 'wb').write(screens)
    print('%d mazes -> %s/maze_dir.bin, maze_banks.bin (%d screen banks, cartridge %d banks)' % (
        len(mazes), outdir, nbanks, FIRST_SCREEN_BANK + nbanks))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == 'export':
        export(a[1] if len(a) > 1 else os.path.join(PKG, 'mazes/original.json'))
    elif a and a[0] == 'build' and len(a) >= 2:
        build(a[1], a[2] if len(a) > 2 else os.path.join(PKG, 'build'))
    else:
        raise SystemExit(__doc__)
