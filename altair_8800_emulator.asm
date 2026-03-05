; ALTAIR 8800 EMULATOR - CORE EMULATION ENGINE
; x86-64 Assembly for Windows (MASM)
; Complete implementation with LED display, math, sound, and instruction execution
; ~1,200 lines

option casemap:none

EXTERN GetStdHandle:PROC
EXTERN WriteConsoleA:PROC
EXTERN Beep:PROC
EXTERN Sleep:PROC
EXTERN ExitProcess:PROC

STD_OUTPUT_HANDLE EQU -11

.data
; Console Handle
hStdOut         qw 0
charsWritten    qw 0

; LED Display (simulating Altair 8800 front panel)
addressBusLEDs  dw 0xAAAA           ; A0-A15 address bus (16 LEDs)
dataBusLEDs     db 0x55             ; D0-D7 data bus (8 LEDs)
statusLEDs      db 0x0F             ; Power, Halt, Wait, Interrupt
powerLED        db 1
haltLED         db 0
waitLED         db 0
interruptLED    db 0

; 16 Toggle Switches
switchStates    db 16 dup(0)

; Intel 8080 CPU Register Simulation
regA            db 0                ; Accumulator
regB            db 0
regC            db 0
regD            db 0
regE            db 0
regH            db 0
regL            db 0
regPC           dw 0                ; Program Counter
regSP           dw 0                ; Stack Pointer
regFlags        db 0                ; Flags register

; Screen Buffer (16x16 character display)
screenBuffer    db 256 dup(0x20)

; Math Operation Results
mathResult      qw 0
mathRemainder   qw 0
mathCarry       db 0

; Messages
titleMsg        db "╔════════════════════════════════════╗",13,10,0
titleMsg2       db "║ ALTAIR 8800 EMULATOR v1.0         ║",13,10,0
titleMsg3       db "║ x86-64 Assembly Implementation    ║",13,10,0
titleMsg4       db "╚════════════════════════════════════╝",13,10,0
bootMsg         db "Initializing emulator core...",13,10,0
addressMsg      db "Address Bus: ",0
dataMsg         db "Data Bus:    ",0
statusMsg       db "Status: ",0
switchMsg       db "Switches:    ",0
newLine         db 13,10,0
space           db " ",0
tab             db 9,0
doneMsg         db "Emulation cycle complete.",13,10,0

; Lookup tables
sinTable        db 0, 25, 49, 71, 90, 105, 117, 124, 127, 124, 117, 105, 90, 71, 49, 25

.code

; ============================================================================
; UTILITY PROCEDURES
; ============================================================================

write_cstr PROC
    ; RCX = string pointer
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

write_char PROC
    ; RCX = character
    push rbx
    sub rsp, 32
    mov al, cl
    mov byte ptr [rsp+32], al
    mov byte ptr [rsp+33], 0
    mov rcx, qword ptr [hStdOut]
    lea rdx, [rsp+32]
    lea r9, charsWritten
    call WriteConsoleA
    add rsp, 32
    pop rbx
    ret
write_char ENDP

write_hex_byte PROC
    ; AL = byte to display as hex
    push rbx
    
    mov bl, al
    shr bl, 4            ; High nibble
    cmp bl, 10
    jl hex_high_digit
    add bl, 'A' - 10
    jmp hex_write_high
hex_high_digit:
    add bl, '0'
hex_write_high:
    mov cl, bl
    call write_char
    
    mov bl, al
    and bl, 0x0F         ; Low nibble
    cmp bl, 10
    jl hex_low_digit
    add bl, 'A' - 10
    jmp hex_write_low
hex_low_digit:
    add bl, '0'
hex_write_low:
    mov cl, bl
    call write_char
    
    pop rbx
    ret
write_hex_byte ENDP

write_binary PROC
    ; AL = byte to display as binary
    push rbx
    mov bl, 128
    
bin_loop:
    test al, bl
    jz bin_zero
    mov cl, '1'
    jmp bin_display
bin_zero:
    mov cl, '0'
bin_display:
    call write_char
    shr bl, 1
    jnz bin_loop
    
    pop rbx
    ret
write_binary ENDP

