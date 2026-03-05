# ALTAIR 8800 EMULATOR v3.0 - COMPLETE SYSTEM

## Welcome to the Future of Retro Computing! 🚀

This is a **complete, production-ready emulation** of the historic **ALTAIR 8800 microcomputer** with comprehensive programming libraries, integrated development tools, and advanced features.

---

## 🌟 What's Included

### 7 Core Components
```
✓ Enhanced UI Interface        - Full-featured front panel with menus and audio
✓ Integrated IDE Editor        - Code editor for ASM, C, and C++
✓ Logic Gate Circuit Editor    - Visual design and simulation  
✓ Audio System                 - Realistic sound effects and feedback
✓ Screen Interface             - 80×24 terminal + graphics display
✓ Backplane Architecture View  - System visualization
✓ Master Launcher              - Central control center
```

### 3 Programming Libraries
```
✓ Assembly Standard Library    - Complete x86-64 assembly routines
✓ C/C++ Standard Library       - Full C/C++ function library
✓ Example Programs             - Working code demonstrations
```

### Key Features
```
✓ Audio/Sound Effects          - Realistic beeps and tones
✓ Multi-Language IDE           - ASM, C, C++ with syntax highlighting
✓ Program Output Terminal      - Real-time output display
✓ Keyboard & Mouse Control     - Full input support
✓ Complete Menu System         - All functions accessible
✓ Logic Simulation             - 9 gate types
✓ Multi-Bit Modes              - 8/16/32/64/128-bit architectures
✓ Memory Management            - Complete memory hierarchy
✓ I/O Port Emulation           - Hardware port support
✓ Interrupt System             - Interrupt vectors and handlers
```

---

## 🚀 Quick Start (30 Seconds)

### Option 1: Master Launcher (Recommended)
```bash
python altair_launcher.py
```
Then click "Quick Launch" → "Full System (Enhanced UI)"

### Option 2: Direct - Main Emulator
```bash
python altair_ui_enhanced.py
```

### Option 3: Direct - Code Editor
```bash
python ide_editor.py
```

---

## 📚 System Architecture

### Memory Map
```
0x0000 - 0x00FF  →  Zero Page (fast access, 256 bytes)
0x0100 - 0x01FF  →  Stack Area (256 bytes)
0x0200 - 0x7FFF  →  Program Code & Data (31.5 KB)
0x8000 - 0xFFFF  →  Upper Memory / Video RAM (32 KB)
```

### Register Set
```
General Purpose:  A, B, C, D, E, H, L (8-bit)
Special:          PC (Program Counter), SP (Stack Pointer)
Flags:            Carry, Zero, Parity, Auxiliary, Sign, Trap
```

### Bus Structure
```
Address Bus:  16-bit (64KB addressing)
Data Bus:     8-bit (1 byte transfers)
Control Bus:  Clock, Reset, Interrupt, Read/Write signals
```

---

## 🎮 Using the Enhanced UI

### Front Panel (Left Side)
- **16-bit Address Bus LEDs** - Shows current address
- **8-bit Data Bus LEDs** - Shows current data value
- **Status Indicators** - POWER, HALT, WAIT, INT
- **CPU Registers** - Live display of A,B,C,D,E,H,L,PC,SP
- **Toggle Switches** - 16 binary input switches
- **Control Buttons** - RUN, HALT, RESET

### Program Output (Right Side)
- **Terminal Display** - Program output in real-time
- **Input Area** - Send data to program
- **Scrollable History** - View previous output

### Top Menu Bar
```
File    → New Program, Open, Save Output, Exit
Edit    → Clear Output, Clear All
View    → Register Details, Memory Viewer, Zoom
Tools   → IDE, Logic Editor, Audio Settings
System  → Bit Mode (8/16/32/64/128), Reset, Info
Help    → About, Shortcuts, Documentation
```

---

## 💻 Programming Languages

### Assembly (x86-64)
```asm
; Hello World in ASM
MOV AX, 5
MOV BX, 3
ADD AX, BX        ; AX = 8
MOV SP, 0x8000
HLT
```

### C Language
```c
#include "altair_stdlib.h"

int main(void) {
    printf("Hello, ALTAIR 8800!\n");
    int x = 42;
    printf("The answer is: %d\n", x);
    return 0;
}
```

### C++ Language
```cpp
#include "altair_stdlib.h"

int main() {
    const char* message = "ALTAIR 8800";
    printf("System: %s\n", message);
    return 0;
}
```

---

## 📦 Component Details

