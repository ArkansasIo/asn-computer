; ============================================================================
; ALTAIR 8800 OPERATING SYSTEM (ALTAIR/OS)
; Bootloader, Kernel, and Core OS Functions
; ============================================================================

.code

extern GetStdHandle:proc
extern WriteConsoleA:proc
extern ReadConsoleA:proc
extern SetConsoleCursorPosition:proc
extern Beep:proc

; ============================================================================
; OS CONSTANTS
; ============================================================================

.data

; OS Identification
OS_NAME:                db "ALTAIR/OS", 0
OS_VERSION:             db "1.0", 0
OS_BUILD:               dd 20260304
OS_AUTHOR:              db "Altair Systems", 0

; Boot sector signatures
BOOT_SIGNATURE_1:       db 0x55
BOOT_SIGNATURE_2:       db 0xAA

; OS Memory Layout
OS_BASE                 equ 0x0800      ; OS starts at 2 KB
OS_SIZE                 equ 0x2000      ; 8 KB for OS
PROGRAM_BASE            equ 0x2800      ; Programs start at 10 KB
PROGRAM_MAX             equ 0xE000 - 0x2800  ; ~44 KB for programs

; System state
current_program:        dd 0            ; Current program PID
program_counter:        dd PROGRAM_BASE ; Current PC
system_running:         db 1            ; System active flag

; System tick counter
system_ticks:           dd 0
system_uptime_sec:      dd 0

; Process table (max 16 processes)
process_table:          db 16*32 dup(0)     ; 16 processes, 32 bytes each

; ============================================================================
; SPLASH SCREEN DATA
; ============================================================================

splash_screen:
    db "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓", 0Dh, 0Ah
    db "┃     ALTAIR 8800 COMPUTER        ┃", 0Dh, 0Ah
    db "┃                                  ┃", 0Dh, 0Ah
    db "┃   ▄▄▄▄▄ ▄   ▄ ▄▄▄▄▄             ┃", 0Dh, 0Ah
    db "┃    █   █  █  █                  ┃", 0Dh, 0Ah
    db "┃    █   █▄▄▄█  ▄▄▄▄              ┃", 0Dh, 0Ah
    db "┃    █   █  █       █             ┃", 0Dh, 0Ah
    db "┃    █   █  █   ▄▄▄▄              ┃", 0Dh, 0Ah
    db "┃                                  ┃", 0Dh, 0Ah
    db "┃   ALTAIR/OS v1.0                ┃", 0Dh, 0Ah
    db "┃   March 4, 2026                 ┃", 0Dh, 0Ah
    db "┃                                  ┃", 0Dh, 0Ah
    db "┃   Loading system components...  ┃", 0Dh, 0Ah
    db "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛", 0Dh, 0Ah, 0

; Boot messages
boot_msg_1:             db "Initializing CPU...", 0Dh, 0Ah, 0
boot_msg_2:             db "Testing memory...", 0Dh, 0Ah, 0
boot_msg_3:             db "Loading kernel...", 0Dh, 0Ah, 0
boot_msg_4:             db "Mounting filesystems...", 0Dh, 0Ah, 0
boot_msg_5:             db "Starting shell...", 0Dh, 0Ah, 0

; ============================================================================
; MAIN OS ENTRY POINT (FROM BOOTLOADER)
; ============================================================================

os_main:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Get console handle
    mov rcx, -11                ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov r11, rax
    
    ; Display splash screen
    call display_splash_screen
    
    ; Boot sequence
    call init_cpu_subsystem
    call init_memory_subsystem
    call init_kernel
    call init_filesystems
    call init_shell
    
    ; Play startup sound
    mov rcx, 1000
    mov rdx, 200
    call Beep
    
    ; Enter main shell loop
    call shell_main_loop
    
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; DISPLAY SPLASH SCREEN
; ============================================================================

display_splash_screen:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [splash_screen]
    mov r8, 500                 ; Approximate length
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; INITIALIZATION FUNCTIONS
; ============================================================================

init_cpu_subsystem:
    push rbp
    mov rbp, rsp
    
    ; Display message
    call print_boot_message_1
    
    ; Initialize CPU
    ; Set base registers
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx
    
    pop rbp
    ret

init_memory_subsystem:
    push rbp
    mov rbp, rsp
    
    call print_boot_message_2
    
    ; Clear user memory
    mov rdi, PROGRAM_BASE
    mov rcx, PROGRAM_MAX
    xor al, al
    rep stosb
    
    pop rbp
    ret

init_kernel:
    push rbp
    mov rbp, rsp
    
    call print_boot_message_3
    
    ; Initialize process table
    mov edi, offset process_table
    mov ecx, 512                ; 16 * 32
    xor al, al
    rep stosb
    
    ; Initialize interrupt handlers
    ; Initialize device drivers
    
    pop rbp
    ret

init_filesystems:
    push rbp
    mov rbp, rsp
    
    call print_boot_message_4
    
    ; Would mount virtual filesystems
    
    pop rbp
    ret

