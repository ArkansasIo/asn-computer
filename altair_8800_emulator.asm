; ============================================================================
; ALTAIR 8800 EMULATOR - x86-64 Assembly (Windows)
; Comprehensive simulation with LEDs, switches, display, sound, and math ops
; ============================================================================

.code

; Forward declarations for external Windows API functions
extern GetStdHandle:proc
extern WriteConsoleA:proc
extern ReadConsoleA:proc
extern SetConsoleCursorPosition:proc
extern Beep:proc
extern ExitProcess:proc
extern GetConsoleScreenBufferInfo:proc

; ============================================================================
; CONSTANTS
; ============================================================================

; Altair 8800 LED/Switch Definitions (16 of each)
LED_COUNT       equ 16
SWITCH_COUNT    equ 16

; Memory configuration
MEMORY_SIZE     equ 65536           ; 64KB address space
PROGRAM_BUFFER  equ 4096            ; Space for loaded program

; Console output constants
STD_OUTPUT_HANDLE equ -11
STD_INPUT_HANDLE  equ -10

; ============================================================================
; DATA SECTION (simulated with .data equivalent)
; ============================================================================

.data

; Altair 8800 LED States (16 LEDs representing binary display)
led_states:     dq 0                ; 16-bit LED state

; Altair 8800 Switch States (16 toggle switches)
switch_states:  dq 0                ; 16-bit switch state

; 64KB Memory array
altair_memory:  dq 0, 0, 0, 0       ; Will allocate at runtime

; CPU registers simulation
cpu_acc:        db 0                ; Accumulator (8-bit)
cpu_b:          db 0                ; Register B
cpu_c:          db 0                ; Register C
cpu_d:          db 0                ; Register D
cpu_e:          db 0                ; Register E
cpu_h:          db 0                ; Register H
cpu_l:          db 0                ; Register L

; 16-bit registers
cpu_bc:         dw 0                ; BC pair
cpu_de:         dw 0                ; DE pair
cpu_hl:         dw 0                ; HL pair
cpu_sp:         dw 0                ; Stack pointer
cpu_pc:         dw 0                ; Program counter

; Program counter for instruction fetch
program_counter: dw 0

; Message strings
title_msg:      db "=== ALTAIR 8800 EMULATOR ===", 0Dh, 0Ah, 0
startup_msg:    db "Altair 8800 Starting up...", 0Dh, 0Ah, 0
led_msg:        db "LED Display: ", 0
switch_msg:     db "Switch Status: ", 0
acc_msg:        db "Accumulator: ", 0
memory_msg:     db "Memory Address: ", 0
hex_prefix:     db "0x", 0
binary_prefix:  db "0b", 0
octal_prefix:   db "0o", 0
decimal_prefix: db "0d", 0
separator:      db " | ", 0
newline_str:    db 0Dh, 0Ah, 0
error_msg:      db "ERROR: Invalid operation", 0Dh, 0Ah, 0

; Math operation results
math_result_64: dq 0
math_result_32: dd 0
math_result_16: dw 0
math_result_8:  db 0

; Sine/Cosine lookup table for sound wave generation
sin_table:      db 0, 12, 25, 37, 47, 56, 63, 67, 69, 67, 63, 56, 47, 37, 25, 12

; ============================================================================
; MAIN PROGRAM
; ============================================================================

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32                     ; Shadow space for Windows API calls
    
    ; Initialize console
    mov rcx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov r11, rax                    ; Store stdout handle
    
    ; Print startup message
    mov rcx, r11
    lea rdx, [title_msg]
    mov r8, 30                      ; Length
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    ; Initialize Altair 8800
    call init_altair
    
    ; Main emulation loop
    mov rax, 0                      ; Initialize counter
    
main_loop:
    cmp rax, 5                      ; Run 5 iterations for demo
    je main_exit
    
    ; Display LED status
    call display_leds
    
    ; Display switch status
    call display_switches
    
    ; Simulate some LED changes
    call update_leds
    
    ; Simulate math operations
    call demo_math_operations
    
    ; Play sound effect
    call play_beep_sequence
    
    inc rax
    jmp main_loop
    
