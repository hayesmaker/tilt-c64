"""KickAssembler-syntax listing of a range of a cartridge bank, with L labels
for jump/branch targets (a starting point for hand-written source).
Usage: python3 tools/quickka.py BANK START END [RUNBASE]   (hex, $8000-based)
RUNBASE: run-time address of START for code that is copied before it runs."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from cpu6502 import OPS, MODES
import crt
bank, s, e = int(sys.argv[1]), int(sys.argv[2], 16), int(sys.argv[3], 16)
m = bytearray(65536)
base = int(sys.argv[4], 16) if len(sys.argv) > 4 else s
m[0x8000:0xa000] = crt.banks()[bank]
if base != s:
    blk = m[s:e]
    m = bytearray(65536)
    m[base:base + len(blk)] = blk
    s, e = base, base + len(blk)
seq = []
pc = s
while pc < e:
    op = m[pc]
    if op not in OPS:
        seq.append((pc, None, None, 1)); pc += 1; continue
    mn, mode = OPS[op]
    seq.append((pc, mn, mode, MODES[mode])); pc += MODES[mode]
tg = set()
for pc, mn, mode, n in seq:
    if mode == 'rel':
        o = m[pc + 1]; tg.add((pc + 2 + (o - 256 if o > 127 else o)) & 0xffff)
    elif mn in ('jmp', 'jsr') and mode == 'abs':
        tg.add(m[pc + 1] | m[pc + 2] << 8)
for pc, mn, mode, n in seq:
    if pc in tg:
        print('L%04x:' % pc)
    if mn is None:
        print('    .byte $%02x' % m[pc]); continue
    a = m[pc + 1] if n > 1 else 0
    w = a | m[pc + 2] << 8 if n == 3 else 0
    def nm(v, wd):
        return ('L%04x' % v) if v in tg else '$%0*x' % (wd, v)
    arg = {'imp': '', 'acc': '', 'imm': '#$%02x' % a, 'zp': '$%02x' % a, 'zpx': '$%02x,x' % a,
           'zpy': '$%02x,y' % a, 'izx': '($%02x,x)' % a, 'izy': '($%02x),y' % a,
           'rel': nm((pc + 2 + (a - 256 if a > 127 else a)) & 0xffff, 4), 'abs': nm(w, 4),
           'abx': '$%04x,x' % w, 'aby': '$%04x,y' % w, 'ind': '($%04x)' % w}[mode]
    if n == 3 and w < 0x100 and mode != 'ind':
        mn += '.a'
    print('    %-24s// $%04x  %s' % ((mn + ' ' + arg).strip(), pc, ' '.join('%02x' % x for x in m[pc:pc + n])))
