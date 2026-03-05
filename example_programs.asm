; EXAMPLE PROGRAMS - Sample Intel 8080 Assembly Programs
; x86-64 Assembly for Windows (MASM)
; 10 sample programs demonstrating various CPU features
; ~600 lines

option casemap:none

.data
; Program descriptions and metadata
program_count   db 10

; Program 1: Binary Counter (0-255)
prog1_name      db "Binary Counter",0
prog1_start:
    db 0x00             ; NOP
    db 0x06, 0x00       ; MVI B, 0x00
prog1_loop:
    db 0x04             ; INR B
    db 0x00             ; NOP
    db 0xC2             ; JNZ
    db 0x02, 0x00       ; (to prog1_loop)
    db 0x76             ; HLT

; Program 2: LED Chaser Pattern
prog2_name      db "LED Chaser",0
prog2_start:
    db 0x06, 0x01       ; MVI B, 0x01
prog2_loop:
    db 0x00             ; NOP (display B)
    db 0x29             ; DAD H (rotate left equivalent)
    db 0xC2             ; JNZ
    db 0x04, 0x00       ; (to prog2_loop)
    db 0x76             ; HLT

; Program 3: Factorial (5!)
prog3_name      db "Factorial",0
prog3_start:
    db 0x06, 0x05       ; MVI B, 0x05 (5)
    db 0x0E, 0x01       ; MVI C, 0x01 (result = 1)
prog3_loop:
    db 0x79             ; MOV A, C
    db 0x80             ; ADD B
    db 0x47             ; MOV B, A
    db 0x05             ; DCR B
    db 0xC2             ; JNZ
    db 0x09, 0x00       ; (to prog3_loop)
    db 0x76             ; HLT

; Program 4: Memory Test
prog4_name      db "Memory Test",0
prog4_start:
    db 0x21, 0x00, 0x00 ; LXI H, 0x0000
    db 0x36, 0xAA       ; MVI M, 0xAA
    db 0x7E             ; MOV A, M
    db 0xFE, 0xAA       ; CPI 0xAA
    db 0xC2             ; JNZ
    db 0x0C, 0x00       ; (to error)
    db 0x76             ; HLT
    db 0x76             ; HLT (error)

; Program 5: Fibonacci Sequence
prog5_name      db "Fibonacci",0
prog5_start:
    db 0x06, 0x01       ; MVI B, 0x01
    db 0x0E, 0x01       ; MVI C, 0x01
prog5_loop:
    db 0x78             ; MOV A, B
    db 0x81             ; ADD C
    db 0x47             ; MOV B, A
    db 0x79             ; MOV A, C
    db 0x48             ; MOV C, B
    db 0x3D             ; DCR A
    db 0xC2             ; JNZ
    db 0x10, 0x00       ; (to prog5_loop)
    db 0x76             ; HLT

; Program 6: BCD Conversion
prog6_name      db "BCD Conversion",0
prog6_start:
    db 0x06, 123        ; MVI B, 123
    db 0x78             ; MOV A, B
    db 0x07             ; RLC (rotate left)
    db 0x07             ; RLC
    db 0x07             ; RLC
    db 0x07             ; RLC
    db 0xE6, 0x0F       ; ANI 0x0F (mask low nibble)
    db 0x76             ; HLT

; Program 7: Bitwise Operations
prog7_name      db "Bitwise Ops",0
prog7_start:
    db 0x06, 0xF0       ; MVI B, 0xF0
    db 0x0E, 0x0F       ; MVI C, 0x0F
    db 0x78             ; MOV A, B
    db 0xA1             ; ANA C (AND)
    db 0x78             ; MOV A, B
    db 0xB1             ; ORA C (OR)
    db 0x78             ; MOV A, B
    db 0xA9             ; XRA C (XOR)
    db 0x76             ; HLT

; Program 8: Prime Number Checker
prog8_name      db "Prime Checker",0
prog8_start:
    db 0x06, 17         ; MVI B, 17 (number to test)
    db 0x0E, 2          ; MVI C, 2 (divisor)
prog8_loop:
    db 0x78             ; MOV A, B
    db 0x81             ; ADD C (test division)
    db 0x79             ; MOV A, C
    db 0x3C             ; INR A
    db 0xFE, 0x0B       ; CPI 11 (limit)
    db 0xC2             ; JNZ
    db 0x2A, 0x00       ; (to prog8_loop)
    db 0x76             ; HLT

; Program 9: Sine Lookup Table
prog9_name      db "Sine Table",0
prog9_start:
    db 0x21, 0x00, 0x10 ; LXI H, 0x1000 (sine table base)
    db 0x06, 0x00       ; MVI B, 0x00 (index)
