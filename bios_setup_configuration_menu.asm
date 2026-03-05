; ============================================================================
; ALTAIR 8800 - BIOS SETUP UTILITY & CONFIGURATION MENU
; Interactive configuration system for CMOS settings
; ============================================================================

.code

extern GetStdHandle:proc
extern WriteConsoleA:proc
extern ReadConsoleA:proc

; ============================================================================
; SETUP UTILITY CONSTANTS
; ============================================================================

.data

; Setup menu option codes
SETUP_MAIN_MENU             equ 0x00
SETUP_SYSTEM_TIME           equ 0x01
SETUP_BOOT_SEQUENCE         equ 0x02
SETUP_HARDWARE_CONFIG       equ 0x03
SETUP_POWER_MANAGEMENT      equ 0x04
SETUP_THERMAL_SETTINGS      equ 0x05
SETUP_SECURITY_OPTIONS      equ 0x06
SETUP_ADVANCED_SETTINGS     equ 0x07
SETUP_EXIT                  equ 0x08

; Display mode for menus
menu_mode_main              db SETUP_MAIN_MENU

; User selection buffer
selected_option:            db 0
selected_value:             db 0

; ============================================================================
; MENU STRING DEFINITIONS
; ============================================================================

; Main menu
main_menu_title:            db "=== ALTAIR 8800 BIOS SETUP UTILITY ===", 0Dh, 0Ah, 0Dh, 0Ah, 0
main_menu_option_1:         db "1. System Time Configuration", 0Dh, 0Ah, 0
main_menu_option_2:         db "2. Boot Sequence Settings", 0Dh, 0Ah, 0
main_menu_option_3:         db "3. Hardware Configuration", 0Dh, 0Ah, 0
main_menu_option_4:         db "4. Power Management", 0Dh, 0Ah, 0
main_menu_option_5:         db "5. Thermal Settings", 0Dh, 0Ah, 0
main_menu_option_6:         db "6. Security Options", 0Dh, 0Ah, 0
main_menu_option_7:         db "7. Advanced Settings", 0Dh, 0Ah, 0
main_menu_option_8:         db "8. Exit Setup", 0Dh, 0Ah, 0Dh, 0Ah, 0
main_menu_prompt:           db "Select an option (1-8): ", 0

; System time menu
time_menu_title:            db "System Time Configuration", 0Dh, 0Ah, 0
time_menu_hour:             db "Current Hour (0-23): ", 0
time_menu_minute:           db "Current Minute (0-59): ", 0
time_menu_second:           db "Current Second (0-59): ", 0
time_menu_month:            db "Month (1-12): ", 0
time_menu_day:              db "Day (1-31): ", 0
time_menu_year:             db "Year (00-99): ", 0

; Boot sequence menu
boot_menu_title:            db "Boot Sequence Settings", 0Dh, 0Ah, 0
boot_menu_option_1:         db "1. First Boot Device", 0Dh, 0Ah, 0
boot_menu_option_2:         db "2. Second Boot Device", 0Dh, 0Ah, 0
boot_menu_option_3:         db "3. Third Boot Device", 0Dh, 0Ah, 0
boot_menu_option_4:         db "4. Boot Mode (Quick/Full POST)", 0Dh, 0Ah, 0
boot_menu_option_5:         db "5. Verbose Boot Messages", 0Dh, 0Ah, 0
boot_device_rom:            db "a. ROM", 0Dh, 0Ah, 0
boot_device_floppy:         db "b. Floppy Drive", 0Dh, 0Ah, 0
boot_device_hard:           db "c. Hard Drive", 0Dh, 0Ah, 0
boot_device_network:        db "d. Network", 0Dh, 0Ah, 0
boot_menu_prompt:           db "Enter device code (a-d): ", 0