### 1. Enhanced UI (`altair_ui_enhanced.py`)
Main emulator interface with full features
- 1400×900 window with split panels
- LED animations (100ms refresh)
- Audio feedback for all actions
- Real-time CPU state display
- Integrated program terminal

**Keyboard:**
- `SPACE` - Toggle Run/Halt
- `R` - Reset
- `H` - Halt
- `Q` - Queue status

### 2. IDE Editor (`ide_editor.py`)
Professional code editor
- Syntax highlighting (ASM, C, C++)
- Line numbering
- Undo/Redo support
- Find & Replace
- File dialogs

**Shortcuts:**
- `Ctrl+N` - New file
- `Ctrl+O` - Open
- `Ctrl+S` - Save
- `Ctrl+H` - Help

### 3. Logic Gate Editor (`logic_gate_editor.py`)
Circuit design and simulation
- 9 gate types
- Drag-and-drop interface
- Real-time simulation
- Circuit save/load
- Visual execution

**Gates:** AND, OR, NOT, NAND, NOR, XOR, XNOR, SWITCH, LED

### 4. Audio System (`audio_system.py`)
Realistic sound effects

**Sounds:**
| Event | Frequency | Duration |
|-------|-----------|----------|
| LED On | 1000 Hz | 50ms |
| LED Off | 800 Hz | 40ms |
| Switch | 1500 Hz | 80ms |
| Power On | 800→1600 Hz | 100ms×3 |
| Power Off | 1600→800 Hz | 100ms×3 |
| Error | 600 Hz | 100ms×2 |

### 5. Screen Interface (`altair_screen_interface.py`)
Terminal and graphics display
- 80×24 character mode
- 320×192 graphics mode
- Cursor control
- Line/circle/rectangle drawing
- Save/load screen contents

### 6. Backplane Viewer (`altair_backplane_ui.py`)
System architecture visualization
- Components shown: CPU, RAM, ROM, I/O cards
- Bus activity display
- Card inspection
- System information panel

### 7. Master Launcher (`altair_launcher.py`)
Central control center
- Quick launch options
- Component management
- Library viewer
- System status display

---

## 📖 Library Reference

### Assembly Library (`asm_stdlib.asm`)

**System Routines:**
- `HALT` - Stop CPU
- `RESET` - Reset system
- `DELAY` - Pause in milliseconds

**Memory Operations:**
- `MEMCPY` - Copy memory block
- `MEMSET` - Fill memory
- `MEMCMP` - Compare memory

**String Operations:**
- `STRLEN` - Get string length
- `STRCPY` - Copy string
- `STRCMP` - Compare strings
- `STRREV` - Reverse string

**Arithmetic:**
- `ADD16`, `SUB16`, `MUL16`, `DIV16`, `ABS16`

**Bit Operations:**
- `BITCOUNT` - Count set bits
- `BITREV` - Reverse bits

**I/O:**
- `PUTCHAR` - Write character
- `GETCHAR` - Read character
- `PUTS` - Write string

### C/C++ Library (`altair_stdlib.h`)

**Memory Management:**
```c
void* memcpy(void* dest, const void* src, size_t n);
void* memset(void* s, int c, size_t n);
int memcmp(const void* s1, const void* s2, size_t n);
void* malloc(size_t size);
void free(void* ptr);
```

**String Functions:**
```c
size_t strlen(const char* s);
char* strcpy(char* dest, const char* src);
int strcmp(const char* s1, const char* s2);
char* strcat(char* dest, const char* src);
void strrev(char* s);
```

**Character Functions:**
```c
int isalpha(int c);    int isdigit(int c);
int isalnum(int c);    int isspace(int c);
int isupper(int c);    int islower(int c);
int toupper(int c);    int tolower(int c);
```

**Math Functions:**
```c
int abs(int j);
div_t div(int numer, int denom);
int min(int a, int b);    int max(int a, int b);
```

**Array Functions:**
```c
void qsort(void* base, size_t n, size_t size, ...);
void* bsearch(const void* key, const void* base, ...);
void array_reverse(int* arr, int n);
int array_sum(int* arr, int n);
int array_max(int* arr, int n);
```

**I/O Functions:**
```c
int printf(const char* format, ...);
int sprintf(char* str, const char* format, ...);
int getchar(void);
int putchar(int c);
```

**System Control:**
```c
void halt(void);
void reset(void);
void delay(unsigned int ms);
void beep(unsigned int freq, unsigned int duration);
byte in_port(byte port);
void out_port(byte port, byte value);
```

---

## 🎵 Audio System

The emulator includes comprehensive audio feedback:

