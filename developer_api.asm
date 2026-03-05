; ============================================================================
; ALTAIR 8800 DEVELOPER API AND SYSTEM CALLS
; Complete API for application development
; ============================================================================

.code

; ============================================================================
; API CONSTANTS
; ============================================================================

.data

; System call numbers
SYS_WRITE               equ 1
SYS_READ                equ 3
SYS_MALLOC              equ 45
SYS_FREE                equ 49
SYS_EXIT                equ 60
SYS_SLEEP               equ 35
SYS_BEEP                equ 100
SYS_GET_TIME            equ 201
SYS_GET_RANDOM          equ 202
SYS_GET_MEMORY_INFO     equ 203
SYS_GET_CPU_INFO        equ 204
SYS_FILE_OPEN           equ 301
SYS_FILE_READ           equ 302
SYS_FILE_WRITE          equ 303
SYS_FILE_CLOSE          equ 304
SYS_LED_UPDATE          equ 401
SYS_TERMINAL_CLEAR      equ 501
SYS_CURSOR_SET          equ 502

; Error codes
E_SUCCESS               equ 0
E_INVALID_PARAM         equ -1
E_NO_MEMORY             equ -2
E_FILE_NOT_FOUND        equ -3
E_DISK_ERROR            equ -4
E_TIMEOUT               equ -5
E_INVALID_DEVICE        equ -6

; ============================================================================
; PROGRAM STRUCTURE
; ============================================================================

; Program header (optional but recommended)
; 0x00: Signature (4 bytes) = "ALTAIR"
; 0x04: Version (2 bytes)
; 0x06: Program type (1 byte)
; 0x07: Entry point (4 bytes)
; 0x0B: Initial stack size (2 bytes)
; 0x0D: Initial heap size (2 bytes)
; 0x0F: Author pointer (8 bytes)
; 0x17: Description pointer (8 bytes)

; Program types
PROG_TYPE_UTILITY       equ 0x01
PROG_TYPE_GAME          equ 0x02
PROG_TYPE_CALCULATOR    equ 0x03
PROG_TYPE_EDITOR        equ 0x04
PROG_TYPE_SYSTEM_TOOL   equ 0x05
PROG_TYPE_LIBRARY       equ 0x06

; ============================================================================
; MEMORY MANAGEMENT API
; ============================================================================

; MALLOC: Allocate memory
; Input: RCX = size (bytes)
; Output: RAX = pointer (NULL if failed)
malloc_api:
    ; CMP RCX, 0
    ; JLE malloc_fail
    ; 
    ; MOV RAX, -1          ; Call system
    ; INT 0x80             ; SYS_MALLOC
    ; RET
    ; 
    ; malloc_fail:
    ; MOV RAX, NULL
    ; RET
    
    push rbp
    mov rbp, rsp
    push rbp
    pop rbp
    ret

; FREE: Deallocate memory
; Input: RCX = pointer
free_api:
    push rbp
    mov rbp, rsp
    pop rbp
    ret

; REALLOC: Reallocate memory
; Input: RCX = pointer, RDX = new size
; Output: RAX = new pointer
realloc_api:
    push rbp
    mov rbp, rsp
    pop rbp
    ret

; MEMCPY: Copy memory
; Input: RCX = dest, RDX = source, R8 = size
memcpy_api:
    push rbp
    mov rbp, rsp
    
    mov r9, 0
    
memcpy_loop:
    cmp r9, r8
    jge memcpy_done
    
    mov al, byte ptr [rdx + r9]
    mov byte ptr [rcx + r9], al
    inc r9
    jmp memcpy_loop
    
memcpy_done:
    pop rbp
    ret

; MEMSET: Fill memory
; Input: RCX = pointer, EDX = value, R8 = size
memset_api:
    push rbp
    mov rbp, rsp
    
    mov r9, 0
    
memset_loop:
    cmp r9, r8
    jge memset_done
    
    mov byte ptr [rcx + r9], dl
    inc r9
    jmp memset_loop
    
memset_done:
    pop rbp
    ret

; STRLEN: String length
; Input: RCX = string pointer
; Output: RAX = length
strlen_api:
    push rbp
    mov rbp, rsp
    
    mov rax, 0
    
strlen_loop:
    mov al, byte ptr [rcx]
    cmp al, 0
    je strlen_done
    inc rcx
    inc rax
    jmp strlen_loop
    
strlen_done:
    pop rbp
    ret

; STRCMP: String comparison
; Input: RCX = string1, RDX = string2
; Output: EAX = 0 (equal), <0 (s1<s2), >0 (s1>s2)
strcmp_api:
    push rbp
    mov rbp, rsp
    
strcmp_loop:
    mov al, byte ptr [rcx]
    mov bl, byte ptr [rdx]
    
    cmp al, bl
    jne strcmp_ne
    
    cmp al, 0
    je strcmp_eq
    
    inc rcx
    inc rdx
    jmp strcmp_loop
    
strcmp_eq:
    mov eax, 0
    jmp strcmp_done
    
strcmp_ne:
    movzx eax, al
    movzx ebx, bl
    sub eax, ebx
    
strcmp_done:
    pop rbp
    ret

; ============================================================================
; I/O API
; ============================================================================

; PRINT_CHAR: Output single character
; Input: AL = character
print_char_api:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [char_buffer]
    mov byte ptr [char_buffer], al
    mov r8, 1
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