; Hardware configuration menu
hardware_menu_title:        db "Hardware Configuration", 0Dh, 0Ah, 0
hardware_menu_option_1:     db "1. Display Type", 0Dh, 0Ah, 0
hardware_menu_option_2:     db "2. Keyboard Layout", 0Dh, 0Ah, 0
hardware_menu_option_3:     db "3. Floppy Drive A", 0Dh, 0Ah, 0
hardware_menu_option_4:     db "4. Floppy Drive B", 0Dh, 0Ah, 0
hardware_menu_option_5:     db "5. Hard Drive 0", 0Dh, 0Ah, 0
hardware_menu_option_6:     db "6. Serial Port Speed", 0Dh, 0Ah, 0
hardware_display_color:     db "Color Display (EGA)", 0Dh, 0Ah, 0
hardware_display_mono:      db "Monochrome Display (MDA)", 0Dh, 0Ah, 0
hardware_keyboard_us:       db "US Keyboard", 0Dh, 0Ah, 0
hardware_keyboard_uk:       db "UK Keyboard", 0Dh, 0Ah, 0
hardware_keyboard_de:       db "German Keyboard", 0Dh, 0Ah, 0

; Power management menu
power_menu_title:           db "Power Management Settings", 0Dh, 0Ah, 0
power_menu_option_1:        db "1. Sleep Mode Timeout (seconds)", 0Dh, 0Ah, 0
power_menu_option_2:        db "2. CPU Throttling", 0Dh, 0Ah, 0
power_menu_option_3:        db "3. Fan Control Mode", 0Dh, 0Ah, 0
power_menu_option_4:        db "4. Display Brightness", 0Dh, 0Ah, 0
power_menu_option_5:        db "5. Hard Drive Standby", 0Dh, 0Ah, 0
power_menu_disabled:        db "(Disabled)", 0Dh, 0Ah, 0
power_menu_enabled:         db "(Enabled)", 0Dh, 0Ah, 0

; Thermal settings menu
thermal_menu_title:         db "Thermal Settings", 0Dh, 0Ah, 0
thermal_menu_current_temp:  db "Current CPU Temperature: ", 0
thermal_menu_warning:       db "Temperature Warning Level: ", 0
thermal_menu_critical:      db "Temperature Critical Level: ", 0
thermal_menu_fan_auto:      db "Fan Control: Automatic", 0Dh, 0Ah, 0
thermal_menu_fan_manual:    db "Fan Control: Manual", 0Dh, 0Ah, 0
thermal_menu_fan_speed:     db "Current Fan Speed (RPM): ", 0

; Security menu
security_menu_title:        db "Security Options", 0Dh, 0Ah, 0
security_menu_option_1:     db "1. Set BIOS Password", 0Dh, 0Ah, 0
security_menu_option_2:     db "2. Hard Drive Lock", 0Dh, 0Ah, 0
security_menu_option_3:     db "3. Boot Device Lock", 0Dh, 0Ah, 0
security_menu_option_4:     db "4. BIOS Modification Lock", 0Dh, 0Ah, 0
security_status_enabled:    db "(Enabled)", 0Dh, 0Ah, 0
security_status_disabled:   db "(Disabled)", 0Dh, 0Ah, 0

; Advanced settings menu
advanced_menu_title:        db "Advanced Settings", 0Dh, 0Ah, 0
advanced_menu_option_1:     db "1. CPU Cache", 0Dh, 0Ah, 0
advanced_menu_option_2:     db "2. Memory Interleaving", 0Dh, 0Ah, 0
advanced_menu_option_3:     db "3. ROM Shadowing", 0Dh, 0Ah, 0
advanced_menu_option_4:     db "4. PCI IRQ Routing", 0Dh, 0Ah, 0
advanced_menu_option_5:     db "5. ACPI Support", 0Dh, 0Ah, 0
advanced_menu_option_6:     db "6. Network Boot", 0Dh, 0Ah, 0

