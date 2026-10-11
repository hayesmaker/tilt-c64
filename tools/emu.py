"""Crude C64 emulation for code-coverage gathering (adapted from thrust-c64).
Boots the Magic Desk cartridge (bin/Tilt.crt): 8K ROML at $8000, bank select
and disable via writes to $DE00. Banks ROMs per $01, emulates VIC raster IRQ, CIA1 timer A IRQ, joystick in
port 2. Records every executed PC and every data read address."""
import sys, random, pickle
sys.path.insert(0, 'tools')
from cpu6502 import CPU, OPS, MODES

import os, struct
ROM = os.environ.get('VICE_ROMS', '/var/lib/flatpak/app/net.sf.VICE/current/active/files/share/vice/C64/')
BASIC = open(ROM + 'basic-901226-01.bin', 'rb').read()
KERNAL = open(ROM + 'kernal-901227-03.bin', 'rb').read()
CHAR = open(ROM + 'chargen-901225-01.bin', 'rb').read()

READS = {'lda', 'ldx', 'ldy', 'adc', 'sbc', 'and', 'ora', 'eor', 'cmp', 'cpx', 'cpy', 'bit',
         'asl', 'lsr', 'rol', 'ror', 'inc', 'dec'}
WRITES = {'sta', 'stx', 'sty', 'asl', 'lsr', 'rol', 'ror', 'inc', 'dec'}

# base cycle counts per addressing mode (approximate is fine)
CYC = {'imp': 2, 'acc': 2, 'imm': 2, 'zp': 3, 'zpx': 4, 'zpy': 4, 'izx': 6,
       'izy': 5, 'rel': 3, 'abs': 4, 'abx': 4, 'aby': 4, 'ind': 5}


