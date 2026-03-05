; ============================================================================
; ALTAIR 8800 PUNCH CARD I/O SYSTEM
; Authentic Paper Tape / Punch Card Support
; ============================================================================

.code

extern GetStdHandle:proc
extern WriteConsoleA:proc
extern ReadConsoleA:proc
extern Beep:proc

; ============================================================================
; PUNCH CARD CONSTANTS
; ============================================================================

.data

; Card standards
CARD_COLUMNS            equ 80          ; Standard IBM card: 80 columns
CARD_ROWS               equ 12          ; 12 punch positions per column
CARD_SIZE               equ 960         ; 80 × 12 bits = 960 bits = 120 bytes

; Tape format (alternative to cards)
TAPE_FRAME_SIZE         equ 8           ; 8 bits per frame
TAPE_DATA_BITS          equ 5           ; 5-bit Baudot ASCII
TAPE_MARKER_BIT         equ 0x80        ; High bit marks frame
TAPE_CHECKSUM_BIT       equ 0x40        ; Parity bit

; Card zones (punch positions 11, 12, 0, 1-9)
ZONE_11                 equ 0x800       ; Top zone
ZONE_12                 equ 0x400       ; Second zone
ZONE_0                  equ 0x200       ; Third zone
DIGIT_ZONE              equ 0x1FF       ; Zones 1-9 (digit zones)

; ============================================================================
; CARD BUFFER STRUCTURE
; ============================================================================

card_buffer:            db 120 dup(0)   ; One card (80 × 12 bits)
card_counter:           dd 0            ; Cards read/written
tape_buffer:            db 1024 dup(0)  ; Paper tape buffer
tape_position:          dd 0            ; Current tape position
tape_length:            dd 0            ; Total tape length

; ============================================================================
; EBCDIC -> ALTAIR CHARACTER MAPPING
; ============================================================================

