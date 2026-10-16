#!/usr/bin/env bash
set -euo pipefail

command -v nasm >/dev/null || { echo 'NASM is required'; exit 1; }
command -v cc >/dev/null || { echo 'C compiler is required'; exit 1; }

make clean
make
./build/altair2026
