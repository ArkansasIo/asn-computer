option casemap:none

EXTERN GetStdHandle:PROC
EXTERN WriteConsoleA:PROC
EXTERN Beep:PROC
EXTERN Sleep:PROC
EXTERN ExitProcess:PROC

STD_OUTPUT_HANDLE EQU -11

.data
hStdOut         dq 0
charsWritten    dq 0
titleMsg        db "=== ALTAIR 8800 EMULATOR ===",13,10,0
bootMsg         db "Booting core systems...",13,10,0
loopMsg         db "Running demo cycle",13,10,0
doneMsg         db "Shutdown complete.",13,10,0

.code

write_cstr PROC
    ; RCX = pointer to null-terminated string
    push rbx
    push rsi

    mov rsi, rcx
    xor r8d, r8d
count_loop:
    mov bl, byte ptr [rsi+r8]
    cmp bl, 0
    je count_done
    inc r8d
    jmp count_loop

count_done:
    mov rcx, qword ptr [hStdOut]
    mov rdx, rsi
    lea r9, charsWritten
    sub rsp, 32
    mov qword ptr [rsp+32], 0
    call WriteConsoleA
    add rsp, 32

    pop rsi
    pop rbx
    ret
write_cstr ENDP

start PROC
    sub rsp, 40

    mov ecx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov qword ptr [hStdOut], rax

    lea rcx, titleMsg
    call write_cstr

    lea rcx, bootMsg
    call write_cstr

    mov ebx, 5
main_loop:
    lea rcx, loopMsg
    call write_cstr

    mov ecx, 880
    mov edx, 80
    call Beep

    mov ecx, 150
    call Sleep

    dec ebx
    jnz main_loop

    lea rcx, doneMsg
    call write_cstr

    xor ecx, ecx
    call ExitProcess

    add rsp, 40
    ret
start ENDP

END
