# Hosted Build and Test Guide

This build validates the portable C reference layer on a normal development machine. It is
not a BIOS image, bootable disk, or validation of physical hardware.

## Requirements
- C11 compiler: Clang, GCC, or MSVC
- Make for the Makefile workflow, or CMake 3.20+
- Python 3.10+ for Python reference-model tests

## Linux / macOS with Make
```sh
cd v2026
make clean
make test
```

## CMake
```sh
cmake -S v2026 -B v2026/cmake-build
cmake --build v2026/cmake-build
ctest --test-dir v2026/cmake-build --output-on-failure
```

## Expected 4K framebuffer sizing
A 3840 x 2160, 32-bit single-buffer framebuffer requires 3840 x 2160 x 4 =
33,177,600 bytes (about 31.64 MiB). Actual graphics scanout requires compatible hardware and
drivers and is outside the hosted state simulator.
