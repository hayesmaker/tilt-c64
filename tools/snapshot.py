"""Boot bin/Tilt.crt in the emulator and save the machine state at the moment the
cartridge loader jumps to the game ($0460): 64K RAM, VIC/CIA registers, CPU.
Usage: python3 tools/snapshot.py [out.pkl]"""
import sys, pickle
sys.path.insert(0, 'tools')
from emu import boot

ENTRY = 0x0460


class Done(Exception):
    pass


def snap(c, pc):
    if pc == ENTRY and not c.cart_on:
        raise Done


c = boot()
c.trace_hook = snap
try:
    while c.frame < 3000:
        c.run_cycles(5000)
    raise SystemExit('game entry not reached')
except Done:
    pass
c.trace_hook = None
c.exec_pcs = {}; c.rd_log = {}; c.wr_log = {}; c.ptr_log = {}; c.ind_jumps = {}
state = {'emu': c, 'ram': bytes(c.m), 'io': bytes(c.io), 'a': c.a, 'x': c.x, 'y': c.y, 'sp': c.sp,
         'p': c.p(), 'frame': c.frame}
pickle.dump(state, open(sys.argv[1] if len(sys.argv) > 1 else 'build/snapshot.pkl', 'wb'))
print('snapshot at frame %d, sp=%02x' % (c.frame, c.sp))
