"""Tilt (C64) disassembler -> KickAssembler source generator.
(Ported from the thrust-c64 generator; Tilt runs where it loads, so there is
no relocation: every address is both the load and the run-time address.)

Inputs:
  bin/Tilt.crt                   cartridge; the game RAM image $0334-$FFFF is rebuilt by tools/crt.py
  tools/coverage/*.pkl           emulator coverage (executed PCs, data accesses)
  tools/tilt_annotations.py      memory regions, labels, comments, data formats
  tools/ann_*.py                 more annotations, merged in file name order

Output: src/tilt.asm (+ include files named in SPLITS, + src/bin/*.bin for
regions marked 'binary').

Usage: python3 tools/disasm.py [out.asm]
"""
import sys, os, glob, pickle, re
from collections import defaultdict
sys.path.insert(0, os.path.dirname(__file__))
from cpu6502 import OPS, MODES
import tilt_annotations as A
import crt

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

IMG = crt.ram_image()
LOAD0 = crt.IMG_START
LOAD_END = 0x10000


class Region:
    def __init__(self, name, start, end, kind='code', note=''):
        self.name, self.start, self.end, self.kind, self.note = name, start, end, kind, note

    def __repr__(self):
        return '%s[%04x-%04x %s]' % (self.name, self.start, self.end, self.kind)


REGIONS = [Region(*r) for r in A.REGIONS]
REGIONS.sort(key=lambda r: r.start)
pos = LOAD0
for rg in REGIONS:
    assert rg.start == pos, ('gap/overlap at', hex(pos), rg)
    pos = rg.end
assert pos == LOAD_END, hex(pos)

region_of = [None] * 65536
for rg in REGIONS:
    for a in range(rg.start, rg.end):
        region_of[a] = rg


def in_image(a):
    return LOAD0 <= a < LOAD_END and region_of[a].kind in ('code', 'data')


# ---------------------------------------------------------------- coverage
exec_pc = {}
rd_log = defaultdict(set)
wr_log = defaultdict(set)
ind_jumps = defaultdict(set)
for f in sorted(glob.glob(os.path.join(HERE, 'coverage', '*.pkl'))):
    c = pickle.load(open(f, 'rb'))
    for pc, b in c['exec'].items():
        exec_pc[pc] = b
    for k, v in c['rd'].items():
        rd_log[k] |= v
    for k, v in c['wr'].items():
        wr_log[k] |= v
    for k, v in c['ind'].items():
        ind_jumps[k] |= v

# --------------------------------------------------------------- classify
CODE, OPER, DATA = 1, 2, 3
kind = [0] * 65536
insn_at = {}                 # addr -> (mn, mode, size)
problems = []


def try_insn(a):
    op = IMG[a]
    if op not in OPS:
        return None
    mn, mode = OPS[op]
    n = MODES[mode]
    rg = region_of[a]
    if rg is None or a + n > rg.end:
        return None
    return mn, mode, n


not_code = set()
for (s, e) in A.DATA_RANGES:
    not_code.update(range(s, e))
for rg in REGIONS:
    if rg.kind != 'code':
        not_code.update(range(rg.start, rg.end))


def mark_code(a, why):
    if kind[a] == CODE:
        return insn_at[a]
    if kind[a] in (OPER, DATA):
        problems.append('%s: %04x already %s' % (why, a, kind[a]))
        return None
    t = try_insn(a)
    if t is None:
        problems.append('%s: bad opcode at %04x' % (why, a))
        return None
    mn, mode, n = t
    for i in range(1, n):
        if kind[a + i] != 0:
            problems.append('%s: operand overlap at %04x' % (why, a))
            return None
    kind[a] = CODE
    for i in range(1, n):
        kind[a + i] = OPER
    insn_at[a] = t
    return t


def target(a, mode):
    if mode == 'rel':
        o = IMG[a + 1]
        return (a + 2 + (o - 256 if o > 127 else o)) & 0xffff
    return IMG[a + 1] | IMG[a + 2] << 8


