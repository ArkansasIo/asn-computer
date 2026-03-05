; =============================================================================
; PROGRAM LAUNCHER - Execute Loaded Programs and Utilities
; =============================================================================
; Purpose: Launch programs, manage execution, handle I/O redirection
; Author: Altair 8800 OS Development Team
; Date: March 4, 2026
; Version: 1.0
; =============================================================================

option casemap:none
EXTERN ExitProcess:PROC
EXTERN GetStdHandle:PROC
EXTERN WriteConsoleA:PROC
EXTERN Sleep:PROC
EXTERN Beep:PROC

; Constants
STD_OUTPUT_HANDLE       EQU -11
MAX_PROGRAMS            EQU 10
PROGRAM_STATE_IDLE      EQU 0
PROGRAM_STATE_RUNNING   EQU 1
PROGRAM_STATE_STOPPED   EQU 2
PROGRAM_STATE_ERROR     EQU 3

.data
moduleName              db "program_launcher", 0
version_str             db "1.0", 0

; Program registry
program_count           dd 0
program_states          dd MAX_PROGRAMS dup(PROGRAM_STATE_IDLE)
program_pids            dd MAX_PROGRAMS dup(0)
program_entry_points    dq MAX_PROGRAMS dup(0)
program_names           db MAX_PROGRAMS * 32 dup(0)

; Execution state
current_program_id      dd 0
current_program_state   dd PROGRAM_STATE_IDLE
current_pid             dd 0
last_exit_code          dd 0

; Output handles
std_output_handle       dq 0
console_output_buffer   db 1024 dup(0)

; Status messages
msg_program_start       db "[LAUNCHER] Starting program ID ", 0
msg_program_end         db "[LAUNCHER] Program completed with exit code: ", 0
msg_program_error       db "[LAUNCHER] Error executing program", 13, 10, 0
msg_invalid_id          db "[LAUNCHER] Invalid program ID", 13, 10, 0
msg_exit_code           db " Exit code: ", 0
msg_crlf                db 13, 10, 0

.code

; =============================================================================
; INITIALIZATION
; =============================================================================

init_launcher PROC
    ; Initialize program launcher
    ; Input: None
    ; Output: EAX = status
    
    push rbx
    push rcx
    
    mov dword ptr [program_count], 0
    mov dword ptr [current_program_id], 0
    mov dword ptr [current_program_state], PROGRAM_STATE_IDLE
    mov dword ptr [last_exit_code], 0
    
    ; Get console output handle
    mov rcx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov qword ptr [std_output_handle], rax
    
    xor eax, eax
    pop rcx
    pop rbx
    ret
init_launcher ENDP

; =============================================================================
; PROGRAM REGISTRATION
; =============================================================================

register_program PROC
    ; Register a program for launching
    ; Input: RCX = program name (ptr)
    ;        RDX = entry point (proc address)
    ; Output: EAX = program ID (or error -1)
    
    push rbx
    push rcx
    push rdi
    push rsi
    
    ; Check if room for more programs
    cmp dword ptr [program_count], MAX_PROGRAMS
    jge reg_error
    
    ; Get next program ID
    mov eax, dword ptr [program_count]
    mov ebx, eax
    inc dword ptr [program_count]
    
    ; Store entry point
    mov rax, rbx
    imul rax, 8
    mov rsi, offset program_entry_points
    add rsi, rax
    mov qword ptr [rsi], rdx
    
    ; Store program name (up to 32 chars)
    mov rax, rbx
    imul rax, 32
    mov rdi, offset program_names
    add rdi, rax
    
    mov rsi, rcx
    mov rax, 32
    
name_copy_loop:
    cmp rax, 0
    je name_copy_done
    mov cl, byte ptr [rsi]
    test cl, cl
    jz name_copy_done
    mov byte ptr [rdi], cl
    inc rsi
    inc rdi
    dec rax
    jmp name_copy_loop
    
name_copy_done:
    mov byte ptr [rdi], 0
    
    ; Set state to idle
    mov byte ptr [program_states + rbx], PROGRAM_STATE_IDLE
    
    mov eax, ebx
    jmp reg_done
    
reg_error:
    mov eax, -1
    
