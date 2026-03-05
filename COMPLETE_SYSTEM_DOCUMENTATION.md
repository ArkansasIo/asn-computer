# ALTAIR 8800 EMULATOR v3.0 - COMPLETE SYSTEM DOCUMENTATION

## Overview

This is a complete, production-ready emulation of the historic ALTAIR 8800 microcomputer with modern development tools, comprehensive programming libraries, and advanced features.

---

## System Components

### 1. **Enhanced UI** (`altair_ui_enhanced.py`)
The main user interface featuring:
- LED drive indicators for address bus, data bus, and status
- CPU register displays
- Control switches (16 toggle switches)
- Program output terminal with input area
- Complete menu system with submenus
- Audio/sound effects feedback
- Keyboard and mouse control support
- Multiple bit-mode support (8, 16, 32, 64, 128-bit)

**Features:**
- Real-time LED animation
- Button click sounds
- Power on/off sequences
- Halt and interrupt indicators
- Integrated program output display

**How to Use:**
```bash
python altair_ui_enhanced.py
```

---

### 2. **Integrated IDE Editor** (`ide_editor.py`)
Professional code editor with syntax highlighting for multiple languages:

**Supported Languages:**
- x86-64 Assembly (ASM)
- C Programming Language
- C++ Programming Language

**Features:**
- Real-time syntax highlighting
- Line numbering
- Automatic indent/dedent
- Find and replace
- Undo/redo support
- File open/save dialogs
- Code templates

**Example Usage:**
```bash
python ide_editor.py
```

Then use:
- `Ctrl+N` - New file
- `Ctrl+O` - Open file
- `Ctrl+S` - Save file
- File → Language to select ASM, C, or C++

---

### 3. **Logic Gate Editor** (`logic_gate_editor.py`)
Visual circuit design and simulation tool:

**Supported Gates:**
- AND, OR, NOT
- NAND, NOR
- XOR, XNOR
- SWITCH (input)
- LED (output)

**Features:**
- Drag-and-drop gate placement
- Real-time simulation
- Connection drawing
- Circuit save/load
- Gate properties dialog
- Visual circuit execution

**How to Use:**
```bash
python logic_gate_editor.py
```

Operations:
1. Select gate type from dropdown
2. Click "Add Gate" to place gates on canvas
3. Right-click to access context menu
4. Click "Simulate" to run circuit
5. "Save" to export circuit design

---

### 4. **Audio System** (`audio_system.py`)
Sound effects and audio feedback:

**Supported Sounds:**
- LED on/off (1000 Hz, 800 Hz)
- Switch toggle (1500 Hz)
- Button click (2000 Hz)
- Power on sequence (ascending tones)
- Power off sequence (descending tones)
- Error alerts (600 Hz)
- Success confirmation (1200-1600 Hz)
- Halt/stop signal (1000 Hz long)
- Interrupt alert (repeated 1800 Hz)

**Usage in Code:**
```python
from audio_system import get_audio_system

audio = get_audio_system()
audio.play_led_on()
audio.play_switch_toggle()
audio.toggle_audio()  # Mute/unmute
audio.set_volume(0.5)  # 0.0 to 1.0
```

---

### 5. **Screen Interface** (`altair_screen_interface.py`)
Terminal/graphics display interface:

**Display Modes:**
1. **TEXT MODE** (80×24 characters)
   - Character output
   - Cursor positioning
   - Screen clearing/scrolling
   - TTY-like interface

2. **GRAPHICS MODE** (320×192 pixels)
   - Pixel drawing
   - Line drawing (Bresenham algorithm)
   - Circle drawing (Midpoint algorithm)
   - Rectangle primitives
   - Filled shapes

**API Functions:**
```python
screen.putchar(char)      # Put single character
screen.putstr(text)       # Put string
screen.gotoxy(x, y)       # Position cursor
screen.clear_screen()     # Clear display
screen.putpixel(x, y)     # Draw pixel
screen.line(x1, y1, x2, y2)    # Draw line
screen.circle(cx, cy, r)       # Draw circle
screen.save_screen()      # Dump to file
```

