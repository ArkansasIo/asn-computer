; ===================================================================
; ALTAIR 8800 ASSEMBLY LANGUAGE STANDARD LIBRARY (stdlib.asm)
; Complete set of standard routines for ALTAIR 8800 assembly programs
; ===================================================================

; Memory Layout for ALTAIR 8800
; 0x0000 - 0x00FF: Zero Page (fast access, 256 bytes)
; 0x0100 - 0x01FF: Stack Area (256 bytes)
; 0x0200 - 0x7FFF: Program Code & Data
; 0x8000 - 0xFFFF: Upper Memory / Video RAM

; ===================================================================
; SECTION: SYSTEM ROUTINES
; ===================================================================

; HALT - Stop CPU execution
; Entry: None
; Exit: Program halted
HALT:
    HLT
    RET

; RESET - Reset CPU state
; Entry: None
; Exit: All registers cleared, PC set to 0
RESET:
    XOR AX, AX           ; Clear AX
    XOR BX, BX           ; Clear BX
    XOR CX, CX           ; Clear CX
    XOR DX, DX           ; Clear DX
    MOV SP, 0x0100       ; Reset stack pointer
    MOV BP, 0x0100       ; Reset base pointer
    JMP 0x0000           ; Jump to program start
    RET

; DELAY - Delay for N milliseconds
; Entry: CX = delay in ms
; Exit: N/A
DELAY:
    PUSH AX
DELAY_LOOP:
    MOV AX, 0xFFFF       ; Inner loop counter
DELAY_INNER:
    DEC AX
    JNZ DELAY_INNER
    DEC CX
    JNZ DELAY_LOOP
    POP AX
    RET

; ===================================================================
; SECTION: MEMORY OPERATIONS
; ===================================================================

; MEMCPY - Copy memory block
; Entry: DS:SI = source, ES:DI = destination, CX = bytes to copy
; Exit: Memory copied, flags set
MEMCPY:
    PUSH SI
    PUSH DI
    CLD
    REP MOVSB            ; Copy bytes from DS:SI to ES:DI
    POP DI
    POP SI
    RET

; MEMSET - Fill memory block with value
; Entry: ES:DI = destination, AL = fill byte, CX = bytes to fill
; Exit: Memory filled
MEMSET:
    PUSH DI
    CLD
    REP STOSB            ; Fill with AL value
    POP DI
    RET

; MEMCMP - Compare memory blocks
; Entry: DS:SI = block1, ES:DI = block2, CX = bytes to compare
; Exit: ZF set if equal, CF set if SI < DI
MEMCMP:
    PUSH SI
    PUSH DI
    CLD
    REPE CMPSB           ; Compare blocks
    POP DI
    POP SI
    RET

; ===================================================================
; SECTION: ARITHMETIC OPERATIONS
; ===================================================================

; ADD16 - Add two 16-bit numbers
; Entry: AX = operand1, BX = operand2
; Exit: AX = result, CF set if overflow
ADD16:
    ADD AX, BX
    RET

; SUB16 - Subtract two 16-bit numbers
; Entry: AX = minuend, BX = subtrahend
; Exit: AX = result
SUB16:
    SUB AX, BX
    RET

; MUL16 - Multiply two 16-bit numbers
; Entry: AX = multiplier, BX = multiplicand
; Exit: DX:AX = result (32-bit)
MUL16:
    MUL BX
    RET

; DIV16 - Divide two 16-bit numbers
; Entry: DX:AX = dividend, BX = divisor
; Exit: AX = quotient, DX = remainder
DIV16:
    DIV BX
    RET

; ABS16 - Get absolute value of 16-bit number
; Entry: AX = number
; Exit: AX = |number|
ABS16:
    TEST AX, AX
    JNS ABS16_DONE
    NEG AX
ABS16_DONE:
    RET

; ===================================================================
; SECTION: STRING OPERATIONS
; ===================================================================

; STRLEN - Get length of null-terminated string
; Entry: DS:SI = pointer to string
; Exit: CX = string length (excluding null terminator)
STRLEN:
    PUSH SI
    XOR CX, CX
STRLEN_LOOP:
    LODSB
    TEST AL, AL
    JZ STRLEN_DONE
    INC CX
    JMP STRLEN_LOOP
STRLEN_DONE:
    POP SI
    RET

; STRCPY - Copy null-terminated string
; Entry: DS:SI = source string, ES:DI = destination
; Exit: String copied with null terminator
STRCPY:
    PUSH SI
    PUSH DI
STRCPY_LOOP:
    LODSB
    STOSB
    TEST AL, AL
    JNZ STRCPY_LOOP
    POP DI
    POP SI
    RET

