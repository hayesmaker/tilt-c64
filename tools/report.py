"""List the non-code runs of the image with how much of each is read / written
by the game (from coverage), to tell tables from buffers and leftovers.
Usage: python3 tools/report.py [minlen]"""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import disasm as D
# readers that touch everything: checksum, start-up copy loops
IGNORE = {0x0896, 0x083f, 0x0845, 0x085f, 0x09b2, 0x09c2}
for k in list(D.rd_log):
    D.rd_log[k] = D.rd_log[k] - IGNORE
    if not D.rd_log[k]:
        del D.rd_log[k]
minlen = int(sys.argv[1]) if len(sys.argv) > 1 else 1
a = D.LOAD0
while a < D.LOAD_END:
    if D.kind[a] in (D.CODE, D.OPER):
        a += 1
        continue
    e = a
    while e < D.LOAD_END and D.kind[e] not in (D.CODE, D.OPER):
        e += 1
    if e - a >= minlen:
        rd = sum(1 for i in range(a, e) if i in D.rd_log)
        wr = sum(1 for i in range(a, e) if i in D.wr_log)
        vals = set(D.IMG[a:e])
        fill = (' fill $%02x' % D.IMG[a]) if len(vals) == 1 else ''
        readers = sorted({pc for i in range(a, e) for pc in D.rd_log.get(i, ())})[:4]
        print('%04x-%04x len %5d  read %5d  written %5d%s  by %s' % (
            a, e - 1, e - a, rd, wr, fill, ' '.join('%04x' % p for p in readers)))
    a = e
