#!/bin/sh
# Build tilt-mod: the hand-edited game source in src/ plus a maze set into
# build/tilt-mod.crt. src/ is NOT touched by the main tools/regen.sh.
#   ./build.sh [mazes.json]          default: mazes/original.json
#   ./build.sh [mazes.json] run      also start the cartridge in VICE
set -e
cd "$(dirname "$0")"
KICKASS=${KICKASS:-/opt/KickAss.jar}
MAZES=mazes/original.json
case "$1" in *.json) MAZES=$1; shift;; esac
mkdir -p build
[ -f mazes/original.json ] || python3 tools/mazes.py export > /dev/null
python3 tools/mazes.py build "$MAZES" build
java -jar "$KICKASS" src/tilt.asm -odir ../build -vicesymbols -symbolfile > build/kickass.log 2>&1 || {
    cat build/kickass.log; exit 1; }
java -jar "$KICKASS" src/cart.asm -odir ../build > build/kickass_cart.log 2>&1 || {
    cat build/kickass_cart.log; exit 1; }
echo "OK: built build/tilt-mod.crt from $MAZES"
if [ "$1" = "run" ]; then
    flatpak run --command=x64sc net.sf.VICE +saveres -moncommands build/tilt.vs -cartcrt build/tilt-mod.crt \
        > build/vice.log 2>&1 &
    echo "Started x64sc (log: build/vice.log)"
fi