def trace(r, why):
    work = [r]
    while work:
        r = work.pop()
        while True:
            if not (LOAD0 <= r < LOAD_END) or r in not_code or kind[r] == CODE:
                break
            t = mark_code(r, why + ' %04x' % r)
            if t is None:
                break
            mn, mode, n = t
            if r in A.NO_TRACE:
                if mn in ('jmp', 'rts', 'rti'):
                    break
                r += n
                continue
            if mode == 'rel':
                work.append(target(r, mode))
            if mn == 'jsr':
                tg = target(r, mode)
                work.append(tg)
                if tg in A.NO_RETURN:
                    break
            if mn == 'jmp':
                if mode == 'abs':
                    work.append(target(r, mode))
                break
            if mn in ('rts', 'rti', 'brk'):
                break
            r += n


# 1. dynamic: executed instructions whose opcode byte matches the image
#    (self-modified operands are fine; a changed opcode byte is not)
for pc in sorted(exec_pc):
    if LOAD0 <= pc and pc not in not_code and IMG[pc] == exec_pc[pc][0]:
        mark_code(pc, 'exec')
for pc, tgts in ind_jumps.items():
    for t in tgts:
        trace(t, 'ind')
# 2. static: entry points + everything reachable from executed code
for e in A.ENTRY_POINTS:
    trace(e, 'entry')
for a in list(insn_at):
    mn, mode, n = insn_at[a]
    if (mode == 'rel' or (mn in ('jsr', 'jmp') and mode == 'abs')) and a not in A.NO_TRACE:
        trace(target(a, mode), 'from %04x' % a)
    if mn not in ('rts', 'rti', 'jmp', 'brk') and not (mn == 'jsr' and target(a, mode) in A.NO_RETURN):
        trace(a + n, 'fall %04x' % a)

# --------------------------------------------------------------- labels
from c64regs import HW

labels = {}            # addr -> name (inside the image)
consts = {}            # addr -> name (outside the image: hardware, KERNAL, RAM buffers)
zp_names = dict(A.ZP)
zp_alias = {n: a for a, n in zp_names.items()}
used_aliases = set()
const_defs = dict(A.CONSTS)
used_consts = set()

for a, n in HW.items():
    consts[a] = n
for a, n in A.LABELS.items():
    if a < 0x100:
        zp_names[a] = n
        zp_alias[n] = a
    elif in_image(a) and a not in A.RAM_LABELS:
        consts.pop(a, None)
        labels[a] = n
    else:
        consts[a] = n
for a, n in A.RAM_LABELS.items():
    consts[a] = n
names = list(labels.values()) + list(consts.values())
dup = [n for n in set(names) if names.count(n) > 1]
assert not dup, 'duplicate label names: %s' % dup

TABLES = sorted((a, e, n) for a, (e, n) in A.TABLES.items())
for (ts, te, tn) in TABLES:
    labels[ts] = tn
    for a in range(ts + 1, te):
        labels.pop(a, None)

COMMENTS = dict(A.COMMENTS)
BLOCKS = dict(A.BLOCK_COMMENTS)
OPNAMES = dict(A.OPERAND_NAMES)
IMMS = dict(A.IMMEDIATES)


def insn_start(a):
    while kind[a] == OPER:
        a -= 1
    return a


def ref(v, data=False):
    """Symbolic text for address v (None if it should stay numeric)."""
    if v in A.RAM_LABELS and data:
        return A.RAM_LABELS[v]
    if v in labels and in_image(v) and kind[v] != OPER:
        return labels[v]
    if v in consts:
        return consts[v]
    for (ts, te, tn) in TABLES:
        if ts < v < te:
            return '%s+%d' % (tn, v - ts)
    for (rs, (re_, rn)) in sorted(A.RAM_TABLES.items()):
        if rs <= v < re_:
            used_ram_tables.add(rs)
            return rn if v == rs else '%s+%d' % (rn, v - rs)
    if not (in_image(v) and kind[v] == CODE):
        for (bs, be, fmt) in A.BASES:
            if bs <= v < be:
                return fmt(v - bs)
    if in_image(v):
        s = insn_start(v)
        if s != v:
            if v in labels:
                return labels[v]          # emitted as .label name = *+k
            return '%s+%d' % (ref(s), v - s)
        nm = ('L' if kind[v] == CODE else 'D') + '%04x' % v
        labels[v] = nm
        return nm
    return None