---

### 6. **Backplane Interface** (`altair_backplane_ui.py`)
System architecture visualization:

**Components Shown:**
- CPU Card (Intel 8080A)
- Memory Cards (RAM0-2, 8KB each)
- ROM (4KB Monitor)
- I/O Cards (Serial, Parallel, Floppy, Network)
- Bus Architecture (Address, Data, Control)
- Power Distribution

**Features:**
- Bus activity indicators
- Card selection/inspection
- System information panel
- 64KB address space visualization
- Real-time bus activity display

**How to Use:**
```bash
python altair_backplane_ui.py
```

Click on any card to see detailed information.

---

### 7. **Master Launcher** (`altair_launcher.py`)
Central control center for the entire system:

**Tabs:**
1. **Quick Launch** - One-click access to all components
2. **Components** - Detailed component management
3. **Libraries & Examples** - View and open library files
4. **System Status** - System information and status

**Features:**
- Launch individual components
- View file contents
- Open files in IDE
- Copy file paths
- Full system launch

**How to Use:**
```bash
python altair_launcher.py
```

---

## Programming Libraries

### Assembly Language Library (`asm_stdlib.asm`)

**Sections:**
1. **System Routines**
   - `HALT` - Stop CPU
   - `RESET` - Reset system
   - `DELAY` - Wait N milliseconds

2. **Memory Operations**
   - `MEMCPY` - Copy memory block
   - `MEMSET` - Fill memory with value
   - `MEMCMP` - Compare memory blocks

3. **Arithmetic Operations**
   - `ADD16` - 16-bit addition
   - `SUB16` - 16-bit subtraction
   - `MUL16` - 16-bit multiplication
   - `DIV16` - 16-bit division
   - `ABS16` - Absolute value

4. **String Operations**
   - `STRLEN` - Get string length
   - `STRCPY` - Copy string
   - `STRCMP` - Compare strings
   - `STRREV` - Reverse string

5. **Bit Operations**
   - `BITCOUNT` - Count set bits
   - `BITREV` - Reverse bits

6. **I/O Operations**
   - `PUTCHAR` - Write character
   - `GETCHAR` - Read character
   - `PUTS` - Write string

7. **Conversion Routines**
   - `HEX2BIN` - Hex to binary
   - `BIN2HEX` - Binary to hex

**Usage Example:**
```asm
    MOV SI, INPUT_STRING
    CALL STRLEN              ; CX = length
    MOV DI, OUTPUT_STRING
    CALL STRCPY              ; Copy string
```

---

### C/C++ Standard Library (`altair_stdlib.h`)

**Type Definitions:**
```c
typedef unsigned char byte;
typedef unsigned short word;
typedef unsigned int dword;
typedef void* ptr_t;
typedef uint16_t addr_t;
```

**Function Categories:**

1. **Memory Management**
   - `memcpy()`, `memset()`, `memcmp()`, `memmove()`
   - `malloc()`, `free()`

2. **String Operations**
   - `strlen()`, `strcpy()`, `strncpy()`
   - `strcmp()`, `strncmp()`, `strcat()`
   - `strchr()`, `strrchr()`, `strstr()`
   - `strrev()`, `strupr()`, `strlwr()`

3. **Character Classification**
   - `isalpha()`, `isdigit()`, `isalnum()`
   - `isspace()`, `isupper()`, `islower()`
   - `isprint()`, `isgraph()`, `iscntrl()`
   - `toupper()`, `tolower()`

4. **Arithmetic & Math**
   - `abs()`, `labs()`, `min()`, `max()`
   - `clamp()`, `sign()`, `div()`, `ldiv()`

5. **Bit Operations**
   - `bitcount()`, `bitrev()`, `highest_bit()`, `lowest_bit()`
   - Macros: `BIT_SET`, `BIT_CLR`, `BIT_GET`, `BIT_TOGGLE`

6. **I/O Operations**
   - `getchar()`, `putchar()`, `gets()`, `puts()`
   - `printf()`, `sprintf()`, `scanf()`, `sscanf()`

