; ALTAIR OPERATING SYSTEM - BOOTLOADER & INITIALIZATION
; x86-64 Assembly for Windows (MASM)
; Complete OS initialization, boot sequence, and startup
; ~1,200 lines

option casemap:none

EXTERN GetStdHandle:PROC
EXTERN WriteConsoleA:PROC
EXTERN ReadConsoleA:PROC
EXTERN Beep:PROC
EXTERN Sleep:PROC
EXTERN ExitProcess:PROC

STD_OUTPUT_HANDLE EQU -11
STD_INPUT_HANDLE  EQU -10

.data
hStdOut         qw 0
hStdIn          qw 0
charsWritten    qw 0
charsRead       qw 0
bitConfig       dd 16
inputBuffer     db 32 dup(0)

; Bootloader messages
bootSplash      db "╔═════════════════════════════════════╗",13,10,0
bootSplash2     db "║                                     ║",13,10,0
bootSplash3     db "║    ALTAIR 8800 OPERATING SYSTEM    ║",13,10,0
bootSplash4     db "║         Version 2.0 x64            ║",13,10,0
bootSplash5     db "║     March 4, 2026                  ║",13,10,0
bootSplash6     db "║                                     ║",13,10,0
bootSplash7     db "╚═════════════════════════════════════╝",13,10,13,10,0

bootMsg1        db "Bootloader starting...",13,10,0
bootMsg2        db "Memory test: PASSED",13,10,0
bootMsg3        db "ROM check: PASSED",13,10,0
bootMsg4        db "Loading kernel...",13,10,0
bootMsg5        db "Initializing drivers...",13,10,0
bootMsg6        db "Starting shell...",13,10,13,10,0

mainMenu        db "╔═══════════════════════════════════╗",13,10,0
mainMenu2       db "║  ALTAIR/OS MAIN MENU              ║",13,10,0
mainMenu3       db "╠═══════════════════════════════════╣",13,10,0
option1         db "║  1. Programs & Utilities          ║",13,10,0
option2         db "║  2. System Diagnostics            ║",13,10,0
option3         db "║  3. BIOS Setup                    ║",13,10,0
option4         db "║  4. File Manager                  ║",13,10,0
option5         db "║  5. System Information            ║",13,10,0
option6         db "║  6. Settings                      ║",13,10,0
option7         db "║  7. Command Line                  ║",13,10,0
option8         db "║  8. Shutdown                      ║",13,10,0
option9         db "║  9. Bit System Config             ║",13,10,0
mainMenuEnd     db "╚═══════════════════════════════════╝",13,10,13,10,0

prompt          db "Enter choice (1-9): ",0
newLine         db 13,10,0

currentCfgMsg   db "Current System Config: ",0
mode16Msg       db "16-bit",13,10,0
mode32Msg       db "32-bit",13,10,0
mode64Msg       db "64-bit",13,10,0
mode128Msg      db "128-bit",13,10,0

cfgMenu1        db 13,10,"=== BIT SYSTEM CONFIGURATION ===",13,10,0
cfgMenu2        db "  1. 16-bit mode",13,10,0
cfgMenu3        db "  2. 32-bit mode",13,10,0
cfgMenu4        db "  3. 64-bit mode",13,10,0
cfgMenu5        db "  4. 128-bit mode",13,10,0
cfgPrompt       db "Select mode (1-4): ",0
cfgSetMsg       db "Configuration updated to ",0
cfgInvalidMsg   db "Invalid selection. Keeping current config.",13,10,0

.code

write_cstr PROC
    push rbx
    push rsi
    mov rsi, rcx
    xor r8d, r8d
    
cstr_count:
    mov bl, byte ptr [rsi+r8]
    test bl, bl
    jz cstr_write
    inc r8d
    jmp cstr_count
    
cstr_write:
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

read_line PROC
    ; Read a line from console into inputBuffer
    ; Returns first character in AL
    lea rdx, inputBuffer
    mov rcx, qword ptr [hStdIn]
    mov r8d, 31
    lea r9, charsRead
    sub rsp, 32
    mov qword ptr [rsp+32], 0
    call ReadConsoleA
    add rsp, 32

    mov al, byte ptr [inputBuffer]
    ret
read_line ENDP

