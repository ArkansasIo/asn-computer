; ALTAIR 8800 ADVANCED FEATURES
; x86-64 Assembly for Windows (MASM)
; Advanced LED animations, bitwise operations, sound synthesis
; ~800 lines

option casemap:none

EXTERN WriteConsoleA:PROC
EXTERN Beep:PROC
EXTERN Sleep:PROC

.data
; Console Handle (inherited from emulator)
extern hStdOut:qw
extern charsWritten:qw

; LED Animation States
counterState    db 0
chaserState     db 1
pulseLevel      db 0
pulseDir        db 1
screenCursorX   db 0
screenCursorY   db 0

; Screen Buffer (16x16)
extern screenBuffer:byte

; Sine/Square wave lookup tables
sinTable        db 0, 25, 49, 71, 90, 105, 117, 124, 127, 124, 117, 105, 90, 71, 49, 25
squareTable     db 0, 0, 0, 0, 0, 0, 0, 0, 127, 127, 127, 127, 127, 127, 127, 127

; Animation messages
counterMsg      db "Counter: ",0
chaserMsg       db "Chaser: ",0
pulseMsg        db "Pulse: ",0
newLine         db 13,10,0

.code

; ============================================================================
; EXTERNAL PROCEDURES (from emulator)
; ============================================================================

extern write_cstr:PROC
extern write_char:PROC
extern write_binary:PROC
extern delay_milliseconds:PROC

; ============================================================================
; LED COUNTER ANIMATION
; ============================================================================

animate_led_counter PROC
    ; Increment counter and wrap at 255
    mov al, [counterState]
    inc al
    mov [counterState], al
    ret
animate_led_counter ENDP

display_counter_state PROC
    ; Display current counter value
    lea rcx, counterMsg
    call write_cstr
    
    mov al, [counterState]
    call write_binary
    
    lea rcx, newLine
    call write_cstr
    ret
display_counter_state ENDP

; ============================================================================
; LED CHASER ANIMATION
; ============================================================================

animate_led_chaser PROC
    ; Rotate LED chaser pattern
    mov al, [chaserState]
    rol al, 1
    jnz chaser_store
    mov al, 1
    
chaser_store:
    mov [chaserState], al
    ret
animate_led_chaser ENDP

display_chaser_state PROC
    ; Display chaser pattern
    lea rcx, chaserMsg
    call write_cstr
    
    mov al, [chaserState]
    call write_binary
    
    lea rcx, newLine
    call write_cstr
    ret
display_chaser_state ENDP

; ============================================================================
; LED PULSE ANIMATION
; ============================================================================

animate_led_pulse PROC
    ; Pulse effect: brighten then dim
    mov al, [pulseDir]
    cmp al, 0
    je pulse_dim_phase
    
    ; Brightness increasing
    mov al, [pulseLevel]
    add al, 8
    jc pulse_clamp_high
    cmp al, 248
    ja pulse_clamp_high
    mov [pulseLevel], al
    ret
    
pulse_clamp_high:
    mov byte ptr [pulseLevel], 248
    mov byte ptr [pulseDir], 0
    ret
    
pulse_dim_phase:
    ; Brightness decreasing
    mov al, [pulseLevel]
    sub al, 8
    jnc pulse_dim_store
    xor al, al
    
pulse_dim_store:
    mov [pulseLevel], al
    
    cmp al, 0
    jne pulse_end
    mov byte ptr [pulseDir], 1
    
pulse_end:
    ret
animate_led_pulse ENDP

display_pulse_state PROC
    ; Display pulse level
    lea rcx, pulseMsg
    call write_cstr
    
    mov al, [pulseLevel]
    call write_binary
    
    lea rcx, newLine
    call write_cstr
    ret
display_pulse_state ENDP

; ============================================================================
; BITWISE OPERATIONS (8-BIT)
; ============================================================================

bitwise_and_8 PROC
    ; AL &= BL, stores result in RAX
    and al, bl
    ret
bitwise_and_8 ENDP

bitwise_or_8 PROC
    ; AL |= BL
    or al, bl
    ret
bitwise_or_8 ENDP

bitwise_xor_8 PROC
    ; AL ^= BL
    xor al, bl
    ret
bitwise_xor_8 ENDP

bitwise_not_8 PROC
    ; AL = ~AL
    not al
    ret
bitwise_not_8 ENDP

; ============================================================================
; BITWISE OPERATIONS (16-BIT)
; ============================================================================

bitwise_and_16 PROC
    ; AX &= BX
    and ax, bx
    ret
bitwise_and_16 ENDP

bitwise_or_16 PROC
    ; AX |= BX
    or ax, bx
    ret
bitwise_or_16 ENDP

bitwise_xor_16 PROC
    ; AX ^= BX
    xor ax, bx
    ret
bitwise_xor_16 ENDP

bitwise_not_16 PROC
    ; AX = ~AX
    not ax
    ret
bitwise_not_16 ENDP

; ============================================================================
; BITWISE OPERATIONS (32-BIT)
; ============================================================================