; Common strings
separator:                  db "----------------------------------------", 0Dh, 0Ah, 0
newline:                    db 0Dh, 0Ah, 0
enabled_str:                db "Enabled", 0
disabled_str:               db "Disabled", 0
yes_str:                    db "Yes", 0
no_str:                      db "No", 0
saved_str:                  db "[Settings Saved]", 0Dh, 0Ah, 0
backspace_prompt:           db "Press ESC to go back, any other key to continue...", 0
enter_value_prompt:         db "Enter value: ", 0

; ============================================================================
; CONFIGURATION VALUE TABLES
; ============================================================================

; Display type options
display_types:
    db "Color Display (EGA)", 0
    db "Monochrome (MDA)", 0

; Keyboard layout options
keyboard_layouts:
    db "US English", 0
    db "UK English", 0
    db "German", 0

; Floppy drive types
floppy_types:
    db "None", 0
    db "360 KB 5.25", 0
    db "1.2 MB 5.25", 0
    db "1.44 MB 3.5", 0

; Serial port baud rates
baud_rates:
    dw 1200, 2400, 4800, 9600, 19200, 38400

; Boot device options
boot_devices:
    db "ROM", 0
    db "Floppy A", 0
    db "Hard Drive", 0
    db "Network", 0

; ============================================================================
; SETUP UTILITY FUNCTIONS
; ============================================================================

.code

; Main setup entry point
enter_setup_utility:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Get stdout handle
    mov rcx, -11                ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov r11, rax
    
    ; Clear display
    call clear_screen
    
    ; Display title
    mov rcx, r11
    lea rdx, [main_menu_title]
    mov r8, 40
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
setup_loop:
    ; Display main menu options
    call display_main_menu
    
    ; Get user input
    sub rsp, 8
    
    ; Check for escape key to exit
    cmp al, 27                  ; ESC key
    je setup_exit_util
    
    ; Process menu selection
    mov [selected_option], al
    
    ; Route to appropriate menu
    cmp al, '1'
    je show_time_menu
    cmp al, '2'
    je show_boot_menu
    cmp al, '3'
    je show_hardware_menu
    cmp al, '4'
    je show_power_menu
    cmp al, '5'
    je show_thermal_menu
    cmp al, '6'
    je show_security_menu
    cmp al, '7'
    je show_advanced_menu
    cmp al, '8'
    je setup_exit_util
    
    jmp setup_loop
    
show_time_menu:
    call display_time_menu
    jmp setup_loop
    
show_boot_menu:
    call display_boot_menu
    jmp setup_loop
    
show_hardware_menu:
    call display_hardware_menu
    jmp setup_loop
    
show_power_menu:
    call display_power_menu
    jmp setup_loop
    
show_thermal_menu:
    call display_thermal_menu
    jmp setup_loop
    
show_security_menu:
    call display_security_menu
    jmp setup_loop
    
show_advanced_menu:
    call display_advanced_menu
    jmp setup_loop
    
setup_exit_util:
    ; Save settings to CMOS
    call save_cmos_settings
    
    ; Clear screen
    call clear_screen
    
    add rsp, 64
    pop rbp
    ret

; ============================================================================
; MENU DISPLAY FUNCTIONS
; ============================================================================

display_main_menu:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11                ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov r11, rax
    
    ; Display options
    mov rcx, r11
    lea rdx, [main_menu_option_1]
    mov r8, 30
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    ; (Additional options would follow the same pattern)
    
    ; Prompt for input
    mov rcx, r11
    lea rdx, [main_menu_prompt]
    mov r8, 25
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

display_time_menu:
    push rbp
    mov rbp, rsp
    
    ; Display time menu and get inputs
    
    pop rbp
    ret

display_boot_menu:
    push rbp
    mov rbp, rsp
    
    ; Display boot menu and get inputs
    
    pop rbp
    ret

display_hardware_menu:
    push rbp
    mov rbp, rsp
    
    ; Display hardware menu and get inputs
    
    pop rbp
    ret

display_power_menu:
    push rbp
    mov rbp, rsp
    
    ; Display power menu and get inputs
    
    pop rbp
    ret

