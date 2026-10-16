# ALTAIR 8800 — 2026 Reference Platform

A modernized software and hardware-design study combining an Altair-inspired front panel and legacy compatibility model with a proposed 64-bit x86-64 computer architecture.

> **Current status:** the portable C target is a hosted reference simulator. This repository does not yet contain a complete x86-64 operating system, production BIOS/UEFI firmware, validated motherboard schematic, or bootable installer.

## Goals
- x86-64 software/platform architecture planning
- portable C reference runtime and Python legacy model
- 3840 × 2160 display target and framebuffer sizing
- Altair-inspired front panel with 16 address controls and 8 data indicators
- Intel 8080 compatibility experimentation
- S-100-compatible expansion through a future isolated bridge
- documented hardware, firmware, PCB and testing process

## Build and test
Requirements: C11 compiler and Make. Python 3.10+ for reference-model tests.

```sh
cd v2026
make clean
make
./build/altair2026
cc -std=c11 -Wall -Wextra -Wpedantic -Werror -Iinclude tests/test_platform.c src/platform.c -o build/test_platform
./build/test_platform
python3 -m unittest discover -s tests -p 'test_*.py'
```

CMake is also supported:

```sh
cmake -S . -B cmake-build
cmake --build cmake-build
ctest --test-dir cmake-build --output-on-failure
```

See [Hosted Build Guide](docs/HOSTED_BUILD.md), [Architecture](docs/ARCHITECTURE.md), [Hardware](docs/HARDWARE.md), and [Firmware](docs/FIRMWARE.md).

## Hardware caution
The board YAML and BOM are planning artifacts, not manufacturing outputs. Before fabrication, freeze the exact processor/SoC part number, package footprint, power rails, memory topology, high-speed routing, connector pinouts, thermal design, and vendor firmware. Complete ERC/DRC, signal-integrity and power-integrity review before ordering PCBs.
