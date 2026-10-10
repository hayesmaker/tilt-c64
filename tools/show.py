"""Print the generated source (src/tilt.asm) between two addresses.
Usage: python3 tools/show.py START END   (hex)"""
import sys, re
lo, hi = int(sys.argv[1], 16), int(sys.argv[2], 16)
on = False
for ln in open('src/tilt.asm'):
    m = re.search(r'// \$([0-9a-f]{4})\b', ln)
    if m:
        a = int(m.group(1), 16)
        on = lo <= a < hi
        if a >= hi:
            break
    if on:
        print(ln.rstrip())