init_shell:
    push rbp
    mov rbp, rsp
    
    call print_boot_message_5
    
    ; Initialize shell environment
    
    pop rbp
    ret

; ============================================================================
; PRINT BOOT MESSAGES
; ============================================================================

print_boot_message_1:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [boot_msg_1]
    mov r8, 20
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

print_boot_message_2:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [boot_msg_2]
    mov r8, 18
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

print_boot_message_3:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [boot_msg_3]
    mov r8, 20
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

print_boot_message_4:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [boot_msg_4]
    mov r8, 25
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

print_boot_message_5:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [boot_msg_5]
    mov r8, 20
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; SHELL MAIN LOOP
; ============================================================================

shell_main_loop:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Display main menu
shell_loop:
    call clear_screen
    call display_main_menu
    
    ; Get user input
    call get_user_input
    
    ; Process command
    mov al, [user_input_buffer]
    
    cmp al, '1'
    je launch_program
    cmp al, '2'
    je system_settings
    cmp al, '3'
    je file_manager
    cmp al, '4'
    je developer_console
    cmp al, '5'
    je system_monitor
    cmp al, '6'
    je help_system
    cmp al, '7'
    je shutdown_os
    
    jmp shell_loop
    
launch_program:
    call launcher_menu
    jmp shell_loop
    
system_settings:
    call settings_menu
    jmp shell_loop
    
file_manager:
    call file_manager_menu
    jmp shell_loop
    
developer_console:
    call developer_menu
    jmp shell_loop
    
system_monitor:
    call monitor_menu
    jmp shell_loop
    
help_system:
    call help_menu
    jmp shell_loop
    
shutdown_os:
    call shutdown_system
    jmp shell_done
    
shell_done:
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; MAIN MENU
; ============================================================================

display_main_menu:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [main_menu_text]
    mov r8, 400
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; MENU STRINGS
; ============================================================================

main_menu_text:
    db 0Dh, 0Ah
    db "╔═══════════════════════════════════════════╗", 0Dh, 0Ah
    db "║    ALTAIR/OS - MAIN MENU                 ║", 0Dh, 0Ah
    db "╠═══════════════════════════════════════════╣", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "║ 1. Run Program                           ║", 0Dh, 0Ah
    db "║ 2. System Settings                       ║", 0Dh, 0Ah
    db "║ 3. File Manager                          ║", 0Dh, 0Ah
    db "║ 4. Developer Console                     ║", 0Dh, 0Ah
    db "║ 5. System Monitor                        ║", 0Dh, 0Ah
    db "║ 6. Help & Documentation                  ║", 0Dh, 0Ah
    db "║ 7. Shutdown System                       ║", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "╚═══════════════════════════════════════════╝", 0Dh, 0Ah
    db 0Dh, 0Ah
    db "Enter selection (1-7): ", 0

; ============================================================================
; SUBMENU FUNCTIONS
; ============================================================================

launcher_menu:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    call clear_screen
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [launcher_menu_text]
    mov r8, 400
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    call get_user_input
    
    add rsp, 32
    pop rbp
    ret

settings_menu:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    call clear_screen
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [settings_menu_text]
    mov r8, 400
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    call get_user_input
    
    add rsp, 32
    pop rbp
    ret

file_manager_menu:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    call clear_screen
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [file_manager_text]
    mov r8, 400
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    call get_user_input
    
    add rsp, 32
    pop rbp
    ret

developer_menu:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    call clear_screen
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [developer_menu_text]
    mov r8, 400
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    call get_user_input
    
    add rsp, 32
    pop rbp
    ret

monitor_menu:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    call clear_screen
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [monitor_menu_text]
    mov r8, 400
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    ; Display system information
    call display_system_info
    
    add rsp, 32
    pop rbp
    ret

help_menu:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    call clear_screen
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [help_menu_text]
    mov r8, 400
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    call get_user_input
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; SUBMENU TEXT
; ============================================================================

launcher_menu_text:
    db 0Dh, 0Ah
    db "╔═══════════════════════════════════════════╗", 0Dh, 0Ah
    db "║    PROGRAM LAUNCHER                      ║", 0Dh, 0Ah
    db "╠═══════════════════════════════════════════╣", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "║ 1. Binary Counter                        ║", 0Dh, 0Ah
    db "║ 2. LED Chaser                            ║", 0Dh, 0Ah
    db "║ 3. Factorial Calculator                  ║", 0Dh, 0Ah
    db "║ 4. Memory Tester                         ║", 0Dh, 0Ah
    db "║ 5. Fibonacci Generator                   ║", 0Dh, 0Ah
    db "║ 6. Math Utilities                        ║", 0Dh, 0Ah
    db "║ 0. Back to Main Menu                     ║", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "╚═══════════════════════════════════════════╝", 0Dh, 0Ah
    db "Select program (0-6): ", 0