def zpref(r, v):
    """Name for a zero-page operand of the instruction at r."""
    if r in OPNAMES:
        nm = OPNAMES[r]
        base, plus = (nm[:-2], 1) if nm.endswith('+1') else (nm, 0)
        if zp_alias.get(base) == v - plus:
            used_aliases.add(base)
            return nm
    for (rs, re_, nms) in A.ZP_RANGE_NAMES:
        if rs <= r < re_:
            for k in (0, 1):
                if v - k in nms:
                    nm = nms[v - k]
                    assert zp_alias.setdefault(nm, v - k) == v - k, 'zp name clash: %s' % nm
                    used_aliases.add(nm)
                    return nm + ('+1' if k else '')
    if v in zp_names:
        used_aliases.add(zp_names[v])
        return zp_names[v]
    if v - 1 in zp_names and v - 1 in A.ZP_WORDS:
        used_aliases.add(zp_names[v - 1])
        return zp_names[v - 1] + '+1'
    return None


def hexv(v, w):
    return '$%0*x' % (w, v)


imm_pairs = {}         # addr of imm insn -> '<expr' / '>expr'


def find_imm_pairs():
    """lda #lo / sta x / lda #hi / sta x+1 sequences -> #<label / #>label."""
    seq = sorted(insn_at)
    for k, a in enumerate(seq):
        mn, mode, n = insn_at[a]
        if mode != 'imm' or mn not in ('lda', 'ldx', 'ldy') or k + 1 >= len(seq):
            continue
        a2 = seq[k + 1]
        mn2, mode2, n2 = insn_at[a2]
        if mn2 != 'st' + mn[2] or mode2 not in ('zp', 'abs'):
            continue
        dst = IMG[a2 + 1] | (IMG[a2 + 2] << 8 if n2 == 3 else 0)
        for j in range(k + 2, min(k + 8, len(seq) - 1)):
            a3 = seq[j]
            mn3, mode3, n3 = insn_at[a3]
            if mode3 == 'imm' and mn3 in ('lda', 'ldx', 'ldy'):
                a4 = seq[j + 1]
                mn4, mode4, n4 = insn_at[a4]
                if mn4 == 'st' + mn3[2] and mode4 == mode2:
                    d2 = IMG[a4 + 1] | (IMG[a4 + 2] << 8 if n4 == 3 else 0)
                    if d2 == dst + 1:
                        v = IMG[a + 1] | IMG[a3 + 1] << 8
                        name = None
                        if 0xd000 <= dst < 0xe000 or v in A.NO_PAIR or a in A.NO_PAIR:
                            break
                        if (v in labels and not re.match(r'^[LD][0-9a-f]{4}$', labels[v])) or \
                                (v in consts and v not in HW):
                            name = ref(v)
                        elif dst < 0x100 and v >= 0x200 and in_image(v):
                            name = ref(v)
                        if name:
                            if re.search(r'[-+*/]', name):
                                name = '(%s)' % name
                            imm_pairs[a] = '<' + name
                            imm_pairs[a3] = '>' + name
                        break
            if mn3 in ('jsr', 'jmp', 'rts', 'rti') or mode3 == 'rel':
                break


# ----------------------------------------------------------------- output
def fmt_operand(a, mn, mode, n):
    if a in A.OPERAND:
        return A.OPERAND[a]
    if mode in ('imp', 'acc'):
        return ''
    if mode == 'imm':
        if a in imm_pairs:
            return '#' + imm_pairs[a]
        if a in IMMS:
            nm = IMMS[a]
            if nm in const_defs and (const_defs[nm][0] & 255) == IMG[a + 1]:
                used_consts.add(nm)
                return '#' + nm
        return '#' + hexv(IMG[a + 1], 2)
    if mode == 'rel':
        return ref(target(a, mode)) or hexv(target(a, mode), 4)
    v = IMG[a + 1] if n == 2 else IMG[a + 1] | IMG[a + 2] << 8
    data = mn not in ('jmp', 'jsr')
    if n == 2 or v < 0x100:
        s = zpref(a, v)
    else:
        s = ref(v, data)
    if s is None:
        s = hexv(v, 2 if n == 2 else 4)
    suffix = {'zpx': ',x', 'abx': ',x', 'zpy': ',y', 'aby': ',y'}.get(mode, '')
    if mode == 'izx': return '(%s,x)' % s
    if mode == 'izy': return '(%s),y' % s
    if mode == 'ind': return '(%s)' % s
    return s + suffix


