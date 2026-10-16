bits 64
default rel

global altair64_entry
extern altair_runtime_init

section .text
altair64_entry:
    cli
    xor ebp, ebp
    call altair_runtime_init
.halt:
    hlt
    jmp .halt