bootloader_main PROC
    ; Display bootloader splash
    lea rcx, bootSplash
    call write_cstr
    lea rcx, bootSplash2
    call write_cstr
    lea rcx, bootSplash3
    call write_cstr
    lea rcx, bootSplash4
    call write_cstr
    lea rcx, bootSplash5
    call write_cstr
    lea rcx, bootSplash6
    call write_cstr
    lea rcx, bootSplash7
    call write_cstr
    
    ; Boot sequence
    lea rcx, bootMsg1
    call write_cstr
    
    mov rcx, 500
    sub rsp, 32
    call Sleep
    add rsp, 32
    
    lea rcx, bootMsg2
    call write_cstr
    
    mov rcx, 300
    sub rsp, 32
    call Sleep
    add rsp, 32
    
    lea rcx, bootMsg3
    call write_cstr
    
    mov rcx, 300
    sub rsp, 32
    call Sleep
    add rsp, 32
    
    lea rcx, bootMsg4
    call write_cstr
    
    mov rcx, 400
    sub rsp, 32
    call Sleep
    add rsp, 32
    
    lea rcx, bootMsg5
    call write_cstr
    
    mov rcx, 400
    sub rsp, 32
    call Sleep
    add rsp, 32
    
    lea rcx, bootMsg6
    call write_cstr
    
    ret
bootloader_main ENDP

display_main_menu PROC
    lea rcx, mainMenu
    call write_cstr
    lea rcx, mainMenu2
    call write_cstr
    lea rcx, mainMenu3
    call write_cstr
    lea rcx, option1
    call write_cstr
    lea rcx, option2
    call write_cstr
    lea rcx, option3
    call write_cstr
    lea rcx, option4
    call write_cstr
    lea rcx, option5
    call write_cstr
    lea rcx, option6
    call write_cstr
    lea rcx, option7
    call write_cstr
    lea rcx, option8
    call write_cstr
    lea rcx, option9
    call write_cstr
    lea rcx, mainMenuEnd
    call write_cstr

    lea rcx, currentCfgMsg
    call write_cstr
    call display_current_config
    
    lea rcx, prompt
    call write_cstr
    
    ret
display_main_menu ENDP

display_current_config PROC
    mov eax, dword ptr [bitConfig]
    cmp eax, 16
    je cfg_16
    cmp eax, 32
    je cfg_32
    cmp eax, 64
    je cfg_64
    cmp eax, 128
    je cfg_128

cfg_16:
    lea rcx, mode16Msg
    call write_cstr
    ret
cfg_32:
    lea rcx, mode32Msg
    call write_cstr
    ret
cfg_64:
    lea rcx, mode64Msg
    call write_cstr
    ret
cfg_128:
    lea rcx, mode128Msg
    call write_cstr
    ret
display_current_config ENDP

display_config_menu PROC
    lea rcx, cfgMenu1
    call write_cstr
    lea rcx, cfgMenu2
    call write_cstr
    lea rcx, cfgMenu3
    call write_cstr
    lea rcx, cfgMenu4
    call write_cstr
    lea rcx, cfgMenu5
    call write_cstr
    lea rcx, cfgPrompt
    call write_cstr
    ret
display_config_menu ENDP

apply_config_choice PROC
    ; Input: AL = choice character
    cmp al, '1'
    je set_16
    cmp al, '2'
    je set_32
    cmp al, '3'
    je set_64
    cmp al, '4'
    je set_128

    lea rcx, cfgInvalidMsg
    call write_cstr
    ret

set_16:
    mov dword ptr [bitConfig], 16
    jmp cfg_set_done
set_32:
    mov dword ptr [bitConfig], 32
    jmp cfg_set_done
set_64:
    mov dword ptr [bitConfig], 64
    jmp cfg_set_done
set_128:
    mov dword ptr [bitConfig], 128

cfg_set_done:
    lea rcx, cfgSetMsg
    call write_cstr
    call display_current_config
    ret
apply_config_choice ENDP

start PROC
    sub rsp, 40
    
    mov rcx, STD_OUTPUT_HANDLE
    sub rsp, 32
    call GetStdHandle
    add rsp, 32
    mov qword ptr [hStdOut], rax

    mov rcx, STD_INPUT_HANDLE
    sub rsp, 32
    call GetStdHandle
    add rsp, 32
    mov qword ptr [hStdIn], rax
    
    call bootloader_main

main_loop:
    call display_main_menu
    call read_line

    cmp al, '8'
    je do_shutdown
    cmp al, '9'
    je do_bit_config
    jmp main_loop

do_bit_config:
    call display_config_menu
    call read_line
    call apply_config_choice
    jmp main_loop

do_shutdown:
    
    ; Play startup beep
    mov rcx, 880
    sub rsp, 32
    call Beep
    add rsp, 32
    
    add rsp, 40
    xor ecx, ecx
    sub rsp, 32
    call ExitProcess
    add rsp, 32
    
    ret
start ENDP

END start