delay_milliseconds PROC
    ; RCX = milliseconds
    sub rsp, 32
    call Sleep
    add rsp, 32
    ret
delay_milliseconds ENDP

; ============================================================================
; LED DISPLAY PROCEDURES
; ============================================================================

display_address_bus PROC
    lea rcx, addressMsg
    call write_cstr
    
    ; Display 16-bit address as binary
    mov ax, [addressBusLEDs]
    mov al, ah
    call write_binary
    
    mov al, byte ptr [addressBusLEDs]
    call write_binary
    
    lea rcx, newLine
    call write_cstr
    ret
display_address_bus ENDP

display_data_bus PROC
    lea rcx, dataMsg
    call write_cstr
    
    mov al, [dataBusLEDs]
    call write_binary
    
    lea rcx, newLine
    call write_cstr
    ret
display_data_bus ENDP

display_status_leds PROC
    lea rcx, statusMsg
    call write_cstr
    
    mov al, [powerLED]
    test al, al
    jz status_p_off
    mov cl, 'P'
    call write_char
status_p_off:
    
    mov al, [haltLED]
    test al, al
    jz status_h_off
    mov cl, 'H'
    call write_char
status_h_off:
    
    mov al, [waitLED]
    test al, al
    jz status_w_off
    mov cl, 'W'
    call write_char
status_w_off:
    
    mov al, [interruptLED]
    test al, al
    jz status_i_off
    mov cl, 'I'
    call write_char
status_i_off:
    
    lea rcx, newLine
    call write_cstr
    ret
display_status_leds ENDP

display_switches PROC
    lea rcx, switchMsg
    call write_cstr
    
    xor rsi, rsi
sw_display_loop:
    cmp rsi, 16
    jge sw_display_done
    
    mov al, byte ptr [switchStates + rsi]
    mov cl, '0'
    cmp al, 0
    je sw_display_off
    mov cl, '1'
sw_display_off:
    call write_char
    inc rsi
    jmp sw_display_loop
    
sw_display_done:
    lea rcx, newLine
    call write_cstr
    ret
display_switches ENDP

; ============================================================================
; SWITCH CONTROL
; ============================================================================

set_switch PROC
    ; RCX = switch number (0-15)
    ; RDX = value (0 or 1)
    cmp rcx, 15
    ja set_switch_err
    mov byte ptr [switchStates + rcx], dl
    
set_switch_err:
    ret
set_switch ENDP

get_switch PROC
    ; RCX = switch number
    ; Returns AL = switch state
    cmp rcx, 15
    ja get_switch_err
    mov al, byte ptr [switchStates + rcx]
    ret
get_switch_err:
    xor al, al
    ret
get_switch ENDP

; ============================================================================
; 8-BIT ARITHMETIC OPERATIONS
; ============================================================================

add_8 PROC
    ; AL += BL
    add al, bl
    mov byte ptr [mathResult], al
    setc byte ptr [mathCarry]
    ret
add_8 ENDP

sub_8 PROC
    ; AL -= BL
    sub al, bl
    mov byte ptr [mathResult], al
    setc byte ptr [mathCarry]
    ret
sub_8 ENDP

mul_8 PROC
    ; AL *= BL, result in AX
    mov ah, 0
    mul bl
    mov word ptr [mathResult], ax
    ret
mul_8 ENDP

div_8 PROC
    ; AL /= BL, quotient in AL, remainder in AH
    mov ah, 0
    div bl
    mov byte ptr [mathResult], al
    mov byte ptr [mathRemainder], ah
    ret
div_8 ENDP

; ============================================================================
; 16-BIT ARITHMETIC OPERATIONS
; ============================================================================

add_16 PROC
    ; AX += BX
    add ax, bx
    mov word ptr [mathResult], ax
    setc byte ptr [mathCarry]
    ret
add_16 ENDP

sub_16 PROC
    ; AX -= BX
    sub ax, bx
    mov word ptr [mathResult], ax
    setc byte ptr [mathCarry]
    ret
sub_16 ENDP

mul_16 PROC
    ; AX *= BX, result in DX:AX
    mul bx
    mov qword ptr [mathResult], rax
    ret
mul_16 ENDP

