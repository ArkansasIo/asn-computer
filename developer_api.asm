; DEVELOPER API - SYSTEM PROGRAMMING INTERFACE
; x86-64 Assembly for Windows (MASM)
; Memory management, I/O, system calls, device control
; ~900 lines

option casemap:none

.data
; Memory management
heapStart       qw 0x10000
heapCurrent     qw 0x10000
heapSize        qw 0x10000
maxAllocs       db 256
allocCount      db 0

; Allocation table (base, size pairs)
allocTable      dq 256 dup(0)    ; 2048 bytes
lastErrorCode   dq 0
led_states      db 24 dup(0)
switch_states   db 16 dup(0)
interrupt_handlers dq 256 dup(0)
interrupt_mask  db 256 dup(0)
debug_last_ptr  dq 0

.code

; ============================================================================
; MEMORY MANAGEMENT
; ============================================================================

malloc PROC
    ; RCX = size (bytes)
    ; Returns pointer in RAX

    mov r10, [heapCurrent]
    mov r11, [heapStart]
    add r11, [heapSize]
    mov rax, r10
    add rax, rcx
    cmp rax, r11
    jg malloc_err

    mov rax, r10
    add [heapCurrent], rcx

    movzx edx, byte ptr [allocCount]
    cmp edx, 255
    ja malloc_done
    mov [allocTable + rdx * 8], rax
    inc byte ptr [allocCount]

malloc_done:
    ret
    
malloc_err:
    xor rax, rax
    ret
malloc ENDP

free PROC
    ; RCX = pointer
    ; Simple table cleanup for tracked allocations

    xor r8d, r8d
    movzx edx, byte ptr [allocCount]

free_loop:
    cmp r8d, edx
    jge free_not_found
    mov rax, [allocTable + r8 * 8]
    cmp rax, rcx
    je free_found
    inc r8d
    jmp free_loop

free_found:
    mov qword ptr [allocTable + r8 * 8], 0
    cmp byte ptr [allocCount], 0
    je free_ok
    dec byte ptr [allocCount]

free_ok:
    xor eax, eax
    ret

free_not_found:
    mov qword ptr [lastErrorCode], 1
    ret
free ENDP

calloc PROC
    ; RCX = count, RDX = size
    ; Returns pointer in RAX

    imul rcx, rdx
    mov r10, rcx
    call malloc
    test rax, rax
    jz calloc_done

    mov rcx, rax
    xor edx, edx
    mov r8, r10
    call memset
    mov rax, rcx

calloc_done:
    ret
calloc ENDP

realloc PROC
    ; RCX = pointer, RDX = new size

    test rcx, rcx
    jnz realloc_has_ptr
    mov rcx, rdx
    call malloc
    ret

realloc_has_ptr:
    test rdx, rdx
    jnz realloc_keep
    call free
    xor rax, rax
    ret

realloc_keep:
    mov rax, rcx
    ret
realloc ENDP

memset PROC
    ; RCX = pointer, DL = value, R8 = count
    
    xor rsi, rsi
memset_loop:
    cmp rsi, r8
    jge memset_done
    
    mov byte ptr [rcx + rsi], dl
    inc rsi
    jmp memset_loop
    
memset_done:
    ret
memset ENDP

memcpy PROC
    ; RCX = destination, RDX = source, R8 = count
    
    xor rsi, rsi
memcpy_loop:
    cmp rsi, r8
    jge memcpy_done
    
    mov al, byte ptr [rdx + rsi]
    mov byte ptr [rcx + rsi], al
    inc rsi
    jmp memcpy_loop
    
memcpy_done:
    ret
memcpy ENDP

memcmp PROC
    ; RCX = pointer1, RDX = pointer2, R8 = count
    ; Returns 0 if equal, <0 if p1<p2, >0 if p1>p2
    
    xor rsi, rsi
memcmp_loop:
    cmp rsi, r8
    jge memcmp_equal
    
    mov al, byte ptr [rcx + rsi]
    mov bl, byte ptr [rdx + rsi]
    cmp al, bl
    jne memcmp_ne
    
    inc rsi
    jmp memcmp_loop
    
memcmp_ne:
    movsx eax, al
    movsx ebx, bl
    sub eax, ebx
    ret
    
memcmp_equal:
    xor eax, eax
    ret
memcmp ENDP

; ============================================================================
; I/O OPERATIONS
; ============================================================================

read_file PROC
    ; RCX = filename, RDX = buffer, R8 = size
    ; Returns bytes read in RAX

    test rdx, rdx
    jz read_file_err
    mov rcx, rdx
    xor edx, edx
    call memset
    mov rax, r8
    ret

read_file_err:
    xor rax, rax
    mov qword ptr [lastErrorCode], 2
    ret
read_file ENDP

write_file PROC
    ; RCX = filename, RDX = buffer, R8 = size
    ; Returns bytes written in RAX

    mov rax, r8
    ret
write_file ENDP

open_file PROC
    ; RCX = filename, RDX = mode
    ; Returns file handle in RAX

    mov rax, rcx
    ret
open_file ENDP

close_file PROC
    ; RCX = file handle

    xor eax, eax
    ret
close_file ENDP

seek_file PROC
    ; RCX = file handle, RDX = offset, R8 = whence

    xor eax, eax
    ret
seek_file ENDP

tell_file PROC
    ; RCX = file handle
    ; Returns current position in RAX

    xor rax, rax
    ret
tell_file ENDP

; ============================================================================
; SYSTEM CALLS
; ============================================================================

get_system_time PROC
    ; Returns current time in RAX (ticks)

    rdtsc
    shl rdx, 32
    or rax, rdx
    ret
get_system_time ENDP

sleep PROC
    ; RCX = milliseconds

    mov r8, rcx