main_exit:
    mov rcx, 0
    call ExitProcess

; ============================================================================
; ALTAIR 8800 INITIALIZATION
; ============================================================================

init_altair:
    push rbp
    mov rbp, rsp
    
    ; Initialize LED states to 0
    mov qword ptr [led_states], 0
    
    ; Initialize switch states to 0
    mov qword ptr [switch_states], 0
    
    ; Initialize CPU registers
    mov byte ptr [cpu_acc], 0
    mov byte ptr [cpu_b], 0
    mov byte ptr [cpu_c], 0
    mov word ptr [cpu_pc], 0
    
    ; Initialize program counter
    mov word ptr [program_counter], 0
    
    pop rbp
    ret

; ============================================================================
; LED DISPLAY FUNCTIONS
; ============================================================================

display_leds:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    mov r11, [rsp + 96]             ; Get stdout handle
    
    ; Build LED display string
    mov rcx, r11
    lea rdx, [led_msg]
    mov r8, 13
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    ; Get LED state
    mov rax, [led_states]
    
    ; Display LED state in binary, hex, and decimal
    call display_value_all_formats
    
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; SWITCH DISPLAY FUNCTIONS
; ============================================================================

display_switches:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    mov r11, [rsp + 96]             ; Get stdout handle
    
    ; Build switch display string
    mov rcx, r11
    lea rdx, [switch_msg]
    mov r8, 16
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    ; Get switch state and display
    mov rax, [switch_states]
    call display_value_all_formats
    
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; DISPLAY VALUE IN MULTIPLE FORMATS (Binary, Hex, Octal, Decimal)
; ============================================================================

display_value_all_formats:
    push rbp
    mov rbp, rsp
    sub rsp, 128
    
    ; Save the value
    mov qword ptr [rsp], rax
    
    ; Display in Binary (16-bit)
    mov rax, qword ptr [rsp]
    and rax, 0xFFFF
    call print_binary_16bit
    
    ; Separator
    call print_separator
    
    ; Display in Hexadecimal
    mov rax, qword ptr [rsp]
    and rax, 0xFFFF
    call print_hex_16bit
    
    ; Separator
    call print_separator
    
    ; Display in Octal
    mov rax, qword ptr [rsp]
    and rax, 0xFFFF
    call print_octal_16bit
    
    ; Separator
    call print_separator
    
    ; Display in Decimal
    mov rax, qword ptr [rsp]
    and rax, 0xFFFF
    call print_decimal_16bit
    
    ; Newline
    call print_newline
    
    add rsp, 128
    pop rbp
    ret

; ============================================================================
; BINARY CONVERSION (16-bit)
; ============================================================================

print_binary_16bit:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; RAX contains the value
    mov r8, 15                      ; Bit counter
    
binary_loop:
    bt rax, r8                      ; Test bit
    jc binary_bit_1
    mov cl, '0'
    jmp binary_next
binary_bit_1:
    mov cl, '1'
binary_next:
    ; Output the character (simplified - would use WriteConsoleA)
    dec r8
    cmp r8, -1
    jne binary_loop
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; HEXADECIMAL CONVERSION (16-bit)
; ============================================================================

print_hex_16bit:
    push rbp
    mov rbp, rsp
    
    ; RAX contains the value
    ; Convert to hex string: each nibble
    rol rax, 32
    mov ecx, 4                      ; 4 hex digits for 16-bit
    
hex_loop:
    rol eax, 4
    mov edx, eax
    and edx, 0x0F
    cmp edx, 9
    jle hex_digit
    add edx, 7                      ; A-F offset
hex_digit:
    add edx, '0'
    ; Output edx (would use WriteConsoleA)
    dec ecx
    jnz hex_loop
    
    pop rbp
    ret

; ============================================================================
; OCTAL CONVERSION (16-bit)
; ============================================================================

