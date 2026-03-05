; =============================================================================
; DATA ENTRY UI - Form-based Data Entry with Validation
; =============================================================================
; Purpose: Dynamic forms, field validation, input capture, error display
; Author: Altair 8800 OS Development Team
; Date: March 4, 2026
; Version: 1.0
; Lines: 900+
; =============================================================================

option casemap:none
EXTERN ExitProcess:PROC

; =============================================================================
; CONSTANTS
; =============================================================================

; Form types
FORM_TYPE_DATA_ENTRY    EQU 1
FORM_TYPE_SEARCH        EQU 2
FORM_TYPE_REPORT        EQU 3

; Field types
FIELD_TEXT              EQU 1
FIELD_NUMBER            EQU 2
FIELD_DATE              EQU 3
FIELD_TIME              EQU 4
FIELD_CHECKBOX          EQU 5
FIELD_DROPDOWN          EQU 6
FIELD_MULTILINE         EQU 7

; Validation flags
VALIDATE_REQUIRED       EQU 1
VALIDATE_EMAIL          EQU 2
VALIDATE_NUMERIC        EQU 4
VALIDATE_DATE           EQU 8
VALIDATE_PHONE          EQU 16
VALIDATE_LENGTH         EQU 32

; Maximum values
MAX_FORMS               EQU 8
MAX_FIELDS_PER_FORM     EQU 32
FIELD_NAME_LEN          EQU 32
FIELD_LABEL_LEN         EQU 64
FIELD_VALUE_LEN         EQU 256

; Form metadata size
FORM_METADATA_SIZE      EQU 512
FIELD_ENTRY_SIZE        EQU 256

; =============================================================================
; DATA SECTION
; =============================================================================

.data

moduleName              db "data_entry_ui", 0
version_str             db "1.0", 0

; Form management
form_count              dd 0
active_forms            dd MAX_FORMS dup(0)
form_metadata           db MAX_FORMS * FORM_METADATA_SIZE dup(0)

; Field storage
field_definitions       db MAX_FORMS * MAX_FIELDS_PER_FORM * FIELD_ENTRY_SIZE dup(0)

; Current form state
current_form_id         dd 0
current_field_index     dd 0
field_count             dd 0
form_submitted          dd 0
form_validated          dd 0

; Field input buffers
field_values            db MAX_FIELDS_PER_FORM * FIELD_VALUE_LEN dup(0)
current_input_buffer    db 256 dup(0)
input_buffer_pos        dd 0

; Validation errors
validation_errors       db MAX_FIELDS_PER_FORM * 64 dup(0)
error_count             dd 0

; UI display
form_title              db "Data Entry Form", 0
field_prompt            db "Enter data: ", 0
error_display           db 1024 dup(0)
status_line             db "Use Tab to navigate, Enter to submit, Esc to cancel", 0

; Default labels
label_name              db "Name", 0
label_email             db "Email", 0
label_phone             db "Phone", 0
label_date              db "Date", 0

; Validation messages
msg_required            db "This field is required", 0
msg_email_invalid       db "Invalid email format", 0
msg_numeric_invalid     db "Please enter a valid number", 0
msg_date_invalid        db "Invalid date format (MM/DD/YYYY)", 0
msg_phone_invalid       db "Invalid phone number", 0
msg_length_invalid      db "Input too long", 0

; =============================================================================
; CODE SECTION
; =============================================================================

.code

; =============================================================================
; FORM CREATION & MANAGEMENT
; =============================================================================

create_form PROC
    ; Create a new form
    ; Input: ECX = form type
    ;        EDX = field count
    ; Output: EAX = form_id
    
    push rbx
    push rcx
    push rdx
    push rdi
    
    ; Check form limit
    cmp dword ptr [form_count], MAX_FORMS
    jge create_form_error
    
    ; Get next form ID
    mov eax, dword ptr [form_count]
    inc eax
    mov ebx, eax
    
    ; Store form metadata
    mov rax, ebx
    imul rax, rax, FORM_METADATA_SIZE
    mov rdi, offset form_metadata
    add rdi, rax
    
    ; Store form type and field count
    mov byte ptr [rdi], cl
    mov byte ptr [rdi + 1], dl
    mov byte ptr [rdi + 2], 0      ; Current field
    
    ; Store form ID in active list
    mov rax, dword ptr [form_count]
    mov dword ptr [active_forms + rax * 4], ebx
    inc dword ptr [form_count]
    
    mov eax, ebx                    ; Return form ID
    mov dword ptr [current_form_id], ebx
    mov dword ptr [field_count], edx
    
    jmp create_form_done
    
create_form_error:
    mov eax, -1
    