7. **Conversion**
   - `atoi()`, `atol()`, `atof()`
   - `itoa()`, `ltoa()`, `ultoa()`
   - `hex_to_byte()`, `byte_to_hex()`, `word_to_hex()`

8. **System Control**
   - `halt()`, `reset()`, `delay()`, `beep()`
   - `in_port()`, `out_port()`
   - `enable_interrupts()`, `disable_interrupts()`

9. **Display Functions**
   - `gotoxy()`, `clrscr()`, `clreol()`
   - `putch_at()`, `putch_color()`

10. **Array Operations**
    - `qsort()`, `bsearch()`, `linear_search()`, `binary_search()`
    - `array_reverse()`, `array_sum()`, `array_max()`, `array_min()`

**Usage Example:**
```c
#include "altair_stdlib.h"

int main(void) {
    char str1[] = "Hello";
    char str2[] = "World";
    
    printf("String: %s\n", str1);
    printf("Length: %d\n", strlen(str1));
    
    return 0;
}
```

---

### Example C Programs (`example_c_program.c`)

Complete working examples demonstrating:
1. Hello World output
2. Arithmetic operations
3. String manipulation
4. Character classification
5. Bit operations
6. Array operations
7. Memory operations
8. System information

**Compile and Run:**
```bash
gcc example_c_program.c -o example
./example
```

---

## Audio Feedback System

The emulator includes realistic audio feedback for all user interactions:

### Sound Map:
| Event | Frequency | Duration | Purpose |
|-------|-----------|----------|---------|
| LED On | 1000 Hz | 50ms | Visual indicator feedback |
| LED Off | 800 Hz | 40ms | Visual indicator feedback |
| Switch | 1500 Hz | 80ms | Toggle confirmation |
| Click | 2000 Hz | 60ms | Button press |
| Power On | 800→1600 Hz | 100ms × 3 | System startup |
| Power Off | 1600→800 Hz | 100ms × 3 | System shutdown |
| Error | 600 Hz | 100ms × 2 | Alert |
| Success | 1200→1600 Hz | 100ms × 2 | Confirmation |

---

## Menu System

### File Menu
- New Program
- Open Program
- Save Output
- Properties
- Exit

### Edit Menu
- Clear Output
- Clear All

### View Menu
- Register Details
- Memory Viewer
- Zoom In/Out

### Tools Menu
- Integrated IDE
- Logic Gate Editor
- Audio Settings
- Volume Control

### System Menu
- Bit Mode (8, 16, 32, 64, 128-bit)
- Reset
- System Info

### Help Menu
- About
- Keyboard Shortcuts
- Documentation

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Space` | Toggle Run/Halt |
| `R` | Reset Program |
| `H` | Halt Program |
| `Q` | Show Queue Status |
| `0-9, A-F` | Toggle switches |
| `Ctrl+N` | New File (IDE) |
| `Ctrl+O` | Open File (IDE) |
| `Ctrl+S` | Save File (IDE) |
| `Ctrl+I` | Open IDE |
| `Ctrl+L` | Open Logic Editor |
| `Ctrl+Q` | Quit Application |

---

## System Architecture

### Memory Map
```
0x0000 - 0x00FF  :  Zero Page (Fast Access)
0x0100 - 0x01FF  :  Stack Area
0x0200 - 0x7FFF  :  Program Code & Data
0x8000 - 0xFFFF  :  Upper Memory / Video RAM
```

### Register Set
- **General Purpose**: A, B, C, D, E, H, L
- **Special**: PC (Program Counter), SP (Stack Pointer)
- **Flags**: Carry, Zero, Parity, Auxiliary, Sign, Trap

### Buses
- **Address Bus**: 16-bit (64KB addressing)
- **Data Bus**: 8-bit (1 byte)
- **Control Bus**: Clock, Reset, Interrupt, Read/Write

---

## Building and Running

### Prerequisites
- Python 3.7+
- tkinter (usually included with Python)
- No external dependencies required

### Quick Start
```bash
# Run the master launcher (recommended)
python altair_launcher.py