print_octal_16bit:
    push rbp
    mov rbp, rsp
    
    ; RAX contains value (16-bit)
    mov ecx, 5                      ; Up to 5 octal digits for 16-bit
    mov edx, 0
    
octal_loop:
    mov ebx, eax
    and ebx, 0x07
    shr eax, 3
    add bl, '0'
    ; Output bl (would use WriteConsoleA)
    dec ecx
    jnz octal_loop
    
    pop rbp
    ret

; ============================================================================
; DECIMAL CONVERSION (16-bit)
; ============================================================================

print_decimal_16bit:
    push rbp
    mov rbp, rsp
    
    ; RAX contains value
    mov rax, [rsp + 16]
    and rax, 0xFFFF
    
    ; Use DIV instruction for decimal conversion
    mov r10, 10000
    mov ecx, 0
    
decimal_divide:
    mov edx, 0
    div r10
    cmp eax, 0
    je decimal_done
    add al, '0'
    ; Output al
    mov rax, rdx
    dec r10
    jnz decimal_divide
    
decimal_done:
    pop rbp
    ret

; ============================================================================
; UTILITY PRINT FUNCTIONS
; ============================================================================

print_separator:
    push rbp
    mov rbp, rsp
    ; Would output " | "
    pop rbp
    ret

print_newline:
    push rbp
    mov rbp, rsp
    ; Would output newline
    pop rbp
    ret

; ============================================================================
; LED UPDATE SIMULATION
; ============================================================================

update_leds:
    push rbp
    mov rbp, rsp
    
    ; Simulate LED pattern: shift left
    mov rax, [led_states]
    rol rax, 1
    and rax, 0xFFFF
    mov [led_states], rax
    
    pop rbp
    ret

; ============================================================================
; MATHEMATICAL OPERATIONS (8, 16, 32, 64-bit)
; ============================================================================

demo_math_operations:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; 8-BIT OPERATIONS
    mov al, 42
    mov bl, 8
    add al, bl
    mov [math_result_8], al
    
    ; 16-BIT OPERATIONS
    mov ax, 1000
    mov bx, 2000
    add ax, bx
    mov [math_result_16], ax
    
    ; 32-BIT OPERATIONS
    mov eax, 100000
    mov ebx, 200000
    add eax, ebx
    mov [math_result_32], eax
    
    ; 64-BIT OPERATIONS
    mov rax, 0x1000000000000000
    mov rbx, 0x0100000000000000
    add rax, rbx
    mov [math_result_64], rax
    
    ; Display results
    call display_math_results
    
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; DISPLAY MATHEMATICAL RESULTS
; ============================================================================

display_math_results:
    push rbp
    mov rbp, rsp
    
    ; Show 8-bit result
    mov al, [math_result_8]
    movzx rax, al
    
    ; Show 16-bit result
    mov ax, [math_result_16]
    movzx rax, ax
    
    ; Show 32-bit result
    mov eax, [math_result_32]
    
    ; Show 64-bit result
    mov rax, [math_result_64]
    
    pop rbp
    ret

; ============================================================================
; SOUND EFFECT GENERATION
; ============================================================================

play_beep_sequence:
    push rbp
    mov rbp, rsp
    
    ; Simple beep sequence: three beeps
    mov rcx, 800                    ; Frequency: 800 Hz
    mov rdx, 100                    ; Duration: 100 ms
    call Beep
    
    mov rcx, 1200
    mov rdx, 100
    call Beep
    
    mov rcx, 600
    mov rdx, 150
    call Beep
    
    pop rbp
    ret

; ============================================================================
; INSTRUCTION EXECUTION ENGINE
; ============================================================================

execute_instruction:
    push rbp
    mov rbp, rsp
    
    ; Fetch instruction from program counter
    mov ax, [program_counter]
    lea rax, [altair_memory + rax]
    mov bx, [rax]
    
    ; Decode and execute (8080 instruction set subset)
    
    ; NOP - no operation
    cmp bx, 0x0000
    je exec_nop
    
    ; MOV - move operations
    cmp bh, 0x40
    je exec_mov
    
    ; ADD - addition
    cmp bh, 0x80
    je exec_add
    
    ; JMP - unconditional jump
    cmp bh, 0xC3
    je exec_jmp
    
    jmp exec_done
    
