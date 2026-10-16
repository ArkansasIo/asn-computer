# ALTAIR 8800 2026 Architecture

## Scope and status
This directory combines a portable hosted reference model with conceptual hardware planning.
The hosted C program is a state simulator, not a 64-bit operating system or emulator of modern
x86 instructions. The Python module contains a small, incomplete Intel 8080 reference model.
Neither by itself boots on physical hardware.

## Compute and address model
- Software architecture target: x86-64.
- Hosted reference state uses 64-bit program-counter and cycle counters.
- Production hardware must select an exact processor/SoC and follow its vendor's board guide,
  package pinout, firmware package, and electrical limits.

## Memory and graphics
The concept proposes DDR5-class memory and 4 KiB pages. ECC support depends on the chosen SoC
and memory topology. The display target is 3840 x 2160 at 32 bits per pixel; a single buffer
requires 33,177,600 bytes. Scanout, refresh rates and link training depend on the GPU/controller.

## Storage and expansion
The concept targets NVMe PCIe x4, modern PCIe expansion, USB, networking, security hardware,
and an FPGA/CPLD-based front-panel or S-100-compatible bridge. Electrical compatibility with
the historic S-100 bus is not implied without a correctly designed bridge.

## Software layers
1. Vendor-specific reset and platform firmware
2. Bootloader and memory discovery
3. 64-bit kernel/runtime
4. Hardware abstraction and driver model
5. Legacy 8080 emulator
6. Front-panel state machine and display UI
7. Application and development tools

Layers 1–4 remain separate implementation tasks. The current hosted build validates only a
subset of the reference state logic.
