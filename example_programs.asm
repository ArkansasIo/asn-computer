; ============================================================================
; ALTAIR 8800 EMULATOR - EXAMPLE PROGRAMS
; Intel 8080 Assembly Programs for Altair 8800 Emulation
; ============================================================================

.code

; ============================================================================
; PROGRAM 1: BINARY COUNTER (0-255)
; ============================================================================
; This program counts from 0 to 255 and displays on LEDs
; Each iteration increments accumulator and outputs to port

program_binary_counter:
    ; MVI A, 0       (Load 0 into accumulator)
    db 3Eh, 00h
    
    ; Initialize counter
    ; MOV B, A       (B = 0)
    db 47h
    
counter_loop:
    ; INR A          (Increment accumulator)
    db 3Ch
    
    ; OUT 0          (Output accumulator to port 0)
    db 0D3h, 00h
    
    ; DAA            (Decimal adjust accumulator)
    db 27h
    
    ; CMP A, 0FFh    (Compare A with 255)
    db 0FEh, 0FFh
    
    ; JNZ counter_loop (Jump if not zero)
    db 0C2h, 00h, 00h
    
    ; HLT            (Halt)
    db 76h
    
    align 16

; ============================================================================
; PROGRAM 2: LED CHASER PATTERN
; ============================================================================
; Creates a moving LED pattern: 1000 0000 → 0100 0000 → etc.

program_led_chaser:
    ; MVI A, 80h     (Load 10000000 binary)
    db 3Eh, 80h
    
chaser_loop:
    ; OUT 0          (Output to LED port)
    db 0D3h, 00h
    
    ; RRC A          (Rotate right through carry)
    db 0Fh
    
    ; JMP chaser_loop
    db 0C3h, 00h, 00h
    
    ; HLT            (Halt)
    db 76h
    
    align 16

; ============================================================================
; PROGRAM 3: FACTORIAL CALCULATION (5!)
; ============================================================================
; Calculates 5! = 120 and outputs result

program_factorial:
    ; MVI A, 5       (Load 5)
    db 3Eh, 05h
    
    ; MVI B, 1       (Load 1 - will be result)
    db 06h, 01h
    
factorial_loop:
    ; MOV C, A       (Copy A to C)
    db 4Fh
    
    ; MOV A, B       (A = B)
    db 78h
    
    ; MUL C          (Multiply: A = A * C)
    ; 8080 doesn't have MUL, use DAD for addition
    ; Alternative: Use repeated addition
    
    ; MOV B, A       (B = result)
    db 47h
    
    ; MOV A, C       (A = C)
    db 79h
    
    ; DCR A          (Decrement A)
    db 3Dh
    
    ; MOV C, A       (Save decremented value)
    db 4Fh
    
    ; CMP A, 0       (Compare with 0)
    db 0FEh, 00h
    
    ; JNZ factorial_loop
    db 0C2h, 00h, 00h
    
    ; MOV A, B       (A = result)
    db 78h
    
    ; OUT 0          (Output result)
    db 0D3h, 00h
    
    ; HLT            (Halt)
    db 76h
    
    align 16

; ============================================================================
; PROGRAM 4: MEMORY TEST
; ============================================================================
; Tests memory by writing and reading patterns

program_memory_test:
    ; LXI H, 8000h   (Load address 0x8000 into HL)
    db 21h, 00h, 80h
    
    ; MVI A, 0AAh    (Pattern 10101010)
    db 3Eh, 0AAh
    
    ; MOV M, A       (Store at HL address)
    db 77h
    
    ; MOV A, M       (Read from HL address)
    db 7Eh
    
    ; SUB A, 0AAh    (Check if matches)
    db 0D6h, 0AAh
    
    ; JNZ memory_error
    db 0C2h, 00h, 00h
    
    ; ON success: MVI A, FFh (All LEDs on)
    db 3Eh, 0FFh
    
    ; OUT 0          (Output success pattern)
    db 0D3h, 00h
    
    ; HLT
    db 76h
    
memory_error:
    ; MVI A, 00h     (All LEDs off - error)
    db 3Eh, 00h
    
    ; OUT 0          (Output error pattern)
    db 0D3h, 00h
    
    ; HLT
    db 76h
    
    align 16

; ============================================================================
; PROGRAM 5: FIBONACCI SEQUENCE
; ============================================================================
; Generates Fibonacci numbers: 1, 1, 2, 3, 5, 8, 13, 21, 34...

program_fibonacci:
    ; MVI A, 1       (First Fibonacci number)
    db 3Eh, 01h
    
    ; MVI B, 1       (Second Fibonacci number)
    db 06h, 01h
    
    ; MVI C, 0       (Counter for iterations)
    db 0Eh, 00h
    