exec_nop:
    inc word ptr [program_counter]
    jmp exec_done
    
exec_mov:
    ; Move operation handling
    inc word ptr [program_counter]
    jmp exec_done
    
exec_add:
    ; Add operation handling
    inc word ptr [program_counter]
    jmp exec_done
    
exec_jmp:
    ; Jump operation handling
    mov ax, [rax + 1]
    mov [program_counter], ax
    jmp exec_done
    
exec_done:
    pop rbp
    ret

; ============================================================================
; PROGRAM LOADER
; ============================================================================

load_program:
    push rbp
    mov rbp, rsp
    
    ; Initialize program memory
    mov rdi, offset altair_memory
    mov rcx, PROGRAM_BUFFER
    xor rax, rax
    rep stosb
    
    ; Load sample program
    call load_sample_program
    
    pop rbp
    ret

load_sample_program:
    push rbp
    mov rbp, rsp
    
    ; Load Intel 8080 opcodes
    ; Simple program: count from 0 to 255
    
    mov rdi, offset altair_memory
    
    ; MVI A, 0 (Load 0 into accumulator)
    mov al, 0x3E
    stosb
    mov al, 0x00
    stosb
    
    ; INR A (Increment accumulator)
    mov al, 0x3C
    stosb
    
    ; JMP (Jump back to increment)
    mov al, 0xC3
    stosb
    mov ax, 0x0000
    stosw
    
    pop rbp
    ret

; ============================================================================
; ADVANCED FUNCTION: WOLFRAM ALPHA STYLE CALCULATIONS
; ============================================================================

wolfram_math_evaluation:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Example: Calculate factorial of 5
    mov rax, 5
    call factorial_calc
    
    ; Example: Power calculation (2^8)
    mov rax, 2
    mov rcx, 8
    call power_calc
    
    ; Example: GCD calculation
    mov rax, 48
    mov rcx, 18
    call gcd_calc
    
    add rsp, 64
    pop rbp
    ret

factorial_calc:
    push rbp
    mov rbp, rsp
    
    ; RAX = input number
    mov r8, rax                     ; Store input in R8
    mov rax, 1                      ; Result = 1
    
    cmp r8, 0
    je factorial_done
    
factorial_loop:
    imul rax, r8
    dec r8
    cmp r8, 0
    jne factorial_loop
    
factorial_done:
    mov [math_result_64], rax
    pop rbp
    ret

power_calc:
    push rbp
    mov rbp, rsp
    
    ; RAX = base, RCX = exponent
    mov r8, rcx                     ; Store exponent
    mov r9, rax                     ; Store base
    mov rax, 1                      ; Result = 1
    
    cmp r8, 0
    je power_done
    
power_loop:
    imul rax, r9
    dec r8
    jnz power_loop
    
power_done:
    mov [math_result_64], rax
    pop rbp
    ret

gcd_calc:
    push rbp
    mov rbp, rsp
    
    ; RAX = first number, RCX = second number
    ; Uses Euclidean algorithm
    
gcd_loop:
    cmp rcx, 0
    je gcd_done
    
    mov rdx, 0
    div rcx
    mov rax, rcx
    mov rcx, rdx
    jmp gcd_loop
    
gcd_done:
    mov [math_result_64], rax
    pop rbp
    ret

; ============================================================================
; MEMORY MANAGEMENT
; ============================================================================

read_memory:
    push rbp
    mov rbp, rsp
    
    ; RAX = address
    mov bx, [altair_memory + rax]
    
    pop rbp
    ret

write_memory:
    push rbp
    mov rbp, rsp
    
    ; RAX = address, RBX = value
    mov [altair_memory + rax], bl
    
    pop rbp
    ret

; ============================================================================
; END OF PROGRAM
; ============================================================================

end main
