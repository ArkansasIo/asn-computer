# ALTAIR/OS API Reference

## Quick Start

To use the API in your program:

```asm
; Option 1: Include the API definitions
include developer_api.inc

; Option 2: Declare external functions
extern malloc_api:proc
extern print_string_api:proc
extern get_random_api:proc

; Write your main program
main:
    ; Your code here
    ret
```

---

## 1. Memory Management API

### malloc_api - Allocate Memory

**Syntax:**
```asm
mov rcx, size_in_bytes
call malloc_api
; RAX = pointer to memory block (or 0 if failed)
```

**Description:**
Allocates a block of memory on the heap.

**Parameters:**
- RCX: Number of bytes to allocate

**Returns:**
- RAX: Pointer to allocated memory (0 if allocation failed)

**Example:**
```asm
mov rcx, 256           ; Allocate 256 bytes
call malloc_api
cmp rax, 0
je malloc_failed
mov [buffer_ptr], rax  ; Save pointer
```

### free_api - Deallocate Memory

**Syntax:**
```asm
mov rcx, pointer
call free_api
```

**Example:**
```asm
mov rcx, [buffer_ptr]
call free_api
```

### memcpy_api - Copy Memory

**Syntax:**
```asm
mov rcx, destination
mov rdx, source
mov r8, size_in_bytes
call memcpy_api
```

**Example:**
```asm
mov rcx, offset dest_buffer
mov rdx, offset src_buffer
mov r8, 256
call memcpy_api
```

### memset_api - Fill Memory

**Syntax:**
```asm
mov rcx, address
mov edx, fill_value
mov r8, size_in_bytes
call memset_api
```

**Example:**
```asm
mov rcx, offset buffer
mov edx, 0
mov r8, 1024
call memset_api         ; Clear 1 KB buffer
```

### strlen_api - String Length

**Syntax:**
```asm
mov rcx, string_pointer
call strlen_api
; RAX = length of string (excluding null terminator)
```

**Example:**
```asm
mov rcx, offset my_string
call strlen_api
mov [str_length], rax
```

### strcmp_api - Compare Strings

**Syntax:**
```asm
mov rcx, string1
mov rdx, string2
call strcmp_api
; RAX = 0 (equal), <0 (s1<s2), >0 (s1>s2)
```

**Example:**
```asm
mov rcx, offset password
mov rdx, offset correct_password
call strcmp_api
cmp eax, 0
je password_correct
```

---

## 2. Input/Output API

### print_char_api - Print Single Character

**Syntax:**
```asm
mov al, character_code
call print_char_api
```

**Example:**
```asm
mov al, 'A'
call print_char_api     ; Output: A

mov al, 0Dh
call print_char_api     ; Carriage return
mov al, 0Ah
call print_char_api     ; Line feed
```

### print_string_api - Print String

**Syntax:**
```asm
mov rcx, string_pointer
call print_string_api
```

**Example:**
```asm
mov rcx, offset message
call print_string_api

section .data
    message db "Hello, ALTAIR!", 0Dh, 0Ah, 0
```

### print_hex_api - Print Hexadecimal

**Syntax:**
```asm
mov eax, value
call print_hex_api
```

**Example:**
```asm
mov eax, 0xDEADBEEF
call print_hex_api      ; Output: DEADBEEF
```

### print_decimal_api - Print Decimal

**Syntax:**
```asm
mov eax, value
call print_decimal_api
```

**Example:**
```asm
mov eax, 12345
call print_decimal_api  ; Output: 12345
```

### read_char_api - Read Single Character

**Syntax:**
```asm
call read_char_api
; AL = character read
```

**Example:**
```asm
call read_char_api
cmp al, 'Y'
je yes_selected
```

### read_line_api - Read Line of Text

**Syntax:**
```asm
mov rcx, buffer_address
mov rdx, max_length
call read_line_api
; RAX = number of characters read
```

**Example:**
```asm
mov rcx, offset input_buffer
mov rdx, 256
call read_line_api
mov [chars_read], rax
```

---

## 3. System Functions

### get_time_api - Get Current System Time

**Syntax:**
```asm
call get_time_api
; RAX = seconds since boot
; RDX = milliseconds component
```

