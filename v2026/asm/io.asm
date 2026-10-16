bits 64

global io_pause

global io_wait

section .text
io_pause:
    pause
    ret

io_wait:
    test rdi, rdi
    jz .done
.loop:
    pause
    dec rdi
    jnz .loop
.done:
    ret