bitwise_and_32 PROC
    ; EAX &= EBX
    and eax, ebx
    ret
bitwise_and_32 ENDP

bitwise_or_32 PROC
    ; EAX |= EBX
    or eax, ebx
    ret
bitwise_or_32 ENDP

bitwise_xor_32 PROC
    ; EAX ^= EBX
    xor eax, ebx
    ret
bitwise_xor_32 ENDP

bitwise_not_32 PROC
    ; EAX = ~EAX
    not eax
    ret
bitwise_not_32 ENDP

; ============================================================================
; BITWISE OPERATIONS (64-BIT)
; ============================================================================

bitwise_and_64 PROC
    ; RAX &= RBX
    and rax, rbx
    ret
bitwise_and_64 ENDP

bitwise_or_64 PROC
    ; RAX |= RBX
    or rax, rbx
    ret
bitwise_or_64 ENDP

bitwise_xor_64 PROC
    ; RAX ^= RBX
    xor rax, rbx
    ret
bitwise_xor_64 ENDP

bitwise_not_64 PROC
    ; RAX = ~RAX
    not rax
    ret
bitwise_not_64 ENDP

; ============================================================================
; BIT SHIFT OPERATIONS
; ============================================================================

bitshift_left_8 PROC
    ; AL <<= CL
    shl al, cl
    ret
bitshift_left_8 ENDP

bitshift_right_8 PROC
    ; AL >>= CL
    shr al, cl
    ret
bitshift_right_8 ENDP

bitshift_left_16 PROC
    ; AX <<= CX
    shl ax, cl
    ret
bitshift_left_16 ENDP

bitshift_right_16 PROC
    ; AX >>= CX
    shr ax, cl
    ret
bitshift_right_16 ENDP

bitshift_left_32 PROC
    ; EAX <<= ECX
    shl eax, cl
    ret
bitshift_left_32 ENDP

bitshift_right_32 PROC
    ; EAX >>= ECX
    shr eax, cl
    ret
bitshift_right_32 ENDP

bitshift_left_64 PROC
    ; RAX <<= RCX
    shl rax, cl
    ret
bitshift_left_64 ENDP

bitshift_right_64 PROC
    ; RAX >>= RCX
    shr rax, cl
    ret
bitshift_right_64 ENDP

; ============================================================================
; BIT ROTATE OPERATIONS
; ============================================================================

bitrotate_left_8 PROC
    ; AL ROL CL
    rol al, cl
    ret
bitrotate_left_8 ENDP

bitrotate_right_8 PROC
    ; AL ROR CL
    ror al, cl
    ret
bitrotate_right_8 ENDP

bitrotate_left_16 PROC
    ; AX ROL CX
    rol ax, cl
    ret
bitrotate_left_16 ENDP

bitrotate_right_16 PROC
    ; AX ROR CX
    ror ax, cl
    ret
bitrotate_right_16 ENDP

bitrotate_left_32 PROC
    ; EAX ROL ECX
    rol eax, cl
    ret
bitrotate_left_32 ENDP

bitrotate_right_32 PROC
    ; EAX ROR ECX
    ror eax, cl
    ret
bitrotate_right_32 ENDP

bitrotate_left_64 PROC
    ; RAX ROL RCX
    rol rax, cl
    ret
bitrotate_left_64 ENDP

bitrotate_right_64 PROC
    ; RAX ROR RCX
    ror rax, cl
    ret
bitrotate_right_64 ENDP

; ============================================================================
; SOUND SYNTHESIS
; ============================================================================

synthesize_sine_wave PROC
    ; RCX = frequency, RDX = duration (ms), R8 = amplitude
    ; Generate sine wave at given frequency
    
    mov r9, rcx         ; frequency
    mov r10, rdx        ; duration
    
sine_loop:
    test r10, r10
    jz sine_done
    
    ; Use sine table lookup
    mov al, [rsi + sinTable]
    mov rcx, r9
    
    sub rsp, 32
    call Beep
    add rsp, 32
    
    dec r10
    jmp sine_loop
    
sine_done:
    ret
synthesize_sine_wave ENDP

synthesize_square_wave PROC
    ; Simple square wave
    mov r9, rcx         ; frequency
    mov r10, rdx        ; duration
    
square_loop:
    test r10, r10
    jz square_done
    
    mov rcx, r9
    sub rsp, 32
    call Beep
    add rsp, 32
    
    dec r10
    jmp square_loop
    
square_done:
    ret
synthesize_square_wave ENDP

; ============================================================================
; ADVANCED SOUND EFFECTS
; ============================================================================

sound_ascending_tones PROC
    ; Play ascending tone sequence
    mov rcx, 400
    sub rsp, 32
    call Beep
    add rsp, 32
    mov rcx, 100
    call delay_milliseconds
    
    mov rcx, 500
    sub rsp, 32
    call Beep
    add rsp, 32
    mov rcx, 100
    call delay_milliseconds
    
    mov rcx, 600
    sub rsp, 32
    call Beep
    add rsp, 32
    mov rcx, 100
    call delay_milliseconds
    
    mov rcx, 700
    sub rsp, 32
    call Beep
    add rsp, 32
    ret