**Toggle in Tools → Audio:**
- Toggle Sound - Mute/unmute all effects
- Volume - Set volume level (0-100%)

**Programmatic Usage:**
```python
from audio_system import get_audio_system

audio = get_audio_system()
audio.play_led_on()                    # 1000 Hz beep
audio.play_switch_toggle()             # 1500 Hz beep
audio.play_power_on()                  # Startup sequence
audio.play_error()                     # Error alert
audio.set_volume(0.7)                  # Set volume 0.0-1.0
audio.toggle_audio()                   # Mute/unmute
```

---

## ⚙️ System Modes

Emulator supports multiple bit-width configurations:

| Mode | Register Width | Address Bus | Data Bus | Use Case |
|------|---|---|---|---|
| 8-bit | 8 | 16 | 8 | Classic 8080 |
| 16-bit | 16 | 20 | 16 | 8086-style |
| 32-bit | 32 | 32 | 32 | 80386-style |
| 64-bit | 64 | 64 | 64 | x86-64 style |
| 128-bit | 128 | 128 | 128 | Experimental |

**Switch Mode:**
- System → Bit Mode → Select desired width

---

## 🗂️ File Structure

```
altair_8800_complete/
├── altair_launcher.py                 ← START HERE
├── altair_ui_enhanced.py              Main emulator
├── ide_editor.py                      Code editor
├── logic_gate_editor.py               Circuit designer
├── audio_system.py                    Sound effects
├── altair_screen_interface.py         Display
├── altair_backplane_ui.py             Architecture
├── emulator_simulator.py              Core simulator
│
├── asm_stdlib.asm                     Assembly library
├── altair_stdlib.h                    C/C++ library  
├── example_c_program.c                C examples
│
├── QUICKSTART.py                      Quick start guide
├── COMPLETE_SYSTEM_DOCUMENTATION.md   Full documentation
├── README.md                          This file
└── [other files]                      Additional components
```

---

## 🔧 System Requirements

- **Python:** 3.7 or higher
- **Dependencies:** tkinter (included with Python)
- **OS:** Windows, macOS, Linux
- **RAM:** 50-100 MB
- **Disk:** ~200 KB (source code)

**No external packages required!**

---

## 📋 Menu System Reference

### File Menu
```
New Program       - Create new program
Open Program      - Load program file
Save Output       - Export terminal output
Properties        - System properties
Exit              - Quit application
```

### Edit Menu
```
Clear Output      - Clear terminal display
Clear All         - Full system reset
```

### View Menu
```
Register Details  - Show all register values
Memory Viewer     - Browse memory contents
Zoom In           - Increase display size
Zoom Out          - Decrease display size
```

### Tools Menu
```
Integrated IDE    - Launch code editor
Logic Gate Editor - Launch circuit designer
Audio:
  Toggle Sound    - Mute/unmute effects
  Volume          - Adjust volume (0-100%)
```

### System Menu
```
Bit Mode:
  8-bit           - 8-bit architecture
  16-bit          - 16-bit architecture
  32-bit          - 32-bit architecture
  64-bit          - 64-bit architecture
  128-bit         - 128-bit architecture
Reset             - Full system reset
System Info       - Display system information
```

### Help Menu
```
About             - About the emulator
Keyboard Shortcuts- Show keyboard shortcuts
Documentation    - User guide
```

---

## ⌨️ Keyboard Shortcuts

**Emulator:**
- `SPACE` - Toggle Run/Pause
- `R` - Reset program
- `H` - Halt program
- `Q` - Show queue status
- `0-9, A-F` - Toggle switches 0-15

**IDE:**
- `Ctrl+N` - New file
- `Ctrl+O` - Open file
- `Ctrl+S` - Save file
- `Ctrl+H` - Help

**General:**
- `Ctrl+I` - Open IDE
- `Ctrl+L` - Open Logic Editor
- `Ctrl+Q` - Quit
- `F1` - Help

---

## 🎯 Quick Examples

### Example 1: Hello World (C)
```c
#include "altair_stdlib.h"

int main(void) {
    puts("╔═══════════════════╗");
    puts("║ Hello, ALTAIR!    ║");
    puts("╚═══════════════════╝");
    return 0;
}
```

### Example 2: Arithmetic (C)
```c
int a = 25, b = 17;
printf("Sum: %d\n", a + b);           // 42
printf("Product: %d\n", a * b);       // 425
printf("Average: %d\n", (a + b) / 2); // 21
```

### Example 3: Strings (C)
```c
char text[] = "ALTAIR";
printf("Original: %s\n", text);
strrev(text);
printf("Reversed: %s\n", text);    // RIATRA
printf("Length: %d\n", strlen(text)); // 6
```

