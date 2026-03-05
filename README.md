# ALTAIR 8800 EMULATOR - COMPREHENSIVE DOCUMENTATION

## Overview

This is a complete x86-64 assembly language implementation of an Altair 8800 emulator for Windows. The Altair 8800, released in 1974, was one of the first commercially successful personal computers. This emulator faithfully reproduces its key features including:

- **16 Address Bus LEDs** (A0-A15 representation)
- **8 Data Bus LEDs** (D0-D7 representation)
- **Status LEDs** (Power, Halt, Wait, Interrupt indicators)
- **16 Toggle Switches** (for input/control)
- **Screen Display** (16x16 character buffer)
- **Sound Effects** (startup, error, success sounds)
- **Instruction Execution Engine** (Intel 8080 subset)
- **Mathematical Operations** (8/16/32/64-bit)
- **Binary/Hex/Octal Conversion**
- **Advanced Animations** (counter, chaser, pulse patterns)
- **Configurable System Width** (16/32/64/128-bit)

---

## Bit Width Configuration (16/32/64/128)

The emulator now supports selecting the active system configuration width.

### Assembly Boot Menu (`SYSTEM_INIT.asm`)

- Main menu includes `9. Bit System Config`
- Config menu options:
   - `1` => `16-bit`
   - `2` => `32-bit`
   - `3` => `64-bit`
   - `4` => `128-bit`
- Current configuration is shown in the main menu.

### Python Simulator (`emulator_simulator.py`)

Run with a configured width:

```bash
python emulator_simulator.py --bit-mode 16
python emulator_simulator.py --bit-mode 32
python emulator_simulator.py --bit-mode 64
python emulator_simulator.py --bit-mode 128
```

The selected mode is applied to configured-word arithmetic demonstrations and reported in system information/statistics.

### Tkinter UI (`altair_ui_interface.py`)

- Includes a `SYSTEM WIDTH` selector with `16/32/64/128`
- Address bus and PC ranges/masks follow the selected width
- Front-panel address LEDs continue to show the lower 16 bits for compatibility

---

## File Structure

### Main Files

1. **altair_8800_emulator.asm** (Primary emulator)
   - Core emulation loop
   - LED/switch management
   - Basic instruction execution
   - Display rendering
   - Sound generation
   - Math operations

2. **altair_8800_advanced.asm** (Advanced features)
   - Extended LED animations
   - Bitwise operations (AND, OR, XOR)
   - Shift/Rotate operations (8/16/32/64-bit)
   - Advanced sound synthesis
   - Trigonometric calculations
   - Screen buffer management

3. **build.bat** (Build script)
   - Assembles both ASM files
   - Links with Windows API libraries
   - Generates executable

4. **README.md** (This file)
   - Documentation and usage guide

---

## Hardware Simulation

### LED Display

The emulator simulates the iconic Altair 8800 LED register display:

**Address Bus LEDs (16 LEDs)**
```
Display format: [LLLL LLLL LLLL LLLL]
Represents:     [A15  A14  A13  A12  ... A3  A2  A1  A0]
State values:   0 = LED off (dark), 1 = LED on (illuminated)
```

**Data Bus LEDs (8 LEDs)**
```
Display format: [LLLL LLLL]
Represents:     [D7  D6  D5  D4  D3  D2  D1  D0]
```

**Status LEDs**
- Power (green) - CPU power indicator
- Halt (red) - CPU in halt state
- Wait (yellow) - CPU waiting for memory
- Interrupt (orange) - Interrupt pending

### Switch Input

The emulator supports 16 toggle switches, each independently controllable:

```
Function: switch_id (0-15), value (0=off, 1=on)
Usage: process_switch_input(RAX=id, RBX=value)
```

### Display/Screen

A 16x16 character buffer for text output:
- Memory: screen_buffer (256 bytes)
- Dimensions: 16 characters wide × 16 characters tall
- Cursor position tracking (X, Y coordinates)

---

## Mathematical Operations

### 8-Bit Operations
```assembly
ADD:     Adds two 8-bit numbers
SUB:     Subtracts two 8-bit numbers
MUL:     Multiplies two 8-bit numbers
DIV:     Divides two 8-bit numbers
AND:     Bitwise AND
OR:      Bitwise OR
XOR:     Bitwise XOR
NOT:     Bitwise NOT
SHL:     Left shift (0-7 positions)
SHR:     Right shift (0-7 positions)
ROL:     Left rotate (0-7 positions)
ROR:     Right rotate (0-7 positions)
```