**Example:**
```asm
call get_time_api
mov [start_time], rax
; Later...
call get_time_api
mov rbx, [start_time]
sub rax, rbx
; RAX = elapsed seconds
```

### sleep_api - Sleep for Duration

**Syntax:**
```asm
mov ecx, milliseconds
call sleep_api
```

**Example:**
```asm
mov ecx, 1000
call sleep_api          ; Sleep 1 second

mov ecx, 100
call sleep_api          ; Sleep 100 ms
```

### beep_api - Generate Sound

**Syntax:**
```asm
mov ecx, frequency_hz
mov edx, duration_ms
call beep_api
```

**Example:**
```asm
mov ecx, 1000           ; 1 kHz
mov edx, 500            ; 500 ms
call beep_api           ; 1 kHz beep for 500 ms

; Two-tone beep
mov ecx, 800
mov edx, 200
call beep_api
mov ecx, 1000
mov edx, 200
call beep_api
```

### get_random_api - Get Random Number

**Syntax:**
```asm
call get_random_api
; RAX = 32-bit random number
```

**Example:**
```asm
call get_random_api
and eax, 0xFF           ; Random 0-255
mov [random_byte], al

call get_random_api
mov ecx, 100
mov edx, 0
div ecx
mov [random_0_99], edx  ; Random 0-99
```

### exit_api - Terminate Program

**Syntax:**
```asm
mov ecx, exit_code
call exit_api
```

**Example:**
```asm
xor ecx, ecx
call exit_api           ; Exit with code 0

mov ecx, 1
call exit_api           ; Exit with code 1 (error)
```

---

## 4. LED Functions

### led_set_api - Set LED State

**Syntax:**
```asm
mov al, led_pattern
call led_set_api
```

**Description:**
Each bit controls one LED. Bit 0 = LED 0, Bit 1 = LED 1, etc.

**Example:**
```asm
mov al, 0xFF            ; All LEDs on
call led_set_api

mov al, 0x00            ; All LEDs off
call led_set_api

mov al, 0x55            ; Alternating pattern (01010101)
call led_set_api

mov al, 0x01            ; Only LED 0 on
call led_set_api
```

### led_get_api - Get LED State

**Syntax:**
```asm
call led_get_api
; AL = current LED state
```

**Example:**
```asm
call led_get_api
mov [saved_state], al
```

### led_toggle_api - Toggle LED

**Syntax:**
```asm
mov cl, led_number
call led_toggle_api
```

**Example:**
```asm
mov cl, 0
call led_toggle_api     ; Toggle LED 0

mov cl, 7
call led_toggle_api     ; Toggle LED 7
```

---

## 5. File I/O Functions

### file_open_api - Open File

**Syntax:**
```asm
mov rcx, filename_pointer
mov edx, access_mode    ; 0=read, 1=write, 2=append
call file_open_api
; RAX = file handle
```

**Example:**
```asm
mov rcx, offset filename
xor edx, edx            ; Read mode
call file_open_api
cmp rax, 0
je file_open_error
mov [file_handle], rax
```

### file_read_api - Read from File

**Syntax:**
```asm
mov rcx, file_handle
mov rdx, buffer_address
mov r8, bytes_to_read
call file_read_api
; RAX = bytes actually read
```

**Example:**
```asm
mov rcx, [file_handle]
mov rdx, offset buffer
mov r8, 256
call file_read_api
mov [bytes_read], rax
```

### file_write_api - Write to File

**Syntax:**
```asm
mov rcx, file_handle
mov rdx, buffer_address
mov r8, bytes_to_write
call file_write_api
; RAX = bytes actually written
```

**Example:**
```asm
mov rcx, [file_handle]
mov rdx, offset data
mov r8, 100
call file_write_api
```

### file_close_api - Close File

**Syntax:**
```asm
mov rcx, file_handle
call file_close_api
```

**Example:**
```asm
mov rcx, [file_handle]
call file_close_api
```

---

## 6. Debugging Functions

### debug_print - Print Debug Message

**Syntax:**
```asm
mov rcx, message_pointer
call debug_print
```

**Example:**
```asm
mov rcx, offset debug_msg
call debug_print

section .data
    debug_msg db "Debug: Value is 0x", 0
```

### assert_api - Assertion Check

**Syntax:**
```asm
mov al, condition_result
mov rcx, error_message
call assert_api
```