reg_done:
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret
register_program ENDP

; =============================================================================
; PROGRAM EXECUTION
; =============================================================================

launch_program PROC
    ; Launch/execute a registered program
    ; Input: ECX = program ID
    ; Output: EAX = exit code
    
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    push rsi
    
    ; Validate program ID
    cmp ecx, dword ptr [program_count]
    jge launch_invalid_id
    
    ; Set current program
    mov dword ptr [current_program_id], ecx
    mov byte ptr [program_states + rcx], PROGRAM_STATE_RUNNING
    mov dword ptr [current_program_state], PROGRAM_STATE_RUNNING
    
    ; Get entry point
    mov rax, rcx
    imul rax, 8
    mov rsi, offset program_entry_points
    mov rbx, qword ptr [rsi + rax]
    
    ; Assign PID (just use counter)
    mov eax, dword ptr [program_count]
    add eax, 1000
    mov dword ptr [program_pids + rcx * 4], eax
    mov dword ptr [current_pid], eax
    
    ; Call the program (simple simulation)
    call rbx
    
    ; Store exit code
    mov dword ptr [last_exit_code], eax
    
    ; Update program state
    mov ecx, dword ptr [current_program_id]
    mov byte ptr [program_states + rcx], PROGRAM_STATE_STOPPED
    
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret
    
launch_invalid_id:
    ; Print error message
    mov rcx, offset msg_invalid_id
    call write_string
    mov eax, -1
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret
launch_program ENDP

launch_program_by_name PROC
    ; Launch a program by name
    ; Input: RCX = program name (ptr)
    ; Output: EAX = exit code
    
    push rbx
    push rcx
    push rdi
    push rsi
    
    xor ebx, ebx
    
search_loop:
    cmp ebx, dword ptr [program_count]
    jge not_found
    
    ; Get program name
    mov rax, rbx
    imul rax, 32
    mov rdi, offset program_names
    add rdi, rax
    
    ; Compare names
    mov rsi, rcx
    call string_compare
    test eax, eax
    jz found_program
    
    inc ebx
    jmp search_loop
    
found_program:
    mov ecx, ebx
    call launch_program
    jmp search_done
    
not_found:
    mov eax, -1
    
search_done:
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret
launch_program_by_name ENDP

; =============================================================================
; UTILITIES
; =============================================================================

write_string PROC
    ; Write a string to console
    ; Input: RCX = string pointer
    ; Output: None
    
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov rsi, rcx
    xor ecx, ecx
    
count_loop:
    mov al, byte ptr [rsi + rcx]
    test al, al
    jz count_done
    inc ecx
    jmp count_loop
    
count_done:
    mov edx, ecx                    ; Length in EDX
    mov rcx, qword ptr [std_output_handle]
    mov r8, offset console_output_buffer
    xor r9d, r9d
    call WriteConsoleA
    
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
write_string ENDP

string_compare PROC
    ; Compare two strings
    ; Input: RDI = string 1, RSI = string 2
    ; Output: EAX = 0 if equal, non-zero if different
    
    xor eax, eax
    pushonce
    
compare_loop:
    mov al, byte ptr [rdi]
    mov cl, byte ptr [rsi]
    cmp al, cl
    jne compare_not_equal
    test al, al
    jz compare_equal
    inc rdi
    inc rsi
    jmp compare_loop
    
compare_equal:
    xor eax, eax
    ret
    
compare_not_equal:
    sub eax, ecx
    ret
string_compare ENDP

get_program_count PROC
    ; Get total number of registered programs
    ; Output: EAX = count
    
    mov eax, dword ptr [program_count]
    ret
get_program_count ENDP

get_program_state PROC
    ; Get execution state of program
    ; Input: ECX = program ID
    ; Output: EAX = state
    
    cmp ecx, dword ptr [program_count]
    jge get_state_error
    
    movzx eax, byte ptr [program_states + rcx]
    ret
    
get_state_error:
    mov eax, -1
    ret
get_program_state ENDP

get_last_exit_code PROC
    ; Get exit code of last executed program
    ; Output: EAX = exit code
    
    mov eax, dword ptr [last_exit_code]
    ret
get_last_exit_code ENDP

END