def needs_abs(a, mode, n):
    if n != 3 or mode == 'ind':
        return False
    v = IMG[a + 1] | IMG[a + 2] << 8
    return v < 0x100 and IMG[a] not in (0x20, 0x4c)


def data_lines(s, e, per=16):
    out = []
    a = s
    while a < e:
        x = min(e, a + per)
        out.append((a, '.byte ' + ','.join('$%02x' % b for b in IMG[a:x]), ''))
        a = x
    return out


COMMENT_COL = 48


def line(text, r=None, c=''):
    if A.SHOW_ADDR and r is not None:
        c = ('$%04x  ' % r) + (c or '') if c else '$%04x' % r
    if c:
        if len(text) >= COMMENT_COL:
            return '%s  // %s' % (text, c)
        return '%-*s// %s' % (COMMENT_COL, text, c)
    return text


def block_comment(w, txt):
    w('')
    w('// ' + '-' * 76)
    for ln in txt.strip('\n').splitlines():
        w('// ' + ln if ln.strip() else '//')
    w('// ' + '-' * 76)


def emit(path, write_bins):
    o = []
    cur = [o]
    files = {}
    split_start = {a: (e, f, d) for (a, e, f, d) in A.SPLITS}
    split_end = None
    srcdir = os.path.dirname(path)

    def w(x):
        cur[0].append(x)
    w('// ' + '=' * 76)
    for ln in A.HEADER.strip('\n').splitlines():
        w('// ' + ln if ln else '//')
    w('// ' + '=' * 76)
    w('')
    for ln in A.PREAMBLE.strip('\n').splitlines():
        w(ln)
    w('')
    if used_consts:
        w('// ' + '-' * 76)
        w('// Constants')
        w('// ' + '-' * 76)
        for n in sorted(used_consts, key=lambda n: (const_defs[n][0], n)):
            v, c = const_defs[n]
            w(line('.const %-30s = $%02x' % (n, v), None, c))
        w('')
    w('// ' + '-' * 76)
    w('// Zero page')
    w('// ' + '-' * 76)
    zpc = A.ZP_COMMENTS
    for n in sorted(used_aliases, key=lambda n: (zp_alias[n], zp_names.get(zp_alias[n]) != n, n)):
        a = zp_alias[n]
        c = zpc.get(a, '') if zp_names.get(a) == n else ''
        w(line('.label %-30s = $%02x' % (n, a), None, c))
    w('')
    w('// ' + '-' * 76)
    w('// Hardware registers, KERNAL and RAM outside the program image')
    w('// ' + '-' * 76)
    for rs in sorted(A.RAM_TABLES):
        if rs in used_ram_tables and A.RAM_TABLES[rs][1] not in consts.values():
            consts[rs] = A.RAM_TABLES[rs][1]
    for a in sorted(consts):
        if consts[a] in used_names_out or a in A.RAM_LABELS:
            w(line('.label %-30s = $%04x' % (consts[a], a), None, A.RAM_COMMENTS.get(a, '')))
    w('')
    for ln in A.SEGMENT.strip('\n').splitlines():
        w(ln)
    for rg in REGIONS:
        w('')
        w('// ' + '=' * 76)
        w('// %s  ($%04x-$%04x)' % (rg.name, rg.start, rg.end - 1))
        if rg.note:
            for ln in rg.note.strip('\n').splitlines():
                w('// ' + ln if ln.strip() else '//')
        w('// ' + '=' * 76)
        if rg.kind == 'binary':
            fn = 'bin/%s.bin' % rg.name
            if write_bins:
                os.makedirs(os.path.join(srcdir, 'bin'), exist_ok=True)
                open(os.path.join(srcdir, fn), 'wb').write(IMG[rg.start:rg.end])
            w('* = $%04x "%s"' % (rg.start, rg.name))
            w('%s:' % rg.name)
            w('    .import binary "%s"' % fn)
            w('    .assert "%s size", * - %s, $%04x' % (rg.name, rg.name, rg.end - rg.start))
            continue
        if rg.kind == 'fill':
            w('* = $%04x "%s"' % (rg.start, rg.name))
            w('%s:' % rg.name)
            w('    .fill $%04x, $%02x' % (rg.end - rg.start, IMG[rg.start]))
            continue
        w('* = $%04x "%s"' % (rg.start, rg.name))
        r = rg.start
        while r < rg.end:
            if split_end is not None and r >= split_end:
                cur[0] = o
                split_end = None
            if r in split_start:
                e_, f_, d_ = split_start[r]
                o.append('')
                o.append('    #import "%s"' % f_)
                files[f_] = ['// ' + '=' * 76, '// %s - %s' % (f_, d_),
                             '// Included from tilt.asm. Addresses $%04x-$%04x' % (r, e_ - 1),
                             '// ' + '=' * 76]
                cur[0] = files[f_]
                split_end = e_
            if r in BLOCKS:
                block_comment(w, BLOCKS[r])
            if r in labels:
                w('%s:' % labels[r])
            if kind[r] == CODE:
                mn, mode, n = insn_at[r]
                for k in range(1, n):
                    if r + k in labels:
                        w('    .label %s = *+%d' % (labels[r + k], k))
                opnd = fmt_operand(r, mn, mode, n)
                m = mn + ('.a' if needs_abs(r, mode, n) else '')
                text = '    %s %s' % (m, opnd) if opnd else '    %s' % m
                w(line(text, r, COMMENTS.get(r, '')))
                r += n
            else:
                e = r + 1
                while e < rg.end and kind[e] != CODE and e not in labels and e not in BLOCKS \
                        and e not in A.FORMATS and e not in split_start and e not in split_ends:
                    e += 1
                for (dl, text, cm) in format_data(r, e, A.FORMATS.get(r)):
                    if text.startswith('//'):
                        w(text)
                        continue
                    w(line('    ' + text, dl, COMMENTS.get(dl, cm)))
                r = e
        if split_end is not None and rg.end >= split_end:
            cur[0] = o
            split_end = None
    w('')
    for ln in A.POSTAMBLE.strip('\n').splitlines():
        w(ln)
    if path != os.devnull:
        open(path, 'w').write('\n'.join(o) + '\n')
        for f_, lines_ in files.items():
            open(os.path.join(srcdir, f_), 'w').write('\n'.join(lines_) + '\n')
    return o + [x for v in files.values() for x in v]


