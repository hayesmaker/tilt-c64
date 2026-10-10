"""Annotations for the Tilt (C64) disassembly: memory regions, labels, comments
and data formats. Tilt runs where it loads, so every address is both the load
and the run-time address. Per-area annotations live in tools/ann_*.py and are
merged in file name order (later files override earlier ones)."""

SHOW_ADDR = True      # append the address to every code/data line

HEADER = """
TILT (Commodore 64) - Codemasters, 1990
Program by Steve Walters.
Commented disassembly for KickAssembler 5.x

This file assembles the game's RAM image, $0334-$FFFF, exactly as the
STATMAT 2023 cartridge conversion (bin/Tilt.crt) copies it into memory
before it jumps to $0460. src/cart.asm then packs the image, the cartridge
loader and the loading picture into a byte-identical Tilt.crt.

Build:   ./build.sh       (assembles src/tilt.asm, then src/cart.asm)
"""

PREAMBLE = """
"""

SEGMENT = """
// ---------------------------------------------------------------- program image
"""

POSTAMBLE = """
"""

# (name, start, end_exclusive, kind, note)    kind: code | data | binary | fill
REGIONS = [
    ('tape_buffer', 0x0334, 0x0400, 'data', 'Cassette buffer area: leftovers, partly used as a work buffer'),
    ('screen', 0x0400, 0x0800, 'code', """Screen RAM ($0400-$07E7) and sprite pointers ($07F8-$07FF).
At start-up it still holds the original disk loader (typed into screen
memory), which loaded "PIC" and "TILT". The cartridge enters at $0460,
the loader's last two instructions."""),
    ('basic', 0x0800, 0x080d, 'data', 'BASIC line: 0 SYS2061'),
    ('main', 0x080d, 0x8f00, 'code', 'The TILT program'),
    ('junk_8f00', 0x8f00, 0xa000, 'binary', 'Not used: leftover RAM contents (a 256 byte KERNAL fragment, repeated)'),
    ('charset_backup', 0xa000, 0xb000, 'binary', """Overwritten at start-up with a copy of the two character sets
($2000-$27FF -> $A000, $7800-$7FFF -> $A800). The bytes here are leftovers."""),
    ('junk_b000', 0xb000, 0xce00, 'binary', 'Not used: leftover RAM contents'),
    ('variables', 0xce00, 0xd000, 'binary', """Game variables ($CE00-$CFFF, see the labels at the top of the file).
The game sets them before use; the bytes here are leftovers."""),
    ('ram_d000', 0xd000, 0xe000, 'binary', 'RAM under the I/O area: not used, leftovers'),
    ('ram_e000', 0xe000, 0x10000, 'binary', 'RAM under the KERNAL ROM: not used, leftovers (an unrelated picture)'),
]

# parts of the source written to separate include files: (start, end, file, description)
SPLITS = []

ENTRY_POINTS = [0x0425, 0x0460, 0x080d]
NO_RETURN = set()
NO_TRACE = set()          # self-modified JMP/JSR whose assembled target is meaningless
NO_PAIR = set()           # immediate lo/hi pairs that are NOT addresses
DATA_RANGES = []          # ranges that must never be treated as code: (start, end)

LABELS = {
    0x0460: 'cart_entry',
    0x080d: 'start',
}
COMMENTS = {}
BLOCK_COMMENTS = {}
FORMATS = {}
OPERAND = {}
TABLES = {}               # start: (end_exclusive, name)
ZP_RANGE_NAMES = []       # zero page temporaries named per code range: (start, end, {zp: name})
RAM_TABLES = {}           # RAM areas outside the image: start: (end_exclusive, name)
RAM_LABELS = {}           # names emitted as constants although inside the image
ZP = {}
ZP_WORDS = set()          # zp names that are 16-bit (zp+1 is written name+1)
RAM_COMMENTS = {}
ZP_COMMENTS = {}
OPERAND_NAMES = {}
IMMEDIATES = {}
CONSTS = {}

# ---------------------------------------------------------------------------
# merge per-area annotation modules
import importlib, glob, os as _os
for _f in sorted(glob.glob(_os.path.join(_os.path.dirname(__file__), 'ann_*.py'))):
    _m = importlib.import_module(_os.path.basename(_f)[:-3])
    for _k in ('LABELS', 'COMMENTS', 'BLOCK_COMMENTS', 'FORMATS', 'OPERAND', 'TABLES', 'RAM_LABELS',
               'RAM_TABLES', 'RAM_COMMENTS', 'ZP', 'ZP_COMMENTS', 'OPERAND_NAMES', 'IMMEDIATES', 'CONSTS'):
        if hasattr(_m, _k):
            globals()[_k].update(getattr(_m, _k))
    ENTRY_POINTS += getattr(_m, 'ENTRY_POINTS', [])
    DATA_RANGES += getattr(_m, 'DATA_RANGES', [])
    ZP_RANGE_NAMES += getattr(_m, 'ZP_RANGE_NAMES', [])
    ZP_WORDS |= getattr(_m, 'ZP_WORDS', set())
    NO_TRACE |= getattr(_m, 'NO_TRACE', set())
    NO_PAIR |= getattr(_m, 'NO_PAIR', set())
