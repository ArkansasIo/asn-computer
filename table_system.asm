; ============================================================================
; ALTAIR 8800 TABLE SYSTEM (SPREADSHEET/GRID)
; Front-end Table Display and Manipulation
; ============================================================================

.code

extern GetStdHandle:proc
extern WriteConsoleA:proc
extern ReadConsoleA:proc
extern SetConsoleCursorPosition:proc

; ============================================================================
; TABLE SYSTEM CONSTANTS
; ============================================================================

.data

; Grid display constants
GRID_MAX_WIDTH          equ 80          ; Max columns in display
GRID_MAX_HEIGHT         equ 24          ; Max rows in display
GRID_CELL_WIDTH         equ 10          ; Width of each cell
GRID_CELL_HEIGHT        equ 1           ; Height of each cell

; Cell types
CELL_TYPE_TEXT          equ 0x01
CELL_TYPE_NUMBER        equ 0x02
CELL_TYPE_FORMULA       equ 0x03
CELL_TYPE_EMPTY         equ 0x00

; ============================================================================
; SPREADSHEET STRUCTURE (16 bytes per cell)
; ============================================================================
; 0x00: Data (8 bytes)
; 0x08: Type (1 byte)
; 0x09: Format (1 byte)
; 0x0A: Flags (1 byte)
; 0x0B: Reserved (5 bytes)

spreadsheet_data:       db 20480 dup(0) ; 80×256 cells × 16 bytes
cell_count:             dd 0
first_pass:             db 1

; Grid state
current_grid_row:       dd 0
current_grid_col:       dd 0
grid_top_row:           dd 0
grid_left_col:          dd 0
selected_cell_row:      dd 0
selected_cell_col:      dd 0

; Cell editing
edit_mode:              db 0
edit_buffer:            db 64 dup(0)
formula_buffer:         db 256 dup(0)

; ============================================================================
; CREATE SPREADSHEET
; ============================================================================

create_spreadsheet:
    ; Input: RCX = rows, RDX = columns
    ; Output: none
    
    push rbp
    mov rbp, rsp
    
    ; Store dimensions
    mov [current_grid_row], rcx
    mov [current_grid_col], rdx
    mov [grid_top_row], dword 0
    mov [grid_left_col], dword 0
    mov [selected_cell_row], dword 0
    mov [selected_cell_col], dword 0
    
    ; Initialize spreadsheet
    mov rax, 0
    mov rcx, rdx
    imul rcx, rax                       ; Total cells
    imul rcx, 16                        ; Bytes per cell
    
    xor r8, r8
    
init_cells:
    cmp r8, rcx
    jge spreadsheet_ready
    
    mov byte ptr [spreadsheet_data + r8], CELL_TYPE_EMPTY
    add r8, 16
    jmp init_cells
    
spreadsheet_ready:
    pop rbp
    ret

; ============================================================================
; SET CELL VALUE
; ============================================================================

set_cell:
    ; Input: RCX = row, RDX = column
    ;        R8  = data pointer, R9D = size
    ; Output: AL = 1 (success), 0 (failure)
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Calculate cell offset
    mov rax, rcx
    mov r10, [current_grid_col]
    imul rax, r10
    add rax, rdx
    imul rax, 16                        ; 16 bytes per cell
    
    ; Check bounds
    cmp rax, 20480
    jge cell_set_fail
    
    ; Store data type
    mov byte ptr [spreadsheet_data + rax], CELL_TYPE_TEXT
    
    ; Copy data
    mov r10, 0
    
copy_cell_data:
    cmp r10d, r9d
    jge cell_set_success
    cmp r10d, 8
    jge cell_set_success
    
    mov bl, [r8 + r10]
    mov [spreadsheet_data + rax + 1 + r10], bl
    inc r10
    jmp copy_cell_data
    
cell_set_success:
    mov al, 1
    jmp cell_set_done
    
cell_set_fail:
    mov al, 0
    
cell_set_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; GET CELL VALUE
; ============================================================================

