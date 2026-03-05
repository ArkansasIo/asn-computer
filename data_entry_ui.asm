; ============================================================================
; ALTAIR 8800 DATA ENTRY UI SYSTEM
; Front-End Data Input and Entry Forms
; ============================================================================

.code

extern GetStdHandle:proc
extern WriteConsoleA:proc
extern ReadConsoleA:proc
extern SetConsoleCursorPosition:proc

; ============================================================================
; FORM SYSTEM CONSTANTS
; ============================================================================

.data

; Form types
FORM_TYPE_DATA_ENTRY    equ 0x01
FORM_TYPE_SEARCH        equ 0x02
FORM_TYPE_FILTER        equ 0x03
FORM_TYPE_EXPORT        equ 0x04

; Field types
FIELD_TEXT              equ 0x01
FIELD_NUMBER            equ 0x02
FIELD_DATE              equ 0x03
FIELD_TIME              equ 0x04
FIELD_CHECKBOX          equ 0x05
FIELD_DROPDOWN          equ 0x06
FIELD_MULTILINE         equ 0x07

; Field validation rules
VALIDATE_REQUIRED       equ 0x01
VALIDATE_NUMERIC        equ 0x02
VALIDATE_EMAIL          equ 0x04
VALIDATE_DATE           equ 0x08
VALIDATE_RANGE          equ 0x10
VALIDATE_LENGTH         equ 0x20

; ============================================================================
; FORM STRUCTURE (64 bytes per field)
; ============================================================================
; 0x00: Field name (16 bytes)
; 0x10: Label (24 bytes)
; 0x28: Type (1 byte)
; 0x29: Validation flags (1 byte)
; 0x2A: Required (1 byte)
; 0x2B: Max length (1 byte)
; 0x2C: Reserved (20 bytes)

; ============================================================================
; FORM DATA STRUCTURES
; ============================================================================

; Current form
current_form_type:      db 0
current_form_id:        dd 0
form_field_count:       dd 0
form_data_buffer:       db 4096 dup(0)
form_validation_errors: db 512 dup(0)

; Field navigation
current_field_index:    dd 0
focused_field:          dd 0
total_fields:           dd 0

; Form mode
form_edit_mode:         db 0
form_insert_mode:       db 0
form_display_mode:      db 0

; Input state
field_values:           db 2048 dup(0)
field_errors:           db 512 dup(0)

; ============================================================================
; CREATE DATA ENTRY FORM
; ============================================================================

create_form:
    ; Input: RCX = form type
    ;        RDX = number of fields
    ;        R8  = data buffer
    ; Output: EAX = form ID
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Store form type
    mov [current_form_type], cl
    
    ; Store field count
    mov [form_field_count], edx
    mov [total_fields], edx
    
    ; Initialize form to insert mode
    mov byte ptr [form_insert_mode], 1
    mov byte ptr [form_edit_mode], 0
    
    ; Copy data buffer
    cmp r8, 0
    je form_create_done
    
    mov rsi, r8
    mov rdi, offset form_data_buffer
    mov rcx, 2048
    
copy_form_data:
    cmp rcx, 0
    je form_create_done
    
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jmp copy_form_data
    
form_create_done:
    mov eax, 1                          ; Form ID
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; ADD FIELD TO FORM
; ============================================================================

add_form_field:
    ; Input: RCX = field name
    ;        RDX = field label
    ;        R8B = field type
    ;        R9B = validation flags
    ; Output: none
    
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Get field index
    mov rax, [form_field_count]
    imul rax, 64
    add rax, offset form_data_buffer
    
    ; Copy field name
    mov rsi, rcx
    mov rdi, rax
    mov rcx, 16
    
copy_name:
    cmp rcx, 0
    je copy_label
    
    mov bl, [rsi]
    mov [rdi], bl
    inc rsi
    inc rdi
    dec rcx
    jmp copy_name
    
copy_label:
    mov rsi, rdx
    mov rcx, 24
    
copy_lbl:
    cmp rcx, 0
    je set_field_type
    
    mov bl, [rsi]
    mov [rdi], bl
    inc rsi
    inc rdi
    dec rcx
    jmp copy_lbl
    
