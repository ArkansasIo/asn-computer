option casemap:none

EXTERN Beep:PROC

.data
counterState    db 0
chaserState     db 1
pulseLevel      db 0
pulseDir        db 1

.code

animate_led_counter PROC
    mov al, counterState
    inc al
    mov counterState, al
    ret
animate_led_counter ENDP

animate_led_chaser PROC
    mov al, chaserState
    rol al, 1
    jnz store_chaser
    mov al, 1
store_chaser:
    mov chaserState, al
    ret
animate_led_chaser ENDP

animate_led_pulse PROC
    mov al, pulseDir
    cmp al, 0
    je dec_phase

    mov al, pulseLevel
    add al, 8
    jc clamp_high
    cmp al, 248
    ja clamp_high
    mov pulseLevel, al
    ret

clamp_high:
    mov pulseLevel, 248
    mov pulseDir, 0
    ret

dec_phase:
    mov al, pulseLevel
    sub al, 8
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