used_names_out = set()
used_ram_tables = set()
split_ends = {e for (a, e, f, d) in A.SPLITS}


def format_data(s, e, fm):
    if fm is None:
        return data_lines(s, e)
    kindf, *args = fm
    out = []
    if kindf == 'words':          # little-endian address words
        i = s
        while i + 1 < e:
            v = IMG[i] | IMG[i + 1] << 8
            out.append((i, '.word ' + (ref(v) or hexv(v, 4)), ''))
            i += 2
        if i < e:
            out += data_lines(i, e)
        return out
    if kindf == 'words_num':      # plain 16-bit numbers, 8 per line
        i = s
        while i + 1 < e:
            j = min(e - (e - i) % 2, i + 16)
            out.append((i, '.word ' + ','.join('$%04x' % (IMG[k] | IMG[k + 1] << 8) for k in range(i, j, 2)), ''))
            i = j
        if i < e:
            out += data_lines(i, e)
        return out
    if kindf in ('lo', 'hi'):     # split pointer tables: args = (other_table,)
        other = args[0]
        for i in range(s, e):
            o = other + (i - s)
            lo, hi = (IMG[i], IMG[o]) if kindf == 'lo' else (IMG[o], IMG[i])
            v = lo | hi << 8
            r_ = ref(v) or hexv(v, 4)
            out.append((i, '.byte %s(%s)' % ('<' if kindf == 'lo' else '>', r_), ''))
        return out
    if kindf == 'rows':           # fixed width rows
        wdt = args[0]
        i = s
        while i < e:
            j = min(e, i + wdt)
            out.append((i, '.byte ' + ','.join('$%02x' % b for b in IMG[i:j]), ''))
            i = j
        return out
    if kindf == 'text':           # ASCII text, shown as comment
        i = s
        while i < e:
            j = min(e, i + 16)
            txt = ''.join(chr(b) if 32 <= b < 127 else '.' for b in IMG[i:j])
            out.append((i, '.byte ' + ','.join('$%02x' % b for b in IMG[i:j]), '"%s"' % txt))
            i = j
        return out
    if kindf == 'screen':         # screen codes, shown as comment
        i = s
        wdt = args[0] if args else 16
        while i < e:
            j = min(e, i + wdt)
            txt = ''.join(chr(b + 64) if 0 < b < 27 else chr(b) if 32 <= b < 64 else '@' if b == 0 else '.'
                          for b in IMG[i:j])
            out.append((i, '.byte ' + ','.join('$%02x' % b for b in IMG[i:j]), '"%s"' % txt))
            i = j
        return out
    if kindf == 'sprites':        # 64-byte sprites: 21 rows of 3 bytes + 1 pad byte
        i = s
        while i + 64 <= e:
            nr = (i & 0x3fff) // 64
            out.append((i, '// sprite $%02x  ($%04x)' % (nr, i), ''))
            for row in range(21):
                b = IMG[i + row * 3:i + row * 3 + 3]
                pic = ''.join(format(x, '08b') for x in b).replace('0', '.').replace('1', '#')
                out.append((i + row * 3, '.byte ' + ','.join('%%%s' % format(x, '08b') for x in b), pic))
            out.append((i + 63, '.byte $%02x' % IMG[i + 63], ''))
            i += 64
        if i < e:
            out += data_lines(i, e)
        return out
    if kindf == 'mcsprites':      # multicolour sprites: pairs of bits shown as . a b c
        i = s
        while i + 64 <= e:
            nr = (i & 0x3fff) // 64
            out.append((i, '// sprite $%02x  ($%04x)' % (nr, i), ''))
            for row in range(21):
                b = IMG[i + row * 3:i + row * 3 + 3]
                bits = ''.join(format(x, '08b') for x in b)
                pic = ''.join('.123'[int(bits[k:k + 2], 2)] * 2 for k in range(0, 24, 2))
                out.append((i + row * 3, '.byte ' + ','.join('%%%s' % format(x, '08b') for x in b), pic))
            out.append((i + 63, '.byte $%02x' % IMG[i + 63], ''))
            i += 64
        if i < e:
            out += data_lines(i, e)
        return out
    if kindf in ('chars', 'mcchars'):   # 8-byte characters, one row per line
        first = args[0] if args else 0
        i = s
        while i + 8 <= e:
            out.append((i, '// char $%02x  ($%04x)' % ((first + (i - s) // 8) & 0xff, i), ''))
            for k in range(8):
                b = IMG[i + k]
                bits = format(b, '08b')
                pic = bits.replace('0', '.').replace('1', '#') if kindf == 'chars' else \
                    ''.join('.123'[int(bits[x:x + 2], 2)] * 2 for x in range(0, 8, 2))
                out.append((i + k, '.byte %%%s' % bits, pic))
            i += 8
        if i < e:
            out += data_lines(i, e)
        return out
    if kindf == 'bin':            # one byte per line as binary
        for i in range(s, e):
            b = IMG[i]
            out.append((i, '.byte %%%s' % format(b, '08b'), format(b, '08b').replace('0', '.').replace('1', '#')))
        return out
    raise ValueError(fm)


if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'src/tilt.asm')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    find_imm_pairs()
    txt = '\n'.join(emit(os.devnull, False))      # pass 1: collect auto labels + used names
    used_names_out.update(re.findall(r'[A-Za-z_][A-Za-z0-9_]*', txt.split(A.SEGMENT.strip().splitlines()[0])[1]))
    emit(out, True)
    ncode = sum(1 for a in range(LOAD0, LOAD_END) if kind[a] in (CODE, OPER))
    print('code bytes %d, other bytes %d, labels %d, problems %d' % (ncode, LOAD_END - LOAD0 - ncode, len(labels), len(problems)))
    os.makedirs(os.path.join(ROOT, 'build'), exist_ok=True)
    with open(os.path.join(ROOT, 'build/problems.txt'), 'w') as f:
        f.write('\n'.join(problems))
    for p in problems[:40]:
        print('  ', p)
