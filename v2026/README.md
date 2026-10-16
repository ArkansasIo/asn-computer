# ALTAIR 8800 — 2026 64-bit Edition

A clean 2026 architecture layer for the existing Altair 8800 project.

## Goals

- x86-64 / long-mode software architecture
- modern memory/storage/I/O model
- 4K 3840×2160 display target
- Altair front-panel compatibility
- Intel 8080-compatible legacy CPU model
- S-100-compatible expansion abstraction
- hardware/firmware documentation
- hosted Linux/Windows development path
- browser front-panel UI

## Platform model

The reference hardware profile uses a contemporary 64-bit SoC class with DDR5, PCIe Gen4,
NVMe, USB4/USB, 10GbE, TPM/security, and HDMI/DP/eDP display paths. Exact production
BGA pinouts, DDR training, VRM sequencing, and vendor firmware are intentionally not
invented here; they must come from the selected silicon vendor's design package.

## Source tree

- `asm/` — x86-64 assembly modules
- `include/` — ABI and hardware definitions
- `src/` — hosted emulator/runtime support
- `python/` — reference emulator and tooling
- `web/` — 4K-capable browser front panel
- `rtl/` — S-100/front-panel FPGA reference RTL
- `config/` — board, memory, PCIe, display and BOM configuration
- `docs/` — engineering documentation
- `tests/` — software tests
- `.github/workflows/` — CI

## Build

Linux:

```bash
cd v2026
./build.sh
./build/altair2026
```

Windows PowerShell:

```powershell
cd v2026
./build.ps1
```

Python reference emulator:

```bash
python3 python/altair2026.py --self-test
```

Browser UI: open `web/index.html` in a browser or serve `v2026/web` with a static server.