# Or launch individual components
python altair_ui_enhanced.py     # Main emulator
python ide_editor.py             # Code editor
python logic_gate_editor.py       # Circuit designer
python altair_screen_interface.py # Display
python altair_backplane_ui.py    # Architecture view
```

---

## Example Programs

### Assembly Example
```asm
    MOV AX, 5
    MOV BX, 3
    ADD AX, BX        ; AX = 8
    MOV SP, 0x8000
    PUSH AX
    HLT
```

### C Example
```c
#include "altair_stdlib.h"

int main(void) {
    printf("ALTAIR 8800 is alive!\n");
    
    int x = 42;
    printf("The answer is: %d\n", x);
    
    char* msg = "Hello, ALTAIR!";
    puts(msg);
    
    return 0;
}
```

### Assembly Library Example
```asm
    MOV SI, SOURCE_BUFFER
    MOV DI, DEST_BUFFER
    MOV CX, 256
    CALL MEMCPY          ; Copy 256 bytes
```

---

## Features Summary

✓ **Complete x86-64 Assembly Emulation**
✓ **Full C/C++ Standard Library**
✓ **Integrated Development Environment**
✓ **Real-time Audio Feedback**
✓ **Multiple System Architectures (8-128 bit)**
✓ **Logic Gate Simulation**
✓ **System Backplane Visualization**
✓ **Terminal Display Interface**
✓ **Comprehensive Menu System**
✓ **Keyboard & Mouse Control**
✓ **Program Output Terminal**
✓ **Memory and Register Displays**
✓ **I/O Port Emulation**
✓ **Interrupt Support**
✓ **Stack Management**
✓ **Configuration Persistence**

---

## Troubleshooting

### GUI Not Appearing
- Ensure tkinter is installed: `python -m tkinter`
- Try running from terminal for error messages

### Audio Not Working
- Check system volume settings
- Windows: System sounds must be enabled
- macOS: Check audio permissions
- Linux: Ensure speaker-test or sox is installed

### IDE Syntax Highlighting Issues
- Close and reopen the file
- Use View menu to refresh

### Logic Gate Simulation Problems
- Ensure all connections are valid
- Click "Simulate" to run circuit
- Check gate property dialog

---

## File Structure

```
altair_8800_complete/
├── altair_launcher.py          # Master launcher
├── altair_ui_enhanced.py       # Main emulator UI
├── ide_editor.py               # Code editor
├── logic_gate_editor.py        # Circuit designer
├── audio_system.py             # Audio system
├── altair_screen_interface.py  # Display terminal
├── altair_backplane_ui.py      # Architecture viewer
├── asm_stdlib.asm              # Assembly library
├── altair_stdlib.h             # C/C++ library
├── example_c_program.c         # Example programs
└── [other assembly files]      # Additional components
```

---

## System Information

**Total Components**: 7
**Total Libraries**: 3
**Total Features**: 50+
**Code Size**: ~200 KB (source)
**Memory Requirements**: ~50 MB (runtime)
**Processing Speed**: Real-time simulation

---

## Future Enhancements

Planned features for future versions:
- [ ] Debugger with breakpoints
- [ ] Memory profiler
- [ ] CPU cycle counter
- [ ] Performance benchmarks
- [ ] Extended graphics modes
- [ ] Network simulation
- [ ] Tape/disk image support
- [ ] Hardware plugin system
- [ ] Remote debugging
- [ ] Compiler/assembler integration

---

## License & Credits

ALTAIR 8800 Emulator v3.0
© 2024 ALTAIR Emulator Project

Built with Python and tkinter.
Historical inspiration from the MITS ALTAIR 8800.

---

## Support & Documentation

For more information, refer to:
- **README.md** - Quick start guide
- **API_REFERENCE.md** - Function documentation
- **DEVELOPER_GUIDE.md** - Development guide
- Code comments and docstrings throughout

---

**Last Updated**: March 2024
**Version**: 3.0 (Complete Enhanced Release)
