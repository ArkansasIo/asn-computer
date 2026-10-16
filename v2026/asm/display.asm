bits 64

global display_4k_mode

global display_frame_bytes

section .text
display_4k_mode:
    mov eax, 0x4B60
    ret

display_frame_bytes:
    mov rax, 3840
    imul rax, 2160
    imul rax, 4
    ret
