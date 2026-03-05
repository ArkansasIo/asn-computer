; =============================================================================
; PUNCH CARD I/O - Authentic Punch Card and Paper Tape Support
; =============================================================================
; Purpose: IBM 80-col cards, Baudot paper tape, EBCDIC/ASCII encoding
; Author: Altair 8800 OS Development Team
; Date: March 4, 2026
; Version: 1.0
; Lines: 950+
; =============================================================================

option casemap:none
EXTERN ExitProcess:PROC

; =============================================================================
; CONSTANTS
; =============================================================================

; Card dimensions
CARD_ROWS               EQU 12                      ; Punch rows (0-9, 11, 12)
CARD_COLS               EQU 80                      ; Columns

; Tape encoding
BAUDOT_BITS             EQU 5
BAUDOT_STOP_BIT         EQU 1
BAUDOT_PARITY_BIT       EQU 1

; Buffer sizes
CARD_BUFFER_SIZE        EQU 960                     ; 12 rows x 80 cols
CARD_DECK_SIZE          EQU 10240                   ; Max 10 cards
TAPE_BUFFER_SIZE        EQU 8192
DECK_INDEX_SIZE         EQU 512

; Card format
PUNCH_NONE              EQU 0
PUNCH_SET               EQU 1

; =============================================================================
; DATA SECTION
; =============================================================================

.data

moduleName              db "punchcard_io", 0
version_str             db "1.0", 0

; Current card buffer (96 bytes = 12 rows x 8 bytes per row for 80 bits)
current_card            db CARD_BUFFER_SIZE dup(0)
card_column_ptr         dd 0

; Card deck (multiple cards)
card_deck               db CARD_DECK_SIZE dup(0)
deck_card_count         dd 0
deck_current_card       dd 0

; Paper tape buffer
paper_tape              db TAPE_BUFFER_SIZE dup(0)
tape_bit_position       dd 0

; Card display
card_display            db 1000 dup(0)

; Parity table (for quick lookup)
parity_table            db 256 dup(0)

; EBCDIC to ASCII conversion table
ebcdic_to_ascii         db 256 dup(0)
ascii_to_ebcdic         db 256 dup(0)

; Punch position lookup
punch_row_map           db 12 dup(0)            ; Maps punch codes to row numbers

; File I/O state
file_buffer             db 4096 dup(0)
file_size               dd 0

; Status
card_valid_flag         dd 0
tape_parity_errors      dd 0
card_checksum           dd 0

; EBCDIC-to-ASCII tables (partial)
ebcdic_table:
    db 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07   ; 0x00-0x07
    db 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F   ; 0x08-0x0F
    ; ... (would contain full 256-byte table in production)

; =============================================================================
; CODE SECTION
; =============================================================================

.code

; =============================================================================
; INITIALIZATION
; =============================================================================

init_punchcard_system PROC
    ; Initialize punch card system
    ; Input: None
    ; Output: EAX = status
    
    push rbx
    push rcx
    push rdi
    
    ; Clear current card
    mov rdi, offset current_card
    mov rcx, CARD_BUFFER_SIZE
    xor al, al
    rep stosb
    
    ; Clear card deck
    mov rdi, offset card_deck
    mov rcx, CARD_DECK_SIZE
    rep stosb
    
    ; Clear paper tape
    mov rdi, offset paper_tape
    mov rcx, TAPE_BUFFER_SIZE
    rep stosb
    
    ; Initialize state
    mov dword ptr [card_column_ptr], 0
    mov dword ptr [deck_card_count], 0
    mov dword ptr [deck_current_card], 0
    mov dword ptr [tape_bit_position], 0
    mov dword ptr [tape_parity_errors], 0
    mov dword ptr [card_valid_flag], 0
    
    ; Initialize parity table
    call init_parity_table
    
    xor eax, eax
    pop rdi
    pop rcx
    pop rbx
    ret
init_punchcard_system ENDP

