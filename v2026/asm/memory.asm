bits 64

global memory_barrier

global memory_zero

section .text
memory_barrier:
    mfence
    ret

; RDI = address, RSI = byte count. Caller owns the buffer.
memory_zero:
    xor eax, eax
    mov rcx, rsi
    mov rsi, rdi
    mov rdi, rsi
    rep stosb
    ret