create_form_done:
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret
create_form ENDP

; =============================================================================
; FIELD OPERATIONS
; =============================================================================

add_form_field PROC
    ; Add a field to current form
    ; Input: RCX = field name
    ;        RDX = field label
    ;        R8B = field type
    ;        R9B = validation flags
    ; Output: EAX = status
    
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Get current form
    mov ecx, dword ptr [current_form_id]
    cmp ecx, 0
    jle add_field_error
    
    ; Get current field index
    mov eax, dword ptr [current_field_index]
    cmp eax, MAX_FIELDS_PER_FORM
    jge add_field_error
    
    ; Calculate field position
    mov rbx, rcx
    imul rbx, rbx, MAX_FIELDS_PER_FORM
    add rbx, rax
    imul rbx, rbx, FIELD_ENTRY_SIZE
    
    mov rdi, offset field_definitions
    add rdi, rbx
    
    ; Copy field name
    mov rsi, rcx
    mov rcx, FIELD_NAME_LEN
    rep movsb
    
    ; Copy field label
    mov rsi, rdx
    mov rcx, FIELD_LABEL_LEN
    rep movsb
    
    ; Store field type and validation
    mov byte ptr [rdi], r8b         ; Field type
    mov byte ptr [rdi + 1], r9b     ; Validation flags
    
    ; Increment field index
    mov eax, dword ptr [current_field_index]
    inc eax
    mov dword ptr [current_field_index], eax
    
    xor eax, eax
    jmp add_field_done
    
add_field_error:
    mov eax, -1
    
add_field_done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
add_form_field ENDP

; =============================================================================
; FORM DISPLAY
; =============================================================================

display_form PROC
    ; Display the current form
    ; Input: None
    ; Output: EAX = 0
    
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Clear screen (simplified)
    mov ecx, 2000
    xor al, al
    
    ; Display form title
    mov rsi, offset form_title
    mov rdi, 0                      ; Display at position 0
    mov rcx, 50
    
display_title_loop:
    mov al, byte ptr [rsi]
    test al, al
    jz title_done
    inc rsi
    loop display_title_loop
    
title_done:
    
    ; Display fields
    xor ecx, ecx                    ; Field counter
    
display_fields_loop:
    cmp ecx, dword ptr [field_count]
    jge fields_done
    
    ; Display field label
    ; (Simplified - in real implementation would format nicely)
    
    inc ecx
    jmp display_fields_loop
    
fields_done:
    
    ; Display status line
    mov rsi, offset status_line
    
    ; Show current field
    mov ecx, dword ptr [current_field_index]
    
    xor eax, eax
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
display_form ENDP

; =============================================================================
; INPUT CAPTURE
; =============================================================================

capture_field_input PROC
    ; Capture input for current field
    ; Input: ECX = field index
    ; Output: EAX = input length
    
    push rbx
    push rcx
    push rdi
    
    ; Set current field
    mov dword ptr [current_field_index], ecx
    
    ; Clear input buffer
    mov rdi, offset current_input_buffer
    mov rcx, 256
    xor al, al
    rep stosb
    
    mov dword ptr [input_buffer_pos], 0
    
    ; Get field type
    mov eax, ecx
    imul eax, eax, FIELD_ENTRY_SIZE
    mov rbx, offset field_definitions
    add rbx, rax
    mov al, byte ptr [rbx]          ; Field type
    
    ; Handle based on field type
    cmp al, FIELD_TEXT
    je capture_text
    cmp al, FIELD_NUMBER
    je capture_number
    cmp al, FIELD_DATE
    je capture_date
    
    ; Default: text input
    
capture_text:
    ; Simulate input (in real implementation would read from keyboard)
    mov rdi, offset current_input_buffer
    mov byte ptr [rdi], 'D'
    mov byte ptr [rdi + 1], 'a'
    mov byte ptr [rdi + 2], 'a'
    mov byte ptr [rdi + 3], 'a'
    mov byte ptr [rdi + 4], 0
    mov eax, 4
    jmp capture_done
    
capture_number:
    mov rdi, offset current_input_buffer
    mov byte ptr [rdi], '1'
    mov byte ptr [rdi + 1], '2'
    mov byte ptr [rdi + 2], '3'
    mov byte ptr [rdi + 3], 0
    mov eax, 3
    jmp capture_done
    