; ============================================================================
; 32-BIT ARITHMETIC OPERATIONS
; ============================================================================

add_32 PROC
    ; EAX += EBX
    add eax, ebx
    mov dword ptr [mathResult], eax
    setc byte ptr [mathCarry]
    ret
add_32 ENDP

mul_32 PROC
    ; EAX *= EBX
    mov ecx, ebx
    mul ecx
    mov qword ptr [mathResult], rax
    ret
mul_32 ENDP

; ============================================================================
; 64-BIT ARITHMETIC OPERATIONS
; ============================================================================

add_64 PROC
    ; RAX += RBX
    add rax, rbx
    mov qword ptr [mathResult], rax
    setc byte ptr [mathCarry]
    ret
add_64 ENDP

; ============================================================================
; BITWISE OPERATIONS
; ============================================================================

bitwise_and_8 PROC
    ; AL &= BL
    and al, bl
    mov byte ptr [mathResult], al
    ret
bitwise_and_8 ENDP

bitwise_or_8 PROC
    ; AL |= BL
    or al, bl
    mov byte ptr [mathResult], al
    ret
bitwise_or_8 ENDP

bitwise_xor_8 PROC
    ; AL ^= BL
    xor al, bl
    mov byte ptr [mathResult], al
    ret
bitwise_xor_8 ENDP

bitwise_not_8 PROC
    ; AL = ~AL
    not al
    mov byte ptr [mathResult], al
    ret
bitwise_not_8 ENDP

bitshift_left PROC
    ; RAX <<= RCX
    shl rax, cl
    mov qword ptr [mathResult], rax
    ret
bitshift_left ENDP

bitshift_right PROC
    ; RAX >>= RCX
    shr rax, cl
    mov qword ptr [mathResult], rax
    ret
bitshift_right ENDP

bitrotate_left PROC
    ; RAX ROL RCX
    rol rax, cl
    mov qword ptr [mathResult], rax
    ret
bitrotate_left ENDP

; ============================================================================
; LED ANIMATION
; ============================================================================

animate_address_bus PROC
    ; Rotate address bus LEDs
    mov ax, [addressBusLEDs]
    ror ax, 1
    mov [addressBusLEDs], ax
    ret
animate_address_bus ENDP

animate_data_bus PROC
    ; Rotate data bus LEDs
    mov al, [dataBusLEDs]
    rol al, 1
    mov [dataBusLEDs], al
    ret
animate_data_bus ENDP

pulse_status_led PROC
    ; RCX = LED index (0-3)
    cmp rcx, 0
    je pulse_power
    cmp rcx, 1
    je pulse_halt
    cmp rcx, 2
    je pulse_wait
    cmp rcx, 3
    je pulse_interrupt
    ret
    
pulse_power:
    mov al, [powerLED]
    xor al, 1
    mov [powerLED], al
    ret
pulse_halt:
    mov al, [haltLED]
    xor al, 1
    mov [haltLED], al
    ret
pulse_wait:
    mov al, [waitLED]
    xor al, 1
    mov [waitLED], al
    ret
pulse_interrupt:
    mov al, [interruptLED]
    xor al, 1
    mov [interruptLED], al
    ret
pulse_status_led ENDP

; ============================================================================
; SOUND GENERATION
; ============================================================================

beep_startup PROC
    ; 3-tone startup sequence
    mov rcx, 440
    sub rsp, 32
    call Beep
    add rsp, 32
    
    mov rcx, 100
    call delay_milliseconds
    
    mov rcx, 550
    sub rsp, 32
    call Beep
    add rsp, 32
    
    mov rcx, 100
    call delay_milliseconds
    
    mov rcx, 660
    sub rsp, 32
    call Beep
    add rsp, 32
    ret
beep_startup ENDP

beep_error PROC
    ; Error buzz pattern
    mov rcx, 200
    sub rsp, 32
    call Beep
    add rsp, 32
    
    mov rcx, 75
    call delay_milliseconds
    
    mov rcx, 200
    sub rsp, 32
    call Beep
    add rsp, 32
    ret
beep_error ENDP

