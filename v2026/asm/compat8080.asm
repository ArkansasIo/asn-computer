bits 64

global i8080_step

global i8080_reset

section .text
i8080_reset:
    xor eax, eax
    ret

; Reference 8080 execution hook.
; RDI = opcode. Returns the opcode class in EAX.
i8080_step:
    mov eax, edi
    and eax, 0xff
    cmp eax, 0x76
    je .halt
    cmp eax, 0x00
    je .nop
    mov eax, 1
    ret
.nop:
    xor eax, eax
    ret
.halt:
    mov eax, 2
    ret
