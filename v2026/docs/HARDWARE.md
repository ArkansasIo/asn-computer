# 2026 Hardware Design

## Main board

- 8-layer controlled-impedance target
- modern x86-64 BGA SoC
- DDR5 memory
- NVMe M.2 PCIe Gen4 x4
- PCIe expansion
- USB4/USB
- 10GbE-class networking
- HDMI/DP/eDP display outputs
- TPM/security
- RTC and service UART

## 4K display

Target: 3840×2160 at 60 Hz or better.
Internal panel: eDP-class connection.
External outputs: HDMI 2.1 and DisplayPort 2.0 class.

## Power

Use a protected 12 V input and platform-specific multi-rail conversion. CPU/GPU/NPU power
must be designed from the exact silicon OPN's electrical specifications; do not infer VRM
phase count or rail voltage from this reference architecture.

## PCB release

Before fabrication, freeze:

- exact CPU OPN and package
- BGA footprint and escape rules
- DDR5 device/module selection
- VRM controller and power stages
- PCIe lane assignment
- USB4 routing
- display transmitter routing
- Ethernet PHY/magnetics
- connectors and mechanical stack
- thermal solution

Then perform ERC/DRC, signal-integrity analysis, power-integrity analysis and thermal review.
