# ALTAIR/OS Developer Guide

Complete guide for developing applications for ALTAIR/OS.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Project Structure](#project-structure)
3. [Building Applications](#building-applications)
4. [Debugging Techniques](#debugging-techniques)
5. [Best Practices](#best-practices)
6. [Common Patterns](#common-patterns)
7. [Troubleshooting](#troubleshooting)

---

## Getting Started

### System Requirements

- ALTAIR/OS bootloader running
- Development tools installed
- Minimum 256 bytes work memory
- Text editor (built-in) or external

### Development Workflow

```
1. Create source file (*.asm)
   ↓
2. Assemble with built-in assembler
   ↓
3. Link if multiple modules
   ↓
4. Load into memory
   ↓
5. Debug and test
   ↓
6. Optimize if needed
   ↓
7. Package and distribute
```

---

## Project Structure

### Minimal Project

```
myapp/
├── main.asm          ; Main program file
└── README.txt        ; Documentation
```

### Medium Project

```
myapp/
├── src/
│  ├── main.asm       ; Entry point
│  ├── utils.asm      ; Utility functions
│  └── math.asm       ; Math operations
├── include/
│  ├── defs.inc       ; Data structures
│  └── macros.inc     ; Macro definitions
├── data/
│  └── resources.bin  ; Data files
├── build.bat         ; Build script
└── README.md         ; Documentation
```

### Large Project

```
myapp/
├── doc/              ; Documentation
├── src/
│  ├── core/
│  │  ├── main.asm
│  │  ├── kernel.asm
│  │  └── shell.asm
│  ├── drivers/
│  │  ├── led.asm
│  │  ├── display.asm
│  │  └── storage.asm
│  └── utils/
│     ├── math.asm
│     ├── strings.asm
│     └── io.asm
├── include/
│  ├── api.inc
│  ├── constants.inc
│  └── structures.inc
├── test/             ; Test programs
├── build.bat
├── link.bat
└── version.txt
```

---

## Building Applications

### Single-File Assembly

```bash
; In ALTAIR/OS Developer Console:

1. Load assembler:
   > ASSEMBLER

2. Load source:
   > LOAD myprogram.asm

3. Assemble:
   > ASSEMBLE

4. Run:
   > RUN

5. Exit:
   > EXIT
```

### Multi-File Project Using Build Script

Create `build.bat`:

```batch
@echo off
REM ALTAIR/OS Build Script

echo Building ALTAIR application...

REM Assemble main module
ml64 /c src\main.asm /Fo obj\main.obj

REM Assemble additional modules
ml64 /c src\utils.asm /Fo obj\utils.obj
ml64 /c src\math.asm /Fo obj\math.obj

REM Link all modules
link /SUBSYSTEM:CONSOLE /OUT:bin\myapp.exe ^
        obj\main.obj obj\utils.obj obj\math.obj ^
        kernel32.lib

echo Build complete. Output: bin\myapp.exe
```

### Command-Line Assembly

```asm
; Template for command-line assembly

; Define symbols for cross-platform compatibility
ifdef _WIN64
    ; Windows x64
else
    ; Other platforms
endif

; Include necessary files
include \inc\kernel32.inc
includelib \lib\kernel32.lib

; Your code here
.code
main proc
    ; Application code
    ret
main endp

end

; To assemble:
; ml64 /c myprogram.asm /Fo myprogram.obj
; link myprogram.obj kernel32.lib /OUT:myprogram.exe
```

### Using Macros

Create `macros.inc`:

```asm
; Macro definitions

; Print constant string
PRINT_CONST macro str_address
    mov rcx, str_address
    call print_string_api
endm

; Print character
PRINT_CHAR macro char_code
    mov al, char_code
    call print_char_api
endm

; Sleep for duration
SLEEP macro ms
    mov ecx, ms
    call sleep_api
endm

; Beep sound
BEEP macro freq, duration
    mov ecx, freq
    mov edx, duration
    call beep_api
endm

; Set LED pattern
SETLED macro pattern
    mov al, pattern
    call led_set_api
endm

; Exit program
EXIT_PROG macro code
    mov ecx, code
    call exit_api
endm

; Allocate memory
MALLOC macro size, result_var
    mov rcx, size
    call malloc_api
    mov result_var, rax
endm
```

Use in program:

```asm
include macros.inc

section .data
    greeting db "Hello, ALTAIR!", 0Dh, 0Ah, 0

section .text
main:
    PRINT_CONST offset greeting
    SLEEP 1000
    BEEP 1000, 500
    EXIT_PROG 0
```

---

## Debugging Techniques

### Using Debug Print

```asm
; Print debug messages at key points

main:
    ; Function entry
    mov rcx, offset msg1
    call debug_print
    
    ; Initialize
    xor eax, eax
    
    ; Loop debug
loop_start:
    mov rcx, offset msg2
    call debug_print
    
    inc eax
    cmp eax, 10
    jl loop_start
    
    ; Function exit
    mov rcx, offset msg3
    call debug_print
    
    xor ecx, ecx
    call exit_api

section .data
    msg1 db "[DEBUG] main() entered", 0Dh, 0Ah, 0
    msg2 db "[DEBUG] Loop iteration", 0Dh, 0Ah, 0
    msg3 db "[DEBUG] main() exiting", 0Dh, 0Ah, 0
```

### Memory Inspection

```asm
; Check memory contents

main:
    ; Allocate memory
    mov rcx, 256
    call malloc_api
    mov [ptr], rax
    
    ; Fill with pattern
    mov rcx, [ptr]
    mov edx, 0xAA
    mov r8, 256
    call memset_api
    
    ; Debug: Check memory
    mov rax, [ptr]
    call print_hex_api      ; Print pointer
    
    ; Verify content
    mov ebx, [rax]
    call print_hex_api      ; Print first 4 bytes
    
    xor ecx, ecx
    call exit_api

section .data
    ptr dq 0
```

### Register Inspection

```asm
; Print register values for debugging

main:
    mov eax, 0x12345678
    mov ebx, 0x9ABCDEF0
    mov ecx, 0x11223344
    
    ; Print values
    call print_hex_api      ; Print EAX
    mov eax, ebx
    call print_hex_api      ; Print EBX
    mov eax, ecx
    call print_hex_api      ; Print ECX
    
    xor ecx, ecx
    call exit_api
```

### Using Breakpoints (Simulator)

```asm
main:
    ; ... code ...
    
    ; Insert breakpoint
    int 3                   ; INT3 instruction
    
    ; ... more code ...
```

---

## Best Practices

### 1. Use Consistent Naming

```asm
; Good:
calculate_sum:
    ; Clear naming convention

; Bad:
cs:                        ; Ambiguous

; Variables:
byte_counter db 0         ; Clearly a byte counter
dword_total dd 0          ; Clearly a 32-bit total
string_buffer db 256 dup(0)  ; Clear purpose
```

### 2. Comment Your Code

```asm
; Purpose: Calculate power
; Input: EAX = base, EBX = exponent
; Output: EAX = base^exponent
; Registers changed: RAX, RBX, RCX, RDX

power_calc:
    mov ecx, eax
    mov eax, 1
    
    cmp ebx, 0
    je power_exit
    
power_loop:
    mul ecx
    dec ebx
    cmp ebx, 0
    jne power_loop
    
power_exit:
    ret
```

### 3. Handle Errors Properly

```asm
; Always check return values

main:
    ; Allocate memory
    mov rcx, 1024
    call malloc_api
    cmp rax, 0
    je malloc_error
    mov [buffer], rax
    
    ; Open file
    mov rcx, offset filename
    xor edx, edx
    call file_open_api
    cmp rax, 0
    je file_open_error
    mov [file_handle], rax
    
    ; ... continue ...
    
    jmp main_exit
    
malloc_error:
    mov rcx, offset msg_mem_error
    call print_string_api
    mov ecx, -2
    call exit_api
    
file_open_error:
    mov rcx, offset msg_file_error
    call print_string_api
    mov ecx, -3
    call exit_api
    
main_exit:
    xor ecx, ecx
    call exit_api

section .data
    msg_mem_error db "Memory allocation failed", 0Dh, 0Ah, 0
    msg_file_error db "File open failed", 0Dh, 0Ah, 0
```

### 4. Preserve Registers Properly

```asm
; Save and restore non-volatile registers

my_function:
    push rbp
    mov rbp, rsp
    
    ; Save registers that will be modified
    push rbx
    push r12
    
    ; ... use RBX and R12 ...
    
    ; Restore registers
    pop r12
    pop rbx
    
    pop rbp
    ret
```

### 5. Use Stack Frames

```asm
; Allocate local variables on stack

calculate_average:
    push rbp
    mov rbp, rsp
    sub rsp, 32            ; 32 bytes of local space
    
    ; [RBP-8]: local variable 1
    ; [RBP-16]: local variable 2
    ; [RBP-24]: local variable 3
    ; [RBP-32]: local variable 4
    
    mov qword ptr [rbp-8], 0  ; Initialize local var
    
    ; ... function code ...
    
    add rsp, 32
    pop rbp
    ret
```

### 6. Document Interfaces

```asm
; Function: find_character
; Purpose: Find first occurrence of character in string
; Input:
;   RCX = String pointer (null-terminated)
;   DL = Character to find
; Output:
;   RAX = Pointer to character (NULL if not found)
;   RX = Position in string (0-based)
; Registers modified: RAX, RDX
; Notes:
;   Case-sensitive search
;   String must be null-terminated

find_character:
    xor rax, rax
    
loop_search:
    mov al, byte ptr [rcx]
    cmp al, 0
    je not_found
    cmp al, dl
    je found
    inc rcx
    inc rax
    jmp loop_search
    
found:
    mov rax, rcx
    ret
    
not_found:
    xor rax, rax
    ret
```

---

## Common Patterns

### Pattern 1: Input Validation Loop

```asm
get_valid_number:
    
input_loop:
    mov rcx, offset prompt
    call print_string_api
    
    call read_line_api
    
    ; Validate number (simplified)
    mov rax, [input_buffer]
    cmp al, '0'
    jl input_loop
    cmp al, '9'
    jg input_loop
    
    ; Valid number entered
    sub al, '0'
    ret
```

### Pattern 2: State Machine

```asm
; Simple traffic light state machine

state_machine:
    mov [state], STATE_RED
    
state_loop:
    mov al, [state]
    
    cmp al, STATE_RED
    je handle_red
    cmp al, STATE_YELLOW
    je handle_yellow
    cmp al, STATE_GREEN
    je handle_green
    
    jmp state_done
    
handle_red:
    mov al, 0xFF            ; Red LED pattern
    call led_set_api
    mov ecx, 5000
    call sleep_api
    mov byte ptr [state], STATE_GREEN
    jmp state_loop
    
handle_yellow:
    mov al, 0x0F            ; Yellow LED pattern
    call led_set_api
    mov ecx, 2000
    call sleep_api
    mov byte ptr [state], STATE_RED
    jmp state_loop
    
handle_green:
    mov al, 0x F0           ; Green LED pattern
    call led_set_api
    mov ecx, 5000
    call sleep_api
    mov byte ptr [state], STATE_YELLOW
    jmp state_loop
    
state_done:
    ret

; Constants
STATE_RED equ 0
STATE_YELLOW equ 1
STATE_GREEN equ 2
```

### Pattern 3: Circular Buffer

```asm
; Simple circular buffer implementation

buffer_init:
    mov qword ptr [buffer_head], offset buffer_data
    mov qword ptr [buffer_tail], offset buffer_data
    mov dword ptr [buffer_count], 0
    ret

buffer_push:
    ; Input: AL = byte to push
    ; Check if full
    cmp dword ptr [buffer_count], BUFFER_SIZE
    jge buffer_full
    
    ; Insert at head
    mov rax, [buffer_head]
    mov [rax], bl
    
    ; Advance head
    add qword ptr [buffer_head], 1
    cmp qword ptr [buffer_head], offset buffer_data + BUFFER_SIZE
    jl buffer_wrap_skip
    mov qword ptr [buffer_head], offset buffer_data
    
buffer_wrap_skip:
    inc dword ptr [buffer_count]
    ret
    
buffer_full:
    ; Handle full buffer
    stc                     ; Set carry flag for error
    ret

buffer_pop:
    ; Output: AL = byte popped
    ; Check if empty
    cmp dword ptr [buffer_count], 0
    je buffer_empty
    
    ; Remove from tail
    mov rax, [buffer_tail]
    mov al, [rax]
    
    ; Advance tail
    add qword ptr [buffer_tail], 1
    cmp qword ptr [buffer_tail], offset buffer_data + BUFFER_SIZE
    jl buffer_pop_wrap_skip
    mov qword ptr [buffer_tail], offset buffer_data
    
buffer_pop_wrap_skip:
    dec dword ptr [buffer_count]
    clc                     ; Clear carry for success
    ret
    
buffer_empty:
    stc                     ; Set carry flag for error
    ret

; Constants
BUFFER_SIZE equ 256

; Data
buffer_head dq 0
buffer_tail dq 0
buffer_count dd 0
buffer_data db BUFFER_SIZE dup(0)
```

### Pattern 4: Linked List

```asm
; Simplified linked list node

; Node structure (16 bytes):
; Offset 0: Data (8 bytes)
; Offset 8: Next pointer (8 bytes)

list_insert:
    ; Input: RCX = pointer to insert after
    ;        RDX = data
    
    ; Allocate new node
    mov r8, 16
    call malloc_api
    
    ; Set data
    mov qword ptr [rax], rdx
    
    ; Link nodes
    mov r9, [rcx+8]
    mov [rax+8], r9
    mov [rcx+8], rax
    
    ret

list_remove:
    ; Input: RCX = pointer to node before one to remove
    
    mov rax, [rcx+8]
    mov rdx, [rax+8]
    mov [rcx+8], rdx
    
    call free_api
    
    ret
```

---

## Troubleshooting

### Issue: Program Won't Start

**Causes:**
1. Entry point not defined
2. Missing include files
3. Stack corruption

**Solution:**
```asm
; Ensure proper entry point
main:
    ; or
main proc
    ; code
    ret
main endp
```

### Issue: Memory Leak

**Causes:**
1. Allocated memory never freed
2. Lost pointer reference

**Solution:**
```asm
; Always pair malloc with free
mov rcx, 256
call malloc_api
mov [ptr], rax

; ... use memory ...

mov rcx, [ptr]
call free_api
```

### Issue: Register Corruption

**Causes:**
1. Overwriting registers without saving
2. Function modifying unexpected registers

**Solution:**
```asm
; Save registers at function entry
my_func:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    ; ... code ...
    
    pop r12
    pop rbx
    pop rbp
    ret
```

### Issue: Infinite Loop

**Causes:**
1. Condition never becomes false
2. Branch misprediction

**Solution:**
```asm
; Add safeguard counter
mov ecx, MAX_ITERATIONS

loop_start:
    ; ... loop code ...
    
    dec ecx
    cmp ecx, 0
    je loop_timeout
    
    ; Check loop condition
    cmp eax, target
    jne loop_start
    
loop_timeout:
    ; Handle timeout
    ret
```

---

## Performance Profiling

```asm
; Profile a code section

profile_section:
    call get_time_api
    mov [time_start], rax
    
    ; Code to profile
    mov ecx, 1000
    call sleep_api
    
    call get_time_api
    mov rbx, [time_start]
    sub rax, rbx
    
    mov rcx, offset result_msg
    call print_string_api
    call print_decimal_api
    
    ret

section .data
    time_start dq 0
    result_msg db "Elapsed: ", 0
```

---

## Conclusion

This guide provides the foundations for developing applications on ALTAIR/OS. Continue learning by studying existing programs and experimenting with different techniques.

**Happy coding!**
