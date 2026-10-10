"""Read bin/Tilt.crt (Magic Desk, hardware type 19) and rebuild the game RAM image.

The STATMAT loader in bank 0 copies (see src/cart.asm):
    bank 0 $8334-$83FF -> $0334-$03FF
    bank 0 $8400-$9FFF -> $0400-$1FFF
    bank n $8000-$9FFF -> n * $2000      (n = 1..7, up to $FFFF)
"""
import os, struct
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CRT = os.path.join(ROOT, 'bin/Tilt.crt')
IMG_START = 0x0334          # first byte of the game image


def banks(path=CRT):
    d = open(path, 'rb').read()
    p = struct.unpack('>I', d[0x10:0x14])[0]
    out = []
    while p < len(d):
        ln = struct.unpack('>I', d[p + 4:p + 8])[0]
        bank, sz = struct.unpack('>H', d[p + 10:p + 12])[0], struct.unpack('>H', d[p + 14:p + 16])[0]
        assert bank == len(out)
        out.append(d[p + 16:p + 16 + sz])
        p += ln
    return out


def ram_image(path=CRT):
    """64K bytearray with the game image at $0334-$FFFF (rest zero)."""
    b = banks(path)
    m = bytearray(65536)
    m[0x0334:0x2000] = b[0][0x0334:0x2000]
    for n in range(1, 8):
        m[n * 0x2000:(n + 1) * 0x2000] = b[n]
    return m


def write_picture(srcdir=os.path.join(ROOT, 'src/bin')):
    """Loading picture used by src/cart.asm: hires bitmap (bank 8) and screen RAM
    (bank 9) - the original Tilt 'PIC' file, shown by the STATMAT viewer."""
    b = banks()
    os.makedirs(srcdir, exist_ok=True)
    open(os.path.join(srcdir, 'pic_bitmap.bin'), 'wb').write(b[8][:8000])
    open(os.path.join(srcdir, 'pic_screen.bin'), 'wb').write(b[9][:1000])


if __name__ == '__main__':
    import sys
    if sys.argv[1:] == ['--picture']:
        write_picture()
        raise SystemExit
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'build/tilt_ram.bin')
    m = ram_image()
    open(out, 'wb').write(bytes([IMG_START & 255, IMG_START >> 8]) + m[IMG_START:])
    print('wrote', out)