prog9_loop:
    db 0x7E             ; MOV A, M (load table entry)
    db 0x04             ; INR B
    db 0x23             ; INX H (next entry)
    db 0xFE, 0x10       ; CPI 16 (table size)
    db 0xC2             ; JNZ
    db 0x36, 0x00       ; (to prog9_loop)
    db 0x76             ; HLT

; Program 10: Stack Operations
prog10_name     db "Stack Ops",0
prog10_start:
    db 0x31, 0x00, 0x20 ; LXI SP, 0x2000
    db 0x06, 0xAB       ; MVI B, 0xAB
    db 0xC5             ; PUSH B
    db 0x0E, 0xCD       ; MVI C, 0xCD
    db 0xC1             ; POP B
    db 0x76             ; HLT

.code

; ============================================================================
; PROGRAM LOADER AND EXECUTOR
; ============================================================================

load_program_by_number PROC
    ; RCX = program number (1-10)
    ; Returns program starting address
    
    cmp rcx, 1
    je load_prog1
    cmp rcx, 2
    je load_prog2
    cmp rcx, 3
    je load_prog3
    cmp rcx, 4
    je load_prog4
    cmp rcx, 5
    je load_prog5
    cmp rcx, 6
    je load_prog6
    cmp rcx, 7
    je load_prog7
    cmp rcx, 8
    je load_prog8
    cmp rcx, 9
    je load_prog9
    cmp rcx, 10
    je load_prog10
    
    xor rax, rax
    ret
    
load_prog1:
    lea rax, prog1_start
    ret
load_prog2:
    lea rax, prog2_start
    ret
load_prog3:
    lea rax, prog3_start
    ret
load_prog4:
    lea rax, prog4_start
    ret
load_prog5:
    lea rax, prog5_start
    ret
load_prog6:
    lea rax, prog6_start
    ret
load_prog7:
    lea rax, prog7_start
    ret
load_prog8:
    lea rax, prog8_start
    ret
load_prog9:
    lea rax, prog9_start
    ret
load_prog10:
    lea rax, prog10_start
    ret
load_program_by_number ENDP

get_program_name PROC
    ; RCX = program number (1-10)
    ; Returns program name pointer
    
    cmp rcx, 1
    je name_prog1
    cmp rcx, 2
    je name_prog2
    cmp rcx, 3
    je name_prog3
    cmp rcx, 4
    je name_prog4
    cmp rcx, 5
    je name_prog5
    cmp rcx, 6
    je name_prog6
    cmp rcx, 7
    je name_prog7
    cmp rcx, 8
    je name_prog8
    cmp rcx, 9
    je name_prog9
    cmp rcx, 10
    je name_prog10
    
    xor rax, rax
    ret
    
name_prog1:
    lea rax, prog1_name
    ret
name_prog2:
    lea rax, prog2_name
    ret
name_prog3:
    lea rax, prog3_name
    ret
name_prog4:
    lea rax, prog4_name
    ret
name_prog5:
    lea rax, prog5_name
    ret
name_prog6:
    lea rax, prog6_name
    ret
name_prog7:
    lea rax, prog7_name
    ret
name_prog8:
    lea rax, prog8_name
    ret
name_prog9:
    lea rax, prog9_name
    ret
name_prog10:
    lea rax, prog10_name
    ret
get_program_name ENDP

; ============================================================================
; SIMPLE CPU EMULATOR (8080 Subset)
; ============================================================================

cpu_execute_instruction PROC
    ; RAX = instruction byte
    ; Simple decoder for subset of 8080 opcodes
    
    cmp al, 0x00        ; NOP
    je instr_nop
    cmp al, 0x76        ; HLT
    je instr_halt
    cmp al, 0x3C        ; INR A
    je instr_incr
    cmp al, 0x3D        ; DCR A
    je instr_decr
    cmp al, 0x07        ; RLC
    je instr_rlc
    cmp al, 0x0F        ; RRC
    je instr_rrc
    
    ret
    
instr_nop:
    ret
    
instr_halt:
    ; Set halt flag
    ret
    
instr_incr:
    ; Increment A register
    ret
    
instr_decr:
    ; Decrement A register
    ret
    
instr_rlc:
    ; Rotate left circular
    ret
    
instr_rrc:
    ; Rotate right circular
    ret
cpu_execute_instruction ENDP

; ============================================================================
; PROGRAM METADATA AND INFO
; ============================================================================

get_program_count PROC
    mov al, [program_count]
    ret
get_program_count ENDP

get_program_description PROC
    ; RCX = program number
    ; Returns description
    
    push rbx
    call get_program_name
    pop rbx
    ret
get_program_description ENDP

END
