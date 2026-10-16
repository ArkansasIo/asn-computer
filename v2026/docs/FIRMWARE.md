# Firmware Boundary

The 2026 source tree intentionally separates open reference code from vendor-specific
firmware.

## Boot stages

1. Reset/vector entry
2. CPU mode establishment
3. memory discovery/training
4. security initialization
5. PCIe discovery
6. NVMe discovery
7. USB discovery
8. display/framebuffer discovery
9. S-100 bridge initialization
10. boot-device selection
11. operating-system handoff

A real board should use the processor vendor's approved firmware/BIOS reference design and
board package. This project does not fabricate proprietary DDR training or undocumented BGA
register sequences.