get_cell:
    ; Input: RCX = row, RDX = column
    ; Output: RAX = data pointer (in spreadsheet), EBX = type
    
    push rbp
    mov rbp, rsp
    
    ; Calculate offset
    mov rax, rcx
    mov r8, [current_grid_col]
    imul rax, r8
    add rax, rdx
    imul rax, 16
    
    ; Get type
    mov ebx, eax
    mov bl, [spreadsheet_data + rax]
    
    ; Return data address
    lea rax, [spreadsheet_data + rax + 1]
    
    pop rbp
    ret

; ============================================================================
; DISPLAY GRID
; ============================================================================

display_grid:
    ; Draw the spreadsheet grid on screen
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Clear screen
    call clear_screen
    
    ; Draw column headers
    call draw_column_headers
    
    ; Draw rows
    mov rcx, 0
    
draw_grid_rows:
    cmp rcx, GRID_MAX_HEIGHT
    jge grid_display_done
    
    ; Draw row number
    call draw_row_number
    
    ; Draw cells in row
    mov rdx, 0
    
draw_grid_cells:
    cmp rdx, GRID_MAX_WIDTH
    jge grid_next_row
    
    ; Draw cell
    mov r8, rcx
    add r8, [grid_top_row]
    mov r9, rdx
    add r9, [grid_left_col]
    
    call draw_cell
    
    inc rdx
    jmp draw_grid_cells
    
grid_next_row:
    inc rcx
    jmp draw_grid_rows
    
grid_display_done:
    ; Display status bar
    call display_status_bar
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; DRAW COLUMN HEADERS
; ============================================================================

draw_column_headers:
    push rbp
    mov rbp, rsp
    
    ; Move to top-left
    mov rcx, 0
    mov rdx, 0
    call set_cursor_position
    
    ; Print "   |"
    mov rcx, offset header_start
    call print_string
    
    ; Print column letters A, B, C...
    mov r8, 0
    
print_col_header:
    cmp r8, GRID_MAX_WIDTH
    jge headers_done
    
    mov al, 'A'
    add al, r8b
    call print_char
    
    mov rcx, GRID_CELL_WIDTH - 1
    
pad_header:
    cmp rcx, 0
    je next_header
    mov al, ' '
    call print_char
    dec rcx
    jmp pad_header
    
next_header:
    inc r8
    jmp print_col_header
    
headers_done:
    pop rbp
    ret

; ============================================================================
; DRAW CELL
; ============================================================================

draw_cell:
    ; Input: R8 = row, R9 = column (absolute)
    ;        RCX = display row, RDX = display column
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Set cursor
    mov rcx, rdx
    imul rcx, GRID_CELL_WIDTH
    add rcx, 4                          ; Offset for row numbers
    mov rdx, rcx
    mov rcx, 0
    add rcx, 1
    call set_cursor_position
    
    ; Get cell data
    mov rcx, r8
    mov rdx, r9
    call get_cell
    
    ; Check if selected
    cmp r8, [selected_cell_row]
    jne cell_normal_display
    cmp r9, [selected_cell_col]
    jne cell_normal_display
    
    ; Highlight selected cell
    mov rcx, offset cell_highlight
    call print_string
    
cell_normal_display:
    ; Display cell content (first 10 chars)
    mov r10, 0
    
display_cell_content:
    cmp r10, GRID_CELL_WIDTH
    jge cell_display_done
    
    mov al, [rax + r10]
    cmp al, 0
    je pad_cell_remaining
    
    call print_char
    inc r10
    jmp display_cell_content
    
pad_cell_remaining:
    cmp r10, GRID_CELL_WIDTH
    jge cell_display_done
    
    mov al, ' '
    call print_char
    inc r10
    jmp pad_cell_remaining
    
cell_display_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; DRAW ROW NUMBERS
; ============================================================================

