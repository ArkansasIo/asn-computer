# ALTAIR/OS - Complete Operating System and Development Guide

## Table of Contents
1. [System Overview](#system-overview)
2. [OS Architecture](#os-architecture)
3. [Boot Process](#boot-process)
4. [GUI Framework](#gui-framework)
5. [API Reference](#api-reference)
6. [Math Library](#math-library)
7. [Developer Tools](#developer-tools)
8. [Application Development](#application-development)
9. [Examples and Tutorials](#examples-and-tutorials)

---

## System Overview

ALTAIR/OS is a complete 16-bit operating system for the Altair 8800 emulator, providing:

- **Bootloader**: Initializes hardware and loads the kernel
- **Kernel**: Process management, memory management, interrupt handling
- **Shell**: Command-line interface and menu system
- **GUI Framework**: Windows, buttons, textboxes, dialogs
- **Device Drivers**: LED, display, keyboard, storage
- **Math Library**: Comprehensive mathematical functions
- **Developer API**: System calls for application development
- **Development Tools**: Assembler, debugger, memory editor, disassembler

### System Specifications

| Component | Specification |
|-----------|---|
| CPU Speed | 3.072 MHz (Intel 8080 simulation) |
| Memory | 64 KB total |
  - 8 KB ROM | BIOS and system code |
  - 2 KB CMOS | Configuration and RTC |
  - 54 KB RAM | Programs and data |
| Maximum Programs | 16 simultaneous processes |
| Display | 80×25 character console |
| Storage | Virtual floppy and hard drive |

---

## OS Architecture

### Memory Layout

```
+----------+ 0x0000
| INTERRUPT VECTORS |
| (256 entries, 1 KB) |
+----------+ 0x0400
| BIOS WORKSPACE |
| (1.5 KB) |
+----------+ 0x0800
| KERNEL & OS |
| (2 KB) |
+----------+ 0x1000
| SHELL & UTILITIES |
| (2 KB) |
+----------+ 0x1800
| FILE BUFFERS |
| (2 KB) |
+----------+ 0x2000
| USER PROGRAMS |
| (44 KB) |
+----------+ 0xE000
| CMOS/RTC |
| (2 KB) |
+----------+ 0xFFFF
```

### Process Table Structure

Each process occupies 32 bytes:

```
Offset | Size | Field
-------|------|------------------------
0x00   | 1    | Process state (0=free, 1=ready, 2=running, 3=blocked)
0x01   | 1    | Process ID
0x02   | 2    | Entry point address
0x04   | 2    | Stack pointer
0x06   | 2    | Program counter
0x08   | 1    | Priority
0x09   | 1    | CPU time used (ticks)
0x0A   | 1    | Parent PID
0x0B   | 1    | Exit code
0x0C   | 8    | Process name (string)
0x14   | 6    | Reserved
```

---

## Boot Process

### 1. Hardware Initialization
```
Power-on reset
  → Initialize CPU (clear registers)
  → Initialize memory (clear RAM)
  → Initialize CMOS with RTC
```

### 2. Firmware Phase
```
Load BIOS from ROM
  → Verify ROM signature
  → Check memory (16 MB test)
  → Initialize interrupt vectors
  → Load FAT from floppy
```

### 3. Kernel Initialization
```
Load kernel from disk
  → Initialize process table
  → Initialize device drivers
  → Mount filesystems
  → Load shell
```

### 4. System Ready
```
Display boot menu
  → Run shell
  → Accept user input
```

### Boot Messages
```
ALTAIR/OS v1.0
Initializing CPU...
Testing memory...
Loading kernel...
Mounting filesystems...
Starting shell...
[OK] System ready
```

---

## GUI Framework

### Supported Widgets

#### Window
```asm
create_window:
  Input:  RCX = title
          RDX = width
          R8  = height
          R9  = x position
          [SP] = y position
  Output: RAX = window handle (-1 if failed)
```

**Window Properties**
- Type: WIDGET_WINDOW (0x01)
- State: ACTIVE, MINIMIZED, MAXIMIZED, HIDDEN
- Border styles: Single, double, custom
- Title bar with close/minimize/maximize buttons
- Draggable by mouse/keyboard
- Resizable with minimum/maximum constraints

#### Button
```asm
create_button:
  Input:  RCX = parent window
          RDX = x position
          R8  = y position
          R9  = button text
          [SP] = width
  Output: RAX = button handle
```

**Button States**
- NORMAL: Default appearance
- HOVER: Highlighted when cursor over
- PRESSED: Inverted when clicked
- FOCUSED: Has keyboard input
- DISABLED: Grayed out, non-interactive

#### Textbox
```asm
create_textbox:
  Input:  RCX = parent window
          RDX = x position
          R8  = y position
          R9  = width
          [SP] = height
  Output: RAX = textbox handle
```

**Textbox Features**
- Single or multi-line
- Character insertion/deletion
- Text selection (Shift+Arrow)
- Copy/paste with Ctrl+C/V
- Maximum length enforcement
- Input masking for passwords

#### Label
```asm
create_label:
  Input:  RCX = parent window
          RDX = x position
          R8  = y position
          R9  = text
  Output: RAX = label handle
```

#### Checkbox
```asm
create_checkbox:
  Input:  RCX = parent window
          RDX = x position
          R8  = y position
          R9  = text
  Output: RAX = checkbox handle
```

#### Other Widgets
- RadioButton: Mutually exclusive selection
- ListBox: Scrollable multi-item list
- ComboBox: Dropdown list with textbox
- ProgressBar: Visual progress indicator
- Slider: Horizontal/vertical slider
- MenuBar: Menu strip with drop-down menus
- StatusBar: Status information bar
- Tab: Tabbed interface

### Dialog Boxes

```asm
show_message_box:
  Input:  RCX = title
          RDX = message text
          R8  = button type (1=OK, 2=YesNo, 3=OKCancel)
  Output: EAX = button clicked (1, 2, or 3)
```

**Button Types**
- 1: OK only
- 2: Yes, No, Cancel
- 3: OK, Cancel
- 4: Retry, Cancel
- 5: Abort, Retry, Ignore

---

## API Reference

### Memory Management

#### malloc
```asm
malloc_api:
  Input:  RCX = size in bytes
  Output: RAX = pointer to allocated block (NULL if failed)
  Errors: E_NO_MEMORY if insufficient space
```

#### free
```asm
free_api:
  Input:  RCX = pointer to block
  Output: None
```

#### memcpy
```asm
memcpy_api:
  Input:  RCX = destination
          RDX = source
          R8  = size in bytes
  Output: RAX = destination address
```

#### memset
```asm
memset_api:
  Input:  RCX = address
          EDX = fill value
          R8  = size in bytes
  Output: RAX = address
```

#### String Functions

```asm
strlen_api:         ; String length
strcmp_api:         ; String compare
strcpy_api:         ; String copy
strcat_api:         ; String concatenate
strrev_api:         ; String reverse
strupr_api:         ; Convert to uppercase
strlwr_api:         ; Convert to lowercase
```

### I/O Functions

#### Console Output

```asm
print_char_api:
  Input:  AL = character
  Output: None
  
print_string_api:
  Input:  RCX = pointer to string
  Output: None
  
print_hex_api:
  Input:  EAX = 32-bit value
  Output: None (prints as hex, e.g., "DEADBEEF")
  
print_decimal_api:
  Input:  EAX = 32-bit value
  Output: None (prints as decimal)
```

#### Console Input

```asm
read_char_api:
  Input:  None
  Output: AL = character read
  
read_line_api:
  Input:  RCX = buffer address
          RDX = maximum length
  Output: RAX = characters read
```

### System Calls

#### get_time_api
```asm
  Output: EAX = seconds since boot
          EDX = milliseconds component
```

#### sleep_api
```asm
  Input:  ECX = milliseconds to sleep
  Output: None
```

#### beep_api
```asm
  Input:  ECX = frequency in Hz (50-20000)
          EDX = duration in milliseconds
  Output: None
```

#### get_random_api
```asm
  Output: EAX = random 32-bit number
```

#### exit_api
```asm
  Input:  ECX = exit code (0-255)
  Output: (terminates program)
```

### LED Functions

```asm
led_set_api:        ; Set LEDs (AL = state)
led_get_api:        ; Get LED state
led_toggle_api:     ; Toggle specific LED
led_blink_api:      ; Blink pattern
led_animate_api:    ; Animation
```

### File I/O

```asm
file_open_api:
  Input:  RCX = filename
          RDX = flags (0=read, 1=write, 2=append)
  Output: EAX = file handle
  
file_read_api:
  Input:  ECX = file handle
          RDX = destination buffer
          R8  = bytes to read
  Output: RAX = bytes read
  
file_write_api:
  Input:  ECX = file handle
          RDX = source buffer
          R8  = bytes to write
  Output: RAX = bytes written
  
file_close_api:
  Input:  ECX = file handle
  Output: None
```

---

## Math Library

### 8-Bit Operations

```| Function | Input | Output |
|----------|-------|--------|
| add_8bit | AL, BL | AL |
| sub_8bit | AL, BL | AL |
| mul_8bit | AL, BL | AX |
| div_8bit | AL, BL | AL (quotient), AH (remainder) |
| mod_8bit | AL, BL | AH (remainder) |
```

### 16-Bit Operations

```
add_16bit: AX = AX + BX
sub_16bit: AX = AX - BX
mul_16bit: DX:AX = AX * BX
div_16bit: AX = (DX:AX) / BX, DX = remainder
mod_16bit: DX = (DX:AX) mod BX
```

### 32-Bit Operations

```
add_32bit: EAX = EAX + EBX
sub_32bit: EAX = EAX - EBX
mul_32bit: EDX:EAX = EAX * EBX
div_32bit: EAX = (EDX:EAX) / EBX, EDX = remainder
```

### 64-Bit Operations

```
add_64bit: RAX = RAX + RBX
sub_64bit: RAX = RAX - RBX
mul_64bit: RDX:RAX = RAX * RBX
div_64bit: RAX = (RDX:RAX) / RBX, RDX = remainder
```

### Advanced Functions

```
power_32bit(base, exp) → result
factorial(n) → n!
fibonacci(n) → fib(n)
gcd(a, b) → greatest common divisor
lcm(a, b) → least common multiple
sqrt(x) → √x
cbrt(x) → ∛x
sin(degrees) → sine (scaled 1000)
cos(degrees) → cosine (scaled 1000)
log10(x) → log₁₀(x)
ln(x) → natural logarithm
round(x) → nearest integer
floor(x) → round down
ceil(x) → round up
```

### Statistics

```
calculate_mean(array, count) → average
calculate_variance(array, count, mean) → variance
calculate_stddev(array, count, mean) → standard deviation
```

### Vector Operations

```
dot_product(v1, v2, count) → dot product
magnitude(v, count) → ||v||
normalize(v, count) → unit vector
cross_product(v1, v2) → v1 × v2
```

### Matrix Operations

```
transpose_matrix(src, dst, rows, cols)
matrix_multiply(A, B, C, m, n, p)
matrix_determinant(matrix, size) → det
matrix_inverse(src, dst, size)
```

### Complex Numbers

```
complex_multiply(a, b, c, d) → (ac-bd) + (ad+bc)i
complex_divide(a, b, c, d) → result
complex_magnitude(a, b) → |a+bi|
```

---

## Developer Tools

### Assembler

The built-in assembler allows on-system code assembly.

```
Available:
- One-pass assembly
- Symbol tables
- Macro expansion
- Include files
- Conditional assembly
- Label resolution
```

### Debugger

Interactive debugging:

```
Commands:
  b address     - Set breakpoint
  c             - Continue execution
  s             - Step single instruction
  r             - Show registers
  m address     - Show memory
  t             - Trace stack
  q             - Quit debugger
```

### Memory Editor

Hexadecimal memory editor:

```
- View/edit memory in hex and ASCII
- Search for byte patterns
- Fill memory regions
- Copy/paste memory blocks
```

### Disassembler

Reverse code from memory:

```
- Display assembly from memory addresses
- Symbol lookup
- Cross-reference display
- Export disassembly to file
```

### Profiler

Performance analysis:

```
- Instruction count tracking
- Function call profiling
- Memory allocation tracking
- CPU time per function
```

---

## Application Development

### Program Structure

```asm
; Include API definitions
include altair_api.inc

; Define program header (optional)
program_header:
    db "ALTAIR"                 ; Signature
    dw 0x0100                   ; Version 1.0
    db PROG_TYPE_UTILITY        ; Program type
    dd main                     ; Entry point
    dw 0x1000                   ; Stack size
    dw 0x2000                   ; Heap size

; Data section
section .data
    message db "Hello, Altair!", 0
    counter dd 0

; Code section
section .text
    main:
        mov rax, offset message
        call print_string_api
        
        mov ecx, 1000
        call sleep_api
        
        mov ecx, 0
        call exit_api
```

### Minimal Program Template

```asm
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Program code here
    
    add rsp, 32
    pop rbp
    mov ecx, 0
    call exit_api
```

### Using the Math Library

```asm
include math_library.inc

main:
    ; Calculate factorial
    mov eax, 5
    call factorial          ; EAX = 120
    
    ; Calculate square root
    mov eax, 144
    call sqrt              ; EAX = 12
    
    ; Calculate sine
    mov eax, 45            ; degrees
    call sin_degrees       ; EAX = sin(45°)
```

### Allocating Memory

```asm
main:
    ; Allocate 256 bytes
    mov rcx, 256
    call malloc_api        ; RAX = pointer
    
    ; Use memory
    mov qword ptr [rax], 0x1234567890ABCDEF
    
    ; Free memory
    call free_api
```

---

## Examples and Tutorials

### Example 1: Simple Counter

```asm
main:
    xor eax, eax           ; Counter = 0
    
counter_loop:
    ; Print counter value
    call print_decimal_api
    
    ; Wait 1 second
    mov ecx, 1000
    call sleep_api
    
    ; Increment
    inc eax
    
    ; Continue if < 100
    cmp eax, 100
    jl counter_loop
    
    ; Exit
    xor ecx, ecx
    call exit_api
```

### Example 2: Factorial Calculator

```asm
main:
    ; Calculate 5!
    mov eax, 5
    call factorial
    
    ; Print result
    call print_decimal_api
    
    xor ecx, ecx
    call exit_api
```

### Example 3: LED Animation

```asm
main:
    mov ebx, 0
    
led_loop:
    ; Set LED pattern
    mov al, bl
    call led_set_api
    
    ; Wait
    mov ecx, 100
    call sleep_api
    
    ; Rotate pattern
    rol al, 1
    mov bl, al
    
    cmp ebx, 0
    jne led_loop
    
    xor ecx, ecx
    call exit_api
```

### Example 4: String Operations

```asm
main:
    lea rax, [hello_str]
    call print_string_api
    
    lea rax, [world_str]
    call print_string_api
    
    xor ecx, ecx
    call exit_api

section .data
    hello_str db "Hello, ", 0
    world_str db "World!", 0Dh, 0Ah, 0
```

---

## Error Handling

### Error Codes

```
#define E_SUCCESS       0
#define E_INVALID_PARAM -1
#define E_NO_MEMORY    -2
#define E_FILE_NOT_FOUND -3
#define E_DISK_ERROR   -4
#define E_TIMEOUT      -5
#define E_INVALID_DEVICE -6
```

### Exception Handling

```asm
try_block:
    mov rax, offset file_path
    mov edx, 0                  ; Read mode
    call file_open_api
    
    cmp eax, 0
    jl error_handler            ; Jump if error
    
    ; File operations
    
    jmp try_done
    
error_handler:
    ; Handle error
    lea rax, [error_msg]
    call print_string_api
    
try_done:
    xor ecx, ecx
    call exit_api

section .data
    error_msg db "Error opening file", 0Dh, 0Ah, 0
    file_path db "FILE.BIN", 0
```

---

## Performance Optimization

### Tips

1. **Minimize system calls**: Batch operations
2. **Use registers efficiently**: RAX-R15 are available
3. **Avoid memory access**: Keep hot data in registers
4. **Use SIMD-like patterns**: MMX instructions where available
5. **Inline small functions**: Reduce call overhead
6. **Optimize loops**: Minimize branch mispredictions

### Profiling

```asm
profile_start:
    call get_time_api           ; EAX = start time
    mov [start_tick], eax
    
    ; Code to profile
    
    call get_time_api
    mov ebx, [start_tick]
    sub eax, ebx
    call print_decimal_api      ; Display elapsed time
```

---

## Conclusion

ALTAIR/OS provides a complete development environment for the Altair 8800 emulator. With the comprehensive API, math library, and GUI framework, developers can create sophisticated applications efficiently using assembly language.

For questions or additional documentation, refer to the system guides and API reference files included in the distribution.

**Happy coding on ALTAIR/OS!**
