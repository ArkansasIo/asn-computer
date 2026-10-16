# ASN Computer — Full Build Guide

## Build matrix

| Layer | Platform | Entry point | Dependencies |
|---|---|---|---|
| Portable CPU core | Windows/macOS/Linux | `build.ps1` / `build.sh` | Python 3.10+ |
| Python OS simulator | Windows/macOS/Linux | `python emulator_simulator.py` | Python 3.x; optional Tkinter for GUI |
| Native assembly emulator | Windows x64 | `build.bat` | MASM `ml64.exe`, Windows SDK linker |
| Automated validation | GitHub Actions | `.github/workflows/python-test.yml` | GitHub-hosted runner |

## 1. Portable validation

Windows PowerShell:

```powershell
.\build.ps1
```

POSIX shell:

```bash
chmod +x build.sh
a./build.sh
```

If the leading `a` was accidentally copied, use `./build.sh`.

The portable build compiles all Python sources, runs the 8080 CPU self-test, and executes the regression suite without third-party packages.

## 2. Run the CPU core

```bash
python tools/altair8080.py --self-test
python tools/altair8080.py --demo
```

The CPU core provides 64 KiB memory, 8080 registers/flags, stack operations, conditional control flow, arithmetic/logic operations, IN/OUT port callbacks, cycle counting, and HLT execution.

## 3. Run the existing OS simulator

```bash
python emulator_simulator.py --help
python emulator_simulator.py --bit-mode 16
python emulator_simulator.py --bit-mode 32
python emulator_simulator.py --bit-mode 64
python emulator_simulator.py --bit-mode 128
```

## 4. Native Windows build

Use a Visual Studio Developer Command Prompt or a Windows SDK environment where `ml64.exe`, `link.exe`, and `kernel32.lib` are available:

```cmd
build.bat
```

The native build assembles the repository's primary x64 emulator modules and links `emulator.exe` against Windows Kernel32 APIs.

## 5. CI

Every push and pull request runs:

1. Python compilation checks.
2. The 8080 self-test.
3. The standard-library regression suite.

The CI workflow deliberately does not claim to build MASM on Linux; the native target remains Windows-specific.

## 6. Architecture

```text
+-------------------------------------------------------+
| Front Panel / Tkinter / Console                      |
+-------------------------------------------------------+
| ALTAIR/OS simulator                                  |
+-------------------------------------------------------+
| 8080 CPU core                                        |
| registers | flags | memory | stack | IN/OUT | cycles |
+-------------------------------------------------------+
| Hardware adapters                                    |
| LEDs | switches | screen | ports | sound            |
+-------------------------------------------------------+
| Native x64 MASM implementation                       |
+-------------------------------------------------------+
```

The portable CPU core is intentionally independent from the Windows API so it can be tested on multiple platforms. The historical front-panel/native assembly implementation remains available as the Windows-specific target.
