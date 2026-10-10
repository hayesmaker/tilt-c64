"""Boot build/tilt-mod.crt in the emulator, start a game and put the ball on the
exit hole every maze, logging maze number / slot / level as the game advances.
Checks that each loaded slot matches the maze set's record.
Usage: python3 tools/test_mod.py [mazes.json] [mazes_to_play]"""
import sys, os, json, time
HERE = os.path.dirname(os.path.abspath(__file__))
PKG = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(PKG)), 'tools'))
from emu import boot

src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(PKG, 'mazes/original.json')
todo = int(sys.argv[2]) if len(sys.argv) > 2 else 8
mazes = json.load(open(src))['mazes']
sym = {}
for ln in open(os.environ.get('VS', os.path.join(PKG, 'build/tilt.vs'))):
    p = ln.split()
    if len(p) == 3 and p[0] == 'al':
        sym[p[2].lstrip('.')] = int(p[1].split(':')[-1], 16)
V = lambda n: sym[n]
c = boot(os.environ.get('CRT', os.path.join(PKG, 'build/tilt-mod.crt')))
if 'maze_number' not in sym:              # unmodified game: compare by slot only
    sym['maze_number'] = sym['maze']
t = time.time()
f = 0
started = False
seen = []
errors = 0
shot_at = -1


def check_slot(c):
    global errors
    n, slot = c.m[V('maze_number')], c.m[V('maze')]
    z = mazes[n]
    got = (c.m[V('hole_x_by_maze') + slot], c.m[V('hole_y_by_maze') + slot],
           c.m[V('maze_floor_colours') + slot])
    want = (z['hole'][0], z['hole'][1], z['floor_colour'])
    scr = bytes(c.m[0xa000 + slot * 0x400:0xa000 + slot * 0x400 + 1000])
    ok = got == want and scr == b''.join(bytes.fromhex(r) for r in z['screen'])
    if not ok:
        errors += 1
    return ok


while f < 40000 and len(seen) < todo:
    c.run_cycles(19656)
    f += 1
    if not started and c.pc < 0x8000 and c.m[V('title_mode')] == 1 and f > 900:
        c.joy = 0xef                                    # fire: start a game
        started = f
    elif started and f - started > 10:
        c.joy = 0xff
    if started and f - started > 30 and c.m[V('steering_on')] and not c.m[V('ball_in_hole')]:
        slot = c.m[V('maze')]
        key = (c.m[V('level')], c.m[V('maze_number')])
        if not seen or seen[-1] != key:
            seen.append(key)
            print('frame %5d  level %d  maze %d  slot %d  record ok: %s' % (
                f, key[0] + 1, key[1], slot, check_slot(c)), flush=True)
            shot_at = f + 60
        if os.environ.get('SHOTS') and f == shot_at:
            from render import render
            render(c, os.path.join(PKG, 'build/shot_l%d_m%d.png' % (key[0] + 1, key[1])))
        # cheat: ball onto the exit hole
        c.m[V('ball_x')] = c.m[V('hole_x')]
        c.m[V('ball_x_hi')] = c.m[V('hole_x_hi')]
        c.m[V('ball_y')] = c.m[V('hole_y')]
        c.m[V('ball_vx')] = c.m[V('ball_vy')] = 0
    if started and c.m[V('ball_waiting')]:
        c.joy = 0xef if f % 20 < 5 else 0xff            # press fire when the ball appears
print('%d mazes played, %d record errors, %.0fs' % (len(seen), errors, time.time() - t))
sys.exit(1 if errors or not seen else 0)
