; =============================================================================
; TABLE SYSTEM - Spreadsheet/Grid Display and Manipulation
; =============================================================================
; Purpose: 80x24 character grid, cell editing, sorting, searching
; Author: Altair 8800 OS Development Team
; Date: March 4, 2026
; Version: 1.0
; Lines: 850+
; =============================================================================

option casemap:none
EXTERN ExitProcess:PROC

; =============================================================================
; CONSTANTS
; =============================================================================

; Grid dimensions
GRID_ROWS               EQU 24
GRID_COLS               EQU 80
CELL_WIDTH              EQU 10
CELL_HEIGHT             EQU 1

; Cell data
CELL_DATA_SIZE          EQU 64
GRID_MAX_CELLS          EQU GRID_ROWS * GRID_COLS

; Keys
KEY_UP                  EQU 72
KEY_DOWN                EQU 80
KEY_LEFT                EQU 75
KEY_RIGHT               EQU 77
KEY_TAB                 EQU 9
KEY_ENTER               EQU 13
KEY_ESCAPE              EQU 27

; =============================================================================
; DATA SECTION
; =============================================================================

.data

moduleName              db "table_system", 0
version_str             db "1.0", 0

; Grid storage
grid_data               db GRID_MAX_CELLS * CELL_DATA_SIZE dup(0)
grid_rows               dd GRID_ROWS
grid_cols               dd GRID_COLS

; Display state
current_row             dd 0
current_col             dd 0
selected_row            dd 0
selected_col            dd 0
edit_mode               dd 0

; Cell buffers
cell_buffer             db 64 dup(0)
input_buffer            db 256 dup(0)
search_buffer           db 64 dup(0)

; Status/Title
grid_title              db "SPREADSHEET VIEW", 0
status_message          db "Use arrows to navigate, Tab/Shift+Tab to move, ENTER to edit", 0

; Column headers
column_headers          db "A         B         C         D         E         F         G         H         ", 0

; Sort state
sort_column             dd 0
sort_ascending          dd 1

; Display buffer (80x24)
display_buffer          db 1920 dup(0)

; =============================================================================
; CODE SECTION
; =============================================================================

.code

; =============================================================================
; INITIALIZATION
; =============================================================================

create_spreadsheet PROC
    ; Create a new spreadsheet
    ; Input: ECX = rows
    ;        EDX = columns
    ; Output: EAX = spreadsheet_id
    
    push rbx
    push rcx
    push rdx
    push rdi
    
    ; Store grid dimensions
    mov dword ptr [grid_rows], ecx
    mov dword ptr [grid_cols], edx
    
    ; Initialize grid data
    mov rdi, offset grid_data
    mov rcx, GRID_MAX_CELLS * CELL_DATA_SIZE
    xor al, al
    rep stosb
    
    ; Initialize cursor position
    mov dword ptr [current_row], 0
    mov dword ptr [current_col], 0
    mov dword ptr [selected_row], 0
    mov dword ptr [selected_col], 0
    mov dword ptr [edit_mode], 0
    
    mov eax, 1                      ; Spreadsheet ID = 1
    
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret
create_spreadsheet ENDP

; =============================================================================
; CELL OPERATIONS
; =============================================================================

set_cell PROC
    ; Set cell data
    ; Input: ECX = row
    ;        EDX = column
    ;        R8 = pointer to data
    ;        R9 = data size
    ; Output: EAX = status (0 = success)
    
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Validate bounds
    cmp ecx, dword ptr [grid_rows]
    jge set_cell_error
    cmp edx, dword ptr [grid_cols]
    jge set_cell_error
    
    ; Calculate cell position
    mov rax, rcx
    imul rax, rax, dword ptr [grid_cols]
    add rax, rdx
    imul rax, rax, CELL_DATA_SIZE
    mov rbx, offset grid_data
    add rbx, rax
    
    ; Copy data to cell
    mov rdi, rbx
    mov rsi, r8
    mov rcx, r9
    cmp rcx, CELL_DATA_SIZE
    jle copy_cell_size_ok
    mov rcx, CELL_DATA_SIZE
    