### 16-Bit Operations
```assembly
ADD16:   Adds two 16-bit numbers (result: result_16bit)
SUB16:   Subtracts two 16-bit numbers
MUL16:   Multiplies two 16-bit numbers
DIV16:   Divides two 16-bit numbers
AND16:   Bitwise AND on 16-bit values
OR16:    Bitwise OR on 16-bit values
XOR16:   Bitwise XOR on 16-bit values
SHL16:   Left shift (0-15 positions)
SHR16:   Right shift (0-15 positions)
ROL16:   Left rotate
ROR16:   Right rotate
```

### 32-Bit Operations
```assembly
ADD32:   Adds two 32-bit numbers (result: result_32bit)
MUL32:   Multiplies two 32-bit numbers
DIV32:   Divides two 32-bit numbers
AND32:   Bitwise AND on 32-bit values
OR32:    Bitwise OR on 32-bit values
XOR32:   Bitwise XOR on 32-bit values
SHL32:   Left shift (0-31 positions)
SHR32:   Right shift (0-31 positions)
```

### 64-Bit Operations
```assembly
ADD64:   Adds two 64-bit numbers (result: result_64bit)
MUL64:   Multiplies two 64-bit numbers
DIV64:   Divides two 64-bit numbers
AND64:   Bitwise AND on 64-bit values
OR64:    Bitwise OR on 64-bit values
XOR64:   Bitwise XOR on 64-bit values
SHL64:   Left shift (0-63 positions)
SHR64:   Right shift (0-63 positions)
```

### Number Base Conversions

**Binary to Hex/Octal/Decimal:**
```assembly
print_binary_16bit:     Converts 16-bit value to binary display
print_hex_16bit:        Converts 16-bit value to hexadecimal
print_octal_16bit:      Converts 16-bit value to octal
print_decimal_16bit:    Converts 16-bit value to decimal
```

**Format Examples:**
```
Input:  0xABCD (43981 decimal)
Binary: 0b 1010 1011 1100 1101
Hex:    0xABCD
Octal:  0o125715
Decimal: 0d43981
```

### Advanced Mathematics

**Factorial Calculation**
```assembly
factorial_calc:
  Input:  RAX = n (0-20 recommended)
  Output: [math_result_64]
  Example: 5! = 120
```

**Power/Exponentiation**
```assembly
power_calc:
  Input:  RAX = base, RCX = exponent
  Output: [math_result_64]
  Example: 2^8 = 256
```

**GCD (Greatest Common Divisor)**
```assembly
gcd_calc:
  Input:  RAX = first number, RCX = second number
  Output: [math_result_64]
  Example: GCD(48, 18) = 6
```

**Trigonometric Functions**
```assembly
sin_calc:   Calculates sine (fixed-point in [sin_result])
cos_calc:   Calculates cosine (fixed-point in [cos_result])
tan_calc:   Calculates tangent (fixed-point in [tan_result])
```

**Logarithmic Functions**
```assembly
log2_calc:   Binary logarithm
ln_calc:     Natural logarithm (base e)
log10_calc:  Common logarithm (base 10)
```

---

## Sound Effects

### Available Sound Patterns

**Startup Chime**
```
Notes: 800 Hz (100ms) → 1200 Hz (100ms) → 1600 Hz (150ms)
Purpose: System initialization
```

**Error Buzz**
```
Notes: 200 Hz (200ms) → 150 Hz (100ms)
Purpose: Operation error indicator
```

**Success Notification**
```
Notes: 1000 Hz (150ms) → 1500 Hz (200ms)
Purpose: Successful operation confirmation
```

### Sound Synthesis

The emulator includes a sine wave synthesis engine:
- 256-point sine lookup table
- Adjustable frequency (in Hz)
- Variable duration (in milliseconds)
- Square wave alternative available

**Usage:**
```assembly
mov rcx, 1000       ; Frequency: 1000 Hz
mov rdx, 500        ; Duration: 500 ms
call synthesize_tone_sine
```

---

## LED Animation Patterns

### Pattern 1: Binary Counter
```
State increments 0-255, LSB at right side
Cycles through all 256 16-bit patterns
Visual effect: Rapid counter advancement
```