class C64(CPU):
    def __init__(self):
        super().__init__()
        self.io = bytearray(0x1000)
        self.raster = 0
        self.rcyc = 0
        self.vic_irq = 0
        self.cia1_ta = 0xffff
        self.cia1_latch = 0xffff
        self.cia1_icr_mask = 0
        self.cia1_icr = 0
        self.cia1_run = 0
        self.joy = 0xff
        self.keys = set()          # (col,row) pressed
        self.exec_pcs = {}         # pc -> bytes executed
        self.rd_log = {}
        self.wr_log = {}
        self.ptr_log = {}
        self.ind_jumps = {}
        self.frame = 0
        self.lineregs = [bytes(0x13)] * 200
        self.cart = None           # list of 8K banks (Magic Desk), None = no cartridge
        self.cart_bank = 0
        self.cart_on = False
        self.rmw = False
        self.trace_hook = None     # called with pc before each instruction

    def banks(self):
        p = self.m[1] & 7
        basic = (p & 3) == 3
        kernal = (p & 2) != 0
        io = (p & 3) != 0 and p != 0 and p >= 4 or p in (5, 6, 7)
        io = p in (5, 6, 7)
        chr_ = p in (1, 2, 3)
        return basic, kernal, io, chr_

    def roml(self):
        return self.cart_on and (self.m[1] & 3) == 3

    def is_ram(self, a):
        basic, kernal, io, chr_ = self.banks()
        if 0x8000 <= a < 0xa000: return not self.roml()
        if a < 0xa000 or 0xc000 <= a < 0xd000: return True
        if a < 0xc000: return not basic
        if a < 0xe000: return not (io or chr_)
        return not kernal

    def rd(self, a):
        a &= 0xffff
        if 0x8000 <= a < 0xa000 and self.roml():
            return self.cart[self.cart_bank][a - 0x8000]
        if a >= 0xa000:
            basic, kernal, io, chr_ = self.banks()
            if a < 0xc000:
                if basic: return BASIC[a - 0xa000]
            elif 0xd000 <= a < 0xe000:
                if io: return self.io_rd(a)
                if chr_: return CHAR[a - 0xd000]
            elif a >= 0xe000:
                if kernal: return KERNAL[a - 0xe000]
        return self.m[a]

    def wr(self, a, v):
        a &= 0xffff
        v &= 0xff
        if 0xd000 <= a < 0xe000 and self.banks()[2]:
            self.io_wr(a, v)
            return
        self.m[a] = v

    def io_rd(self, a):
        r = a & 0xfff
        if r < 0x400:
            r &= 0x3f
            if r == 0x11: return (self.io[0x11] & 0x7f) | ((self.raster >> 1) & 0x80)
            if r == 0x12: return self.raster & 0xff
            if r == 0x19: return self.vic_irq | (0x80 if self.vic_irq else 0) | 0x70
            if r in (0x1e, 0x1f):
                v = self.io[r]; self.io[r] = 0; return v
            return self.io[r]
        if r < 0x800:  # SID
            r &= 0x1f
            if r == 0x1b: return random.randint(0, 255)
            if r == 0x1c: return 0
            return 0
        if r < 0xc00:  # colour RAM: 4 bits
            return self.io[r] & 0x0f
        if 0xc00 <= r < 0xd00:  # CIA1
            r &= 0xf
            if r == 0: return self.joy
            if r == 1:
                cols = self.io[0xc00]
                v = 0xff
                for (c, rw) in self.keys:
                    if not (cols >> c) & 1: v &= ~(1 << rw)
                return v & 0xff
            if r == 4: return self.cia1_ta & 0xff
            if r == 5: return self.cia1_ta >> 8
            if r == 0xd:
                v = self.cia1_icr | (0x80 if self.cia1_icr & self.cia1_icr_mask else 0)
                self.cia1_icr = 0
                return v
            return self.io[0xc00 + r]
        if 0xd00 <= r < 0xe00:
            r &= 0xf
            if r == 0: return self.io[0xd00] | 0xc0     # serial CLK/DATA in idle high
            return self.io[0xd00 + r]
        return 0

    def io_wr(self, a, v):
        r = a & 0xfff
        if r < 0x400:
            r &= 0x3f
            if r == 0x19:
                # RMW instructions (ASL/INC $D019...) first write back the value
                # they read; that dummy write acknowledges every pending flag
                if self.rmw: v |= self.vic_irq
                self.vic_irq &= ~v & 0xf; return
            self.io[r] = v
            return
        if 0xc00 <= r < 0xd00:
            r &= 0xf
            if r == 4: self.cia1_latch = (self.cia1_latch & 0xff00) | v
            elif r == 5:
                self.cia1_latch = (self.cia1_latch & 0xff) | (v << 8)
                if not self.cia1_run: self.cia1_ta = self.cia1_latch
            elif r == 0xd:
                if v & 0x80: self.cia1_icr_mask |= v & 0x1f
                else: self.cia1_icr_mask &= ~v & 0x1f
            elif r == 0xe:
                self.cia1_run = v & 1
                if v & 0x10: self.cia1_ta = self.cia1_latch
            self.io[0xc00 + r] = v
            return
        if 0xe00 <= r < 0xf00 and self.cart is not None:   # Magic Desk bank register
            self.cart_bank = v & 0x7f
            self.cart_on = not (v & 0x80) and self.cart_bank < len(self.cart)
            return
        self.io[r] = v

    def irq(self):
        r = (self.pc) & 0xffff
        self.push(r >> 8); self.push(r)
        self.push(self.p() & ~0x10)
        self.i = 1
        self.pc = self.rd(0xfffe) | (self.rd(0xffff) << 8)

    def nmi_vec(self):
        pass

    def run_cycles(self, n):
        end = self.cycles + n
        while self.cycles < end:
            pc = self.pc
            if self.trace_hook: self.trace_hook(self, pc)
            op = self.rd(pc)
            mn, mode = OPS[op]
            if self.is_ram(pc):
                if pc not in self.exec_pcs:
                    self.exec_pcs[pc] = bytes(self.m[pc:pc + MODES[mode]])
                if mode not in ('imp', 'acc', 'imm', 'rel'):
                    ea = self.addr(mode)
                    if mn in ('jmp', 'jsr'):
                        if mode == 'ind':
                            self.ind_jumps.setdefault(pc, set()).add(ea)
                    else:
                        if mn in READS:
                            self.rd_log.setdefault(ea, set()).add(pc)
                        if mn in WRITES:
                            self.wr_log.setdefault(ea, set()).add(pc)
                        if mode in ('izx', 'izy'):
                            z = self.m[pc + 1] + (self.x if mode == 'izx' else 0) & 0xff
                            self.ptr_log.setdefault(pc, set()).add(ea - (self.y if mode == 'izy' else 0) & 0xffff)
                            self.rd_log.setdefault(z, set()).add(pc)
                            self.rd_log.setdefault(z + 1 & 0xff, set()).add(pc)
            c0 = self.cycles
            self.rmw = mn in ('asl', 'lsr', 'rol', 'ror', 'inc', 'dec') and mode != 'acc'
            self.step()
            dc = CYC[mode]
            self.cycles = c0 + dc
            # VIC raster
            self.rcyc += dc
            if self.rcyc >= 63:
                self.rcyc -= 63
                self.raster += 1
                if 51 <= self.raster < 251:
                    self.lineregs[self.raster - 51] = bytes(self.io[0x11:0x24])
                if self.raster >= 312:
                    self.raster = 0
                    self.frame += 1
                cmp_ = self.io[0x12] | ((self.io[0x11] & 0x80) << 1)
                if self.raster == cmp_:
                    self.vic_irq |= 1
            # CIA1 timer A
            if self.cia1_run:
                self.cia1_ta -= dc
                if self.cia1_ta <= 0:
                    self.cia1_ta += self.cia1_latch + 1
                    self.cia1_icr |= 1
            if not self.i:
                if (self.vic_irq & self.io[0x1a] & 0xf) or (self.cia1_icr & self.cia1_icr_mask):
                    self.irq()

    def step(self):
        # use our banked rd/wr via CPU core (CPU.step uses self.rd/self.wr)
        super().step()


def load_crt(path):
    """Return the list of 8K CHIP banks of a .crt file."""
    d = open(path, 'rb').read()
    p = struct.unpack('>I', d[0x10:0x14])[0]
    banks = []
    while p < len(d):
        ln = struct.unpack('>I', d[p + 4:p + 8])[0]
        bank, sz = struct.unpack('>HH', d[p + 10:p + 12] + d[p + 14:p + 16])
        assert bank == len(banks)
        banks.append(d[p + 16:p + 16 + sz])
        p += ln
    return banks


def boot(crt='bin/Tilt.crt'):
    """Power-on with the cartridge inserted: KERNAL reset finds CBM80 at $8004."""
    c = C64()
    c.cart = load_crt(crt)
    c.cart_on = True
    c.m[0] = 0x2f; c.m[1] = 0x37
    c.pc = c.rd(0xfffc) | c.rd(0xfffd) << 8
    c.sp = 0xff
    return c


if __name__ == '__main__':
    c = boot(sys.argv[1] if len(sys.argv) > 1 else 'bin/Tilt.crt')
    frames = int(sys.argv[2]) if len(sys.argv) > 2 else 200
    import time
    t = time.time()
    while c.frame < frames:
        c.run_cycles(19656)
    print('frames %d, %d unique pcs, pc %04x, %.1fs' % (c.frame, len(c.exec_pcs), c.pc, time.time() - t))