### Example 4: Arrays (C)
```c
int nums[] = {45, 23, 67, 12, 89};
printf("Sum: %d\n", array_sum(nums, 5));    // 236
printf("Max: %d\n", array_max(nums, 5));    // 89
printf("Min: %d\n", array_min(nums, 5));    // 12
bubble_sort(nums, 5);
```

### Example 5: Assembly
```asm
MOV AX, 0x1234
MOV BX, 0x5678  
ADD AX, BX      ; AX = 0x68AC
MOV SP, 0x8000
PUSH AX
HLT
```

---

## 🚨 Troubleshooting

### GUI Not Appearing
```bash
# Test tkinter installation
python -m tkinter

# If that works, try launching with explicit path
python -X dev altair_launcher.py
```

### Audio Not Working
- **Windows:** Check Sound settings
- **macOS:** Check System Audio permissions
- **Linux:** Install `speaker-test` or `sox`

### IDE Won't Launch
```bash
# Launch IDE directly
python ide_editor.py

# Check Python installation
python --version
```

### Logic Gate Simulation Issues
- Verify all connection points
- Ensure gates have valid inputs
- Click "Simulate" to run
- Use "Clear All" to reset

---

## 📚 Documentation

Main documentation files:
- **COMPLETE_SYSTEM_DOCUMENTATION.md** - Full system guide
- **QUICKSTART.py** - Quick start instructions
- **example_c_program.c** - C code examples
- **asm_stdlib.asm** - Assembly library examples

---

## 🌍 Features Overview

### CPU Emulation
- ✓ 8080A instruction set
- ✓ Register operations
- ✓ Memory addressing modes
- ✓ Flag handling
- ✓ Interrupt support
- ✓ Stack management

### Memory System
- ✓ 64KB address space
- ✓ Zero page optimization
- ✓ Stack area
- ✓ Program/data area
- ✓ Video RAM

### I/O System
- ✓ 4 I/O ports
- ✓ Input/output operations
- ✓ Status port
- ✓ Control port
- ✓ Port mapping

### User Interface
- ✓ LED indicators
- ✓ Register displays
- ✓ Toggle switches
- ✓ Control buttons
- ✓ Status indicators
- ✓ Program terminal

### Development Tools
- ✓ Code editor IDE
- ✓ Logic circuit designer
- ✓ System visualizer
- ✓ Memory viewer
- ✓ Register inspector

### Libraries
- ✓ Assembly stdlib
- ✓ C/C++ stdlib
- ✓ Example programs
- ✓ Comprehensive documentation

### Audio System
- ✓ Sound effects
- ✓ Volume control
- ✓ Mute/unmute
- ✓ Realistic feedback

---

## 🎓 Learning Resources

### Getting Started
1. Read this README
2. Run `python QUICKSTART.py`
3. Launch the main emulator
4. Try the examples

### Understanding the System
1. Open Backplane Viewer
2. Click on components
3. Read detailed information
4. Understand architecture

### Programming
1. Open IDE Editor
2. Select language (ASM/C/C++)
3. Read library headers
4. Look at example programs
5. Write your own code

---

## 👥 Community & Support

For issues, suggestions, or questions:
- Review documentation files
- Check example programs
- Test with simple programs first
- Verify system requirements

---

## 📝 Version History

### v3.0 (Current)
- ✓ Audio system with realistic sound effects
- ✓ Enhanced UI with menus and submenus
- ✓ Integrated IDE for ASM, C, C++
- ✓ Logic gate circuit editor
- ✓ Program output terminal
- ✓ Screen interface (text + graphics)
- ✓ Comprehensive standard libraries
- ✓ Master launcher control center
- ✓ Multi-bit architecture support

### Future Plans
- [ ] Debugger with breakpoints
- [ ] Memory profiler
- [ ] CPU performance counter
- [ ] Extended graphics modes
- [ ] Network simulation
- [ ] Compiler integration

---

## 🎉 Conclusion

You now have a complete, professional-grade ALTAIR 8800 emulator with:
- Full CPU emulation
- Comprehensive libraries
- Advanced development tools
- Realistic audio feedback
- Beautiful UI interface

**Start now:**
```bash
python altair_launcher.py
```

Enjoy your journey into retro computing! 🚀

---

**ALTAIR 8800 Emulator v3.0**
*Because the past is prologue to the future*

---

## 📄 License

This project is provided as-is for educational and nostalgic purposes.

---

**Happy Computing! 🖥️✨**