### Pattern 2: LED Chaser
```
Single LED moves left across display
Creates "chase" visual effect
Loop: LED0 → LED1 → ... → LED15 → LED0
```

### Pattern 3: Pulse
```
All LEDs brighten and fade repeatedly
Uses 8-level brightness table
Visual direction: brightness 0 → 255 → 0 → ...
```

### Pattern Animation Control
```assembly
animate_led_counter:    Call to activate counter pattern
animate_led_chaser:     Call to activate chase pattern
animate_led_pulse:      Call to activate pulse pattern
```

---

## CPU/Instruction Set (8080 Subset)

The emulator includes a basic instruction execution engine supporting Intel 8080 opcodes:

| Instruction | Opcode | Description |
|-----------|--------|-------------|
| NOP | 0x00 | No operation |
| MOV | 0x40-0x7F | Move operations |
| ADD | 0x80 | Add to accumulator |
| JMP | 0xC3 | Unconditional jump |
| HLT | 0x76 | Halt processor |
| RST | 0xC7 | Restart |

**Program Counter:** Started at 0x0000, incremented on instruction execution

---

## Building and Running

### Prerequisites
- Windows operating system
- Visual Studio 2015+ with C++ tools, OR
- Windows SDK (includes build tools)
- MASM (Microsoft Macro Assembler)

### Build Steps

1. **Automatic Build:**
   ```cmd
   build.bat
   ```
   This will:
   - Check for MASM availability
   - Assemble both .asm files
   - Link with kernel32.lib
   - Generate emulator.exe

2. **Manual Build (Advanced):**
   ```cmd
   ML64.exe /c /Fo output\altair_8800_emulator.obj altair_8800_emulator.asm
   ML64.exe /c /Fo output\altair_8800_advanced.obj altair_8800_advanced.asm
   link.exe /out:emulator.exe output\*.obj kernel32.lib
   ```

3. **Run the Emulator:**
   ```cmd
   emulator.exe
   ```

---

## Memory Layout

```
Address Range  | Size    | Purpose
---------------|---------|------------------------------------------
0x0000-0xFFFF  | 64 KB   | Main address space
0x0000-0x0FFF  | 4 KB    | Program/bootloader area
0x1000-0xFFFF  | 61 KB   | Data and stack
Stack grows downward from 0xFFFF
```

---

## Register Reference

### 8-Bit Registers
```
[reg_a]    - Accumulator (main working register)
[reg_b]    - Register B
[reg_c]    - Register C  
[reg_d]    - Register D
[reg_e]    - Register E
[reg_h]    - Register H (high byte of HL pair)
[reg_l]    - Register L (low byte of HL pair)
```

### 16-Bit Register Pairs
```
[reg_sp]   - Stack Pointer
[reg_pc]   - Program Counter
BC pair    - Combined B and C registers
DE pair    - Combined D and E registers
HL pair    - Combined H and L registers (memory addressing)
```

### Flags Register
```
[flag_zero]     - Set if result is zero
[flag_carry]    - Set if operation caused carry/borrow
[flag_parity]   - Set if result has even parity
[flag_aux_carry] - Auxiliary carry for BCD
[flag_sign]     - Set if result is negative
```

---

## Data Structures

### LED State Format
```assembly
Offset | Size | Field
-------|------|---------
+0     | 8    | Address bus LED state (A0-A7)
+8     | 8    | Address bus LED state (A8-A15)
+16    | 1    | Data bus LED state (D0-D7)
+17    | 1    | Status LED state
```

### Switch State Format
```assembly
Offset | Size | Field
-------|------|---------
+0     | 8    | Switches 0-7
+8     | 8    | Switches 8-15
```

---

## Performance Notes

- **Instruction Fetch**: ~10 CPU cycles
- **LED Update**: ~5 CPU cycles per LED
- **Display Render**: ~256 CPU cycles (full 16×16 buffer)
- **Sound Synthesis**: ~500-1000 CPU cycles (variable)
- **Math Operation (64-bit)**: ~50-200 CPU cycles (depends on operation)

---

## Troubleshooting

### Build Issues

**"ML64.exe not found"**
- Solution: Install Visual Studio with C++ workload or Windows SDK

**"link.exe not found"**
- Solution: Ensure Visual Studio build tools are installed and in PATH

**"kernel32.lib not found"**
- Solution: Run build.bat from a Visual Studio Developer Command Prompt

### Runtime Issues

**Emulator exits immediately**
- Check console for error messages
- Verify Windows API calls are successful