display_thermal_menu:
    push rbp
    mov rbp, rsp
    
    ; Display thermal menu and get inputs
    
    pop rbp
    ret

display_security_menu:
    push rbp
    mov rbp, rsp
    
    ; Display security menu and get inputs
    
    pop rbp
    ret

display_advanced_menu:
    push rbp
    mov rbp, rsp
    
    ; Display advanced menu and get inputs
    
    pop rbp
    ret

; ============================================================================
; UTILITY FUNCTIONS
; ============================================================================

clear_screen:
    ; Clear console screen (simulated)
    push rbp
    mov rbp, rsp
    
    ; Would clear console buffer
    
    pop rbp
    ret

save_cmos_settings:
    ; Save all CMOS settings
    push rbp
    mov rbp, rsp
    
    ; Calculate CMOS checksum
    call calculate_cmos_checksum
    
    pop rbp
    ret

calculate_cmos_checksum:
    ; Calculate checksum for CMOS configuration
    push rbp
    mov rbp, rsp
    
    ; Sum all CMOS bytes
    ; Store result at checksum locations
    
    pop rbp
    ret

load_cmos_settings:
    ; Load CMOS settings to variables
    push rbp
    mov rbp, rsp
    
    pop rbp
    ret

; ============================================================================
; CONFIGURATION VALIDATORS
; ============================================================================

validate_hour:
    ; AL = hour value
    ; Check if 0-23
    cmp al, 23
    jle valid_hour
    jmp invalid_value
valid_hour:
    ret

validate_minute_second:
    ; AL = minute or second value
    ; Check if 0-59
    cmp al, 59
    jle valid_minute
    jmp invalid_value
valid_minute:
    ret

validate_month:
    ; AL = month value
    ; Check if 1-12
    cmp al, 1
    jl invalid_value
    cmp al, 12
    jle valid_month
    jmp invalid_value
valid_month:
    ret

validate_day:
    ; AL = day value
    ; Check if 1-31
    cmp al, 1
    jl invalid_value
    cmp al, 31
    jle valid_day
    jmp invalid_value
valid_day:
    ret

invalid_value:
    ; Handle invalid input
    ret

; ============================================================================
; CMOS CONFIGURATION STORAGE
; ============================================================================

store_time_config:
    ; Store time configuration to CMOS
    push rbp
    mov rbp, rsp
    
    ; Store hour, minute, second, day, month, year
    ; to CMOS_RTC_HOURS, CMOS_RTC_MINUTES, etc.
    
    pop rbp
    ret

store_boot_config:
    ; Store boot sequence to CMOS
    push rbp
    mov rbp, rsp
    
    pop rbp
    ret

store_hardware_config:
    ; Store hardware configuration to CMOS
    push rbp
    mov rbp, rsp
    
    pop rbp
    ret

store_power_config:
    ; Store power settings to CMOS
    push rbp
    mov rbp, rsp
    
    pop rbp
    ret

; ============================================================================
; CONFIGURATION UPDATE COMMANDS
; ============================================================================

update_config_timer:
    ; Update timer-based settings
    push rbp
    mov rbp, rsp
    
    ; Check for timeout conditions
    ; Trigger sleep if needed
    ; Check thermal limits
    
    pop rbp
    ret

update_config_boot:
    ; Update boot parameters
    push rbp
    mov rbp, rsp
    
    pop rbp
    ret

; ============================================================================
; DEFAULTS AND RESET FUNCTIONS
; ============================================================================

reset_to_factory_defaults:
    push rbp
    mov rbp, rsp
    
    ; Reset all options to factory defaults
    ; Time: 00:00:00, 01/01/00
    ; Boot: ROM then Floppy then Hard Drive
    ; Display: Color
    ; Power: Normal mode
    ; Thermal: Auto fan control
    
    pop rbp
    ret

; ============================================================================
; END OF SETUP UTILITY
; ============================================================================

end
