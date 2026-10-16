#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN="${PYTHON_BIN:-python3}"

printf '%s\n' 'ASN Computer - portable validation build'
"$PYTHON_BIN" --version
"$PYTHON_BIN" -m compileall -q emulator_simulator.py tools tests
"$PYTHON_BIN" tools/altair8080.py --self-test
"$PYTHON_BIN" -m unittest discover -s tests -p 'test_*.py'

printf '%s\n' 'Portable build completed successfully.'
printf '%s\n' 'Native MASM build is Windows-only; use build.bat or build.ps1 on a Visual Studio Developer environment.'
