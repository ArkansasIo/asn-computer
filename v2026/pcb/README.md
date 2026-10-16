# 2026 PCB Source Package

The PCB layer is an engineering specification package rather than a fabricated Gerber set.

Boards:

- `ALT-MB-2026` — main CPU/memory/I/O board
- `ALT-FP-2026` — front-panel switch/LED board
- `ALT-BP-2026` — S-100-compatible backplane
- `ALT-PWR-2026` — power/VRM board
- `ALT-DISP-4K` — 4K display interface

Before generating production KiCad files, freeze the exact silicon OPNs and connector/panel
part numbers. High-speed routing must use the actual vendor reference design and fabricated
stackup.
