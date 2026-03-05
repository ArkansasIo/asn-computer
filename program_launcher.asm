; ============================================================================
; ALTAIR 8800 APPLICATION LOADER AND LAUNCHER
; Loads and executes user programs
; ============================================================================

.code

extern GetStdHandle:proc
extern WriteConsoleA:proc
extern ReadConsoleA:proc
extern Beep:proc
extern ExitProcess:proc

; ============================================================================
; PROGRAM LAUNCHER
; ============================================================================

.data

; Program registry (stores loaded program information)
program_registry:       db 64 dup(0)    ; 64 bytes per program entry
num_programs:           dd 0

; Built-in program list
builtin_programs:
    db "BIN_COUNTER", 0
    db "LED_CHASER", 0
    db "FACTORIAL", 0
    db "MEMORY_TEST", 0
    db "FIBONACCI", 0
    db "MATH_UTILS", 0

; Program descriptions
program_descriptions:
    db "Binary Counter: Counts 0-255 on LEDs", 0
    db "LED Chaser: Moving LED pattern", 0
    db "Factorial Calculator: Computes N!", 0
    db "Memory Test: Tests RAM", 0
    db "Fibonacci Generator: Generates sequence", 0
    db "Math Utilities: Demo of math functions", 0

; ============================================================================
; LOAD PROGRAM
; ============================================================================

load_program:
    ; Input: ECX = program ID
    ; Output: RAX = program entry point (0 if failed)
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Validate program ID
    mov eax, ecx
    cmp eax, 0
    jl load_fail
    cmp eax, 5
    jg load_fail
    
    ; Get program entry point based on ID
    cmp eax, 0
    je load_bin_counter
    cmp eax, 1
    je load_led_chaser
    cmp eax, 2
    je load_factorial
    cmp eax, 3
    je load_memory_test
    cmp eax, 4
    je load_fibonacci
    cmp eax, 5
    je load_math_utils
    
    jmp load_fail
    
load_bin_counter:
    lea rax, [program_binary_counter]
    jmp load_success
    
load_led_chaser:
    lea rax, [program_led_chaser]
    jmp load_success
    
load_factorial:
    lea rax, [program_factorial_calculator]
    jmp load_success
    
load_memory_test:
    lea rax, [program_memory_test]
    jmp load_success
    
load_fibonacci:
    lea rax, [program_fibonacci]
    jmp load_success
    
load_math_utils:
    lea rax, [program_math_utils]
    jmp load_success
    
load_success:
    add rsp, 32
    pop rbp
    ret
    
load_fail:
    mov rax, 0
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; LAUNCH PROGRAM
; ============================================================================

launch_program:
    ; Input: RAX = program entry point
    ; Output: None (transfers control to program)
    
    call rax                            ; Jump to program
    ret

; ============================================================================
; PROGRAM: BINARY COUNTER
; ============================================================================

program_binary_counter:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    xor eax, eax
    
counter_loop:
    ; Set LED pattern to counter value
    mov al, bl
    call led_display
    
    ; Print counter
    mov eax, ebx
    call print_decimal
    
    ; Wait 500ms
    mov ecx, 500
    call delay_ms
    
    ; Increment counter
    inc ebx
    
    ; Loop 0-255
    cmp ebx, 256
    jl counter_loop
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; PROGRAM: LED CHASER
; ============================================================================

program_led_chaser:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov r8, 0
    mov r9, 0x01                       ; Initial pattern
    
chaser_loop:
    ; Set LED pattern
    mov al, r9b
    call led_display
    
    ; Wait 100ms
    mov ecx, 100
    call delay_ms
    
    ; Rotate pattern left
    rol r9b, 1
    
    ; Counter
    inc r8
    cmp r8, 256
    jl chaser_loop
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; PROGRAM: FACTORIAL CALCULATOR
; ============================================================================

program_factorial_calculator:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Calculate factorials 1-10
    mov ecx, 1
    
factorial_loop:
    ; Print N
    mov eax, ecx
    call print_decimal
    
    mov al, '!'
    call print_char
    
    mov al, ' '
    call print_char
    
    ; Calculate N!
    mov eax, ecx
    call factorial_calc
    
    ; Print result
    call print_decimal
    
    mov al, 0Dh
    call print_char
    mov al, 0Ah
    call print_char
    
    ; Next
    inc ecx
    cmp ecx, 10
    jle factorial_loop
    
    add rsp, 32
    pop rbp
    ret

factorial_calc:
    ; Input: EAX = n
    ; Output: EAX = n!
    
    mov ecx, eax
    mov eax, 1
    
    cmp ecx, 0
    je fact_done
    cmp ecx, 1
    je fact_done
    
fact_mul_loop:
    imul eax, ecx
    dec ecx
    cmp ecx, 1
    jne fact_mul_loop
    
fact_done:
    ret

; ============================================================================
; PROGRAM: MEMORY TEST
; ============================================================================

program_memory_test:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, offset memory_test_msg
    call print_string
    
    ; Test 1: Write pattern
    mov rcx, 0x1000
    mov edx, 0xAA
    mov r8, 256
    call memory_fill
    
    ; Test 2: Verify pattern
    mov rcx, 0x1000
    mov edx, 0xAA
    mov r8, 256
    call memory_verify
    
    cmp eax, 0
    jne memory_test_fail
    
    mov rcx, offset mem_pass_msg
    call print_string
    
    jmp memory_test_done
    