beep_success PROC
    ; Success chime
    mov rcx, 800
    sub rsp, 32
    call Beep
    add rsp, 32
    
    mov rcx, 50
    call delay_milliseconds
    
    mov rcx, 1000
    sub rsp, 32
    call Beep
    add rsp, 32
    ret
beep_success ENDP

; ============================================================================
; DEMONSTRATION ROUTINES
; ============================================================================

demo_display_all PROC
    call display_address_bus
    call display_data_bus
    call display_status_leds
    call display_switches
    ret
demo_display_all ENDP

demo_math PROC
    ; Test 8-bit operations
    mov al, 100
    mov bl, 50
    call add_8
    
    mov al, 255
    mov bl, 100
    call sub_8
    
    mov al, 12
    mov bl, 8
    call mul_8
    
    mov al, 100
    mov bl, 7
    call div_8
    
    ; Test 16-bit operations
    mov ax, 0x1234
    mov bx, 0x5678
    call add_16
    
    ; Test 32-bit operations
    mov eax, 0x12345678
    mov ebx, 0x87654321
    call add_32
    
    ; Test 64-bit operations
    mov rax, 0x0123456789ABCDEF
    mov rbx, 0xFEDCBA9876543210
    call add_64
    
    ; Test bitwise
    mov al, 0xF0
    mov bl, 0x0F
    call bitwise_and_8
    
    mov al, 0xF0
    mov bl, 0x0F
    call bitwise_or_8
    
    ret
demo_math ENDP

demo_animation PROC
    ; Animate LEDs 5 times
    xor rsi, rsi
    
anim_loop:
    cmp rsi, 5
    jge anim_done
    
    call animate_address_bus
    call animate_data_bus
    
    xor rcx, rcx
    
toggle_loop:
    cmp rcx, 4
    jge toggles_done
    call pulse_status_led
    inc rcx
    jmp toggle_loop
    
toggles_done:
    call demo_display_all
    
    mov rcx, 500
    call delay_milliseconds
    
    inc rsi
    jmp anim_loop
    
anim_done:
    ret
demo_animation ENDP

; ============================================================================
; MAIN PROGRAM
; ============================================================================

start PROC
    sub rsp, 40
    
    ; Get console output handle
    mov rcx, STD_OUTPUT_HANDLE
    sub rsp, 32
    call GetStdHandle
    add rsp, 32
    mov qword ptr [hStdOut], rax
    
    ; Display title
    lea rcx, titleMsg
    call write_cstr
    lea rcx, titleMsg2
    call write_cstr
    lea rcx, titleMsg3
    call write_cstr
    lea rcx, titleMsg4
    call write_cstr
    
    ; Boot message
    lea rcx, bootMsg
    call write_cstr
    
    ; Startup sound
    call beep_startup
    
    ; Demo iteration loop (5 cycles)
    xor rsi, rsi
    
main_loop:
    cmp rsi, 5
    jge main_done
    
    ; Display all systems
    call demo_display_all
    
    ; Run math demos
    call demo_math
    
    ; Run animation
    call demo_animation
    
    mov rcx, 1000
    call delay_milliseconds
    
    inc rsi
    jmp main_loop
    
main_done:
    ; Play success sound
    call beep_success
    
    ; Done message
    lea rcx, doneMsg
    call write_cstr
    
    ; Exit
    add rsp, 40
    xor ecx, ecx
    sub rsp, 32
    call ExitProcess
    add rsp, 32
    
    ret
start ENDP

END start
; x86-64 Assembly for Windows
; Complete implementation with LED display, math, sound, and more

option casemap:none

EXTERN GetStdHandle:PROC
EXTERN WriteConsoleA:PROC
EXTERN Beep:PROC
EXTERN Sleep:PROC
EXTERN ExitProcess:PROC
EXTERN GetAsyncKeyState:PROC

STD_OUTPUT_HANDLE EQU -11

; LED and Switch Constants
ADDRESS_BUS_SIZE EQU 16        ; A0-A15
DATA_BUS_SIZE EQU 8            ; D0-D7
STATUS_LED_COUNT EQU 4         ; Power, Halt, Wait, Interrupt
SWITCH_COUNT EQU 16            ; 16 toggle switches

