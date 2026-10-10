#!/bin/sh
# Regenerate src/tilt.asm from the annotations and verify the build.
set -e
cd "$(dirname "$0")/.."
[ -f build/orig_ram.prg ] || { mkdir -p build; python3 tools/crt.py build/orig_ram.prg > /dev/null; }
python3 tools/disasm.py
./build.sh | tee /dev/stderr | grep -q '^OK: build/tilt.crt'
