#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v make >/dev/null || { echo "make is required" >&2; exit 1; }
command -v cc >/dev/null || { echo "A C compiler (cc) is required" >&2; exit 1; }
make clean
make test