**Sound not playing**
- Check system volume
- Verify Beep() API is available on your Windows version

**Display appears blank**
- Console buffer may need refresh
- Check WriteConsoleA return codes

---

## Assembly Syntax Reference

This project uses **Microsoft Macro Assembler (MASM)** syntax:

```assembly
; Constants
CONSTANT equ value

; Data section
.data
label:          db byte_value
label:          dw word_value (2 bytes)
label:          dd dword_value (4 bytes)
label:          dq qword_value (8 bytes)

; Code section
.code
function:
    push rbp
    mov rbp, rsp
    ; ... function body ...
    pop rbp
    ret
```

---

## Advanced Features Demo

The emulator includes demonstration code for:

1. **Multi-format Number Display**
   - Binary with leading 0b
   - Hexadecimal with 0x prefix
   - Octal with 0o prefix
   - Decimal with 0d prefix

2. **Comprehensive Math Library**
   - Addition/subtraction across bit widths
   - Multiplication with overflow handling
   - Division with remainder
   - Modulo operations
   - Factorial, power, GCD

3. **Bitwise Operation Suite**
   - AND, OR, XOR, NOT
   - Left/right shifts with rotation
   - Bit manipulation utilities

4. **Animation Engine**
   - Frame-based animation system
   - Multiple simultaneous patterns
   - Configurable animation speed

---

## Design Architecture

The emulator follows a modular design:

```
┌─────────────────────────────────────┐
│   User Interface / Console I/O      │
├─────────────────────────────────────┤
│  Hardware Simulation Layer          │
│  ├─ LED Driver                      │
│  ├─ Switch Controller               │
│  ├─ Display Buffer                  │
│  └─ Audio Generator                 │
├─────────────────────────────────────┤
│  CPU Emulation Layer                │
│  ├─ Register File                   │
│  ├─ Instruction Fetch/Decode/Execute│
│  ├─ Memory Management               │
│  └─ Flag Logic                      │
├─────────────────────────────────────┤
│  Math & Utility Functions           │
│  ├─ Binary Conversions              │
│  ├─ Arithmetic Operations           │
│  ├─ Bitwise Operations              │
│  └─ Advanced Math                   │
├─────────────────────────────────────┤
│   Windows API Wrapper               │
│   ├─ Console I/O                    │
│   ├─ Audio Output                   │
│   └─ System Time                    │
└─────────────────────────────────────┘
```

---

## License & History

This emulator faithfully represents the Altair 8800 computer from 1974:
- **Processor**: Intel 8080 (3.072 MHz)
- **Memory**: 256 bytes to 64 KB (in 4KB increments)
- **I/O**: 256 ports
- **Display**: 16 LEDs (address+data bus)
- **Input**: 16 toggle switches

Historical significance: First hobby computer with significant sales, helped spark the personal computer revolution.

---

## Future Enhancements

Potential additions to expand emulator capabilities:

1. Cassette tape simulation with data loading
2. Expanded instruction set (full 8080 ISA)
3. Memory-mapped I/O simulation
4. Real-time clock emulation
5. File I/O system simulation
6. Expanded display modes (graphics)
7. Interrupt system with handlers
8. Debugger with breakpoints
9. Program counter history (trace buffer)
10. Altair BASIC interpreter integration

---

## Contact & Support

For questions, issues, or enhancement requests, please refer to the assembly source code comments for detailed implementation notes.

**Last Updated**: March 4, 2026

---

## Quick Reference Card

```
ASSEMBLY BUILD:        build.bat
RUN EMULATOR:          emulator.exe

MAIN FUNCTIONS:
  init_altair            - Initialize emulator
  display_leds           - Show LED states
  display_switches       - Show switch states
  demo_math_operations   - Run math demos
  play_beep_sequence     - Generate sounds

KEY PROCEDURES:
  print_binary_16bit     - Binary output
  print_hex_16bit        - Hexadecimal output
  print_octal_16bit      - Octal output
  print_decimal_16bit    - Decimal output

MATH FUNCTIONS:
  factorial_calc         - Calculate N!
  power_calc            - Calculate base^exponent
  gcd_calc              - Greatest common divisor

ANIMATION CONTROL:
  animate_led_counter    - Counter pattern
  animate_led_chaser     - Chase pattern
  animate_led_pulse      - Pulse pattern
```

---

**Documentation Complete**