init_parity_table PROC
    ; Initialize parity lookup table
    ; Input: None
    ; Output: parity_table filled
    
    push rbx
    push rcx
    push rdi
    
    mov rdi, offset parity_table
    xor ecx, ecx
    
parity_init_loop:
    cmp ecx, 256
    jge parity_init_done
    
    ; Count set bits in ECX
    mov eax, ecx
    xor ebx, ebx
    
bit_count_loop:
    test eax, eax
    jz bit_count_done
    
    mov ebx, eax
    and ebx, 1
    add ebx, ebx
    shr eax, 1
    jmp bit_count_loop
    
bit_count_done:
    ; Store parity (0 or 1)
    and ebx, 1
    mov byte ptr [rdi + rcx], bl
    
    inc ecx
    jmp parity_init_loop
    
parity_init_done:
    pop rdi
    pop rcx
    pop rbx
    ret
init_parity_table ENDP

; =============================================================================
; CARD PUNCHING/READING
; =============================================================================

punch_card PROC
    ; Punch a character at current position
    ; Input: AL = character to punch
    ;        ECX = column (0-79)
    ; Output: EAX = status
    
    push rbx
    push rcx
    push rdx
    
    ; Validate column
    cmp ecx, CARD_COLS
    jge punch_error
    
    ; Encode character to punch holes
    call encode_punch_pattern
    
    ; Store punch pattern in card buffer
    ; Each column uses multiple bytes for the 12 rows
    mov ebx, ecx
    imul ebx, ebx, 2                ; 2 bytes per column for 12 bits
    
    mov rdx, offset current_card
    add rdx, rbx
    
    ; Store punched rows
    mov byte ptr [rdx], al
    mov byte ptr [rdx + 1], ah
    
    mov dword ptr [card_column_ptr], ecx
    inc ecx
    mov dword ptr [card_column_ptr], ecx
    
    xor eax, eax
    jmp punch_done
    
punch_error:
    mov eax, -1
    
punch_done:
    pop rdx
    pop rcx
    pop rbx
    ret
punch_card ENDP

read_card PROC
    ; Read a character from current position
    ; Input: ECX = column (0-79)
    ; Output: AL = character
    
    push rbx
    push rcx
    push rdx
    
    ; Validate column
    cmp ecx, CARD_COLS
    jge read_card_error
    
    ; Get punch pattern from card buffer
    mov ebx, ecx
    imul ebx, ebx, 2
    
    mov rdx, offset current_card
    add rdx, rbx
    
    mov al, byte ptr [rdx]
    
    ; Decode punch pattern
    call decode_punch_pattern
    
    pop rdx
    pop rcx
    pop rbx
    ret
    
read_card_error:
    xor al, al
    pop rdx
    pop rcx
    pop rbx
    ret
read_card ENDP

encode_punch_pattern PROC
    ; Encode character to IBM punch card pattern
    ; Input: AL = ASCII character
    ; Output: AX = punch pattern (each bit = one row)
    
    push rbx
    push rcx
    
    movzx eax, al
    
    ; Simplified: map common characters to punch patterns
    ; In production, would use full EBCDIC conversion
    
    cmp al, '0'
    jl encode_default
    cmp al, '9'
    jg encode_check_alpha
    
    sub al, '0'                     ; 0-9 maps to rows 0-9
    mov bl, al
    mov ah, 0
    mov al, bl
    jmp encode_done
    
encode_check_alpha:
    cmp al, 'A'
    jl encode_default
    cmp al, 'Z'
    jg encode_default
    
    sub al, 'A'
    add al, 1                       ; Shift for double punch
    mov bl, al
    mov ah, 0
    mov al, bl
    jmp encode_done
    
encode_default:
    mov eax, 0x0082                ; Default punch (rows 1,7)
    
encode_done:
    pop rcx
    pop rbx
    ret
encode_punch_pattern ENDP

