; ============================================================================
; ALTAIR 8800 GUI FRAMEWORK
; Windows, Widgets, Controls, and User Interface Components
; ============================================================================

.code

extern GetStdHandle:proc
extern WriteConsoleA:proc
extern ReadConsoleA:proc
extern SetConsoleCursorPosition:proc

; ============================================================================
; GUI CONSTANTS
; ============================================================================

.data

; Widget types
WIDGET_WINDOW               equ 0x01
WIDGET_BUTTON               equ 0x02
WIDGET_LABEL                equ 0x03
WIDGET_TEXTBOX              equ 0x04
WIDGET_CHECKBOX             equ 0x05
WIDGET_RADIOBUTTON          equ 0x06
WIDGET_LISTBOX              equ 0x07
WIDGET_COMBOBOX             equ 0x08
WIDGET_PROGRESSBAR          equ 0x09
WIDGET_SLIDER               equ 0x0A
WIDGET_MENUBAR              equ 0x0B
WIDGET_STATUSBAR            equ 0x0C
WIDGET_TAB                  equ 0x0D
WIDGET_PANEL                equ 0x0E

; Window states
WINDOW_ACTIVE               equ 0x01
WINDOW_MINIMIZED            equ 0x02
WINDOW_MAXIMIZED            equ 0x04
WINDOW_HIDDEN               equ 0x08

; Button states
BUTTON_NORMAL               equ 0x00
BUTTON_HOVER                equ 0x01
BUTTON_PRESSED              equ 0x02
BUTTON_FOCUSED              equ 0x04
BUTTON_DISABLED             equ 0x08

; Widget table (max 32 active widgets)
widget_count:               dd 0
widget_table:               db 32*64 dup(0)     ; 32 widgets, 64 bytes per widget

; Active window
active_window:              dd 0

; ============================================================================
; WINDOW STRUCTURE (64 bytes)
; ============================================================================
; 0x00: Type (1 byte)
; 0x01: State (1 byte)
; 0x02: X position (2 bytes)
; 0x04: Y position (2 bytes)
; 0x06: Width (2 bytes)
; 0x08: Height (2 bytes)
; 0x0A: Title pointer (8 bytes)
; 0x12: Content pointer (8 bytes)
; 0x1A: Parent window (4 bytes)
; 0x1E: Child count (1 byte)
; 0x1F: Background color (1 byte)
; 0x20: Border color (1 byte)
; 0x21: Text color (1 byte)
; 0x22: FLAGS (1 byte)
; ... (remaining bytes for additional properties)

; ============================================================================
; CREATE WINDOW
; ============================================================================
create_window:
    ; Input: RCX = title, RDX = width, R8 = height, R9 = x, Stack = y
    ; Output: RAX = window handle
    
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    ; Check if space available
    mov eax, [widget_count]
    cmp eax, 32
    jge create_window_fail
    
    ; Get window slot
    mov rbx, [widget_count]
    imul rax, rbx, 64
    lea rdi, [widget_table + rax]
    
    ; Initialize window structure
    mov byte ptr [rdi], WIDGET_WINDOW
    mov byte ptr [rdi+1], WINDOW_ACTIVE
    mov word ptr [rdi+2], r9w           ; X position
    mov eax, [rbp+16]
    mov word ptr [rdi+4], ax            ; Y position
    mov word ptr [rdi+6], dx            ; Width
    mov word ptr [rdi+8], r8w           ; Height
    mov qword ptr [rdi+10], rcx         ; Title
    mov byte ptr [rdi+30], 0xF0         ; Light gray background
    mov byte ptr [rdi+31], 0x0F         ; White border
    mov byte ptr [rdi+32], 0x0F         ; White text
    
    ; Increment widget count
    inc dword ptr [widget_count]
    mov eax, ebx
    
    jmp create_window_done
    
create_window_fail:
    mov eax, -1
    
create_window_done:
    add rsp, 48
    pop rbp
    ret