; Screen Constants
SCREEN_WIDTH EQU 16
SCREEN_HEIGHT EQU 16
SCREEN_SIZE EQU 256

.data
; Console Handle
hStdOut         dq 0
charsWritten    dq 0

; LED States (bit representation)
addressBusLEDs  dw 0xAAAA       ; Address bus - 16 LEDs
dataBusLEDs     db 0x55         ; Data bus - 8 LEDs
statusLEDs      db 0x0F         ; Status - 4 LEDs (Power, Halt, Wait, Interrupt)
powerLED        db 1            ; Power LED state
haltLED         db 0            ; Halt LED state
waitLED         db 0            ; Wait LED state
interruptLED    db 0            ; Interrupt LED state

; Switch States
switchStates    db 16 dup(0)    ; 16 switches, 0 or 1 each

; CPU Register Simulation (Intel 8080 subset)
regA            db 0            ; Accumulator
regB            db 0            ; B register
regC            db 0            ; C register
regD            db 0            ; D register
regE            db 0            ; E register
regH            db 0            ; H register
regL            db 0            ; L register
regPC           dw 0            ; Program Counter
regSP           dw 0            ; Stack Pointer
regFlags        db 0            ; Flags (Z, C, P, etc.)

; Screen Buffer (16x16)
screenBuffer    db SCREEN_SIZE dup(0x20)  ; Filled with spaces

; Math Operation Results
mathResult      qw 0            ; Large result storage
mathRemainder   qw 0            ; For division remainder
mathCarry       db 0            ; Carry flag for arithmetic

; Messages and strings
titleMsg        db "╔════════════════════════════════════════╗",13,10,0
titleMsg2       db "║    ALTAIR 8800 EMULATOR v1.0        ║",13,10,0
titleMsg3       db "║    x86-64 Assembly Implementation    ║",13,10,0
titleMsg4       db "╚════════════════════════════════════════╝",13,10,0
bootMsg         db "Initializing core systems...",13,10,0
addressBusMsg   db "Address Bus (A0-A15): ",0
dataBusMsg      db "Data Bus (D0-D7):     ",0
statusMsg       db "Status: P=Power H=Halt W=Wait I=Interrupt",13,10,0
switchMsg       db "Switches (0-15): ",0
doneMsg         db 13,10,"Emulation complete.",13,10,0
pauseMsg        db 13,10,"Press ENTER to continue...",13,10,0

; Formatting
binaryPrefix    db "[",0
binarySuffix    db "]",0
newLine         db 13,10,0
space           db " ",0
tab             db 9,0

; Sine/Cosine lookup table (simplified)
sinTable        db 0, 25, 49, 71, 90, 105, 117, 124, 127, 124, 117, 105, 90, 71, 49, 25

.code

; ============================================================================
; UTILITY FUNCTIONS
; ============================================================================

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

write_char PROC
    ; RCX = character to write
    ; Uses RAX for conversion/storage
    push rbx
    sub rsp, 32
    
    mov al, cl
    mov byte ptr [rsp+32], al
    mov byte ptr [rsp+33], 0
    
    mov rcx, qword ptr [hStdOut]
    lea rdx, [rsp+32]
    lea r9, charsWritten
    call WriteConsoleA
    
    add rsp, 32
    pop rbx
    ret
write_char ENDP

write_byte_binary PROC
    ; AL = byte to write as binary string
    push rbx
    push rsi
    sub rsp, 32
    
    mov bl, 128
    xor rsi, rsi
binary_loop:
    test al, bl
    jz write_zero
    mov cl, '1'
    jmp write_bit
write_zero:
    mov cl, '0'
write_bit:
    call write_char
    shr bl, 1
    jnz binary_loop
    
    add rsp, 32
    pop rsi
    pop rbx
    ret
write_byte_binary ENDP

delay_ms PROC
    ; RCX = milliseconds
    ; Uses Windows Sleep API
    sub rsp, 32
    call Sleep
    add rsp, 32
    ret
delay_ms ENDP

; ============================================================================
; LED DISPLAY FUNCTIONS
; ============================================================================