memory_test_fail:
    mov rcx, offset mem_fail_msg
    call print_string
    
memory_test_done:
    add rsp, 32
    pop rbp
    ret

memory_fill:
    ; Input: RCX = address, EDX = value, R8 = size
    mov r9, 0
    
mem_fill_loop:
    cmp r9, r8
    jge mem_fill_done
    
    mov al, dl
    mov [rcx + r9], al
    inc r9
    jmp mem_fill_loop
    
mem_fill_done:
    ret

memory_verify:
    ; Input: RCX = address, EDX = expected, R8 = size
    ; Output: EAX = 0 (success), 1 (failure)
    
    mov r9, 0
    mov eax, 0
    
mem_verify_loop:
    cmp r9, r8
    jge mem_verify_done
    
    mov al, [rcx + r9]
    cmp al, dl
    jne mem_verify_fail
    
    inc r9
    jmp mem_verify_loop
    
mem_verify_fail:
    mov eax, 1
    
mem_verify_done:
    ret

; ============================================================================
; PROGRAM: FIBONACCI
; ============================================================================

program_fibonacci:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    xor r8d, r8d                        ; A = 0
    mov r9d, 1                          ; B = 1
    mov r10d, 0                         ; Counter
    
fib_loop:
    ; Print A
    mov eax, r8d
    call print_decimal
    
    mov al, ' '
    call print_char
    
    ; Calculate next
    mov edx, r8d
    add edx, r9d
    mov r8d, r9d
    mov r9d, edx
    
    ; Counter
    inc r10d
    cmp r10d, 20
    jl fib_loop
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; PROGRAM: MATH UTILITIES
; ============================================================================

program_math_utils:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, offset math_header
    call print_string
    
    ; Test power function
    mov rcx, offset power_test
    call print_string
    
    mov eax, 2
    mov ebx, 8
    call power_32
    call print_decimal
    
    mov al, 0Dh
    call print_char
    mov al, 0Ah
    call print_char
    
    ; Test GCD function
    mov rcx, offset gcd_test
    call print_string
    
    mov eax, 48
    mov ebx, 18
    call gcd_32
    call print_decimal
    
    add rsp, 32
    pop rbp
    ret

power_32:
    ; Input: EAX = base, EBX = exponent
    ; Output: EAX = base^exp
    
    mov ecx, eax
    mov eax, 1
    
    cmp ebx, 0
    je pow_done
    
pow_loop:
    imul eax, ecx
    dec ebx
    cmp ebx, 0
    jne pow_loop
    
pow_done:
    ret

gcd_32:
    ; Input: EAX = a, EBX = b
    ; Output: EAX = gcd(a, b)
    
gcd_loop:
    cmp ebx, 0
    je gcd_done
    
    mov ecx, eax
    mov eax, ebx
    mov edx, 0
    div ebx
    mov ebx, edx
    jmp gcd_loop
    
gcd_done:
    ret

; ============================================================================
; UTILITY FUNCTIONS
; ============================================================================

print_string:
    ; Input: RCX = string pointer
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    mov rdx, [rsp+40]                   ; String address
    mov r8, 256                         ; Max length
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

print_decimal:
    ; Input: EAX = value
    
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    ; Convert to string
    mov ecx, 10
    mov r8, 0                           ; Digit count
    
convert_loop:
    mov edx, 0
    div ecx
    
    add dl, '0'
    mov [rsp + r8], dl
    
    inc r8
    cmp eax, 0
    jne convert_loop
    
    ; Reverse and print
    mov r9, r8
    dec r9
    
print_loop:
    cmp r9, 0
    jl print_decimal_done
    
    mov al, [rsp + r9]
    call print_char
    
    dec r9
    jmp print_loop
    
print_decimal_done:
    add rsp, 48
    pop rbp
    ret

print_char:
    ; Input: AL = character
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov byte ptr [rsp+32], al
    
    mov rcx, r11
    mov rdx, rsp
    add rdx, 32
    mov r8, 1
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

led_display:
    ; Input: AL = pattern
    
    ; Would set LED display here
    ret

delay_ms:
    ; Input: ECX = milliseconds
    
    push rbp
    mov rbp, rsp
    
    ; Simple busy wait (not actual timing)
    mov r8, rcx
    mov r9, 1000000
    
delay_loop:
    dec r9
    cmp r9, 0
    jne delay_loop
    
    dec r8
    cmp r8, 0
    jne delay_loop
    
    pop rbp
    ret

; ============================================================================
; DATA SECTION
; ============================================================================

memory_test_msg:        db "Starting memory test...", 0Dh, 0Ah, 0
mem_pass_msg:           db "Memory test PASSED", 0Dh, 0Ah, 0
mem_fail_msg:           db "Memory test FAILED", 0Dh, 0Ah, 0
math_header:            db "Math Utilities Demo", 0Dh, 0Ah, 0Dh, 0Ah, 0
power_test:             db "2^8 = ", 0
gcd_test:               db "GCD(48, 18) = ", 0

; ============================================================================
; END OF LAUNCHER
; ============================================================================

end