set_field_type:
    mov [rdi], r8b                      ; Type
    inc rdi
    mov [rdi], r9b                      ; Validation flags
    
    inc dword ptr [form_field_count]
    
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; DISPLAY FORM
; ============================================================================

display_form:
    ; Draw form on screen
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Clear screen
    call clear_data_entry_screen
    
    ; Print form header
    mov rcx, offset form_title
    call print_string_form
    
    ; Print each field
    mov r8d, 0
    
display_fields:
    cmp r8d, [form_field_count]
    jge form_display_done
    
    ; Calculate field position
    mov rax, r8
    add rax, 2
    mov rcx, rax
    mov rdx, 0
    call set_form_cursor
    
    ; Display field
    mov rax, r8
    imul rax, 64
    add rax, offset form_data_buffer
    
    ; Print label
    mov rcx, [rax + 0x10]
    call print_string_form
    
    ; Print input box
    mov rcx, 40
    
print_input_box:
    cmp rcx, 0
    je field_input_complete
    
    mov al, '_'
    call print_char_form
    dec rcx
    jmp print_input_box
    
field_input_complete:
    inc r8d
    jmp display_fields
    
form_display_done:
    ; Print buttons
    mov rcx, 22
    mov rdx, 0
    call set_form_cursor
    
    mov rcx, offset form_buttons
    call print_string_form
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; CAPTURE FIELD INPUT
; ============================================================================

capture_field_input:
    ; Input: EAX = field index
    ; Output: RCX = input buffer
    
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Get field structure
    mov rsi, rax
    imul rsi, 64
    add rsi, offset form_data_buffer
    
    ; Get field type
    mov bl, [rsi + 0x28]
    
    ; Get field size
    mov r8b, [rsi + 0x2B]
    
    ; Position cursor for input
    mov rdx, rax
    add rdx, 2
    mov rcx, 30
    call set_form_cursor
    
    ; Clear previous input
    mov rcx, 40
    
clear_input_line:
    cmp rcx, 0
    je input_line_cleared
    
    mov al, ' '
    call print_char_form
    dec rcx
    jmp clear_input_line
    
input_line_cleared:
    ; Reposition cursor
    mov rcx, 30
    call set_form_cursor_back
    
    ; Get input based on field type
    cmp bl, FIELD_TEXT
    je input_text_field
    cmp bl, FIELD_NUMBER
    je input_number_field
    cmp bl, FIELD_DATE
    je input_date_field
    
    jmp input_done
    
input_text_field:
    call read_text_input
    jmp input_done
    
input_number_field:
    call read_number_input
    jmp input_done
    
input_date_field:
    call read_date_input
    jmp input_done
    
input_done:
    ; Store input value
    mov rdi, offset field_values
    mov rsi, offset form_data_buffer
    mov rcx, 40
    
    ; Copy to field values
    rep movsb
    
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; INPUT VALIDATION
; ============================================================================

validate_form_data:
    ; Validate all fields
    ; Output: AL = 0 (valid), 1 (invalid)
    
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    mov r8d, 0
    
validate_field_loop:
    cmp r8d, [form_field_count]
    jge validation_complete
    
    ; Get field
    mov rax, r8
    imul rax, 64
    add rax, offset form_data_buffer
    
    ; Get validation flags
    mov bl, [rax + 0x29]
    
    ; Get field value
    mov rsi, rax
    add rsi, 0x40                       ; Data offset
    
    ; Validate required
    test bl, VALIDATE_REQUIRED
    je check_numeric
    
    mov al, [rsi]
    cmp al, 0
    jne check_numeric
    
    ; Record error
    mov rcx, r8
    mov rdx, offset error_required
    call record_validation_error
    inc dword ptr [validation_errors]
    
check_numeric:
    test bl, VALIDATE_NUMERIC
    je check_email
    
    call validate_numeric_field
    cmp al, 0
    je check_email
    
    mov rcx, r8
    mov rdx, offset error_numeric
    call record_validation_error
    