; STRCMP - Compare null-terminated strings
; Entry: DS:SI = string1, ES:DI = string2
; Exit: ZF set if equal, CF set if SI < DI
STRCMP:
    PUSH SI
    PUSH DI
STRCMP_LOOP:
    LODSB
    MOV BL, [ES:DI]
    CMP AL, BL
    JNE STRCMP_DONE
    TEST AL, AL
    JZ STRCMP_DONE
    INC DI
    JMP STRCMP_LOOP
STRCMP_DONE:
    POP DI
    POP SI
    RET

; STRREV - Reverse null-terminated string in place
; Entry: DS:SI = pointer to string
; Exit: String reversed
STRREV:
    PUSH SI
    PUSH DI
    MOV DI, SI
    CALL STRLEN          ; CX = string length
    DEC CX
    ADD DI, CX
    SHR CX, 1
    INC CX
STRREV_LOOP:
    LODSB
    XCHG AL, [ES:DI]
    MOV [SI-1], AL
    DEC DI
    LOOP STRREV_LOOP
    POP DI
    POP SI
    RET

; ===================================================================
; SECTION: BIT OPERATIONS
; ===================================================================

; BITCOUNT - Count set bits in 16-bit number
; Entry: AX = number
; Exit: BX = count of set bits
BITCOUNT:
    XOR BX, BX
    MOV CX, 16
BITCOUNT_LOOP:
    SHR AX, 1
    ADC BX, 0            ; Add carry to count
    LOOP BITCOUNT_LOOP
    RET

; BITREV - Reverse bits in 16-bit number
; Entry: AX = number
; Exit: AX = bit-reversed result
BITREV:
    XOR BX, BX
    MOV CX, 16
BITREV_LOOP:
    SHR AX, 1
    RCL BX, 1
    LOOP BITREV_LOOP
    MOV AX, BX
    RET

; ===================================================================
; SECTION: I/O OPERATIONS
; ===================================================================

; PUTCHAR - Write character to output
; Entry: AL = ASCII character
; Exit: Character written
PUTCHAR:
    PUSH AX
    MOV DX, 0x01         ; Output port
    OUT DX, AL           ; Send to port
    POP AX
    RET

; GETCHAR - Read character from input
; Entry: None
; Exit: AL = input character
GETCHAR:
    MOV DX, 0x00         ; Input port
    IN AL, DX            ; Read from port
    RET

; PUTS - Write null-terminated string
; Entry: DS:SI = pointer to string
; Exit: String written
PUTS:
    PUSH SI
    PUSH AX
PUTS_LOOP:
    LODSB
    TEST AL, AL
    JZ PUTS_DONE
    CALL PUTCHAR
    JMP PUTS_LOOP
PUTS_DONE:
    POP AX
    POP SI
    RET

; ===================================================================
; SECTION: CONVERSION ROUTINES
; ===================================================================

; HEX2BIN - Convert hex character to binary
; Entry: AL = hex character ('0'-'9', 'A'-'F', 'a'-'f')
; Exit: AL = binary value (0-15), CF set if invalid
HEX2BIN:
    CMP AL, '0'
    JL HEX2BIN_INVALID
    CMP AL, '9'
    JLE HEX2BIN_DIGIT
    CMP AL, 'A'
    JL HEX2BIN_INVALID
    CMP AL, 'F'
    JLE HEX2BIN_UPPER
    CMP AL, 'a'
    JL HEX2BIN_INVALID
    CMP AL, 'f'
    JG HEX2BIN_INVALID
    SUB AL, 'a' - 10
    CLC
    RET
HEX2BIN_UPPER:
    SUB AL, 'A' - 10
    CLC
    RET
HEX2BIN_DIGIT:
    SUB AL, '0'
    CLC
    RET
HEX2BIN_INVALID:
    STC
    RET

; BIN2HEX - Convert binary value to hex character
; Entry: AL = binary value (0-15)
; Exit: AL = hex character
BIN2HEX:
    AND AL, 0x0F
    CMP AL, 10
    JL BIN2HEX_DIGIT
    ADD AL, 'A' - 10
    RET
BIN2HEX_DIGIT:
    ADD AL, '0'
    RET

; ===================================================================
; SECTION: INTERRUPT HANDLERS
; ===================================================================

; INT_HANDLER - Generic interrupt handler
; Entry: None
; Exit: Interrupt processed
INT_HANDLER:
    PUSH AX
    PUSH BX
    MOV AX, 0x20         ; Acknowledge interrupt
    MOV BX, 0xFF00       ; Interrupt status port
    OUT BX, AX
    POP BX
    POP AX
    IRET

; ===================================================================
; END OF STANDARD LIBRARY
; ===================================================================