sound_ascending_tones ENDP

sound_descending_tones PROC
    ; Play descending tone sequence
    mov rcx, 700
    sub rsp, 32
    call Beep
    add rsp, 32
    mov rcx, 100
    call delay_milliseconds
    
    mov rcx, 600
    sub rsp, 32
    call Beep
    add rsp, 32
    mov rcx, 100
    call delay_milliseconds
    
    mov rcx, 500
    sub rsp, 32
    call Beep
    add rsp, 32
    mov rcx, 100
    call delay_milliseconds
    
    mov rcx, 400
    sub rsp, 32
    call Beep
    add rsp, 32
    ret
sound_descending_tones ENDP

; ============================================================================
; SCREEN BUFFER OPERATIONS
; ============================================================================

clear_screen_buffer PROC
    ; Fill entire screen buffer with spaces
    xor rsi, rsi
    mov al, 0x20
    
clear_loop:
    cmp rsi, 256
    jge clear_done
    
    mov byte ptr [screenBuffer + rsi], al
    inc rsi
    jmp clear_loop
    
clear_done:
    mov byte ptr [screenCursorX], 0
    mov byte ptr [screenCursorY], 0
    ret
clear_screen_buffer ENDP

put_char_at PROC
    ; RCX = X (0-15), RDX = Y (0-15), R8B = character
    ; Calculate buffer offset: Y * 16 + X
    mov rax, rdx
    imul rax, 16
    add rax, rcx
    
    cmp rax, 256
    jge put_char_err
    
    mov byte ptr [screenBuffer + rax], r8b
    ret
    
put_char_err:
    ret
put_char_at ENDP

print_at_cursor PROC
    ; RCX = string pointer
    ; Prints string at current cursor position
    mov rsi, rcx
    
print_loop:
    mov al, byte ptr [rsi]
    test al, al
    jz print_done
    
    mov r8b, al
    mov rcx, [screenCursorX]
    mov rdx, [screenCursorY]
    call put_char_at
    
    mov al, [screenCursorX]
    inc al
    cmp al, 16
    jl cursor_no_wrap
    
    xor al, al
    mov byte ptr [screenCursorY], 0
    
cursor_no_wrap:
    mov byte ptr [screenCursorX], al
    inc rsi
    jmp print_loop
    
print_done:
    ret
print_at_cursor ENDP

; ============================================================================
; BIT COUNTING OPERATIONS
; ============================================================================

popcount_8 PROC
    ; Count set bits in AL
    xor ecx, ecx
    
popcount_8_loop:
    test al, al
    jz popcount_8_done
    
    test al, 1
    jz popcount_8_next
    inc ecx
    
popcount_8_next:
    shr al, 1
    jmp popcount_8_loop
    
popcount_8_done:
    mov al, cl
    ret
popcount_8 ENDP

popcount_16 PROC
    ; Count set bits in AX
    xor ecx, ecx
    
popcount_16_loop:
    test ax, ax
    jz popcount_16_done
    
    test ax, 1
    jz popcount_16_next
    inc ecx
    
popcount_16_next:
    shr ax, 1
    jmp popcount_16_loop
    
popcount_16_done:
    mov ax, cx
    ret
popcount_16 ENDP

; ============================================================================
; BIT SCANNING OPERATIONS
; ============================================================================

bitscan_forward PROC
    ; Find first set bit position in RAX
    ; Returns position in RAX (0-63), RCX = 0 if not found
    
    xor rcx, rcx
    
bsf_loop:
    cmp rcx, 64
    jge bsf_not_found
    
    bt rax, rcx
    jc bsf_found
    
    inc rcx
    jmp bsf_loop
    
bsf_found:
    mov rax, rcx
    mov rcx, 1
    ret
    
bsf_not_found:
    xor rcx, rcx
    ret
bitscan_forward ENDP

; ============================================================================
; SWITCH INPUT PROCESSING
; ============================================================================

extern switchStates:byte

process_switch_input PROC
    ; RCX = switch ID (0-15)
    ; RDX = press action (0=release, 1=press)
    
    cmp rcx, 15
    ja switch_input_err
    
    mov byte ptr [switchStates + rcx], dl
    
switch_input_err:
    ret
process_switch_input ENDP

; ============================================================================
; COMBINED ANIMATION DEMO
; ============================================================================

demo_all_animations PROC
    call animate_led_counter
    call display_counter_state
    
    call animate_led_chaser
    call display_chaser_state
    
    call animate_led_pulse
    call display_pulse_state
    
    ret
demo_all_animations ENDP

END
    jnc store_low
    xor al, al
store_low:
    mov pulseLevel, al
    cmp al, 0
    jne pulse_done
    mov pulseDir, 1
pulse_done:
    ret
animate_led_pulse ENDP

synthesize_tone_sine PROC
    ; ECX = frequency, EDX = duration
    call Beep
    ret
synthesize_tone_sine ENDP

END
