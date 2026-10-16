# 2026 Memory Map

This is a logical reference map, not a claim about a specific SoC's physical MMIO map.

| Region | Purpose |
|---|---|
| 0x0000_0000–0x7FFF_FFFF | DRAM / firmware-reserved low memory |
| 0x8000_0000–0x8FFF_FFFF | platform MMIO window |
| 0x9000_0000–0x9FFF_FFFF | PCIe ECAM/MMIO reference window |
| 0xA000_0000–0xAFFF_FFFF | framebuffer reference window |
| 0xB000_0000–0xBFFF_FFFF | S-100 bridge reference window |
| high canonical addresses | OS virtual memory |

A production board must use the memory map assigned by firmware/ACPI/PCI enumeration.