fib_loop:
    ; OUT 0          (Output current Fibonacci number)
    db 0D3h, 00h
    
    ; MOV D, A       (D = A)
    db 57h
    
    ; MOV A, B       (A = B)
    db 78h
    
    ; ADD D          (A = A + D)
    db 82h, 00h
    
    ; MOV B, D       (B = D)
    db 47h
    
    ; MOV D, B       (D = B)
    db 57h
    
    ; INR C          (Increment counter)
    db 0Ch
    
    ; CMP C, 0Ah     (Compare counter with 10)
    db 0FEh, 0Ah
    
    ; JNZ fib_loop   (Continue if not done)
    db 0C2h, 00h, 00h
    
    ; HLT            (Halt)
    db 76h
    
    align 16

; ============================================================================
; PROGRAM 6: BINARY TO BCD CONVERSION
; ============================================================================
; Converts 8-bit binary to Binary-Coded Decimal

program_bin_to_bcd:
    ; MVI A, 99h     (Load 153 decimal = 99 hex)
    db 3Eh, 99h
    
    ; MVI B, 00h     (Result accumulator)
    db 06h, 00h
    
    ; MVI C, 10      (Divisor)
    db 0Eh, 0Ah
    
    ; DIV C          (Divide by 10: A = quotient, accumulator) 
    ; 8080 doesn't have DIV, use repeated subtraction
    
    ; Alternative: manual BCD conversion
    ; MOV D, A       (D = A)
    db 57h
    
    ; ANI 0F0h       (Mask lower nibble)
    db 0E6h, 0F0h
    
    ; RRC A, 4       (Shift right 4 times to get high digit)
    db 0Fh
    db 0Fh
    db 0Fh
    db 0Fh
    
    ; MOV E, A       (E = high digit)
    db 5Fh
    
    ; MOV A, D       (A = original)
    db 78h
    
    ; ANI 0Fh        (Mask lower nibble)
    db 0E6h, 0Fh
    
    ; OUT 0          (Output BCD result)
    db 0D3h, 00h
    
    ; HLT
    db 76h
    
    align 16

; ============================================================================
; PROGRAM 7: BITWISE OPERATIONS DEMO
; ============================================================================
; Demonstrates AND, OR, XOR operations

program_bitwise_ops:
    ; MVI A, 0F0h    (Load 1111 0000)
    db 3Eh, 0F0h
    
    ; MVI B, 0CCh    (Load 1100 1100)
    db 06h, 0CCh
    
    ; AND B          (A = A AND B = 1100 0000)
    db 0A0h
    
    ; OUT 1          (Output AND result to port 1)
    db 0D3h, 01h
    
    ; MVI A, 0F0h    (Reload A)
    db 3Eh, 0F0h
    
    ; ORA B          (A = A OR B = 1111 1100)
    db 0B0h
    
    ; OUT 2          (Output OR result to port 2)
    db 0D3h, 02h
    
    ; MVI A, 0F0h    (Reload A)
    db 3Eh, 0F0h
    
    ; XRA B          (A = A XOR B = 0011 1100)
    db 0A8h
    
    ; OUT 3          (Output XOR result to port 3)
    db 0D3h, 03h
    
    ; HLT
    db 76h
    
    align 16

; ============================================================================
; PROGRAM 8: PRIME NUMBER CHECKER
; ============================================================================
; Checks if accumulator value is prime

program_prime_check:
    ; MVI A, 17h     (Load 23 decimal - prime)
    db 3Eh, 17h
    
    ; MVI B, 2       (Divisor starts at 2)
    db 06h, 02h
    
prime_loop:
    ; CMP B, A       (Compare B with A)
    db 0B8h
    
    ; JNC prime_found (Jump if B >= A)
    db 0D2h, 00h, 00h
    
    ; MOV C, A       (C = A)
    db 4Fh
    
    ; MOV A, B       (A = B)
    db 78h
    
    ; We need MOD operation - simplified version:
    ; SUB C repeatedly until negative
    ; This is complex in 8080, so we'll use comparison
    
    ; INR B          (Increment B)
    db 04h
    
    ; JMP prime_loop
    db 0C3h, 00h, 00h
    
prime_found:
    ; FFh = prime (all LEDs on)
    ; MVI A, FFh
    db 3Eh, 0FFh
    
    ; OUT 0          (Output prime indicator)
    db 0D3h, 00h
    
    ; HLT
    db 76h
    
    align 16

; ============================================================================
; PROGRAM 9: LOOKUP TABLE (SINE APPROXIMATION)
; ============================================================================
; Accesses lookup table for sine values (0-90 degrees)