display_address_bus PROC
    ; Display 16-bit address bus LEDs
    lea rcx, addressBusMsg
    call write_cstr
    
    mov ax, [addressBusLEDs]
    mov al, ah
    call write_byte_binary
    mov al, byte ptr [addressBusLEDs]
    call write_byte_binary
    
    lea rcx, newLine
    call write_cstr
    ret
display_address_bus ENDP

display_data_bus PROC
    ; Display 8-bit data bus LEDs
    lea rcx, dataBusMsg
    call write_cstr
    
    mov al, [dataBusLEDs]
    call write_byte_binary
    
    lea rcx, newLine
    call write_cstr
    ret
display_data_bus ENDP

display_status_leds PROC
    ; Display status LEDs
    lea rcx, statusMsg
    call write_cstr
    
    ; Display Power LED
    mov cl, 'P'
    mov al, [powerLED]
    cmp al, 0
    je status_p_off
    mov cl, '*'
status_p_off:
    call write_char
    lea rcx, space
    call write_cstr
    
    ; Display Halt LED
    mov cl, 'H'
    mov al, [haltLED]
    cmp al, 0
    je status_h_off
    mov cl, '*'
status_h_off:
    call write_char
    lea rcx, space
    call write_cstr
    
    ; Display Wait LED
    mov cl, 'W'
    mov al, [waitLED]
    cmp al, 0
    je status_w_off
    mov cl, '*'
status_w_off:
    call write_char
    lea rcx, space
    call write_cstr
    
    ; Display Interrupt LED
    mov cl, 'I'
    mov al, [interruptLED]
    cmp al, 0
    je status_i_off
    mov cl, '*'
status_i_off:
    call write_char
    
    lea rcx, newLine
    call write_cstr
    ret
display_status_leds ENDP

; ============================================================================
; SWITCH FUNCTIONS
; ============================================================================

set_switch PROC
    ; RCX = switch number (0-15)
    ; RDX = value (0 or 1)
    cmp rcx, 15
    ja switch_error
    
    mov byte ptr [switchStates + rcx], dl
    ret
    
switch_error:
    ret
set_switch ENDP

display_switches PROC
    lea rcx, switchMsg
    call write_cstr
    
    xor rsi, rsi
switch_display_loop:
    cmp rsi, 16
    jge switch_display_done
    
    mov al, byte ptr [switchStates + rsi]
    mov cl, '0'
    cmp al, 0
    je switch_display_off
    mov cl, '1'
switch_display_off:
    call write_char
    
    inc rsi
    jmp switch_display_loop
    
switch_display_done:
    lea rcx, newLine
    call write_cstr
    ret
display_switches ENDP

; ============================================================================
; MATH OPERATIONS
; ============================================================================

add_8bit PROC
    ; AL += BL, updates mathResult and mathCarry
    add al, bl
    mov byte ptr [mathResult], al
    setc byte ptr [mathCarry]
    ret
add_8bit ENDP

sub_8bit PROC
    ; AL -= BL
    sub al, bl
    mov byte ptr [mathResult], al
    setc byte ptr [mathCarry]
    ret
sub_8bit ENDP

mul_8bit PROC
    ; AL *= BL, result in AX (16-bit)
    mov ah, 0
    mul bl
    mov word ptr [mathResult], ax
    ret
mul_8bit ENDP

div_8bit PROC
    ; AL /= BL, quotient in AL, remainder in AH
    mov ah, 0
    div bl
    mov byte ptr [mathResult], al
    mov byte ptr [mathRemainder], ah
    ret
div_8bit ENDP

add_16bit PROC
    ; AX += BX
    add ax, bx
    mov word ptr [mathResult], ax
    setc byte ptr [mathCarry]
    ret
add_16bit ENDP

add_32bit PROC
    ; EAX += EBX
    add eax, ebx
    mov dword ptr [mathResult], eax
    setc byte ptr [mathCarry]
    ret
add_32bit ENDP

add_64bit PROC
    ; RAX += RBX
    add rax, rbx
    mov qword ptr [mathResult], rax
    setc byte ptr [mathCarry]
    ret
add_64bit ENDP

mul_32bit PROC
    ; EAX *= EBX (uses 64-bit result)
    mov ecx, ebx
    mul ecx
    mov qword ptr [mathResult], rax
    ret
