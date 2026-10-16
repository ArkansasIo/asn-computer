bits 64

global memory_barrier
global memory_zero

section .text
memory_barrier:
    mfence
    ret

; RDI = address, RSI = byte count. Caller owns the buffer.
memory_zero:
    mov rcx, rsi
    xor eax, eax
    rep stosb
    ret
