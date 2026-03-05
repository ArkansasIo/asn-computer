#!/usr/bin/env python3
"""
ALTAIR 8800 EMULATOR v3.0 - QUICK START GUIDE
This file provides instructions to get started immediately
"""

QUICK_START = """
╔══════════════════════════════════════════════════════════════════╗
║        ALTAIR 8800 EMULATOR v3.0 - QUICK START GUIDE            ║
║                                                                  ║
║  Complete System with Libraries, IDE, Audio, and Components    ║
╚══════════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════════
WHAT'S NEW IN v3.0
═══════════════════════════════════════════════════════════════════

✓ AUDIO SYSTEM
  - Sound effects for all UI interactions
  - Power on/off sequences
  - Error/success alerts
  - Customizable volume

✓ INTEGRATED IDE EDITOR  
  - Syntax highlighting for ASM, C, C++
  - Code completion
  - File open/save
  - Undo/redo support

✓ LOGIC GATE EDITOR
  - Visual circuit designer
  - 9 gate types (AND, OR, NOT, NAND, NOR, XOR, XNOR, SWITCH, LED)
  - Real-time simulation
  - Save/load circuits

✓ ENHANCED UI
  - Program output terminal
  - Keyboard & mouse control
  - Complete menu system
  - Comprehensive statusbar

✓ COMPLETE LIBRARIES
  - Assembly Standard Library (asm_stdlib.asm)
  - C/C++ Standard Library (altair_stdlib.h)
  - Example programs

✓ SCREEN INTERFACE
  - 80×24 character terminal
  - Graphics mode (320×192 pixels)
  - Cursor control
  - Drawing primitives

✓ BACKPLANE VIEWER
  - System architecture visualization
  - Component inspection
  - Bus activity display

═══════════════════════════════════════════════════════════════════
GETTING STARTED (5 MINUTES)
═══════════════════════════════════════════════════════════════════

OPTION 1: Master Launcher (Recommended)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This provides a unified control center for all components.

$ python altair_launcher.py

Then:
1. Click "Quick Launch" tab
2. Click "Full System (Enhanced UI)" button
3. The complete emulator will launch!

OPTION 2: Launch Individual Components
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Launch what you need:

Main Emulator (with menus and audio):
$ python altair_ui_enhanced.py

Code Editor (with syntax highlighting):
$ python ide_editor.py

Circuit Designer (logic gate simulator):
$ python logic_gate_editor.py

Display Terminal (80×24 text + graphics):
$ python altair_screen_interface.py

System Backplane (architecture viewer):
$ python altair_backplane_ui.py

═══════════════════════════════════════════════════════════════════
KEY FEATURES TOUR
═══════════════════════════════════════════════════════════════════

ENHANCED UI INTERFACE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Left Side - Front Panel:
  • Address Bus LEDs (16-bit)
  • Data Bus LEDs (8-bit)
  • Status Indicators (POWER, HALT, WAIT, INT)
  • CPU Registers (A, B, C, D, E, H, L, PC, SP)
  • Toggle Switches (16 binary switches)
  • Control Buttons (RUN, HALT, RESET)

Right Side - Program Output:
  • Terminal display for program output
  • Input text area with keyboard entry
  • Blinking cursor
  • Scrollable history

Top Menu Bar:
  • File: New, Open, Save, Properties
  • Edit: Clear output
  • View: Register details, Memory viewer, Zoom
  • Tools: IDE, Logic Editor, Audio settings
  • System: Bit mode selection (8/16/32/64/128-bit)
  • Help: About, Shortcuts, Documentation

Keyboard Shortcuts:
  SPACE    - Toggle Run/Halt
  R        - Reset Program
  H        - Halt Program
  Q        - Show queue status
  0-9, A-F - Toggle switches

INTEGRATED IDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Features:
  • Real-time syntax highlighting
  • Line numbering
  • Multiple language support (ASM, C, C++)
  • Undo/Redo (Ctrl+Z / Ctrl+Y)
  • Find/Replace
  • Auto-indent

Keyboard:
  Ctrl+N   - New file
  Ctrl+O   - Open file
  Ctrl+S   - Save file
  Ctrl+H   - Help

Language Menu:
  Select from: ASM (x86-64), C, C++

LOGIC GATE EDITOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Supported Gates:
  Logic:    AND, OR, NOT, NAND, NOR, XOR, XNOR
  I/O:      SWITCH (input), LED (output)

Workflow:
  1. Select gate type from dropdown
  2. Click "Add Gate" to place
  3. Drag gates to arrange
  4. Right-click connections
  5. Click "Simulate" to run
  6. "Save" exports circuit

═══════════════════════════════════════════════════════════════════
PROGRAMMING LIBRARIES
═══════════════════════════════════════════════════════════════════

ASSEMBLY LIBRARY (asm_stdlib.asm)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Contains x86-64 assembly routines:

System:
  HALT          - Stop CPU
  RESET         - Reset system
  DELAY         - Pause N milliseconds

Memory:
  MEMCPY        - Copy memory block
  MEMSET        - Fill memory with value
  MEMCMP        - Compare memory blocks

String:
  STRLEN        - Get string length
  STRCPY        - Copy string
  STRCMP        - Compare strings
  STRREV        - Reverse string

Arithmetic:
  ADD16, SUB16, MUL16, DIV16, ABS16

Bit:
  BITCOUNT      - Count set bits
  BITREV        - Reverse bits

I/O:
  PUTCHAR       - Write character
  GETCHAR       - Read character
  PUTS          - Write string

Example Usage:
    MOV SI, SOURCE
    MOV DI, DEST
    MOV CX, 256
    CALL MEMCPY     ; Copy 256 bytes

C/C++ LIBRARY (altair_stdlib.h)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Complete C/C++ standard library for ALTAIR 8800:

Types:
  byte, word, dword, sbyte, sword, sdword
  ptr_t, addr_t

Memory:
  memcpy(), memset(), memcmp(), memmove()
  malloc(), free()

String:
  strlen(), strcpy(), strcat(), strcmp()
  strchr(), strstr(), strrev()

Character:
  isalpha(), isdigit(), isspace(), isupper(), islower()
  toupper(), tolower()

Array Search/Sort:
  qsort(), bsearch(), linear_search(), binary_search()
  bubble_sort(), insertion_sort()

Math:
  abs(), min(), max(), clamp(), sign()
  Bit operations: BIT_SET, BIT_GET, BIT_CLR, BIT_TOGGLE

I/O:
  printf(), sprintf(), scanf(), sscanf()
  getchar(), putchar(), gets(), puts()

System:
  halt(), reset(), delay(), beep()
  in_port(), out_port()

Display:
  gotoxy(), clrscr(), clreol()
  putch_at(), putch_color()

Example Usage:
  #include "altair_stdlib.h"
  
  int main(void) {
      printf("Hello, ALTAIR 8800!\n");
      int x = 42;
      printf("Value: %d\n", x);
      return 0;
  }

═══════════════════════════════════════════════════════════════════
AUDIO & SOUND EFFECTS
═══════════════════════════════════════════════════════════════════

The emulator provides realistic audio feedback:

  Power On:     Ascending tones (800 → 1200 → 1600 Hz)
  Power Off:    Descending tones (1600 → 1200 → 800 Hz)
  LED On:       1000 Hz beep (50ms)
  LED Off:      800 Hz beep (40ms)
  Switch:       1500 Hz beep (80ms)
  Click:        2000 Hz beep (60ms)
  Halt:         1000 Hz long beep (200ms)
  Error:        600 Hz × 2 beeps
  Success:      1200 → 1600 Hz (confirmation)

To disable audio in Tools menu:
  Tools → Audio → Toggle Sound

To adjust volume:
  Tools → Audio → Volume

═══════════════════════════════════════════════════════════════════
SYSTEM SPECIFICATIONS
═══════════════════════════════════════════════════════════════════

CPU:             Intel 8080A (2 MHz)
Memory:          64 KB (configurable)
Address Bus:     16-bit (64KB addressing)
Data Bus:        8-bit (1 byte)

Register Set:
  General:       A, B, C, D, E, H, L (8-bit each)
  Special:       PC (Program Counter), SP (Stack Pointer)
  Flags:         Carry, Zero, Parity, Auxiliary, Sign, Trap

Memory Layout:
  0x0000-0x00FF  Zero Page (256 bytes, fast)
  0x0100-0x01FF  Stack Area (256 bytes)
  0x0200-0x7FFF  Program & Data (31.5 KB)
  0x8000-0xFFFF  Upper Memory/Video (32 KB)

I/O Ports:
  0x00           Input Port
  0x01           Output Port
  0x02           Status Port
  0x03           Control Port

═══════════════════════════════════════════════════════════════════
EXAMPLE PROGRAMS
═══════════════════════════════════════════════════════════════════

HELLO WORLD (C):
  #include "altair_stdlib.h"
  
  int main(void) {
      puts("Hello, ALTAIR 8800!");
      return 0;
  }

ARITHMETIC (C):
  int a = 15, b = 7;
  int result = a + b;
  printf("15 + 7 = %d\n", result);

ASSEMBLY EXAMPLE:
  MOV AX, 0x1234
  MOV BX, 0x5678
  ADD AX, BX         ; AX = 0x68AC
  HLT

STRING OPERATIONS (C):
  char str1[] = "ALTAIR";
  char str2[32];
  strcpy(str2, str1);
  strrev(str2);
  printf("Reversed: %s\n", str2);  ; Output: RIATRA

═══════════════════════════════════════════════════════════════════
MULTI-BIT MODE SUPPORT
═══════════════════════════════════════════════════════════════════

The emulator supports multiple architectural configurations:

8-bit  Mode   - Classic 8080 (8-bit registers and bus)
16-bit Mode   - 8086-style (16-bit registers, 20-bit address)
32-bit Mode   - 80386-style (32-bit registers and bus)
64-bit Mode   - x86-64 style (64-bit registers)
128-bit Mode  - Extended (128-bit registers - experimental)

Change mode in System menu:
  System → Bit Mode → [8/16/32/64/128]

═══════════════════════════════════════════════════════════════════
FILE STRUCTURE
═══════════════════════════════════════════════════════════════════

altair_8800_complete/
├── altair_launcher.py           ← Start here!
├── altair_ui_enhanced.py        ← Main emulator
├── ide_editor.py                ← Code editor
├── logic_gate_editor.py         ← Circuit designer
├── audio_system.py              ← Sound effects
├── altair_screen_interface.py   ← Display
├── altair_backplane_ui.py       ← Architecture
├── asm_stdlib.asm               ← Assembly library
├── altair_stdlib.h              ← C/C++ library
├── example_c_program.c          ← C examples
└── [docs]                       ← Documentation

═══════════════════════════════════════════════════════════════════
MENU REFERENCE
═══════════════════════════════════════════════════════════════════

FILE MENU:
  New Program          - Create new program
  Open Program         - Load program file
  Save Output          - Export program output
  Properties           - System properties
  Exit                 - Quit application

EDIT MENU:
  Clear Output         - Clear terminal
  Clear All            - Reset everything

VIEW MENU:
  Register Details     - Show register values
  Memory Viewer        - View memory contents
  Zoom In              - Increase display size
  Zoom Out             - Decrease display size

TOOLS MENU:
  Integrated IDE       - Launch code editor
  Logic Gate Editor    - Launch circuit designer
  Audio → Toggle Sound - Mute/unmute
  Audio → Volume       - Adjust sound level

SYSTEM MENU:
  Bit Mode → 8-bit     - 8-bit architecture
  Bit Mode → 16-bit    - 16-bit architecture
  Bit Mode → 32-bit    - 32-bit architecture
  Bit Mode → 64-bit    - 64-bit architecture
  Bit Mode → 128-bit   - 128-bit architecture
  Reset                - Full system reset
  System Info          - Display system info

HELP MENU:
  About                - About dialog
  Keyboard Shortcuts   - Show shortcuts
  Documentation        - Open user guide

═══════════════════════════════════════════════════════════════════
TROUBLESHOOTING
═══════════════════════════════════════════════════════════════════

Problem: GUI not showing
Solution: Install tkinter: python -m tkinter
          Or check display settings

Problem: Audio not working
Solution: Check system volume
          Windows: Sound settings
          macOS: Audio permissions
          Linux: Install speaker-test

Problem: IDE not launching
Solution: Try launching directly: python ide_editor.py
          Check Python installation

Problem: Logic gate simulation issues
Solution: Ensure valid connections
          Check gate input/output ports
          Use "Clear All" to reset

═══════════════════════════════════════════════════════════════════
NEXT STEPS
═══════════════════════════════════════════════════════════════════

1. Run the launcher:
   $ python altair_launcher.py

2. Click "Full System (Enhanced UI)" to start

3. Explore the features:
   - Try the toggle switches
   - Open File > Save Output
   - Test Tools > Integrated IDE
   - Design circuits in Logic Editor

4. Write your first program:
   - File > New Program
   - Type your code
   - View output in terminal

5. Learn more:
   - Read COMPLETE_SYSTEM_DOCUMENTATION.md
   - Review example_c_program.c
   - Check out the assembly library examples

═══════════════════════════════════════════════════════════════════
HOW TO USE THE LIBRARIES
═══════════════════════════════════════════════════════════════════

ASSEMBLY:
1. Open IDE: python ide_editor.py
2. Language: Select ASM
3. Include: ; #include "asm_stdlib.asm"
4. Use functions like: CALL STRLEN, CALL MEMCPY, etc.

C/C++:
1. Open IDE or text editor
2. Write: #include "altair_stdlib.h"
3. Use: printf(), strlen(), malloc(), etc.
4. Compile with: gcc program.c -o program
5. Run: ./program

═══════════════════════════════════════════════════════════════════
KEYBOARD SHORTCUTS SUMMARY
═══════════════════════════════════════════════════════════════════

Emulator:
  SPACE       Toggle Run/Pause
  R           Reset
  H           Halt
  Q           Queue status
  0-9, A-F    Toggle switches 0-15

IDE:
  Ctrl+N      New file
  Ctrl+O      Open file
  Ctrl+S      Save file
  Ctrl+H      Help

General:
  Ctrl+I      Open IDE
  Ctrl+L      Open Logic Editor
  Ctrl+Q      Quit
  F1          Help

═══════════════════════════════════════════════════════════════════
RESOURCES & DOCUMENTATION
═══════════════════════════════════════════════════════════════════

Main Documentation:
  COMPLETE_SYSTEM_DOCUMENTATION.md  - Full system guide
  README.md                          - Overview
  API_REFERENCE.md                   - Function reference

Examples:
  example_c_program.c                - C program examples
  example_programs.asm               - Assembly examples

Libraries:
  asm_stdlib.asm                     - Assembly library
  altair_stdlib.h                    - C/C++ library

═══════════════════════════════════════════════════════════════════
QUICK REFERENCE - COMMON COMMANDS
═══════════════════════════════════════════════════════════════════

Start everything:
  $ python altair_launcher.py

Start main emulator:
  $ python altair_ui_enhanced.py

Open code editor:
  $ python ide_editor.py

Run simulator:
  $ python emulator_simulator.py

Open logic designer:
  $ python logic_gate_editor.py

View screen display:
  $ python altair_screen_interface.py

View system backplane:
  $ python altair_backplane_ui.py

═══════════════════════════════════════════════════════════════════

THAT'S IT! You're ready to use the ALTAIR 8800 Emulator v3.0!

Start with: python altair_launcher.py

Enjoy exploring this comprehensive retro computing system!

═══════════════════════════════════════════════════════════════════
"""

if __name__ == "__main__":
    print(QUICK_START)
    
    # Also try to show help in main launcher
    try:
        import tkinter as tk
        from tkinter import messagebox
        root = tk.Tk()
        root.withdraw()
        messagebox.showinfo("ALTAIR 8800 v3.0 - Quick Start", 
                          "See console output for quick start guide!\n\nRun: python altair_launcher.py")
        root.destroy()
    except:
        pass
