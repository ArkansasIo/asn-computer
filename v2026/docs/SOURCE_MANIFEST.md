# 2026 Source Manifest

## Build

- `Makefile`
- `CMakeLists.txt`
- `build.sh`
- `build.ps1`

## Assembly

- `asm/boot64.asm` — 64-bit entry skeleton
- `asm/cpu.asm` — CPUID/CPU feature hook
- `asm/memory.asm` — memory barrier/zero primitives
- `asm/io.asm` — wait/pause primitives
- `asm/display.asm` — 4K mode/framebuffer sizing
- `asm/frontpanel.asm` — panel masks
- `asm/compat8080.asm` — legacy instruction hook

## Runtime

- `src/main.c`
- `src/platform.c`
- `include/platform.h`
- `include/hw.inc`

## Emulator/UI

- `python/altair2026.py`
- `web/index.html`
- `web/style.css`
- `web/app.js`

## Hardware

- `config/board.yaml`
- `config/memory-map.md`
- `config/bom.csv`
- `rtl/s100_bridge.sv`
- `rtl/frontpanel.sv`

## Documentation

- `docs/ARCHITECTURE.md`
- `docs/HARDWARE.md`
- `docs/FIRMWARE.md`
- `docs/4K_DISPLAY.md`
- `docs/TEST_PLAN.md`

## CI

- `.github/workflows/ci.yml`
