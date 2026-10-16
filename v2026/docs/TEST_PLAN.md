# Test Plan

## Hosted C layer
- Reset initializes a deterministic state.
- Tick advances counters and exposes front-panel state.
- Null state pointers are tolerated by public functions.
- The 4K framebuffer byte count is 33,177,600.
- Self-test validates the documented platform constants.

## Python reference model
- Self-test verifies NOP/HALT progression and 4K target.
- Front-panel address output remains within 16 bits.
- HALT stops CPU instruction advancement.

## Continuous integration
GitHub Actions should build and run C unit tests, run the Python reference suite, and verify
the CMake build completes.

## Hardware validation (not yet implemented)
- SoC power sequencing and reset timing
- DDR initialization/training
- PCIe/NVMe enumeration
- USB/network links
- display link training and 4K scanout
- thermal and power-integrity tests
- S-100 bridge timing and voltage-level compliance