capture_date:
    mov rdi, offset current_input_buffer
    mov byte ptr [rdi], '1'
    mov byte ptr [rdi + 1], '2'
    mov byte ptr [rdi + 2], '/'
    mov byte ptr [rdi + 3], '2'
    mov byte ptr [rdi + 4], '5'
    mov byte ptr [rdi + 5], '/'
    mov byte ptr [rdi + 6], '2'
    mov byte ptr [rdi + 7], '0'
    mov byte ptr [rdi + 8], '2'
    mov byte ptr [rdi + 9], '6'
    mov byte ptr [rdi + 10], 0
    mov eax, 10
    
capture_done:
    pop rdi
    pop rcx
    pop rbx
    ret
capture_field_input ENDP

; =============================================================================
; FIELD NAVIGATION
; =============================================================================

next_form_field PROC
    ; Move to next form field
    ; Input: None
    ; Output: EAX = status
    
    mov ecx, dword ptr [current_field_index]
    inc ecx
    cmp ecx, dword ptr [field_count]
    jge next_field_boundary
    
    mov dword ptr [current_field_index], ecx
    xor eax, eax
    ret
    
next_field_boundary:
    mov eax, -1
    ret
next_form_field ENDP

previous_form_field PROC
    ; Move to previous form field
    ; Input: None
    ; Output: EAX = status
    
    mov ecx, dword ptr [current_field_index]
    cmp ecx, 0
    jle prev_field_boundary
    
    dec ecx
    mov dword ptr [current_field_index], ecx
    xor eax, eax
    ret
    
prev_field_boundary:
    mov eax, -1
    ret
previous_form_field ENDP

; =============================================================================
; VALIDATION
; =============================================================================

validate_form_data PROC
    ; Validate all form fields
    ; Input: None
    ; Output: EAX = 1 if valid, 0 if errors
    
    push rbx
    push rcx
    push rdx
    
    mov dword ptr [error_count], 0
    xor ecx, ecx                    ; Field counter
    
validate_loop:
    cmp ecx, dword ptr [field_count]
    jge validate_complete
    
    ; Validate this field
    mov edx, ecx
    call validate_single_field
    
    inc ecx
    jmp validate_loop
    
validate_complete:
    cmp dword ptr [error_count], 0
    je validate_ok
    
    mov eax, 0                      ; Has errors
    jmp validate_done
    
validate_ok:
    mov eax, 1                      ; No errors
    
validate_done:
    pop rdx
    pop rcx
    pop rbx
    ret
validate_form_data ENDP

validate_single_field PROC
    ; Validate a single field
    ; Input: EDX = field index
    ; Output: EAX = status
    
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Get field definition
    mov eax, edx
    imul eax, eax, FIELD_ENTRY_SIZE
    mov rbx, offset field_definitions
    add rbx, rax
    
    ; Check validation flags
    mov cl, byte ptr [rbx + 1]      ; Validation flags
    
    ; Check required
    cmp cl, VALIDATE_REQUIRED
    jne validate_check_format
    
    mov rsi, offset current_input_buffer
    cmp byte ptr [rsi], 0
    je validate_field_error
    
validate_check_format:
    ; Check format based on field type
    mov al, byte ptr [rbx]          ; Field type
    
    cmp al, FIELD_NUMBER
    je validate_numeric_field
    cmp al, FIELD_DATE
    je validate_date_field
    cmp al, FIELD_TEXT
    je validate_text_field
    
validate_text_field:
    xor eax, eax
    jmp validate_field_done
    
validate_numeric_field:
    call validate_numeric_format
    jmp validate_field_done
    
validate_date_field:
    call validate_date_format
    jmp validate_field_done
    
validate_field_error:
    inc dword ptr [error_count]
    mov eax, -1
    
validate_field_done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
validate_single_field ENDP

validate_numeric_field PROC
    ; Validate numeric field format
    ; Input: RCX = input string
    ; Output: EAX = 0 if valid
    
    push rbx
    push rcx
    
    mov rsi, rcx
    
numeric_check_loop:
    mov al, byte ptr [rsi]
    test al, al
    jz numeric_valid
    
    ; Check if digit or minus
    cmp al, '-'
    je numeric_ok
    cmp al, '0'
    jl numeric_invalid
    cmp al, '9'
    jg numeric_invalid
    
numeric_ok:
    inc rsi
    jmp numeric_check_loop
    
numeric_invalid:
    mov eax, -1
    jmp numeric_done
    
numeric_valid:
    xor eax, eax
    
numeric_done:
    pop rcx
    pop rbx
    ret
validate_numeric_field ENDP

validate_date_field PROC
    ; Validate date field format (MM/DD/YYYY)
    ; Input: RCX = input string
    ; Output: EAX = 0 if valid
    
    push rbx
    push rcx
    push rdx
    
    mov rsi, rcx
    xor ecx, ecx
    
    ; Must be exactly 10 characters: MM/DD/YYYY
    
