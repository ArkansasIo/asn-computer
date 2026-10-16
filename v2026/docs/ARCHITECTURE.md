# ALTAIR 8800 2026 Architecture

## Compute

The system is a 64-bit x86 architecture. The reference hardware profile assumes a modern
embedded x86 SoC with CPU, integrated GPU and AI accelerator resources.

## Memory

DDR5-class dual-channel memory is the baseline. ECC is preferred where the selected silicon
and module topology support it.

## Graphics

The system supports a 3840×2160 framebuffer and modern external display links. The integrated
GPU is the baseline graphics device; a discrete PCIe GPU can be added as an expansion option.

## Storage

NVMe over PCIe Gen4 x4 is the baseline mass-storage interface.

## Legacy compatibility

The front panel retains 16 address switches/indicators and 8 data indicators. The software
also retains an Intel 8080-compatible reference CPU model. An FPGA/CPLD bridge can expose an
S-100-compatible expansion bus.

## Software layers

1. Boot/firmware boundary
2. 64-bit runtime
3. Device abstraction
4. Legacy 8080 emulator
5. Front-panel state machine
6. Display/UI
7. Application/runtime tooling
