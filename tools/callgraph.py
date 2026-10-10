"""List subroutines (JSR targets) with their callers, plus JMP targets, to get an
overview of the program. Usage: python3 tools/callgraph.py [lo hi]"""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import disasm as D
lo, hi = (int(sys.argv[1], 16), int(sys.argv[2], 16)) if len(sys.argv) > 2 else (D.LOAD0, D.LOAD_END)
calls = {}
for a, (mn, mode, n) in D.insn_at.items():
    if mn == 'jsr':
        calls.setdefault(D.target(a, mode), []).append(a)
for t in sorted(calls):
    if lo <= t < hi:
        nm = D.A.LABELS.get(t, '')
        print('%04x %-28s %3d callers: %s' % (t, nm, len(calls[t]), ' '.join('%04x' % c for c in sorted(calls[t])[:10])))