draw_row_number:
    ; Input: RCX = display row
    
    push rbp
    mov rbp, rsp
    
    ; Set cursor to row number column
    mov rdx, 0
    call set_cursor_position
    
    ; Get absolute row number
    mov rax, rcx
    add rax, [grid_top_row]
    inc rax                             ; 1-based row numbers
    
    ; Print row number (right-aligned in 3 chars)
    cmp eax, 9
    jg row_num_two_digit
    
    mov rcx, offset row_num_pad
    call print_string
    
    mov al, 0x30
    add al, al
    call print_char
    jmp row_num_done
    
row_num_two_digit:
    mov al, (eax / 10) + 0x30
    call print_char
    mov al, (eax % 10) + 0x30
    call print_char
    
row_num_done:
    mov al, ' '
    call print_char
    mov al, '|'
    call print_char
    
    pop rbp
    ret

; ============================================================================
; HANDLE KEYBOARD INPUT (GRID NAVIGATION)
; ============================================================================

handle_grid_input:
    ; Read keyboard and handle navigation/editing
    ; Output: AL = 0 (continue), 1 (exit), 2 (save)
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    call read_char
    
    ; Handle keys
    cmp al, 27                          ; ESC
    je grid_input_exit
    
    cmp al, 13                          ; ENTER
    je grid_cell_edit
    
    cmp al, 0x09                        ; TAB
    je grid_next_column
    
    cmp al, 0x48                        ; UP arrow (if raw)
    je grid_move_up
    
    cmp al, 0x50                        ; DOWN arrow
    je grid_move_down
    
    xor al, al
    jmp grid_input_done
    
grid_cell_edit:
    ; Enter edit mode for selected cell
    call edit_cell
    jmp grid_input_redraw
    
grid_next_column:
    ; Move to next column
    inc dword ptr [selected_cell_col]
    cmp dword ptr [selected_cell_col], GRID_MAX_WIDTH
    jl grid_input_redraw
    
    mov dword ptr [selected_cell_col], 0
    ; Fall through to next row
    
grid_move_down:
    inc dword ptr [selected_cell_row]
    cmp dword ptr [selected_cell_row], GRID_MAX_HEIGHT
    jl grid_input_redraw
    
    mov dword ptr [selected_cell_row], 0
    jmp grid_input_redraw
    
grid_move_up:
    cmp dword ptr [selected_cell_row], 0
    je grid_input_redraw
    
    dec dword ptr [selected_cell_row]
    
grid_input_redraw:
    call display_grid
    xor al, al
    jmp grid_input_done
    
grid_input_exit:
    mov al, 1
    
grid_input_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; EDIT CELL
; ============================================================================

edit_cell:
    ; Enter edit mode for current selected cell
    
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    mov byte ptr [edit_mode], 1
    
    ; Get current value
    mov rcx, [selected_cell_row]
    mov rdx, [selected_cell_col]
    call get_cell
    
    ; Copy to edit buffer
    mov rsi, rax
    mov rdi, offset edit_buffer
    mov rcx, 64
    
copy_edit_buffer:
    cmp rcx, 0
    je edit_input_ready
    
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jmp copy_edit_buffer
    
edit_input_ready:
    ; Get new input
    mov rcx, offset edit_buffer
    mov rdx, 64
    call read_line
    
    ; Save new value
    mov rcx, [selected_cell_row]
    mov rdx, [selected_cell_col]
    mov r8, offset edit_buffer
    mov r9d, 64
    call set_cell
    
    mov byte ptr [edit_mode], 0
    
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; SORT/FILTER GRID
; ============================================================================

sort_by_column:
    ; Input: RCX = column number
    
    push rbp
    mov rbp, rsp
    
    ; Simple bubble sort on column
    mov r8, 0                           ; Outer loop
    
sort_outer:
    cmp r8, [current_grid_row]
    jge sort_complete
    
    mov r9, 0                           ; Inner loop
    