**Example:**
```asm
cmp eax, 0              ; Check if EAX is zero
je assertion_passed
mov al, 0               ; Assertion failed
mov rcx, offset assert_msg
call assert_api

assertion_passed:
    mov al, 1           ; Assertion passed
    call assert_api
```

### trace_api - Function Trace

**Syntax:**
```asm
mov rcx, function_name
call trace_api
```

**Example:**
```asm
my_function:
    mov rcx, offset func_name
    call trace_api
    ; Function code...
    ret

section .data
    func_name db "my_function", 0
```

---

## 7. Program Control

### yield_api - Yield CPU

**Syntax:**
```asm
call yield_api
```

**Description:**
Yields CPU time to other processes.

### get_pid_api - Get Process ID

**Syntax:**
```asm
call get_pid_api
; RAX = current process ID
```

**Example:**
```asm
call get_pid_api
mov [my_pid], rax
```

---

## Complete Example Programs

### Program 1: Counter with Display

```asm
section .data
    counter dd 0

section .text
global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    xor eax, eax
    
loop_count:
    call print_decimal_api  ; Print counter
    
    mov ecx, 500
    call sleep_api          ; Sleep 500 ms
    
    inc eax
    cmp eax, 100
    jl loop_count
    
    xor ecx, ecx
    call exit_api
```

### Program 2: File Copy Utility

```asm
section .data
    src_file db "INPUT.BIN", 0
    dst_file db "OUTPUT.BIN", 0
    buffer db 256 dup(0)

section .text
global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Open source file
    mov rcx, offset src_file
    xor edx, edx
    call file_open_api
    cmp rax, 0
    je open_error
    mov [src_handle], rax
    
    ; Open destination file
    mov rcx, offset dst_file
    mov edx, 1              ; Write mode
    call file_open_api
    mov [dst_handle], rax
    
copy_loop:
    ; Read from source
    mov rcx, [src_handle]
    mov rdx, offset buffer
    mov r8, 256
    call file_read_api
    cmp rax, 0
    je copy_done
    
    ; Write to destination
    mov rcx, [dst_handle]
    mov rdx, offset buffer
    mov r8, rax
    call file_write_api
    
    jmp copy_loop
    
copy_done:
    ; Close files
    mov rcx, [src_handle]
    call file_close_api
    
    mov rcx, [dst_handle]
    call file_close_api
    
    xor ecx, ecx
    call exit_api
    
open_error:
    mov rcx, offset error_msg
    call print_string_api
    mov ecx, 1
    call exit_api

section .data
    error_msg db "Error opening file", 0Dh, 0Ah, 0
    src_handle dq 0
    dst_handle dq 0
```

### Program 3: LED Blink Pattern

```asm
section .text
global main

main:
    push rbp
    mov rbp, rsp
    
    mov ebx, 0xFF
    
blink_loop:
    mov al, 0xFF
    call led_set_api
    
    mov ecx, 500
    call sleep_api
    
    mov al, 0x00
    call led_set_api
    
    mov ecx, 500
    call sleep_api
    
    cmp ebx, 1
    jg blink_loop
    
    xor ecx, ecx
    call exit_api
```

---

## Error Handling Reference

### Standard Error Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| -1 | Invalid parameter |
| -2 | No memory available |
| -3 | File not found |
| -4 | Disk error |
| -5 | Timeout |
| -6 | Invalid device |

### Error Checking Pattern

```asm
mov rcx, 256
call malloc_api
cmp rax, 0              ; Check for NULL
je handle_allocation_error
; Use allocated memory...

handle_allocation_error:
    mov rcx, offset error_msg
    call print_string_api
    mov ecx, -2
    call exit_api
```

---

## Optimization Tips

1. **Minimize function calls**: Buffer I/O operations
2. **Use efficient data types**: Prefer 32-bit operations over 64-bit
3. **Cache frequently accessed values**: Keep in registers
4. **Inline small functions**: Reduces overhead
5. **Optimize loops**: Minimize branches

---

## See Also

- ALTAIR_OS_COMPLETE_GUIDE.md - Comprehensive system documentation
- math_library.asm - Mathematical functions
- gui_framework.asm - Window and widget creation
- developer_api.asm - API implementation source

---

**End of API Reference**