; ============================================================================
; DRAW WINDOW
; ============================================================================
draw_window:
    ; Input: RCX = window handle
    ; Output: None
    
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    ; Get window structure
    imul rax, rcx, 64
    lea rsi, [widget_table + rax]
    
    ; Get console handle
    mov rax, -11
    call GetStdHandle
    mov r11, rax
    
    ; Draw top border
    movzx r8d, word ptr [rsi+2]         ; X pos
    movzx r9d, word ptr [rsi+4]         ; Y pos
    movzx r10d, word ptr [rsi+6]        ; Width
    
    ; Set cursor position
    mov rcx, r11
    mov rdx, r8
    mov r8, r9
    call set_console_cursor
    
    ; Draw border chars (simplified - would use proper box characters)
    mov rcx, r11
    lea rdx, [border_top]
    mov r8, r10
    call draw_horizontal_line
    
    ; Store window as active
    mov [active_window], rcx
    
    add rsp, 48
    pop rbp
    ret

; ============================================================================
; CREATE BUTTON
; ============================================================================
create_button:
    ; Input: RCX = parent, RDX = x, R8 = y, R9 = text, Stack = width
    
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    ; Check widget space
    mov eax, [widget_count]
    cmp eax, 32
    jge create_button_fail
    
    ; Get button slot
    mov rbx, [widget_count]
    imul rax, rbx, 64
    lea rdi, [widget_table + rax]
    
    ; Initialize button
    mov byte ptr [rdi], WIDGET_BUTTON
    mov byte ptr [rdi+1], BUTTON_NORMAL
    mov word ptr [rdi+2], dx            ; X pos
    mov word ptr [rdi+4], r8w           ; Y pos
    mov eax, [rbp+16]
    mov word ptr [rdi+6], ax            ; Width
    mov qword ptr [rdi+10], r9          ; Text
    mov dword ptr [rdi+26], rcx         ; Parent window
    
    inc dword ptr [widget_count]
    mov eax, ebx
    jmp create_button_done
    
create_button_fail:
    mov eax, -1
    
create_button_done:
    add rsp, 48
    pop rbp
    ret

; ============================================================================
; CREATE TEXTBOX
; ============================================================================
create_textbox:
    ; Input: RCX = parent, RDX = x, R8 = y, R9 = width, Stack = height
    
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    mov eax, [widget_count]
    cmp eax, 32
    jge create_textbox_fail
    
    mov rbx, [widget_count]
    imul rax, rbx, 64
    lea rdi, [widget_table + rax]
    
    mov byte ptr [rdi], WIDGET_TEXTBOX
    mov byte ptr [rdi+1], 0
    mov word ptr [rdi+2], dx
    mov word ptr [rdi+4], r8w
    mov word ptr [rdi+6], r9w
    mov eax, [rbp+16]
    mov word ptr [rdi+8], ax
    mov dword ptr [rdi+26], rcx
    
    inc dword ptr [widget_count]
    mov eax, ebx
    jmp create_textbox_done
    
create_textbox_fail:
    mov eax, -1
    
create_textbox_done:
    add rsp, 48
    pop rbp
    ret

; ============================================================================
; CREATE LABEL
; ============================================================================
create_label:
    ; Input: RCX = parent, RDX = x, R8 = y, R9 = text
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov eax, [widget_count]
    cmp eax, 32
    jge create_label_fail
    
    mov rbx, [widget_count]
    imul rax, rbx, 64
    lea rdi, [widget_table + rax]
    
    mov byte ptr [rdi], WIDGET_LABEL
    mov byte ptr [rdi+1], 0
    mov word ptr [rdi+2], dx
    mov word ptr [rdi+4], r8w
    mov qword ptr [rdi+10], r9
    mov dword ptr [rdi+26], rcx
    
    inc dword ptr [widget_count]
    mov eax, ebx
    jmp create_label_done
    
create_label_fail:
    mov eax, -1
    
create_label_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; CREATE CHECKBOX
; ============================================================================
create_checkbox:
    ; Input: RCX = parent, RDX = x, R8 = y, R9 = text
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov eax, [widget_count]
    cmp eax, 32
    jge create_checkbox_fail
    
    mov rbx, [widget_count]
    imul rax, rbx, 64
    lea rdi, [widget_table + rax]
    
    mov byte ptr [rdi], WIDGET_CHECKBOX
    mov byte ptr [rdi+1], 0
    mov word ptr [rdi+2], dx
    mov word ptr [rdi+4], r8w
    mov qword ptr [rdi+10], r9
    mov dword ptr [rdi+26], rcx
    
    inc dword ptr [widget_count]
    mov eax, ebx
    jmp create_checkbox_done
    