copy_cell_size_ok:
    rep movsb
    
    xor eax, eax
    jmp set_cell_done
    
set_cell_error:
    mov eax, -1
    
set_cell_done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
set_cell ENDP

get_cell PROC
    ; Get cell data
    ; Input: ECX = row
    ;        EDX = column
    ; Output: RAX = pointer to cell data
    
    push rbx
    push rcx
    push rdx
    
    ; Validate bounds
    cmp ecx, dword ptr [grid_rows]
    jge get_cell_error
    cmp edx, dword ptr [grid_cols]
    jge get_cell_error
    
    ; Calculate cell position
    mov rax, rcx
    imul rax, rax, dword ptr [grid_cols]
    add rax, rdx
    imul rax, rax, CELL_DATA_SIZE
    mov rbx, offset grid_data
    add rax, rbx
    
    jmp get_cell_done
    
get_cell_error:
    xor rax, rax
    
get_cell_done:
    pop rdx
    pop rcx
    pop rbx
    ret
get_cell ENDP

clear_cell PROC
    ; Clear a cell
    ; Input: ECX = row
    ;        EDX = column
    ; Output: EAX = status
    
    push rdi
    push rcx
    push rdx
    
    ; Get cell pointer
    call get_cell
    test rax, rax
    jz clear_cell_error
    
    ; Clear the data
    mov rdi, rax
    mov rcx, CELL_DATA_SIZE
    xor al, al
    rep stosb
    
    xor eax, eax
    jmp clear_cell_done
    
clear_cell_error:
    mov eax, -1
    
clear_cell_done:
    pop rdx
    pop rcx
    pop rdi
    ret
clear_cell ENDP

; =============================================================================
; DISPLAY & RENDERING
; =============================================================================

display_grid PROC
    ; Render the grid to display buffer
    ; Input: None
    ; Output: EAX = 0
    
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Initialize display buffer
    mov rdi, offset display_buffer
    mov rcx, 1920
    xor al, al
    rep stosb
    
    ; Display title
    mov rsi, offset grid_title
    mov rdi, offset display_buffer
    mov rcx, 16
    rep movsb
    
    ; Display column headers
    mov rsi, offset column_headers
    mov rdi, offset display_buffer
    add rdi, 80                     ; Next line
    mov rcx, 80
    rep movsb
    
    ; Display grid cells
    xor ecx, ecx                    ; Row counter
    
display_row_loop:
    cmp ecx, dword ptr [grid_rows]
    jge display_done
    
    xor edx, edx                    ; Column counter
    
display_col_loop:
    cmp edx, dword ptr [grid_cols]
    jge display_next_row
    
    ; Get cell data
    call get_cell
    test rax, rax
    jz display_skip_cell
    
    ; Display cell content (simplified)
    mov rsi, rax
    mov rdi, offset cell_buffer
    mov r8, 10
    rep movsb
    
display_skip_cell:
    inc edx
    jmp display_col_loop
    
display_next_row:
    inc ecx
    jmp display_row_loop
    
display_done:
    xor eax, eax
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
display_grid ENDP

display_status_bar PROC
    ; Display status bar at bottom
    ; Input: None
    ; Output: EAX = 0
    
    push rbx
    push rsi
    push rdi
    
    ; Position status bar at end of display buffer
    mov rdi, offset display_buffer
    add rdi, 1840                   ; 80 * 23
    
    mov rsi, offset status_message
    mov rcx, 80
    