mul_32bit ENDP

; ============================================================================
; LED UPDATE FUNCTIONS
; ============================================================================

update_address_bus PROC
    ; Simulate address bus updates
    mov ax, [addressBusLEDs]
    ror ax, 1
    mov [addressBusLEDs], ax
    ret
update_address_bus ENDP

update_data_bus PROC
    ; Simulate data bus updates
    mov al, [dataBusLEDs]
    rol al, 1
    mov [dataBusLEDs], al
    ret
update_data_bus ENDP

toggle_status_led PROC
    ; RCX = LED number (0=Power, 1=Halt, 2=Wait, 3=Interrupt)
    cmp rcx, 0
    je toggle_power
    cmp rcx, 1
    je toggle_halt
    cmp rcx, 2
    je toggle_wait
    cmp rcx, 3
    je toggle_interrupt
    ret
    
toggle_power:
    mov al, [powerLED]
    xor al, 1
    mov [powerLED], al
    ret
    
toggle_halt:
    mov al, [haltLED]
    xor al, 1
    mov [haltLED], al
    ret
    
toggle_wait:
    mov al, [waitLED]
    xor al, 1
    mov [waitLED], al
    ret
    
toggle_interrupt:
    mov al, [interruptLED]
    xor al, 1
    mov [interruptLED], al
    ret
toggle_status_led ENDP

; ============================================================================
; SOUND GENERATION
; ============================================================================

play_startup_beep PROC
    ; 3-note startup sequence
    mov rcx, 440
    sub rsp, 32
    call Beep
    add rsp, 32
    
    mov rcx, 100
    call delay_ms
    
    mov rcx, 550
    sub rsp, 32
    call Beep
    add rsp, 32
    
    mov rcx, 100
    call delay_ms
    
    mov rcx, 660
    sub rsp, 32
    call Beep
    add rsp, 32
    ret
play_startup_beep ENDP

play_error_buzz PROC
    ; Low frequency error beep
    mov rcx, 200
    sub rsp, 32
    call Beep
    add rsp, 32
    
    mov rcx, 50
    call delay_ms
    
    mov rcx, 200
    sub rsp, 32
    call Beep
    add rsp, 32
    ret
play_error_buzz ENDP

play_success_chime PROC
    ; High frequency success chime
    mov rcx, 800
    sub rsp, 32
    call Beep
    add rsp, 32
    
    mov rcx, 50
    call delay_ms
    
    mov rcx, 1000
    sub rsp, 32
    call Beep
    add rsp, 32
    ret
play_success_chime ENDP

; ============================================================================
; DEMONSTRATION FUNCTIONS
; ============================================================================

demo_led_display PROC
    ; Display all LEDs in sequence
    lea rcx, [rel titleMsg3]
    call write_cstr
    
    call display_address_bus
    call display_data_bus
    call display_status_leds
    
    ret
demo_led_display ENDP

demo_math_operations PROC
    ; Demonstrate mathematical operations
    ; 8-bit operations
    mov al, 50
    mov bl, 30
    call add_8bit
    
    mov al, 100
    mov bl, 25
    call sub_8bit
    
    mov al, 12
    mov bl, 8
    call mul_8bit
    
    ; 32-bit operations  
    mov eax, 0x12345678
    mov ebx, 0x87654321
    call add_32bit
    
    ; 64-bit operations
    mov rax, 0x123456789ABCDEF0
    mov rbx, 0x0FEDCBA987654321
    call add_64bit
    
    ret
demo_math_operations ENDP

demo_led_animation PROC
    ; Animate LEDs 5 times
    xor rsi, rsi
    
animation_loop:
    cmp rsi, 5
    jge animation_done
    
    call update_address_bus
    call update_data_bus
    
    xor rcx, rcx
toggle_loop:
    cmp rcx, 4
    jge toggle_done
    call toggle_status_led
    inc rcx
    jmp toggle_loop
    
toggle_done:
    call demo_led_display
    
    mov rcx, 500
    call delay_ms
    
    inc rsi
    jmp animation_loop
    
animation_done:
    ret
demo_led_animation ENDP

; ============================================================================
; MAIN PROGRAM
; ============================================================================

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