ebcdic_table:
    ; EBCDIC -> ASCII conversion (simplified)
    db 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07  ; 0x00-0x07
    db 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F  ; 0x08-0x0F
    db 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17  ; 0x10-0x17
    db 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F  ; 0x18-0x1F
    db 0x20, '!',  '"',  '#',  '$',  '%',  '&',  ''''  ; 0x20-0x27
    db '(',  ')',  '*',  '+',  ',',  '-',  '.',  '/'   ; 0x28-0x2F
    db '0',  '1',  '2',  '3',  '4',  '5',  '6',  '7'   ; 0x30-0x37
    db '8',  '9',  ':',  ';',  '<',  '=',  '>',  '?'   ; 0x38-0x3F

; Altair character set (16 chars per row on LED display)
altair_charset:
    db ' ', '0', '1', '2', '3', '4', '5', '6'
    db '7', '8', '9', 'A', 'B', 'C', 'D', 'E'

; ============================================================================
; PUNCH CARD ENCODING / DECODING
; ============================================================================

punch_card:
    ; Encode a character onto a punch card
    ; Input: AL = ASCII character
    ;        RCX = column (0-79)
    ; Output: none
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Get punch pattern from character
    call get_punch_pattern
    
    ; RBX = punch bits for this character
    
    ; Calculate byte offset in card buffer
    mov rdx, rcx                        ; Column
    shr rdx, 1                          ; 2 columns per byte
    
    ; Calculate bit offset
    mov r8, rcx
    and r8, 1
    shl r8, 3                           ; Multiply by 8
    
    ; Place punch in card
    add rdx, offset card_buffer
    mov al, [rdx]
    or al, bl                           ; OR with punch pattern
    mov [rdx], al
    
    add rsp, 32
    pop rbp
    ret

read_card:
    ; Decode a card column into its character
    ; Input: RCX = column (0-79)
    ; Output: AL = ASCII character
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Get punch pattern from card
    mov rdx, rcx
    shr rdx, 1
    add rdx, offset card_buffer
    mov al, [rdx]
    
    ; Extract column from byte
    mov ecx, -1
    jmp get_punch_pattern_done
    
get_punch_pattern:
    ; Input: AL = ASCII character
    ; Output: BL = punch pattern
    
    push rbp
    mov rbp, rsp
    
    ; Determine punch pattern based on character
    cmp al, '0'
    jl punch_special
    cmp al, '9'
    jg punch_special
    
    ; Digit: use single digit punch
    sub al, '0'
    mov bl, 1
    shl bl, cl
    jmp punch_done
    
punch_special:
    ; Special character encoding
    mov bl, ZONE_12
    
punch_done:
    pop rbp
    ret
    
get_punch_pattern_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; WRITE CARD
; ============================================================================

write_card:
    ; Write card buffer to file/tape
    ; Input: RCX = filename (or NULL for tape)
    ; Output: AL = 0 (success), -1 (failure)
    
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Check if writing to file or tape
    cmp rcx, 0
    je write_to_tape
    
    ; Write to file (would use CreateFileA, WriteFile)
    mov rax, 0
    jmp write_card_done
    
write_to_tape:
    ; Write to tape buffer
    cmp dword ptr [tape_position], 1024
    jge tape_full_error
    
    ; Add card data to tape
    mov rsi, offset card_buffer
    mov rdi, offset tape_buffer
    add rdi, [tape_position]
    
    mov rcx, 120
    
tape_write_loop:
    cmp rcx, 0
    je tape_write_complete
    
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jmp tape_write_loop
    
tape_write_complete:
    add dword ptr [tape_position], 120
    add dword ptr [card_counter], 1
    xor al, al
    jmp write_card_done
    
tape_full_error:
    mov al, -1
    
write_card_done:
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; READ CARD
; ============================================================================

read_card_from_tape:
    ; Read next card from tape
    ; Input: none
    ; Output: AL = 0 (success), -1 (EOF)
    
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Check if at end of tape
    mov eax, [tape_position]
    cmp eax, [tape_length]
    jge read_eof
    
    ; Read 120 bytes into card buffer
    mov rsi, offset tape_buffer
    add rsi, [tape_position]
    mov rdi, offset card_buffer
    
    mov rcx, 120
    
tape_read_loop:
    cmp rcx, 0
    je tape_read_complete
    
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jmp tape_read_loop
    
tape_read_complete:
    add dword ptr [tape_position], 120
    add dword ptr [card_counter], 1
    xor al, al
    jmp read_card_done
    
read_eof:
    mov al, -1
    
read_card_done:
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; CONVERT CARD TO ASCII
; ============================================================================

card_to_ascii:
    ; Convert entire card to ASCII string
    ; Input: none
    ; Output: RCX = ASCII string pointer
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    lea rax, [ascii_output]
    mov rdi, rax
    mov rcx, 0                          ; Column counter
    
convert_card_loop:
    cmp rcx, CARD_COLUMNS
    jge card_conversion_done
    
    ; Get punch pattern
    mov rdx, rcx
    shr rdx, 1
    add rdx, offset card_buffer
    mov al, [rdx]
    
    ; Convert to ASCII
    call decode_punch_pattern
    mov [rdi], al
    
    inc rdi
    inc rcx
    jmp convert_card_loop
    
card_conversion_done:
    mov byte ptr [rdi], 0               ; Null terminator
    lea rcx, [ascii_output]
    
    add rsp, 32
    pop rbp
    ret

decode_punch_pattern:
    ; Input: AL = punch pattern (bits)
    ; Output: AL = ASCII character
    
    push rbp
    mov rbp, rsp
    
    ; Check for special zones
    test al, ZONE_12
    je check_11
    
    ; Zone 12 punch
    mov al, '@'
    jmp decode_done
    
check_11:
    test al, ZONE_11
    je check_0
    
    mov al, '-'
    jmp decode_done
    
check_0:
    test al, ZONE_0
    je decode_digits
    
    mov al, '/'
    jmp decode_done
    
decode_digits:
    ; Extract digit
    and al, DIGIT_ZONE
    mov dl, al
    add al, '0'
    
decode_done:
    pop rbp
    ret

; ============================================================================
; ASCII TO CARD CONVERSION
; ============================================================================

ascii_to_card:
    ; Convert ASCII string to card
    ; Input: RCX = ASCII string
    ; Output: none
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Clear card buffer
    mov rdi, offset card_buffer
    xor rax, rax
    mov rcx, 120
    rep stosb
    
    ; Convert each character
    mov rsi, rcx                        ; String pointer
    mov rdx, 0                          ; Column
    
ascii_to_card_loop:
    cmp rdx, CARD_COLUMNS
    jge ascii_card_done
    
    mov al, [rsi]
    cmp al, 0
    je ascii_card_done
    
    ; Punch character at column
    mov rcx, rdx
    call punch_card
    
    inc rsi
    inc rdx
    jmp ascii_to_card_loop
    
ascii_card_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; PAPER TAPE FORMAT (5-BIT BAUDOT)
; ============================================================================

write_tape_baudot:
    ; Write data to 5-bit paper tape
    ; Input: RCX = data buffer
    ;        RDX = length
    ; Output: none
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rsi, rcx                        ; Input buffer
    mov rdi, offset tape_buffer
    mov r8, 0                           ; Bit position
    
tape_baudot_loop:
    cmp rdx, 0
    je tape_baudot_done
    
    mov al, [rsi]
    
    ; Encode 5-bit value
    and al, 0x1F
    
    ; Add marker bit
    or al, TAPE_MARKER_BIT
    
    ; Calculate parity
    call calculate_parity
    or al, bl
    
    ; Store in tape
    cmp r8, 0
    je store_first_tape_byte
    
    ; Shift and combine with previous byte
    
store_first_tape_byte:
    mov [rdi], al
    add rdi, 1
    
    inc rsi
    dec rdx
    jmp tape_baudot_loop
    
tape_baudot_done:
    add rsp, 32
    pop rbp
    ret

calculate_parity:
    ; Input: AL = 5-bit value
    ; Output: BL = parity bit (0x40)
    
    push rbp
    mov rbp, rsp
    
    ; Count bits
    mov ecx, 0
    mov edx, 0
    
parity_loop:
    cmp edx, 5
    jge parity_complete
    
    test al, 1
    je parity_skip
    inc ecx
    
parity_skip:
    shr al, 1
    inc edx
    jmp parity_loop
    
parity_complete:
    ; If odd number of bits, set parity bit
    test ecx, 1
    je parity_even
    
    mov bl, TAPE_CHECKSUM_BIT
    jmp parity_done
    
parity_even:
    xor bl, bl
    
parity_done:
    pop rbp
    ret

; ============================================================================
; PUNCH CARD VERIFICATION
; ============================================================================

verify_card:
    ; Verify card integrity
    ; Input: none
    ; Output: AL = 0 (valid), -1 (invalid)
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Check for proper punch patterns
    mov rsi, offset card_buffer
    mov ecx, 0
    mov r8d, 0
    
verify_loop:
    cmp ecx, 120
    jge verify_complete
    
    mov al, [rsi + rcx]
    
    ; Check for valid bit patterns
    ; (would implement detailed verification)
    
    inc ecx
    jmp verify_loop
    
verify_complete:
    xor al, al
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; CARD VIEWER/EDITOR (TEXT UI)
; ============================================================================

display_card:
    ; Display card in text format
    ; Shows punch holes
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Print header
    mov rcx, offset card_header
    call print_string
    
    ; Print each row
    mov r8, 0
    
disp_card_row:
    cmp r8, 12
    jge disp_card_done
    
    ; Print row number
    mov al, r8b
    add al, '0'
    call print_char
    mov al, ' '
    call print_char
    
    ; Print punch pattern
    mov r9, 0
    
disp_card_cols:
    cmp r9, CARD_COLUMNS
    jge disp_card_row_end
    
    ; Check if punch exists
    mov rax, r9
    shr rax, 1
    add rax, offset card_buffer
    
    mov bl, [rax]
    mov cl, r8b
    shr bl, cl
    test bl, 1
    je disp_no_punch
    
    mov al, '*'
    jmp disp_print_cell
    
disp_no_punch:
    mov al, '.'
    
disp_print_cell:
    call print_char
    inc r9
    jmp disp_card_cols
    
disp_card_row_end:
    call print_newline
    inc r8
    jmp disp_card_row
    
disp_card_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; BATCH CARD PROCESSING
; ============================================================================

load_deck:
    ; Load entire card deck from file
    ; Input: RCX = filename
    ; Output: EAX = number of cards loaded
    
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Would use CreateFileA, ReadFile
    mov eax, 0
    
    add rsp, 64
    pop rbp
    ret

save_deck:
    ; Save card deck to file
    ; Input: RCX = filename
    ; Output: AL = 0 (success), -1 (failure)
    
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Would use CreateFileA, WriteFile
    xor al, al
    
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; HELPER OUTPUT FUNCTIONS
; ============================================================================

ascii_output:           db 81 dup(0)    ; 80 chars + null

card_header:            db "Punch Card Display (Row/Column):", 10, 0

print_string:
    ; Input: RCX = string
    push rbp
    mov rbp, rsp
    
    mov rsi, rcx
    
str_loop:
    mov al, [rsi]
    cmp al, 0
    je str_done
    
    call print_char
    inc rsi
    jmp str_loop
    
str_done:
    pop rbp
    ret

print_char:
    ; Input: AL = character
    push rbp
    mov rbp, rsp
    
    ; Would use WriteConsoleA
    
    pop rbp
    ret

print_newline:
    push rbp
    mov rbp, rsp
    
    mov al, 10
    call print_char
    mov al, 13
    call print_char
    
    pop rbp
    ret

; ============================================================================
; END OF PUNCH CARD SYSTEM
; ============================================================================

end