date_validate_loop:
    mov al, byte ptr [rsi + rcx]
    
    ; Check positions 2 and 5 for slashes
    cmp ecx, 2
    je date_check_slash
    cmp ecx, 5
    je date_check_slash
    cmp ecx, 10
    je date_validate_ok
    
    ; Check if digit
    cmp al, '0'
    jl date_invalid
    cmp al, '9'
    jg date_invalid
    
    inc ecx
    jmp date_validate_loop
    
date_check_slash:
    cmp al, '/'
    jne date_invalid
    inc ecx
    jmp date_validate_loop
    
date_invalid:
    mov eax, -1
    jmp date_validate_done
    
date_validate_ok:
    xor eax, eax
    
date_validate_done:
    pop rdx
    pop rcx
    pop rbx
    ret
validate_date_field ENDP

validate_email_field PROC
    ; Validate email format
    ; Input: RCX = input string
    ; Output: EAX = 0 if valid
    
    push rbx
    push rcx
    push rdx
    
    mov rsi, rcx
    xor eax, eax
    xor ebx, ebx                    ; @ found flag
    
email_loop:
    mov al, byte ptr [rsi]
    test al, al
    jz email_check_valid
    
    cmp al, '@'
    jne email_next
    
    cmp ebx, 1
    je email_invalid               ; Multiple @ signs
    mov ebx, 1
    
email_next:
    inc rsi
    jmp email_loop
    
email_invalid:
    mov eax, -1
    jmp email_done
    
email_check_valid:
    cmp ebx, 1
    jne email_invalid
    xor eax, eax
    
email_done:
    pop rdx
    pop rcx
    pop rbx
    ret
validate_email_field ENDP

; =============================================================================
; ERROR DISPLAY
; =============================================================================

display_validation_errors PROC
    ; Display validation errors
    ; Input: None
    ; Output: EAX = error count
    
    push rbx
    push rcx
    push rdi
    push rsi
    
    ; Build error message
    mov rdi, offset error_display
    mov rsi, offset validation_errors
    mov ecx, dword ptr [error_count]
    
error_display_loop:
    cmp ecx, 0
    je error_display_done
    
    mov al, byte ptr [rsi]
    mov byte ptr [rdi], al
    
    inc rsi
    inc rdi
    dec ecx
    jmp error_display_loop
    
error_display_done:
    mov byte ptr [rdi], 0           ; Null terminate
    
    mov eax, dword ptr [error_count]
    
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret
display_validation_errors ENDP

; =============================================================================
; FORM SUBMISSION
; =============================================================================

submit_form PROC
    ; Submit the form
    ; Input: None
    ; Output: EAX = status (0 = success)
    
    push rbx
    push rcx
    
    ; Validate form
    call validate_form_data
    cmp eax, 1
    jne submit_error
    
    ; Mark form as submitted
    mov dword ptr [form_submitted], 1
    
    xor eax, eax
    jmp submit_done
    
submit_error:
    mov eax, -1
    
submit_done:
    pop rcx
    pop rbx
    ret
submit_form ENDP

; =============================================================================
; UTILITY
; =============================================================================

get_field_value PROC
    ; Get value of a form field
    ; Input: ECX = field index
    ; Output: RAX = pointer to value string
    
    push rbx
    
    mov eax, ecx
    imul eax, eax, FIELD_VALUE_LEN
    mov rbx, offset field_values
    add rax, rbx
    
    pop rbx
    ret
get_field_value ENDP

set_field_value PROC
    ; Set value of a form field
    ; Input: ECX = field index
    ;        RDX = pointer to value string
    ; Output: EAX = status
    
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    mov rax, rcx
    imul rax, rax, FIELD_VALUE_LEN
    mov rbx, offset field_values
    add rax, rbx
    
    mov rdi, rax
    mov rsi, rdx
    mov rcx, FIELD_VALUE_LEN
    rep movsb
    
    xor eax, eax
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
set_field_value ENDP

clear_form PROC
    ; Clear all form data
    ; Input: None
    ; Output: EAX = 0
    
    push rdi
    
    mov rdi, offset field_values
    mov rcx, MAX_FIELDS_PER_FORM * FIELD_VALUE_LEN
    xor al, al
    rep stosb
    
    mov dword ptr [current_field_index], 0
    mov dword ptr [form_submitted], 0
    mov dword ptr [error_count], 0
    
    xor eax, eax
    pop rdi
    ret
clear_form ENDP

; =============================================================================
; FORM VALIDATION
; =============================================================================