check_email:
    test bl, VALIDATE_EMAIL
    je check_date
    
    call validate_email_field
    cmp al, 0
    je check_date
    
    mov rcx, r8
    mov rdx, offset error_email
    call record_validation_error
    
check_date:
    test bl, VALIDATE_DATE
    je next_validate_field
    
    call validate_date_field
    cmp al, 0
    je next_validate_field
    
    mov rcx, r8
    mov rdx, offset error_date
    call record_validation_error
    
next_validate_field:
    inc r8d
    jmp validate_field_loop
    
validation_complete:
    mov eax, [validation_errors]
    test eax, eax
    je validation_success
    
    mov al, 1
    jmp validation_exit
    
validation_success:
    xor al, al
    
validation_exit:
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; FIELD TYPE INPUT HANDLERS
; ============================================================================

read_text_input:
    ; Read text input for text field
    push rbp
    mov rbp, rsp
    
    mov rcx, offset field_values
    mov rdx, 64
    call read_line_input
    
    pop rbp
    ret

read_number_input:
    ; Read numeric input with validation
    push rbp
    mov rbp, rsp
    
    mov r8d, 0
    
number_input_loop:
    call read_char_input
    
    ; Check if digit or special char
    cmp al, '0'
    jl number_check_special
    cmp al, '9'
    jg number_check_special
    
    mov rsi, offset field_values
    add rsi, r8
    mov [rsi], al
    inc r8d
    
    call print_char_form
    jmp number_input_loop
    
number_check_special:
    cmp al, 13                          ; ENTER
    je number_input_done
    
    cmp al, 8                           ; Backspace
    jne number_input_loop
    
    cmp r8d, 0
    je number_input_loop
    
    dec r8d
    mov al, 8
    call print_char_form
    
    jmp number_input_loop
    
number_input_done:
    mov rsi, offset field_values
    add rsi, r8
    mov byte ptr [rsi], 0               ; Null terminate
    
    pop rbp
    ret

read_date_input:
    ; Read date input (MM/DD/YYYY format)
    push rbp
    mov rbp, rsp
    
    ; Would implement date-specific input with validation
    
    pop rbp
    ret

; ============================================================================
; FIELD VALIDATION HELPERS
; ============================================================================

validate_numeric_field:
    ; Input: RSI = field data
    ; Output: AL = 0 (valid), 1 (invalid)
    
    push rbp
    mov rbp, rsp
    
    mov rcx, 0
    
check_number_chars:
    mov al, [rsi + rcx]
    cmp al, 0
    je number_valid
    
    cmp al, '0'
    jl number_invalid
    cmp al, '9'
    jg number_check_decimal
    
    inc rcx
    jmp check_number_chars
    
number_check_decimal:
    cmp al, '.'
    je inc_and_continue
    
    jmp number_invalid
    
inc_and_continue:
    inc rcx
    jmp check_number_chars
    
number_valid:
    xor al, al
    jmp validate_numeric_done
    
number_invalid:
    mov al, 1
    
validate_numeric_done:
    pop rbp
    ret

validate_email_field:
    ; Input: RSI = field data
    ; Output: AL = 0 (valid), 1 (invalid)
    
    push rbp
    mov rbp, rsp
    
    ; Check for @ symbol
    mov rcx, 0
    mov r8d, 0
    
check_email_chars:
    mov al, [rsi + rcx]
    cmp al, 0
    je check_email_at_found
    
    cmp al, '@'
    jne skip_at_check
    
    inc r8d
    
skip_at_check:
    inc rcx
    jmp check_email_chars
    
check_email_at_found:
    cmp r8d, 1
    je email_valid
    
    mov al, 1
    jmp validate_email_done
    
email_valid:
    xor al, al
    
validate_email_done:
    pop rbp
    ret

validate_date_field:
    ; Input: RSI = field data (format MM/DD/YYYY)
    ; Output: AL = 0 (valid), 1 (invalid)
    
    push rbp
    mov rbp, rsp
    
    ; Simplified date validation
    xor al, al
    
    pop rbp
    ret

