#!/bin/sh
# Assemble the game image (src/tilt.asm) and the cartridge (src/cart.asm) with
# KickAssembler into build/ and compare the results with the originals.
#   KICKASS=/path/to/KickAss.jar ./build.sh      (default /opt/KickAss.jar)
#   ./build.sh run                                 also start the cartridge in VICE
set -e
cd "$(dirname "$0")"
KICKASS=${KICKASS:-/opt/KickAss.jar}
mkdir -p build
[ -f build/orig_ram.prg ] || python3 tools/crt.py build/orig_ram.prg > /dev/null
java -jar "$KICKASS" src/tilt.asm -odir ../build -vicesymbols -symbolfile > build/kickass.log 2>&1 || {
    cat build/kickass.log; exit 1; }
if cmp -s build/tilt.prg build/orig_ram.prg; then
    echo "OK: build/tilt.prg is identical to the original game image"
else
    echo "NOTE: build/tilt.prg differs from the original game image (expected if you changed the source)"
fi
if [ -f src/cart.asm ]; then
    java -jar "$KICKASS" src/cart.asm -odir ../build -vicesymbols > build/kickass_cart.log 2>&1 || {
        cat build/kickass_cart.log; exit 1; }
    if cmp -s build/tilt.crt bin/Tilt.crt; then
        echo "OK: build/tilt.crt is identical to bin/Tilt.crt"
    else
        echo "NOTE: build/tilt.crt differs from bin/Tilt.crt"
    fi
fi
if [ "$1" = "run" ]; then
    flatpak run --command=x64sc net.sf.VICE +saveres -moncommands build/tilt.vs -cartcrt build/tilt.crt \
        > build/vice.log 2>&1 &
    echo "Started x64sc (log: build/vice.log)"
fi