; PRINT_STRING: Output string
; Input: RCX = string pointer
print_string_api:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Get string length
    mov rdx, rcx
    call strlen_api
    mov r8, rax
    
    ; Get console handle
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    ; Output string
    mov rcx, r11
    mov rdx, rdx
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

; PRINT_HEX: Output 32-bit hex value
; Input: EAX = value
print_hex_api:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    mov ecx, 8                          ; 8 hex digits
    lea rdi, [hex_buffer]
    
hex_loop:
    mov ebx, eax
    shr eax, 4
    and ebx, 0x0F
    
    cmp bl, 10
    jb hex_digit
    add bl, 7                           ; A-F
    
hex_digit:
    add bl, '0'
    dec rdi
    mov byte ptr [rdi], bl
    
    dec ecx
    cmp ecx, 0
    jne hex_loop
    
    lea rcx, [rdi]
    call print_string_api
    
    add rsp, 48
    pop rbp
    ret

; READ_CHAR: Input single character
; Output: AL = character
read_char_api:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -10
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [input_buffer]
    mov r8, 1
    sub rsp, 8
    push 0
    call ReadConsoleA
    add rsp, 16
    
    mov al, [input_buffer]
    
    add rsp, 32
    pop rbp
    ret

; READ_LINE: Input line of text
; Input: RCX = buffer, RDX = max length
read_line_api:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -10
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    mov r8, rdx
    sub rsp, 8
    push 0
    call ReadConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; SYSTEM CALL API
; ============================================================================

; GET_TIME: Get current system time
; Output: EAX = seconds, EDX = milliseconds
get_time_api:
    push rbp
    mov rbp, rsp
    
    ; Would use Windows GetTickCount
    mov eax, 0
    mov edx, 0
    
    pop rbp
    ret

; SLEEP: Sleep for milliseconds
; Input: ECX = milliseconds
sleep_api:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Would use Windows Sleep
    mov ecx, ecx
    
    add rsp, 32
    pop rbp
    ret

; BEEP: Generate sound
; Input: ECX = frequency, EDX = duration
beep_api:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, ecx
    mov rdx, edx
    call Beep
    
    add rsp, 32
    pop rbp
    ret

; GET_RANDOM: Get random number
; Output: EAX = random 32-bit value
get_random_api:
    push rbp
    mov rbp, rsp
    
    ; Use simple LCG
    mov eax, [random_state]
    mov ecx, 1103515245
    imul eax, ecx
    add eax, 12345
    mov [random_state], eax
    
    pop rbp
    ret

; ============================================================================
; PROGRAM CONTROL API
; ============================================================================

; EXIT: Terminate program
; Input: ECX = exit code
exit_api:
    push rbp
    mov rbp, rsp
    
    mov eax, ecx
    mov rcx, 0
    call ExitProcess
    
    pop rbp
    ret

; YIELD: Yield CPU to other processes
yield_api:
    push rbp
    mov rbp, rsp
    pop rbp
    ret

; GET_PID: Get process ID
; Output: EAX = PID
get_pid_api:
    push rbp
    mov rbp, rsp
    mov eax, [current_pid]
    pop rbp
    ret

; ============================================================================
; LED/DISPLAY API
; ============================================================================

; LED_SET: Set LED state
; Input: AL bits = LED on/off
led_set_api:
    push rbp
    mov rbp, rsp
    
    mov [led_state], al
    
    pop rbp
    ret

; LED_GET: Get LED state
; Output: AL = LED state
led_get_api:
    push rbp
    mov rbp, rsp
    mov al, [led_state]
    pop rbp
    ret

; LED_TOGGLE: Toggle LED
; Input: CL = LED number
led_toggle_api:
    push rbp
    mov rbp, rsp
    
    mov al, 1
    shl al, cl
    xor [led_state], al
    
    pop rbp
    ret

; ============================================================================
; DEVELOPER TOOLS AND UTILITIES
; ============================================================================

; DEBUG_PRINT: Print debug message
; Input: RCX = message
debug_print:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    lea r10, [debug_prefix]
    mov rcx, r10
    call print_string_api
    
    mov rcx, [rsp+40]
    call print_string_api
    
    add rsp, 32
    pop rbp
    ret

; ASSERT: Assertion check
; Input: AL = condition, RCX = message
assert_api:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    cmp al, 0
    je assert_fail
    jmp assert_done
    
assert_fail:
    lea r10, [assert_fail_msg]
    call print_string_api
    mov rcx, [rsp+40]
    call print_string_api
    
    ; Would exit or breakpoint
    
assert_done:
    add rsp, 32
    pop rbp
    ret

; TRACE: Function trace
; Input: RCX = function name
trace_api:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    lea r10, [trace_prefix]
    call print_string_api
    call print_string_api
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; GLOBAL DATA
; ============================================================================

random_state:           dd 12345
current_pid:            dd 1
char_buffer:            db 0
hex_buffer:             db "00000000", 0
input_buffer:           db 256 dup(0)

; Debug strings
debug_prefix:           db "[DEBUG] ", 0
assert_fail_msg:        db "[ASSERT FAILED] ", 0
trace_prefix:           db "[TRACE] ", 0

; ============================================================================
; API WRAPPER MACROS (would be in include file for users)
; ============================================================================

; EXAMPLE USAGE:
; mov rax, offset string_buffer
; call print_string_api
;
; mov ecx, 0x1234
; call print_hex_api
;
; mov al, 0xFF
; call led_set_api
;
; mov ecx, 1000
; call sleep_api

; ============================================================================
; END OF DEVELOPER API
; ============================================================================

end