validate_form PROC
    ; Validate all fields in current form
    ; Output: EAX = 0 if valid, error count otherwise
    
    push rbx
    push rcx
    push rdi
    push rsi
    
    xor ecx, ecx                    ; Error counter
    xor ebx, ebx                    ; Field index
    
validate_loop:
    cmp ebx, dword ptr [field_count]
    jge validate_done
    
    ; Check if field is required
    mov rsi, offset field_definitions
    mov rax, rbx
    imul rax, FIELD_ENTRY_SIZE
    add rsi, rax
    
    mov al, byte ptr [rsi]          ; Flags
    test al, VALIDATE_REQUIRED
    jz validate_optional
    
    ; Check if field has value
    mov rdi, offset field_values
    mov rax, rbx
    imul rax, FIELD_VALUE_LEN
    add rdi, rax
    
    cmp byte ptr [rdi], 0
    je validate_error_found
    
validate_optional:
    inc ebx
    jmp validate_loop
    
validate_error_found:
    inc ecx
    inc ebx
    jmp validate_loop
    
validate_done:
    mov eax, ecx
    mov dword ptr [error_count], ecx
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret
validate_form ENDP

validate_field PROC
    ; Validate a specific field
    ; Input: ECX = field index
    ; Output: EAX = 0 if valid, error code otherwise
    
    push rbx
    push rcx
    push rdi
    
    ; Get field definition
    mov rdi, offset field_definitions
    mov rax, rcx
    imul rax, FIELD_ENTRY_SIZE
    add rdi, rax
    
    ; Get field value
    mov rbx, offset field_values
    mov rax, rcx
    imul rax, FIELD_VALUE_LEN
    add rbx, rax
    
    ; Get validation flags
    mov al, byte ptr [rdi]
    
    ; Check email format if required
    test al, VALIDATE_EMAIL
    jz skip_email_check
    
    mov rdi, rbx
    call validate_email
    cmp eax, 0
    jne email_invalid
    
skip_email_check:
    ; Check numeric if required
    test al, VALIDATE_NUMERIC
    jz skip_numeric_check
    
    mov rdi, rbx
    call validate_numeric
    cmp eax, 0
    jne numeric_invalid
    
skip_numeric_check:
    xor eax, eax
    jmp validate_field_done
    
email_invalid:
    mov eax, 2
    jmp validate_field_done
    
numeric_invalid:
    mov eax, 3
    
validate_field_done:
    pop rdi
    pop rcx
    pop rbx
    ret
validate_field ENDP

validate_email PROC
    ; Simple email validation
    ; Input: RDI = email string
    ; Output: EAX = 0 if valid
    
    push rcx
    push rdi
    
    ; Check for @ symbol
    xor ecx, ecx
    
find_at_loop:
    mov al, byte ptr [rdi + rcx]
    test al, al
    jz no_at_found
    
    cmp al, '@'
    je at_found
    
    inc ecx
    cmp ecx, 256
    jl find_at_loop
    
no_at_found:
    mov eax, -1
    jmp validate_email_done
    
at_found:
    ; Check for dot after @
    inc ecx
    xor ecx, ecx
    
find_dot_loop:
    mov al, byte ptr [rdi + rcx]
    test al, al
    jz no_dot_found
    
    cmp al, '.'
    je dot_found
    
    inc ecx
    jmp find_dot_loop
    
no_dot_found:
    mov eax, -1
    jmp validate_email_done
    
dot_found:
    xor eax, eax
    
validate_email_done:
    pop rdi
    pop rcx
    ret
validate_email ENDP

validate_numeric PROC
    ; Check if field contains only numeric data
    ; Input: RDI = value string
    ; Output: EAX = 0 if numeric
    
    xor ecx, ecx
    
numeric_check_loop:
    mov al, byte ptr [rdi + rcx]
    test al, al
    jz numeric_valid
    
    cmp al, '0'
    jl numeric_invalid_char
    cmp al, '9'
    jg numeric_invalid_char
    
    inc ecx
    jmp numeric_check_loop
    
numeric_valid:
    xor eax, eax
    ret
    
numeric_invalid_char:
    mov eax, -1
    ret
validate_numeric ENDP

submit_form PROC
    ; Submit form after validation
    ; Output: EAX = 0 if submitted, error code otherwise
    
    call validate_form
    cmp eax, 0
    jne submit_error
    
    mov dword ptr [form_submitted], 1
    mov dword ptr [form_validated], 1
    
    xor eax, eax
    ret
    
submit_error:
    mov eax, -1
    ret
submit_form ENDP

get_form_field_count PROC
    ; Get number of fields in current form
    ; Output: EAX = field count
    
    mov eax, dword ptr [field_count]
    ret
get_form_field_count ENDP

END