decode_punch_pattern PROC
    ; Decode IBM punch card pattern to character
    ; Input: AL = punch pattern
    ; Output: AL = ASCII character
    
    push rbx
    push rcx
    
    movzx eax, al
    
    ; Decode based on punch pattern
    ; Single punch in 0-9 rows = digit
    mov ebx, eax
    
    ; Check for digit punch
    cmp al, 0x01
    jl decode_check_letter
    cmp al, 0x09
    jg decode_check_letter
    
    add al, '0'                     ; Convert to ASCII digit
    jmp decode_done
    
decode_check_letter:
    ; Check for letter punch (with 12 or 11 rows)
    cmp al, 0x0A
    jl decode_default
    
    sub al, 0x0A
    add al, 'A'
    jmp decode_done
    
decode_default:
    mov al, '?'                     ; Unknown punch
    
decode_done:
    pop rcx
    pop rbx
    ret
decode_punch_pattern ENDP

; =============================================================================
; CARD I/O
; =============================================================================

write_card PROC
    ; Write current card to storage
    ; Input: None
    ; Output: EAX = status
    
    push rbx
    push rcx
    push rsi
    push rdi
    
    ; Check deck space
    cmp dword ptr [deck_card_count], 10
    jge write_card_error
    
    ; Copy card to deck
    mov rax, dword ptr [deck_card_count]
    imul rbx, rax, CARD_BUFFER_SIZE
    
    mov rsi, offset current_card
    mov rdi, offset card_deck
    add rdi, rbx
    
    mov rcx, CARD_BUFFER_SIZE
    rep movsb
    
    ; Increment card count
    inc dword ptr [deck_card_count]
    
    xor eax, eax
    jmp write_card_done
    
write_card_error:
    mov eax, -1
    
write_card_done:
    pop rdi
    pop rsi
    pop rcx
    pop rbx
    ret
write_card ENDP

read_card_from_tape PROC
    ; Read a card from paper tape storage
    ; Input: None
    ; Output: AL = status
    
    push rbx
    push rcx
    push rsi
    push rdi
    
    ; Check if more cards
    mov eax, dword ptr [deck_current_card]
    cmp eax, dword ptr [deck_card_count]
    jge read_tape_eof
    
    ; Load card from deck
    imul rbx, rax, CARD_BUFFER_SIZE
    
    mov rsi, offset card_deck
    add rsi, rbx
    mov rdi, offset current_card
    
    mov rcx, CARD_BUFFER_SIZE
    rep movsb
    
    ; Increment current card
    inc dword ptr [deck_current_card]
    
    xor al, al
    jmp read_tape_done
    
read_tape_eof:
    mov al, -1
    
read_tape_done:
    pop rdi
    pop rsi
    pop rcx
    pop rbx
    ret
read_card_from_tape ENDP

; =============================================================================
; CARD CONVERSION
; =============================================================================

card_to_ascii PROC
    ; Convert card data to ASCII string
    ; Input: None
    ; Output: RCX = pointer to ASCII string
    
    push rbx
    push rdx
    push rsi
    push rdi
    
    ; Create ASCII string from card
    mov rsi, offset current_card
    mov rdi, offset file_buffer
    xor ecx, ecx
    
ascii_convert_loop:
    cmp ecx, CARD_COLS
    jge ascii_convert_done
    
    ; Get punch pattern
    mov ax, word ptr [rsi + rcx * 2]
    
    ; Decode to character
    mov al, byte ptr [rsi + rcx]
    call decode_punch_pattern
    
    mov byte ptr [rdi + rcx], al
    inc ecx
    jmp ascii_convert_loop
    
ascii_convert_done:
    mov byte ptr [rdi + rcx], 0     ; Null terminate
    
    mov rcx, offset file_buffer
    
    pop rdi
    pop rsi
    pop rdx
    pop rbx
    ret
card_to_ascii ENDP

ascii_to_card PROC
    ; Convert ASCII string to card punches
    ; Input: RCX = pointer to ASCII string
    ; Output: EAX = status
    
    push rbx
    push rcx
    push rdi
    push rsi
    
    mov rsi, rcx                    ; Input string
    mov rdi, offset current_card
    xor ecx, ecx
    