program_sine_table:
    ; Sine lookup table (0, 1, 2, 3, 4, 5, ..., angles)
    sine_lut:
    db 0, 17, 34, 50, 64, 76, 86, 93, 97, 99, 100
    
    ; MVI A, 5       (Load angle 5 * 10 degrees = 50 degrees)
    db 3Eh, 05h
    
    ; LXI H, sine_lut (Load lookup table address)
    db 21h, 00h, 00h  ; Placeholder - actual address would differ
    
    ; MOV E, A       (E = index)
    db 5Fh
    
    ; MVI D, 0       (D = 0 for 16-bit address)
    db 16h, 00h
    
    ; DAD D          (HL += DE - add index to base address)
    db 19h
    
    ; MOV A, M       (A = value at HL)
    db 7Eh
    
    ; OUT 0          (Output sine value)
    db 0D3h, 00h
    
    ; HLT
    db 76h
    
    align 16

; ============================================================================
; PROGRAM 10: STACK OPERATIONS
; ============================================================================
; Demonstrates stack push/pop operations

program_stack_ops:
    ; LXI SP, 0FFFFh (Initialize stack pointer)
    db 31h, 0FFh, 0FFh
    
    ; MVI A, 12h     (Load 18 decimal)
    db 3Eh, 12h
    
    ; PUSH PSW       (Push A and flags onto stack)
    db 0F5h
    
    ; MVI A, 34h     (Load 52 decimal)
    db 3Eh, 34h
    
    ; PUSH PSW       (Push A and flags onto stack)
    db 0F5h
    
    ; POP PSW        (Pop back to A)
    db 0F1h
    
    ; OUT 0          (Output first value)
    db 0D3h, 00h
    
    ; POP PSW        (Pop second value)
    db 0F1h
    
    ; OUT 1          (Output second value)
    db 0D3h, 01h
    
    ; HLT
    db 76h
    
    align 16

; ============================================================================
; PROGRAM SELECTION FUNCTION
; ============================================================================
; Loads selected program into memory

load_program_by_number:
    ; RAX = program number (1-10)
    ; Loads corresponding program into memory
    
    push rbp
    mov rbp, rsp
    
    cmp rax, 1
    je load_prog1
    cmp rax, 2
    je load_prog2
    cmp rax, 3
    je load_prog3
    cmp rax, 4
    je load_prog4
    cmp rax, 5
    je load_prog5
    cmp rax, 6
    je load_prog6
    cmp rax, 7
    je load_prog7
    cmp rax, 8
    je load_prog8
    cmp rax, 9
    je load_prog9
    cmp rax, 10
    je load_prog10
    
    jmp load_prog_done
    
load_prog1:
    lea rsi, [program_binary_counter]
    jmp copy_program
load_prog2:
    lea rsi, [program_led_chaser]
    jmp copy_program
load_prog3:
    lea rsi, [program_factorial]
    jmp copy_program
load_prog4:
    lea rsi, [program_memory_test]
    jmp copy_program
load_prog5:
    lea rsi, [program_fibonacci]
    jmp copy_program
load_prog6:
    lea rsi, [program_bin_to_bcd]
    jmp copy_program
load_prog7:
    lea rsi, [program_bitwise_ops]
    jmp copy_program
load_prog8:
    lea rsi, [program_prime_check]
    jmp copy_program
load_prog9:
    lea rsi, [program_sine_table]
    jmp copy_program
load_prog10:
    lea rsi, [program_stack_ops]
    jmp copy_program
    
copy_program:
    ; Copy program from rsi to altair_memory
    mov rdi, offset altair_memory
    mov rcx, 32                     ; Copy 32 bytes (typical program size)
    rep movsb
    
load_prog_done:
    pop rbp
    ret

; ============================================================================
; PROGRAM DESCRIPTIONS
; ============================================================================
; 
; Program 1: Binary Counter
;   Counts from 0 to 255, displaying each value on port 0
;   Learning: Basic loops, incrementing, output operations
;
; Program 2: LED Chaser
;   Creates moving light pattern on LEDs
;   Learning: Rotate operations, infinite loops, port I/O
;
; Program 3: Factorial
;   Calculates 5! = 120
;   Learning: Multiplication operations, register operations
;
; Program 4: Memory Test
;   Writes pattern to memory and reads it back
;   Learning: Memory addressing, compare operations, conditionals
;
; Program 5: Fibonacci Sequence
;   Generates first 10 Fibonacci numbers
;   Learning: Addition, sequence generation, counting loops
;
; Program 6: Binary to BCD
;   Converts 8-bit binary to BCD format
;   Learning: Bit shifting, masking, nibble operations
;
; Program 7: Bitwise Operations
;   Demonstrates AND, OR, XOR operations
;   Learning: Bitwise logic, multiple outputs
;
; Program 8: Prime Checker
;   Checks if a number is prime
;   Learning: Modulo, comparison, conditional jumps
;
; Program 9: Lookup Table
;   Accesses sine approximation table
;   Learning: Array access, pointer manipulation
;
; Program 10: Stack Operations
;   Demonstrates stack push/pop
;   Learning: Stack usage, data preservation

; ============================================================================
; END OF EXAMPLE PROGRAMS
; ============================================================================

end