settings_menu_text:
    db 0Dh, 0Ah
    db "╔═══════════════════════════════════════════╗", 0Dh, 0Ah
    db "║    SYSTEM SETTINGS                       ║", 0Dh, 0Ah
    db "╠═══════════════════════════════════════════╣", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "║ 1. Display Settings                      ║", 0Dh, 0Ah
    db "║ 2. Keyboard Configuration                ║", 0Dh, 0Ah
    db "║ 3. Power Management                      ║", 0Dh, 0Ah
    db "║ 4. Speaker Volume                        ║", 0Dh, 0Ah
    db "║ 5. Date & Time                           ║", 0Dh, 0Ah
    db "║ 0. Back to Main Menu                     ║", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "╚═══════════════════════════════════════════╝", 0Dh, 0Ah
    db "Select option (0-5): ", 0

file_manager_text:
    db 0Dh, 0Ah
    db "╔═══════════════════════════════════════════╗", 0Dh, 0Ah
    db "║    FILE MANAGER                          ║", 0Dh, 0Ah
    db "╠═══════════════════════════════════════════╣", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "║ Floppy A: /PROGRAMS/                     ║", 0Dh, 0Ah
    db "║           /SYSTEM/                       ║", 0Dh, 0Ah
    db "║           /DATA/                         ║", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "║ 1. View Directory                        ║", 0Dh, 0Ah
    db "║ 2. Load Program                          ║", 0Dh, 0Ah
    db "║ 3. Save Program                          ║", 0Dh, 0Ah
    db "║ 0. Back to Main Menu                     ║", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "╚═══════════════════════════════════════════╝", 0Dh, 0Ah
    db "Select option (0-3): ", 0

developer_menu_text:
    db 0Dh, 0Ah
    db "╔═══════════════════════════════════════════╗", 0Dh, 0Ah
    db "║    DEVELOPER CONSOLE                     ║", 0Dh, 0Ah
    db "╠═══════════════════════════════════════════╣", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "║ 1. Assembler                             ║", 0Dh, 0Ah
    db "║ 2. Debugger                              ║", 0Dh, 0Ah
    db "║ 3. Memory Editor                         ║", 0Dh, 0Ah
    db "║ 4. Disassembler                          ║", 0Dh, 0Ah
    db "║ 5. Math Library Tester                   ║", 0Dh, 0Ah
    db "║ 6. Performance Analyzer                  ║", 0Dh, 0Ah
    db "║ 0. Back to Main Menu                     ║", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "╚═══════════════════════════════════════════╝", 0Dh, 0Ah
    db "Select tool (0-6): ", 0

monitor_menu_text:
    db 0Dh, 0Ah
    db "╔═══════════════════════════════════════════╗", 0Dh, 0Ah
    db "║    SYSTEM MONITOR                        ║", 0Dh, 0Ah
    db "╠═══════════════════════════════════════════╣", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah

help_menu_text:
    db 0Dh, 0Ah
    db "╔═══════════════════════════════════════════╗", 0Dh, 0Ah
    db "║    HELP & DOCUMENTATION                  ║", 0Dh, 0Ah
    db "╠═══════════════════════════════════════════╣", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "║ 1. Getting Started                       ║", 0Dh, 0Ah
    db "║ 2. Program Examples                      ║", 0Dh, 0Ah
    db "║ 3. Math Library Reference                ║", 0Dh, 0Ah
    db "║ 4. System API Documentation              ║", 0Dh, 0Ah
    db "║ 5. About ALTAIR/OS                       ║", 0Dh, 0Ah
    db "║ 0. Back to Main Menu                     ║", 0Dh, 0Ah
    db "║                                           ║", 0Dh, 0Ah
    db "╚═══════════════════════════════════════════╝", 0Dh, 0Ah
    db "Select option (0-5): ", 0

; ============================================================================
; UTILITY FUNCTIONS
; ============================================================================

clear_screen:
    ; Simulate screen clear with newlines
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [clear_seq]
    mov r8, 50
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

get_user_input:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Read user input from console
    lea rax, [user_input_buffer]
    
    add rsp, 64
    pop rbp
    ret

display_system_info:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [system_info_text]
    mov r8, 300
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

shutdown_system:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11
    call GetStdHandle
    mov r11, rax
    
    mov rcx, r11
    lea rdx, [shutdown_msg]
    mov r8, 50
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    ; Play shutdown sound
    mov rcx, 200
    mov rdx, 300
    call Beep
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; UTILITY STRINGS
; ============================================================================

clear_seq:              db 0Dh, 0Ah, 0Dh, 0Ah, 0Dh, 0Ah, 0Dh, 0Ah, 0
user_input_buffer:      db 0
system_info_text:       db "CPU: 3.072 MHz", 0Dh, 0Ah, "Memory: 64 KB", 0Dh, 0Ah, 0
shutdown_msg:           db "System shutting down...", 0Dh, 0Ah, 0

; ============================================================================
; END OF OS
; ============================================================================

end