sort_inner:
    cmp r9d, dword ptr [current_grid_row]
    jge sort_outer_next
    
    ; Compare cells
    mov rax, r9
    imul rax, [current_grid_col]
    add rax, rcx
    imul rax, 16
    
    mov rbx, r9
    inc rbx
    imul rbx, [current_grid_col]
    add rbx, rcx
    imul rbx, 16
    
    ; Simple comparison (would need proper compare function)
    mov al, [spreadsheet_data + rax]
    mov bl, [spreadsheet_data + rbx]
    cmp al, bl
    jle sort_inner_next
    
    ; Swap rows
    call swap_rows
    
sort_inner_next:
    inc r9
    jmp sort_inner
    
sort_outer_next:
    inc r8
    jmp sort_outer
    
sort_complete:
    pop rbp
    ret

swap_rows:
    ; Swap row R9 with R9+1
    push rbp
    mov rbp, rsp
    pop rbp
    ret

; ============================================================================
; SEARCH CELLS
; ============================================================================

search_cells:
    ; Input: RCX = search string
    ; Output: RAX = found row, RDX = found column (-1 if not found)
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov r8, 0                           ; Row counter
    
search_rows:
    cmp r8, [current_grid_row]
    jge search_not_found
    
    mov r9, 0                           ; Column counter
    
search_cols:
    cmp r9, [current_grid_col]
    jge search_next_row
    
    ; Get cell
    mov rax, r8
    mov rdx, r9
    call get_cell
    
    ; Compare with search string
    mov rsi, rax
    mov rdi, rcx
    
compare_strings:
    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne search_next_col
    cmp al, 0
    je search_found
    inc rsi
    inc rdi
    jmp compare_strings
    
search_found:
    mov rax, r8
    mov rdx, r9
    jmp search_done
    
search_next_col:
    inc r9
    jmp search_cols
    
search_next_row:
    inc r8
    jmp search_rows
    
search_not_found:
    mov rax, -1
    mov rdx, -1
    
search_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; DISPLAY STATUS BAR
; ============================================================================

display_status_bar:
    push rbp
    mov rbp, rsp
    
    ; Move to last line
    mov rcx, 24
    mov rdx, 0
    call set_cursor_position
    
    ; Print status
    mov rcx, offset status_message
    call print_string
    
    pop rbp
    ret

; ============================================================================
; HELPER FUNCTIONS
; ============================================================================

clear_screen:
    push rbp
    mov rbp, rsp
    
    ; Print 25 blank lines
    mov rax, 0
    
clear_loop:
    cmp rax, 25
    jge clear_done
    
    mov rcx, 10
    mov rdx, '│'
    call print_char
    
    inc rax
    jmp clear_loop
    
clear_done:
    pop rbp
    ret

set_cursor_position:
    ; Input: RCX = X, RDX = Y
    push rbp
    mov rbp, rsp
    
    ; Would use SetConsoleCursorPosition
    
    pop rbp
    ret

print_string:
    ; Input: RCX = string pointer
    push rbp
    mov rbp, rsp
    
    mov rsi, rcx
    
print_loop:
    mov al, [rsi]
    cmp al, 0
    je print_done
    
    call print_char
    inc rsi
    jmp print_loop
    
print_done:
    pop rbp
    ret

print_char:
    ; Input: AL = character
    push rbp
    mov rbp, rsp
    
    ; Would use WriteConsole
    
    pop rbp
    ret

read_char:
    ; Output: AL = character
    push rbp
    mov rbp, rsp
    
    ; Would use ReadConsole
    
    pop rbp
    ret

read_line:
    ; Input: RCX = buffer, RDX = max length
    push rbp
    mov rbp, rsp
    
    ; Would use ReadConsole
    
    pop rbp
    ret

; ============================================================================
; DATA STRINGS
; ============================================================================

header_start:           db "   |", 0
row_num_pad:            db "  ", 0
cell_highlight:         db "[", 0
status_message:         db "R: ESC=Exit | ENTER=Edit | TAB=Next | Arrow=Move", 0

; ============================================================================
; END OF TABLE SYSTEM
; ============================================================================

end