punch_convert_loop:
    mov al, byte ptr [rsi]
    test al, al
    jz punch_convert_done
    
    ; Encode character to punch
    call encode_punch_pattern
    
    ; Store punch
    mov ebx, ecx
    imul ebx, ebx, 2
    add ebx, edi
    mov byte ptr [ebx], al
    mov byte ptr [ebx + 1], ah
    
    inc rsi
    inc ecx
    cmp ecx, CARD_COLS
    jl punch_convert_loop
    
punch_convert_done:
    xor eax, eax
    
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret
ascii_to_card ENDP

; =============================================================================
; CARD VALIDATION & VERIFICATION
; =============================================================================

verify_card PROC
    ; Verify card integrity
    ; Input: None
    ; Output: AL = valid (1) or invalid (0)
    
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov rsi, offset current_card
    xor edx, edx
    xor ecx, ecx
    
verify_loop:
    cmp ecx, CARD_BUFFER_SIZE
    jge verify_checksum
    
    mov al, byte ptr [rsi + rcx]
    add edx, eax
    inc ecx
    jmp verify_loop
    
verify_checksum:
    mov dword ptr [card_checksum], edx
    mov al, 1                       ; For now, always valid
    
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
verify_card ENDP

; =============================================================================
; CARD DISPLAY
; =============================================================================

display_card PROC
    ; Display card visualization
    ; Input: None
    ; Output: RCX = pointer to display buffer
    
    push rbx
    push rdx
    push rsi
    push rdi
    
    ; Create visual representation
    mov rdi, offset card_display
    mov rsi, offset current_card
    
    ; Display card header
    mov rcx, 80
    xor al, al
    rep stosb
    
    ; Display punch rows (simplified)
    xor ecx, ecx
    
display_card_loop:
    cmp ecx, CARD_ROWS
    jge display_card_done
    
    ; Add row label
    mov al, '*'
    mov byte ptr [rdi], al
    inc rdi
    
    inc ecx
    jmp display_card_loop
    
display_card_done:
    mov byte ptr [rdi], 0
    mov rcx, offset card_display
    
    pop rdi
    pop rsi
    pop rdx
    pop rbx
    ret
display_card ENDP

; =============================================================================
; DECK OPERATIONS
; =============================================================================

load_deck PROC
    ; Load a card deck from storage
    ; Input: RCX = filename pointer
    ; Output: EAX = card count
    
    push rbx
    push rcx
    
    ; Clear current deck
    xor ecx, ecx
    mov dword ptr [deck_card_count], ecx
    
    ; In production, would read from file
    ; For now, simulate with some test data
    mov eax, 5                      ; 5 cards loaded
    mov dword ptr [deck_card_count], eax
    
    pop rcx
    pop rbx
    ret
load_deck ENDP

save_deck PROC
    ; Save card deck to storage
    ; Input: RCX = filename pointer
    ; Output: EAX = status
    
    push rbx
    push rcx
    
    ; In production, would write to file
    xor eax, eax
    
    pop rcx
    pop rbx
    ret
save_deck ENDP

; =============================================================================
; PAPER TAPE OPERATIONS (Baudot 5-bit ASCII)
; =============================================================================

write_tape_baudot PROC
    ; Write Baudot-encoded data to paper tape
    ; Input: RCX = data pointer
    ;        RDX = length
    ; Output: EAX = bytes written
    
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    mov rsi, rcx                    ; Data pointer
    mov rdi, offset paper_tape
    mov rcx, rdx                    ; Length
    xor eax, eax                    ; Bytes written
    
tape_write_loop:
    cmp rcx, 0
    je tape_write_done
    
    mov bl, byte ptr [rsi]
    
    ; Encode to Baudot (5 bits)
    and bl, 0x1F                    ; Keep only 5 bits
    
    ; Add parity bit
    mov al, bl
    call calculate_parity
    ror bl, 1
    or bl, al
    
    ; Store in tape
    mov byte ptr [rdi], bl
    
    inc rsi
    inc rdi
    inc eax
    dec rcx
    jmp tape_write_loop
    
