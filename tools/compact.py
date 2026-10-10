"""Compact listing of the generated source for reading: 'addr  text' per line,
.byte runs abbreviated. Usage: python3 tools/compact.py START END"""
import sys, re
lo, hi = int(sys.argv[1], 16), int(sys.argv[2], 16)
pend = []
on = False
for ln in open('src/tilt.asm'):
    m = re.search(r'^(.*?)\s*// \$([0-9a-f]{4})\b ?(.*)$', ln.rstrip())
    if m:
        a = int(m.group(2), 16)
        if a >= hi:
            break
        on = a >= lo
        if not on:
            continue
        txt = m.group(1).strip()
        if txt.startswith('.byte') and len(txt) > 40:
            txt = txt[:40] + '...'
        for p in pend:
            print('      ' + p)
        pend = []
        c = m.group(3)
        print('%04x  %s%s' % (a, txt, ('   ; ' + c) if c else ''))
    elif on:
        s = ln.strip()
        if s and not s.startswith('//'):
            pend.append(s)
