# 2026 Test Plan

## Software

- CPUID/CPU startup
- 64-bit arithmetic
- memory model
- 8080 compatibility
- front-panel state
- 4K display mode
- reset/run/step/halt behavior

## Hardware bring-up

1. Inspect PCB
2. Validate power rails with SoC absent where possible
3. Verify clock/reset
4. Verify SPI boot flash
5. Bring up CPU firmware
6. Train and test DDR5
7. Enumerate PCIe
8. Detect NVMe
9. Test USB
10. Test 10GbE
11. Test eDP/HDMI/DP at 4K
12. Test S-100 bridge
13. Test front panel
14. Thermal soak
15. Long-duration memory/storage test

## Release gates

- ERC clean
- DRC clean
- SI/PI review complete
- thermal review complete
- firmware recovery path tested
- documented known issues