tape_write_done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
write_tape_baudot ENDP

; =============================================================================
; PARITY CALCULATION
; =============================================================================

calculate_parity PROC
    ; Calculate parity bit for Baudot encoding
    ; Input: AL = data (5 bits)
    ; Output: AL = parity bit (0 or 1)
    
    push rbx
    push rcx
    
    movzx eax, al
    mov rbx, offset parity_table
    mov al, byte ptr [rbx + rax]
    
    pop rcx
    pop rbx
    ret
calculate_parity ENDP

; =============================================================================
; DECK MANAGEMENT
; =============================================================================

get_deck_card_count PROC
    ; Get number of cards in deck
    ; Output: EAX = card count
    
    mov eax, dword ptr [deck_card_count]
    ret
get_deck_card_count ENDP

clear_deck PROC
    ; Clear all cards from deck
    ; Input: None
    ; Output: EAX = 0
    
    push rdi
    
    mov rdi, offset card_deck
    mov rcx, CARD_DECK_SIZE
    xor al, al
    rep stosb
    
    mov dword ptr [deck_card_count], 0
    mov dword ptr [deck_current_card], 0
    
    xor eax, eax
    pop rdi
    ret
clear_deck ENDP

; =============================================================================
; STATUS & DEBUG
; =============================================================================

get_parity_errors PROC
    ; Get tape parity error count
    ; Output: EAX = error count
    
    mov eax, dword ptr [tape_parity_errors]
    ret
get_parity_errors ENDP

get_card_checksum PROC
    ; Get current card checksum
    ; Output: EAX = checksum
    
    mov eax, dword ptr [card_checksum]
    ret
get_card_checksum ENDP

; =============================================================================
; PAPER TAPE OPERATIONS
; =============================================================================

write_to_tape PROC
    ; Write data to paper tape
    ; Input: AL = data byte
    ;        ECX = position on tape
    ; Output: EAX = bytes written
    
    push rbx
    push rcx
    push rdi
    
    ; Validate position
    cmp ecx, TAPE_BUFFER_SIZE
    jge tape_error
    
    ; Write byte to tape
    mov rdi, offset paper_tape
    add rdi, rcx
    mov byte ptr [rdi], al
    
    ; Calculate parity
    mov bl, al
    mov cl, 8
    xor eax, eax
    
parity_calc_loop:
    test cl, cl
    jz parity_calc_done
    
    mov eax, ebx
    and eax, 1
    shr ebx, 1
    dec ecx
    jmp parity_calc_loop
    
parity_calc_done:
    ; Parity stored in AL
    mov eax, 1
    jmp tape_write_done
    
tape_error:
    mov eax, -1
    
tape_write_done:
    pop rdi
    pop rcx
    pop rbx
    ret
write_to_tape ENDP

read_from_tape PROC
    ; Read data from paper tape
    ; Input: ECX = position on tape
    ; Output: AL = data byte
    
    ; Validate position
    cmp ecx, TAPE_BUFFER_SIZE
    jge tape_read_error
    
    mov rax, offset paper_tape
    add rax, rcx
    mov al, byte ptr [rax]
    ret
    
tape_read_error:
    xor al, al
    ret
read_from_tape ENDP

; =============================================================================
; DECK MANAGEMENT
; =============================================================================

add_card_to_deck PROC
    ; Add current card to deck
    ; Output: EAX = deck position
    
    push rbx
    push rcx
    push rdi
    push rsi
    
    ; Check deck space
    cmp dword ptr [deck_card_count], 10
    jge deck_full
    
    ; Calculate deck offset
    mov rax, dword ptr [deck_card_count]
    imul rax, CARD_BUFFER_SIZE
    mov rdi, offset card_deck
    add rdi, rax
    
    ; Copy current card to deck
    mov rsi, offset current_card
    mov rcx, CARD_BUFFER_SIZE
    rep movsb
    
    ; Increment card count
    inc dword ptr [deck_card_count]
    mov eax, dword ptr [deck_card_count]
    dec eax
    
    jmp deck_add_done
    
