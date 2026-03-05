@echo off
REM ============================================================================
REM ALTAIR 8800 EMULATOR - BUILD SCRIPT
REM Assembles x86-64 ASM files for Windows (MASM)
REM ============================================================================

REM Check if ML64.exe is available
where ML64.exe >nul 2>nul
if errorlevel 1 (
    echo.
    echo ERROR: Microsoft Macro Assembler (ML64.exe) not found!
    echo.
    echo Please install one of the following:
    echo   1. Visual Studio with C++ development tools
    echo   2. Windows SDK
    echo   3. Microsoft Macro Assembler standalone
    echo.
    echo Then ensure the build tools are in your PATH.
    pause
    exit /b 1
)

echo ============================================================================
echo ALTAIR 8800 EMULATOR - ASSEMBLING
echo ============================================================================
echo.

REM Create output directory
if not exist "output" mkdir output

REM Assemble main emulator
echo [1/2] Assembling main emulator (altair_8800_emulator.asm)...
ML64.exe /c /Fo output\altair_8800_emulator.obj altair_8800_emulator.asm
if errorlevel 1 (
    echo ERROR: Failed to assemble altair_8800_emulator.asm
    pause
    exit /b 1
)

REM Assemble advanced features
echo [2/2] Assembling advanced features (altair_8800_advanced.asm)...
ML64.exe /c /Fo output\altair_8800_advanced.obj altair_8800_advanced.asm
if errorlevel 1 (
    echo ERROR: Failed to assemble altair_8800_advanced.asm
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo LINKING
echo ============================================================================
echo.

REM Link object files
echo Linking objects...
link.exe /out:emulator.exe output\altair_8800_emulator.obj output\altair_8800_advanced.obj kernel32.lib
if errorlevel 1 (
    echo ERROR: Failed to link
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo BUILD COMPLETE
echo ============================================================================
echo.
echo Output file: emulator.exe
echo.
echo Type "emulator.exe" to run the emulator
echo.
pause
