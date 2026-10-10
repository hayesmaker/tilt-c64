"""Run the game in the crude emulator from the start-of-game snapshot with a
scripted input and save coverage (executed PCs + data refs) for the disassembler.
Usage: python3 tools/coverage.py SCRIPT FRAMES OUT.pkl [SEED] [PNGDIR]
SCRIPT: attract | play"""
import sys, random, pickle, time, os
sys.path.insert(0, 'tools')
from render import render

KEY = {'space': (7, 4), 'f1': (0, 4), 'f7': (0, 3), 'f3': (0, 5), 'f5': (0, 6), 'stop': (7, 7),
       'return': (0, 1), 'q': (7, 6), 'p': (5, 1), 'h': (3, 5)}
script, total, out = sys.argv[1], int(sys.argv[2]), sys.argv[3]
random.seed(int(sys.argv[4]) if len(sys.argv) > 4 else 1)
pngdir = sys.argv[5] if len(sys.argv) > 5 else None
c = pickle.load(open('build/snapshot.pkl', 'rb'))['emu']
f0 = c.frame
t = time.time()
last = -1
joy = 0xff
while c.frame - f0 < total:
    f = c.frame - f0
    if f != last:
        last = f
        if f % 250 == 0:
            print('frame', f, 'pcs', len(c.exec_pcs), '%.0fs' % (time.time() - t), flush=True)
            if pngdir:
                render(c, os.path.join(pngdir, 'f%05d.png' % f))
        c.keys = set()
        if script == 'attract':
            joy = 0xff
            if 1500 <= f < 1510: c.keys = {KEY['f7']}        # demo mode
        elif script == 'play':
            ph = f % 4000
            if ph < 300: joy = 0xff
            elif ph < 310: joy = 0xef                        # fire to play
            elif f % 20 == 0:
                joy = 0xff & ~random.choice([0, 1, 2, 4, 8, 5, 6, 9, 10, 0x10, 0x11, 0x14, 0x18])
        c.joy = joy
    c.run_cycles(1000)
pickle.dump({'exec': c.exec_pcs, 'rd': c.rd_log, 'wr': c.wr_log, 'ptr': c.ptr_log, 'ind': c.ind_jumps},
            open(out, 'wb'))
print('done', len(c.exec_pcs))