; ============================================================================
; FORM NAVIGATION
; ============================================================================

next_form_field:
    ; Move to next field
    
    inc dword ptr [current_field_index]
    cmp dword ptr [current_field_index], [form_field_count]
    jl field_nav_done
    
    mov dword ptr [current_field_index], 0
    
field_nav_done:
    ret

previous_form_field:
    ; Move to previous field
    
    cmp dword ptr [current_field_index], 0
    eq field_at_start
    
    dec dword ptr [current_field_index]
    jmp prev_field_done
    
field_at_start:
    mov eax, [form_field_count]
    dec eax
    mov [current_field_index], eax
    
prev_field_done:
    ret

; ============================================================================
; FORM SUBMISSION
; ============================================================================

submit_form:
    ; Submit form and insert/update data
    ; Output: AL = 0 (success), -1 (validation error)
    
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Validate all fields first
    call validate_form_data
    cmp al, 0
    jne submit_validation_failed
    
    ; Insert data into database
    mov rcx, offset field_values
    call insert_form_data
    
    xor al, al
    jmp submit_done
    
submit_validation_failed:
    mov al, -1
    call display_validation_errors
    
submit_done:
    add rsp, 64
    pop rbp
    ret

insert_form_data:
    ; Insert form data into database
    ; Input: RCX = data buffer
    
    push rbp
    mov rbp, rsp
    
    ; Would call database insert
    
    pop rbp
    ret

; ============================================================================
; ERROR HANDLING
; ============================================================================

record_validation_error:
    ; Input: RCX = field index, RDX = error message
    
    push rbp
    mov rbp, rsp
    
    mov rsi, rdx
    mov rdi, offset form_validation_errors
    
    ; Append error message
    
    pop rbp
    ret

display_validation_errors:
    ; Display all validation errors
    
    push rbp
    mov rbp, rsp
    
    mov rcx, offset form_validation_errors
    call print_string_form
    
    pop rbp
    ret

; ============================================================================
; HELPER FUNCTIONS
; ============================================================================

clear_data_entry_screen:
    push rbp
    mov rbp, rsp
    
    mov rcx, 25
    
clear_form_lines:
    cmp rcx, 0
    je form_cleared
    
    mov al, 10
    call print_char_form
    dec rcx
    jmp clear_form_lines
    
form_cleared:
    pop rbp
    ret

set_form_cursor:
    ; Input: RCX = X, RDX = Y
    push rbp
    mov rbp, rsp
    
    ; Would use SetConsoleCursorPosition
    
    pop rbp
    ret

set_form_cursor_back:
    push rbp
    mov rbp, rsp
    
    ; Move cursor back N positions
    
    pop rbp
    ret

print_string_form:
    ; Input: RCX = string
    push rbp
    mov rbp, rsp
    
    mov rsi, rcx
    
form_str_loop:
    mov al, [rsi]
    cmp al, 0
    je form_str_done
    
    call print_char_form
    inc rsi
    jmp form_str_loop
    
form_str_done:
    pop rbp
    ret

print_char_form:
    ; Input: AL = character
    push rbp
    mov rbp, rsp
    
    ; Would use WriteConsoleA
    
    pop rbp
    ret

read_char_input:
    ; Output: AL = character
    push rbp
    mov rbp, rsp
    
    ; Would use ReadConsoleA
    
    pop rbp
    ret

read_line_input:
    ; Input: RCX = buffer, RDX = max length
    push rbp
    mov rbp, rsp
    
    ; Would use ReadConsoleA
    
    pop rbp
    ret

; ============================================================================
; ERROR MESSAGES
; ============================================================================

form_title:             db "Data Entry Form", 0
form_buttons:           db "[F1]=Save [F2]=Cancel [Tab]=Next [Shift+Tab]=Prev", 0

error_required:         db "Field is required", 0
error_numeric:          db "Must be numeric", 0
error_email:            db "Invalid email format", 0
error_date:             db "Invalid date format", 0

validation_errors:      dd 0

; ============================================================================
; END OF DATA ENTRY UI SYSTEM
; ============================================================================

end