create_checkbox_fail:
    mov eax, -1
    
create_checkbox_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; DRAW BUTTON
; ============================================================================
draw_button:
    ; Input: RCX = button handle
    
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    imul rax, rcx, 64
    lea rsi, [widget_table + rax]
    
    mov rax, -11
    call GetStdHandle
    mov r11, rax
    
    ; Get button properties
    movzx r8d, word ptr [rsi+2]
    movzx r9d, word ptr [rsi+4]
    movzx r10d, word ptr [rsi+6]
    movzx eax, byte ptr [rsi+1]
    
    ; Draw button based on state
    cmp al, BUTTON_NORMAL
    je draw_button_normal
    cmp al, BUTTON_PRESSED
    je draw_button_pressed
    cmp al, BUTTON_HOVER
    je draw_button_hover
    jmp draw_button_done
    
draw_button_normal:
    ; Draw normal button
    mov rcx, r11
    lea rdx, [button_normal_frame]
    mov r8, 10
    call WriteConsoleA
    jmp draw_button_done
    
draw_button_pressed:
    ; Draw pressed button
    mov rcx, r11
    lea rdx, [button_pressed_frame]
    mov r8, 10
    call WriteConsoleA
    jmp draw_button_done
    
draw_button_hover:
    ; Draw hovered button
    mov rcx, r11
    lea rdx, [button_hover_frame]
    mov r8, 10
    call WriteConsoleA
    
draw_button_done:
    add rsp, 48
    pop rbp
    ret

; ============================================================================
; DRAW TEXTBOX
; ============================================================================
draw_textbox:
    ; Input: RCX = textbox handle
    
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    imul rax, rcx, 64
    lea rsi, [widget_table + rax]
    
    mov rax, -11
    call GetStdHandle
    mov r11, rax
    
    ; Draw textbox border
    mov rcx, r11
    lea rdx, [textbox_frame]
    mov r8, 10
    call WriteConsoleA
    
    add rsp, 48
    pop rbp
    ret

; ============================================================================
; GUI UTILITY FUNCTIONS
; ============================================================================

set_console_cursor:
    ; Input: RCX = handle, RDX = x, R8 = y
    ; (Simplified - actual implementation would use Windows API)
    
    push rbp
    mov rbp, rsp
    
    pop rbp
    ret

draw_horizontal_line:
    ; Input: RCX = handle, RDX = start, R8 = length
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, rcx
    lea rdx, [h_line]
    mov r8, r8
    call WriteConsoleA
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; DIALOG BOX FUNCTIONS
; ============================================================================

show_message_box:
    ; Input: RCX = title, RDX = message, R8 = buttons
    
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    ; Create dialog window
    call create_window
    mov r10, rax                        ; Save window handle
    
    ; Add message label
    mov rcx, r10
    mov rdx, 2
    mov r8, 2
    mov r9, rdx                         ; message text
    call create_label
    
    ; Add buttons
    cmp r8, 1                           ; Single button
    je messagebox_ok
    cmp r8, 2                           ; Yes/No
    je messagebox_yesno
    cmp r8, 3                           ; OK/Cancel
    je messagebox_okcancel
    
    jmp messagebox_draw
    
messagebox_ok:
    mov rcx, r10
    mov rdx, 20
    mov r8, 15
    mov r9, offset ok_button_text
    mov dword ptr [rsp+32], 8
    call create_button
    jmp messagebox_draw
    
messagebox_yesno:
    ; Create Yes and No buttons
    jmp messagebox_draw
    
messagebox_okcancel:
    ; Create OK and Cancel buttons
    jmp messagebox_draw
    
messagebox_draw:
    mov rcx, r10
    call draw_window
    
    add rsp, 48
    pop rbp
    ret

; ============================================================================
; GUI STRINGS AND FRAMES
; ============================================================================

border_top:             db "┌─┐", 0
button_normal_frame:    db "[ ]", 0
button_pressed_frame:   db "[█]", 0
button_hover_frame:     db "[▓]", 0
textbox_frame:          db "├─┤", 0
h_line:                 db "───", 0
ok_button_text:         db "OK", 0

; ============================================================================
; END OF GUI FRAMEWORK
; ============================================================================

end