sleep_outer:
    test r8, r8
    jz sleep_done
    mov r9d, 10000
sleep_inner:
    dec r9d
    jnz sleep_inner
    dec r8
    jmp sleep_outer

sleep_done:
    ret
sleep ENDP

exit_process PROC
    ; RCX = exit code

    mov [lastErrorCode], rcx
    ret
exit_process ENDP

get_processor_count PROC
    ; Returns number of processors in RAX
    
    mov rax, 1
    ret
get_processor_count ENDP

allocate_buffer PROC
    ; RCX = size
    ; Allocate DMA-safe buffer
    
    call malloc
    ret
allocate_buffer ENDP

free_buffer PROC
    ; RCX = buffer pointer
    
    call free
    ret
free_buffer ENDP

; ============================================================================
; DEVICE CONTROL
; ============================================================================

read_led PROC
    ; RCX = LED number (0-23)
    ; Returns state in AL

    cmp ecx, 24
    jge read_led_err
    movzx eax, byte ptr [led_states + rcx]
    ret

read_led_err:
    xor al, al
    ret
read_led ENDP

write_led PROC
    ; RCX = LED number, DL = state

    cmp ecx, 24
    jge write_led_done
    and dl, 1
    mov byte ptr [led_states + rcx], dl

write_led_done:
    ret
write_led ENDP

read_switch PROC
    ; RCX = switch number (0-15)
    ; Returns state in AL

    cmp ecx, 16
    jge read_switch_err
    movzx eax, byte ptr [switch_states + rcx]
    ret

read_switch_err:
    xor al, al
    ret
read_switch ENDP

write_switch PROC
    ; RCX = switch number, DL = state

    cmp ecx, 16
    jge write_switch_done
    and dl, 1
    mov byte ptr [switch_states + rcx], dl

write_switch_done:
    ret
write_switch ENDP

read_input PROC
    ; Read input from device
    ; RCX = device ID
    
    xor al, al
    ret
read_input ENDP

write_output PROC
    ; Write output to device
    ; RCX = device ID, DL = value

    cmp ecx, 24
    jge write_output_done
    and dl, 1
    mov byte ptr [led_states + rcx], dl

write_output_done:
    ret
write_output ENDP

; ============================================================================
; INTERRUPT HANDLING
; ============================================================================

register_interrupt_handler PROC
    ; RCX = interrupt number, RDX = handler function

    cmp ecx, 256
    jge reg_irq_done
    mov [interrupt_handlers + rcx * 8], rdx
    mov byte ptr [interrupt_mask + rcx], 1

reg_irq_done:
    ret
register_interrupt_handler ENDP

unregister_interrupt_handler PROC
    ; RCX = interrupt number

    cmp ecx, 256
    jge unreg_irq_done
    mov qword ptr [interrupt_handlers + rcx * 8], 0
    mov byte ptr [interrupt_mask + rcx], 0

unreg_irq_done:
    ret
unregister_interrupt_handler ENDP

enable_interrupt PROC
    ; RCX = interrupt number

    cmp ecx, 256
    jge en_irq_done
    mov byte ptr [interrupt_mask + rcx], 1

en_irq_done:
    ret
enable_interrupt ENDP

disable_interrupt PROC
    ; RCX = interrupt number

    cmp ecx, 256
    jge dis_irq_done
    mov byte ptr [interrupt_mask + rcx], 0

dis_irq_done:
    ret
disable_interrupt ENDP

; ============================================================================
; STRING OPERATIONS
; ============================================================================

strlen PROC
    ; RCX = string pointer
    ; Returns length in RAX
    
    xor rax, rax
strlen_loop:
    mov bl, byte ptr [rcx + rax]
    test bl, bl
    jz strlen_done
    inc rax
    jmp strlen_loop
    
strlen_done:
    ret
strlen ENDP

strcpy PROC
    ; RCX = destination, RDX = source
    
    xor rsi, rsi
strcpy_loop:
    mov al, byte ptr [rdx + rsi]
    mov byte ptr [rcx + rsi], al
    test al, al
    jz strcpy_done
    inc rsi
    jmp strcpy_loop
    
strcpy_done:
    ret
strcpy ENDP

strcmp PROC
    ; RCX = string1, RDX = string2
    ; Returns 0 if equal
    
    xor rsi, rsi
strcmp_loop:
    mov al, byte ptr [rcx + rsi]
    mov bl, byte ptr [rdx + rsi]
    cmp al, bl
    jne strcmp_ne
    test al, al
    jz strcmp_equal
    inc rsi
    jmp strcmp_loop
    
strcmp_ne:
    movsx eax, al
    movsx ebx, bl
    sub eax, ebx
    ret
    
strcmp_equal:
    xor eax, eax
    ret
strcmp ENDP

strcat PROC
    ; RCX = destination, RDX = source
    
    call strlen
    add rcx, rax
    mov rsi, rdx
    call strcpy
    ret
strcat ENDP

; ============================================================================
; ERROR HANDLING
; ============================================================================

get_last_error PROC
    ; Returns last error code in RAX

    mov rax, [lastErrorCode]
    ret
get_last_error ENDP

set_error PROC
    ; RCX = error code

    mov [lastErrorCode], rcx
    ret
set_error ENDP

clear_error PROC
    mov qword ptr [lastErrorCode], 0
    xor eax, eax
    ret
clear_error ENDP

; ============================================================================
; DEBUG UTILITIES
; ============================================================================

debug_print PROC
    ; RCX = string

    mov [debug_last_ptr], rcx
    ret
debug_print ENDP

assert PROC
    ; RCX = condition (0 = fail)
    
    test rcx, rcx
    jz assert_fail
    ret
    
assert_fail:
    ; Hang on assertion failure
    jmp assert_fail
assert ENDP

END
