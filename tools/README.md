# ASN Computer Build Tools

The repository contains two execution paths:

- `build.bat` — native Windows MASM/x64 build for the existing assembly components.
- `emulator_simulator.py` — portable Python simulator.
- `tools/altair8080.py` — standalone Intel 8080 core used for deterministic tests and CLI execution.

## Portable build

From the repository root:

```text
python tools/altair8080.py --self-test
python tools/altair8080.py --demo
```

## Windows native build

Open a **Developer Command Prompt for Visual Studio** and run:

```text
build.bat
```

The native build requires MASM (`ml64.exe`) and the Windows SDK linker. The portable build does not require Visual Studio.