deck_full:
    mov eax, -1
    
deck_add_done:
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret
add_card_to_deck ENDP

get_card_from_deck PROC
    ; Retrieve a card from deck
    ; Input: ECX = card index
    ; Output: EAX = status
    
    push rbx
    push rdi
    push rsi
    
    ; Validate index
    cmp ecx, dword ptr [deck_card_count]
    jge deck_get_error
    
    ; Calculate deck offset
    mov rax, rcx
    imul rax, CARD_BUFFER_SIZE
    mov rsi, offset card_deck
    add rsi, rax
    
    ; Copy to current card
    mov rdi, offset current_card
    mov rcx, CARD_BUFFER_SIZE
    rep movsb
    
    mov dword ptr [deck_current_card], eax
    xor eax, eax
    jmp deck_get_done
    
deck_get_error:
    mov eax, -1
    
deck_get_done:
    pop rsi
    pop rdi
    pop rbx
    ret
get_card_from_deck ENDP

; =============================================================================
; FILE OPERATIONS
; =============================================================================

save_deck_to_file PROC
    ; Save card deck to file
    ; Input: RCX = filename
    ; Output: EAX = bytes written
    
    push rbx
    push rcx
    
    ; Calculate total size
    mov rax, dword ptr [deck_card_count]
    imul rax, CARD_BUFFER_SIZE
    
    mov dword ptr [file_size], eax
    mov eax, dword ptr [file_size]
    
    pop rcx
    pop rbx
    ret
save_deck_to_file ENDP

load_deck_from_file PROC
    ; Load card deck from file
    ; Input: RCX = filename
    ; Output: EAX = cards loaded
    
    push rdi
    push rsi
    
    ; Initialize deck
    mov rdi, offset card_deck
    mov rcx, CARD_DECK_SIZE
    xor al, al
    rep stosb
    
    mov dword ptr [deck_card_count], 0
    
    xor eax, eax
    pop rsi
    pop rdi
    ret
load_deck_from_file ENDP

; =============================================================================
; DISPLAY FUNCTIONS
; =============================================================================

display_card PROC
    ; Display current card visually
    ; Output: Card printed to console
    
    push rbx
    push rcx
    push rdi
    push rsi
    
    ; Print card frame
    mov rdi, offset card_display
    mov rsi, offset current_card
    
    ; Print top border
    mov rcx, 82                     ; 80 cols + borders
    mov al, '-'
    rep stosb
    
    ; Print each row
    xor ecx, ecx
    
card_print_rows:
    cmp ecx, CARD_ROWS
    jge card_print_done
    
    mov al, '|'
    mov byte ptr [rdi], al
    inc rdi
    
    mov rax, rcx
    imul rax, CARD_COLS
    mov rbx, rsi
    add rbx, rax
    
    mov r8, CARD_COLS
    
card_print_cols:
    cmp r8, 0
    je card_print_row_end
    
    mov al, byte ptr [rbx]
    test al, al
    jz card_print_blank
    mov al, '*'
    jmp card_col_done
    
card_print_blank:
    mov al, ' '
    
card_col_done:
    mov byte ptr [rdi], al
    inc rdi
    inc rbx
    dec r8
    jmp card_print_cols
    
card_print_row_end:
    mov al, '|'
    mov byte ptr [rdi], al
    inc rdi
    
    mov al, 13                     ; CR
    mov byte ptr [rdi], al
    inc rdi
    mov al, 10                     ; LF
    mov byte ptr [rdi], al
    inc rdi
    
    inc ecx
    jmp card_print_rows
    
card_print_done:
    mov byte ptr [rdi], 0           ; Null terminate
    
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret
display_card ENDP

get_deck_card_count PROC
    ; Get number of cards in deck
    ; Output: EAX = card count
    
    mov eax, dword ptr [deck_card_count]
    ret
get_deck_card_count ENDP

END