status_copy_loop:
    cmp rcx, 0
    je status_done
    
    mov al, byte ptr [rsi]
    test al, al
    jz status_done
    
    mov byte ptr [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jmp status_copy_loop
    
status_done:
    xor eax, eax
    
    pop rdi
    pop rsi
    pop rbx
    ret
display_status_bar ENDP

highlight_cell PROC
    ; Highlight selected cell
    ; Input: ECX = row
    ;        EDX = column
    ; Output: EAX = 0
    
    push rbx
    push rcx
    push rdx
    
    ; Mark cell as selected
    mov dword ptr [selected_row], ecx
    mov dword ptr [selected_col], edx
    
    ; Will be drawn differently on next render
    xor eax, eax
    
    pop rdx
    pop rcx
    pop rbx
    ret
highlight_cell ENDP

; =============================================================================
; NAVIGATION
; =============================================================================

move_up PROC
    ; Move cursor up
    ; Input: None
    ; Output: EAX = status
    
    mov ecx, dword ptr [current_row]
    cmp ecx, 0
    jle move_boundary
    
    dec ecx
    mov dword ptr [current_row], ecx
    
    xor eax, eax
    ret
    
move_boundary:
    mov eax, -1
    ret
move_up ENDP

move_down PROC
    ; Move cursor down
    ; Input: None
    ; Output: EAX = status
    
    mov ecx, dword ptr [current_row]
    inc ecx
    cmp ecx, dword ptr [grid_rows]
    jge move_boundary_d
    
    mov dword ptr [current_row], ecx
    xor eax, eax
    ret
    
move_boundary_d:
    mov eax, -1
    ret
move_down ENDP

move_left PROC
    ; Move cursor left
    ; Input: None
    ; Output: EAX = status
    
    mov edx, dword ptr [current_col]
    cmp edx, 0
    jle move_boundary_l
    
    dec edx
    mov dword ptr [current_col], edx
    
    xor eax, eax
    ret
    
move_boundary_l:
    mov eax, -1
    ret
move_left ENDP

move_right PROC
    ; Move cursor right
    ; Input: None
    ; Output: EAX = status
    
    mov edx, dword ptr [current_col]
    inc edx
    cmp edx, dword ptr [grid_cols]
    jge move_boundary_r
    
    mov dword ptr [current_col], edx
    xor eax, eax
    ret
    
move_boundary_r:
    mov eax, -1
    ret
move_right ENDP

; =============================================================================
; SORTING
; =============================================================================

sort_by_column PROC
    ; Sort grid by column
    ; Input: ECX = column number
    ;        EDX = ascending (1) or descending (0)
    ; Output: EAX = status
    
    push rbx
    push rcx
    push rdx
    
    ; Validate column
    cmp ecx, dword ptr [grid_cols]
    jge sort_error
    
    ; Store sort parameters
    mov dword ptr [sort_column], ecx
    mov dword ptr [sort_ascending], edx
    
    ; For now, mark as sorted (full implementation would do bubble/quicksort)
    xor eax, eax
    jmp sort_done
    
sort_error:
    mov eax, -1
    
sort_done:
    pop rdx
    pop rcx
    pop rbx
    ret
sort_by_column ENDP

; =============================================================================
; SEARCH
; =============================================================================

search_cells PROC
    ; Search for text in cells
    ; Input: RCX = search string
    ; Output: EAX = found (1) or not found (0)
    ;         RDX = row, R8D = column
    
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    mov rsi, rcx                    ; Search string
    xor ecx, ecx                    ; Current row
    
search_row_loop:
    cmp ecx, dword ptr [grid_rows]
    jge search_not_found
    
    xor edx, edx                    ; Current column
    
search_col_loop:
    cmp edx, dword ptr [grid_cols]
    jge search_next_row
    
    ; Get cell
    call get_cell
    test rax, rax
    jz search_skip
    
    ; Compare with search string
    mov rdi, rax
    mov rsi, rcx
    xor rbx, rbx
    
compare_loop:
    mov al, byte ptr [rdi + rbx]
    mov bl, byte ptr [rsi + rbx]
    cmp al, bl
    jne search_skip
    test al, al
    jz search_found
    inc rbx
    jmp compare_loop
    
search_found:
    mov eax, 1
    mov edx, ecx                    ; Return row
    mov r8d, edx                    ; Return col
    jmp search_done
    
search_skip:
    inc edx
    jmp search_col_loop
    
search_next_row:
    inc ecx
    jmp search_row_loop
    
search_not_found:
    xor eax, eax
    
search_done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
search_cells ENDP

; =============================================================================
; EDITING
; =============================================================================

enter_edit_mode PROC
    ; Enter cell edit mode
    ; Input: None
    ; Output: EAX = 0
    
    mov dword ptr [edit_mode], 1
    
    ; Get current cell
    mov ecx, dword ptr [current_row]
    mov edx, dword ptr [current_col]
    call get_cell
    
    ; Copy to input buffer
    mov rsi, rax
    mov rdi, offset input_buffer
    mov rcx, 256
    rep movsb
    
    xor eax, eax
    ret
enter_edit_mode ENDP

exit_edit_mode PROC
    ; Exit cell edit mode and save
    ; Input: None
    ; Output: EAX = 0
    
    ; Save input to current cell
    mov ecx, dword ptr [current_row]
    mov edx, dword ptr [current_col]
    mov r8, offset input_buffer
    mov r9, 256
    call set_cell
    
    mov dword ptr [edit_mode], 0
    
    xor eax, eax
    ret
exit_edit_mode ENDP

append_to_input PROC
    ; Append character to input buffer
    ; Input: AL = character
    ; Output: EAX = input length
    
    push rbx
    push rdi
    
    mov rdi, offset input_buffer
    xor ecx, ecx
    
find_end:
    cmp byte ptr [rdi + rcx], 0
    je input_at_end
    inc rcx
    cmp rcx, 256
    jl find_end
    jmp input_full
    
input_at_end:
    mov byte ptr [rdi + rcx], al
    inc rcx
    mov byte ptr [rdi + rcx], 0
    mov eax, ecx
    jmp append_done
    
input_full:
    mov eax, -1
    
append_done:
    pop rdi
    pop rbx
    ret
append_to_input ENDP

; =============================================================================
; UTILITY
; =============================================================================

get_current_position PROC
    ; Get current cursor position
    ; Output: ECX = row, EDX = column
    
    mov ecx, dword ptr [current_row]
    mov edx, dword ptr [current_col]
    ret
get_current_position ENDP

set_current_position PROC
    ; Set current cursor position
    ; Input: ECX = row, EDX = column
    ; Output: EAX = status
    
    cmp ecx, dword ptr [grid_rows]
    jge pos_error
    cmp edx, dword ptr [grid_cols]
    jge pos_error
    
    mov dword ptr [current_row], ecx
    mov dword ptr [current_col], edx
    
    xor eax, eax
    ret
    
pos_error:
    mov eax, -1
    ret
set_current_position ENDP

clear_grid PROC
    ; Clear all grid data
    ; Input: None
    ; Output: EAX = 0
    
    push rdi
    
    mov rdi, offset grid_data
    mov rcx, GRID_MAX_CELLS * CELL_DATA_SIZE
    xor al, al
    rep stosb
    
    mov dword ptr [current_row], 0
    mov dword ptr [current_col], 0
    
    xor eax, eax
    pop rdi
    ret
clear_grid ENDP

; =============================================================================
; CELL OPERATIONS
; =============================================================================

get_cell PROC
    ; Get cell value at position
    ; Input: ECX = row, EDX = col
    ; Output: RAX = cell data pointer
    
    push rbx
    push rcx
    push rdx
    
    ; Validate position
    cmp ecx, GRID_ROWS
    jge cell_get_error
    cmp edx, GRID_COLS
    jge cell_get_error
    
    ; Calculate offset
    mov rax, rcx
    imul rax, GRID_COLS
    add rax, rdx
    imul rax, CELL_DATA_SIZE
    
    mov rbx, offset grid_data
    add rax, rbx
    
    pop rdx
    pop rcx
    pop rbx
    ret
    
cell_get_error:
    xor rax, rax
    pop rdx
    pop rcx
    pop rbx
    ret
get_cell ENDP

set_cell PROC
    ; Set cell value at position
    ; Input: ECX = row, EDX = col, RSI = data, R8 = size
    ; Output: EAX = status
    
    push rbx
    push rcx
    push rdi
    push rsi
    
    ; Validate position
    cmp ecx, GRID_ROWS
    jge cell_set_error
    cmp edx, GRID_COLS
    jge cell_set_error
    
    ; Calculate offset
    mov rax, rcx
    imul rax, GRID_COLS
    add rax, rdx
    imul rax, CELL_DATA_SIZE
    
    mov rdi, offset grid_data
    add rdi, rax
    
    ; Copy data to cell
    mov rcx, r8
    cmp rcx, CELL_DATA_SIZE
    jle copy_all
    mov rcx, CELL_DATA_SIZE
    
copy_all:
    rep movsb
    
    xor eax, eax
    jmp cell_set_done
    
cell_set_error:
    mov eax, -1
    
cell_set_done:
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret
set_cell ENDP

; =============================================================================
; SORTING & SEARCHING
; =============================================================================

sort_rows PROC
    ; Sort grid rows by column
    ; Input: ECX = sort column, EDX = sort direction (0=asc, 1=desc)
    ; Output: EAX = 0
    
    push rbx
    push rcx
    push rdx
    
    ; Validate sort column and persist sort state.
    cmp ecx, dword ptr [grid_cols]
    jge sort_rows_done
    mov dword ptr [sort_column], ecx
    mov dword ptr [sort_ascending], 1
    test edx, edx
    jz sort_dir_set
    mov dword ptr [sort_ascending], 0

sort_dir_set:
    ; Perform one adjacent-pass over key column cells.
    xor ebx, ebx

sort_pass_loop:
    mov eax, dword ptr [grid_rows]
    dec eax
    cmp ebx, eax
    jge sort_rows_done

    ; cell(row=ebx, col=sort_column)
    mov eax, ebx
    imul eax, dword ptr [grid_cols]
    add eax, dword ptr [sort_column]
    imul eax, CELL_DATA_SIZE
    mov r10, offset grid_data
    add r10, rax

    ; cell(row=ebx+1, col=sort_column)
    mov eax, ebx
    inc eax
    imul eax, dword ptr [grid_cols]
    add eax, dword ptr [sort_column]
    imul eax, CELL_DATA_SIZE
    mov r11, offset grid_data
    add r11, rax

    movzx r8d, byte ptr [r10]
    movzx r9d, byte ptr [r11]

    cmp dword ptr [sort_ascending], 0
    je sort_desc_cmp

    ; Ascending: swap when current > next
    cmp r8d, r9d
    jle sort_next_pair
    jmp sort_swap

sort_desc_cmp:
    ; Descending: swap when current < next
    cmp r8d, r9d
    jge sort_next_pair

sort_swap:
    ; Swap fixed-size key cell payloads (64 bytes).
    mov ecx, CELL_DATA_SIZE
sort_swap_loop:
    mov al, byte ptr [r10]
    mov dl, byte ptr [r11]
    mov byte ptr [r10], dl
    mov byte ptr [r11], al
    inc r10
    inc r11
    dec ecx
    jnz sort_swap_loop

sort_next_pair:
    inc ebx
    jmp sort_pass_loop

sort_rows_done:
    xor eax, eax
    
    pop rdx
    pop rcx
    pop rbx
    ret
sort_rows ENDP

search_grid PROC
    ; Search for value in grid
    ; Input: RCX = search string
    ;        RDX = search column (-1 for all)
    ; Output: EAX = row found (-1 if not found)
    
    push rbx
    push rcx
    push rdi
    push rsi
    
    ; Empty search token -> not found.
    mov al, byte ptr [rcx]
    test al, al
    jz search_not_found

    xor ebx, ebx                    ; Row counter
    
search_row_loop:
    cmp ebx, GRID_ROWS
    jge search_not_found
    
    ; Search this row
    test edx, edx
    js search_all_cols              ; If col = -1, search all
    
    ; Search specific column
    mov r8d, edx
    cmp r8d, GRID_COLS
    jge search_next_row
    
    mov eax, ebx
    imul eax, dword ptr [grid_cols]
    add eax, r8d
    imul eax, CELL_DATA_SIZE
    mov rsi, offset grid_data
    add rsi, rax

    mov al, byte ptr [rcx]
    cmp al, byte ptr [rsi]
    je search_found
    jmp search_next_row
    
search_all_cols:
    xor r8d, r8d

search_all_cols_loop:
    cmp r8d, dword ptr [grid_cols]
    jge search_next_row

    mov eax, ebx
    imul eax, dword ptr [grid_cols]
    add eax, r8d
    imul eax, CELL_DATA_SIZE
    mov rsi, offset grid_data
    add rsi, rax

    mov al, byte ptr [rcx]
    cmp al, byte ptr [rsi]
    je search_found

    inc r8d
    jmp search_all_cols_loop

search_found:
    mov eax, ebx
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret
    
search_next_row:
    inc ebx
    jmp search_row_loop
    
search_not_found:
    mov eax, -1
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret
search_grid ENDP

; =============================================================================
; DISPLAY & FORMATTING
; =============================================================================

format_cell PROC
    ; Format cell for display
    ; Input: RCX = cell data, RDX = format type
    ; Output: RAX = formatted string
    
    push rbx
    push rcx
    
    ; Format type 0 = text, 1 = number, 2 = date
    mov eax, edx
    
    pop rcx
    pop rbx
    ret
format_cell ENDP

display_grid PROC
    ; Display grid on console
    ; Output: Grid printed
    
    push rbx
    push rcx
    push rdx
    
    xor ecx, ecx                    ; Row counter
    
display_row_loop:
    cmp ecx, GRID_ROWS
    jge display_grid_done
    
    xor edx, edx                    ; Col counter
    
display_col_loop:
    cmp edx, GRID_COLS
    jge display_next_row
    
    ; Would display cell at [ecx, edx]
    
    inc edx
    jmp display_col_loop
    
display_next_row:
    inc ecx
    jmp display_row_loop
    
display_grid_done:
    pop rdx
    pop rcx
    pop rbx
    ret
display_grid ENDP

; =============================================================================
; NAVIGATION
; =============================================================================

handle_arrow_keys PROC
    ; Handle arrow key navigation
    ; Input: AL = arrow key code
    ; Output: EAX = new position
    
    cmp al, KEY_UP
    je move_up
    cmp al, KEY_DOWN
    je move_down
    cmp al, KEY_LEFT
    je move_left
    cmp al, KEY_RIGHT
    je move_right
    
    xor eax, eax
    ret
    
move_up:
    mov ecx, dword ptr [current_row]
    test ecx, ecx
    jz at_top
    dec ecx
    mov dword ptr [current_row], ecx
    jmp nav_done
    
at_top:
    xor eax, eax
    ret
    
move_down:
    mov ecx, dword ptr [current_row]
    cmp ecx, GRID_ROWS
    jge at_bottom
    inc ecx
    mov dword ptr [current_row], ecx
    jmp nav_done
    
at_bottom:
    xor eax, eax
    ret
    
move_left:
    mov edx, dword ptr [current_col]
    test edx, edx
    jz at_left
    dec edx
    mov dword ptr [current_col], edx
    jmp nav_done
    
at_left:
    xor eax, eax
    ret
    
move_right:
    mov edx, dword ptr [current_col]
    cmp edx, GRID_COLS
    jge at_right
    inc edx
    mov dword ptr [current_col], edx
    jmp nav_done
    
at_right:
    xor eax, eax
    ret
    
nav_done:
    mov eax, dword ptr [current_row]
    mov edx, dword ptr [current_col]
    shl eax, 16
    or eax, edx
    ret
handle_arrow_keys ENDP

get_grid_size PROC
    ; Get grid dimensions
    ; Output: EAX = rows, EDX = cols
    
    mov eax, GRID_ROWS
    mov edx, GRID_COLS
    ret
get_grid_size ENDP

END
