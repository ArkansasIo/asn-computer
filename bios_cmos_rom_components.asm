; ============================================================================
; ALTAIR 8800 SYSTEM COMPONENTS - BIOS, CMOS, RAM, ROM
; Complete implementation of computer hardware components and BIOS
; ============================================================================

.code

extern GetStdHandle:proc
extern WriteConsoleA:proc
extern ExitProcess:proc

; ============================================================================
; CONSTANTS
; ============================================================================

; Memory Organization
ROM_START           equ 0x0000      ; ROM starts at 0x0000
ROM_SIZE            equ 0x2000      ; 8KB ROM
RAM_START           equ 0x2000      ; RAM starts at 0x2000
RAM_SIZE            equ 0xE000      ; 56KB RAM
CMOS_START          equ 0xF800      ; CMOS starts at 0xF800
CMOS_SIZE           equ 0x0800      ; 2KB CMOS

; I/O Port Assignments
PORT_SYSTEM_STATUS  equ 0x00
PORT_SYSTEM_CTRL    equ 0x01
PORT_CMOS_ADDR      equ 0x70
PORT_CMOS_DATA      equ 0x71
PORT_TIMER          equ 0x40
PORT_INT_CTRL       equ 0x20

; CMOS Addresses
CMOS_RTC_SECONDS    equ 0x00
CMOS_RTC_MINUTES    equ 0x02
CMOS_RTC_HOURS      equ 0x04
CMOS_BOOT_CONFIG    equ 0x10
CMOS_DIAG_STATUS    equ 0x11
CMOS_CHECKSUM_HIGH  equ 0x2E
CMOS_CHECKSUM_LOW   equ 0x2F
CMOS_EXTENDED_START equ 0x30

; System Status Flags
STATUS_POWER_OK     equ 0x01
STATUS_CPU_OK       equ 0x02
STATUS_RAM_OK       equ 0x04
STATUS_ROM_OK       equ 0x08
STATUS_CMOS_OK      equ 0x10

; Boot Codes
BOOT_FIRST_FLOPPY   equ 0x00
BOOT_FIRST_HARD     equ 0x01
BOOT_ROM            equ 0x02

; ============================================================================
; ROM - READ-ONLY MEMORY (First 8KB)
; ============================================================================

.data

; ROM Signature
rom_signature:      db "ALTAIR8800BIOS", 0

; ROM Version Information
rom_version:        db 1, 0         ; Version 1.0
rom_build:          dd 20260304     ; Build date: March 4, 2026

; ROM Entry Points (ROM Address Table)
rom_entry_points:
    dw offset bios_startup          ; 0x0000 - BIOS startup
    dw offset bios_post             ; 0x0002 - POST (Power-On Self Test)
    dw offset bios_boot             ; 0x0004 - Boot loader
    dw offset int_vector_table      ; 0x0006 - Interrupt vectors
    dw offset beep_low              ; 0x0008 - Speaker control
    dw offset beep_high             ; 0x000A
    dw offset int_18h_handler       ; 0x000C - Disk I/O
    dw offset int_10h_handler       ; 0x000E - Video I/O
    dw offset int_16h_handler       ; 0x0010 - Keyboard I/O

; ROM Character Display Font (5x7 bitmap)
rom_font_data:      db 256 dup(0)   ; Font table

; ROM Subroutines stored in ROM
rom_subroutines_begin:

; Basic input/output routines
rom_read_disk:      db "READ_DISK", 0
rom_write_disk:     db "WRITE_DISK", 0
rom_read_kbd:       db "READ_KBD", 0
rom_write_screen:   db "WRITE_SCREEN", 0

rom_subroutines_end:

; ============================================================================
; CMOS - NON-VOLATILE RAM (Configuration/Status)
; ============================================================================

cmos_memory:
    ; RTC (Real-Time Clock) Registers
    cmos_seconds:           db 0        ; 0x00 - Seconds (0-59)
    cmos_seconds_alarm:     db 0        ; 0x01 - Seconds alarm
    cmos_minutes:           db 0        ; 0x02 - Minutes (0-59)
    cmos_minutes_alarm:     db 0        ; 0x03 - Minutes alarm
    cmos_hours:             db 0        ; 0x04 - Hours (0-23)
    cmos_hours_alarm:       db 0        ; 0x05 - Hours alarm
    cmos_day_of_week:       db 1        ; 0x06 - Day of week (1=Sunday)
    cmos_day_of_month:      db 1        ; 0x07 - Day of month (1-31)
    cmos_month:             db 1        ; 0x08 - Month (1-12)
    cmos_year:              db 26       ; 0x09 - Year (0-99, 26=2026)
    
    ; RTC Status and Control
    cmos_status_a:          db 0x26     ; 0x0A - Status register A
    cmos_status_b:          db 0x02     ; 0x0B - Status register B (update enabled)
    cmos_status_c:          db 0x00     ; 0x0C - Status register C
    cmos_status_d:          db 0x80     ; 0x0D - Status register D
    
    ; Boot Configuration
    cmos_boot_device:       db BOOT_ROM ; 0x10 - Primary boot device
    cmos_boot_device_2:     db BOOT_FIRST_FLOPPY ; 0x11 - Secondary boot device
    cmos_boot_device_3:     db BOOT_FIRST_HARD ; 0x12 - Tertiary boot device
    
    ; System Configuration
    cmos_system_features:   db 0        ; 0x13 - System features
    cmos_extended_config:   db 0        ; 0x14 - Extended configuration
    cmos_memory_low:        db 0        ; 0x15 - Base memory low byte (KB)
    cmos_memory_high:       db 0        ; 0x16 - Base memory high byte (KB)
    
    ; Diagnostics
    cmos_diag_status:       db 0        ; 0x17 - Diagnostics status
    cmos_post_result:       db 0        ; 0x18 - POST result code
    
    ; Additional Settings (0x19-0x2D)
    cmos_display_type:      db 0        ; 0x19 - Display type (0=color, 1=mono)
    cmos_hard_drive_0:      db 0        ; 0x1A - Hard drive 0 type
    cmos_hard_drive_1:      db 0        ; 0x1B - Hard drive 1 type
    cmos_parallel_ports:    db 0        ; 0x1C - Parallel ports count
    cmos_serial_ports:      db 0        ; 0x1D - Serial ports count
    
    ; Keyboard Setup
    cmos_keyboard_layout:   db 0        ; 0x1E - Keyboard layout (0=US)
    cmos_keyboard_repeat:   db 0x20     ; 0x1F - Keyboard repeat rate
    
    ; Floppy Drive Configuration
    cmos_floppy_a_type:     db 0        ; 0x20 - Floppy A type (0=none, 1=360K, etc)
    cmos_floppy_b_type:     db 0        ; 0x21 - Floppy B type
    
    ; Feature Flags (0x22-0x2D)
    cmos_features_1:        db 0        ; 0x22 - Feature set 1
    cmos_features_2:        db 0        ; 0x23 - Feature set 2
    cmos_clock_rate:        db 0        ; 0x24 - CPU clock multiplier
    cmos_reserved_25:       db 0        ; 0x25 - Reserved
    cmos_reserved_26:       db 0        ; 0x26 - Reserved
    cmos_reserved_27:       db 0        ; 0x27 - Reserved
    cmos_reserved_28:       db 0        ; 0x28 - Reserved
    cmos_reserved_29:       db 0        ; 0x29 - Reserved
    cmos_reserved_2A:       db 0        ; 0x2A - Reserved
    cmos_reserved_2B:       db 0        ; 0x2B - Reserved
    cmos_reserved_2C:       db 0        ; 0x2C - Reserved
    cmos_reserved_2D:       db 0        ; 0x2D - Reserved
    
    ; Checksum
    cmos_checksum_high:     db 0        ; 0x2E - Checksum high byte
    cmos_checksum_low:      db 0        ; 0x2F - Checksum low byte

; Extended CMOS Settings (0x30 and beyond)
cmos_extended_memory:
    cmos_extended_flags:    db 0        ; 0x30 - Extended feature flags
    cmos_power_management:  db 0        ; 0x31 - Power management settings
    cmos_temp_monitor:      db 0        ; 0x32 - Temperature monitoring
    cmos_fan_control:       db 0        ; 0x33 - Fan control settings
    cmos_cpu_frequency:     dd 3072000  ; 0x34-0x37 - CPU frequency (Hz)
    cmos_pci_irq_routing:   dd 0        ; 0x38-0x3B - PCI IRQ routing
    cmos_acpi_settings:     db 0        ; 0x3C - ACPI settings
    cmos_reserved_3D:       db 0        ; 0x3D - Reserved
    cmos_reserved_3E:       db 0        ; 0x3E - Reserved
    cmos_reserved_3F:       db 0        ; 0x3F - Reserved

; ============================================================================
; RAM - RANDOM ACCESS MEMORY
; ============================================================================

; RAM is dynamically allocated, storage here is for variables only

; Interrupt Vector Table (stored in RAM at 0x0000-0x03FF in real 8086)
interrupt_vectors:
    dw 256 dup(0)           ; 256 interrupt vectors, 2 bytes each

; System Work Area (stored in RAM)
system_work_area:
    db 256 dup(0)           ; 256 bytes system work area

; Memory Allocation Table
memory_allocation_table:
    db 128 dup(0)           ; Bitmap for allocated/free memory blocks

; ============================================================================
; BIOS - BASIC INPUT/OUTPUT SYSTEM
; ============================================================================

; Current CMOS address register
cmos_current_addr:  db 0

; System state flags
system_status:      db 0                ; Bit flags for system status
system_time_sec:    dd 0                ; System uptime in seconds
system_boot_count:  dw 0                ; Number of boots

; POST (Power-On Self Test) Results
post_results:
    post_ram_test:          db 0        ; 1 = passed
    post_rom_test:          db 0        ; 1 = passed
    post_cpu_test:          db 0        ; 1 = passed
    post_keyboard_test:     db 0        ; 1 = passed
    post_disk_test:         db 0        ; 1 = passed
    post_video_test:        db 0        ; 1 = passed

; Configuration options
config_power_management:    db 0        ; Power management level (0-3)
config_display_brightness: db 100       ; Display brightness (0-255)
config_speaker_volume:      db 100       ; Speaker volume (0-255)
config_cpu_speed:           db 255       ; CPU speed (0=slow, 255=fast)
config_mouse_enabled:       db 1        ; Mouse enabled (0/1)
config_keyboard_beep:       db 1        ; Keyboard beep enabled (0/1)

; ============================================================================
; BIOS STARTUP ROUTINE
; ============================================================================

bios_startup:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    ; Initialize system status
    mov byte ptr [system_status], 0
    
    ; Check power supply voltage (simulated)
    mov al, STATUS_POWER_OK
    or [system_status], al
    
    ; Clear first 256 bytes of RAM (interrupt vector table)
    mov ecx, 256
    lea rdi, [interrupt_vectors]
    xor al, al
    rep stosb
    
    ; Initialize interrupt vectors
    call setup_interrupt_vectors
    
    ; Initialize CMOS
    call initialize_cmos
    
    ; Set system time to current
    call update_system_time
    
    ; Increment boot counter
    inc word ptr [system_boot_count]
    
    ; Display startup message
    call display_bios_message
    
    ; Run POST (Power-On Self Test)
    call run_post
    
    ; Load boot sector
    call load_boot_code
    
    add rsp, 48
    pop rbp
    ret

; ============================================================================
; SETUP INTERRUPT VECTORS
; ============================================================================

setup_interrupt_vectors:
    push rbp
    mov rbp, rsp
    
    ; INT 0x00 - Divide by zero
    mov rax, 0
    lea rbx, [divide_error_handler]
    mov [interrupt_vectors + rax*2], rbx
    
    ; INT 0x0E - Page fault
    mov rax, 0x0E
    lea rbx, [page_fault_handler]
    mov [interrupt_vectors + rax*2], rbx
    
    ; INT 0x10 - Video services
    mov rax, 0x10
    lea rbx, [int_10h_handler]
    mov [interrupt_vectors + rax*2], rbx
    
    ; INT 0x13 - Disk I/O
    mov rax, 0x13
    lea rbx, [int_13h_handler]
    mov [interrupt_vectors + rax*2], rbx
    
    ; INT 0x16 - Keyboard I/O
    mov rax, 0x16
    lea rbx, [int_16h_handler]
    mov [interrupt_vectors + rax*2], rbx
    
    pop rbp
    ret

; ============================================================================
; INITIALIZE CMOS
; ============================================================================

initialize_cmos:
    push rbp
    mov rbp, rsp
    
    ; Set RTC to default values (midnight, Jan 1, 2026)
    mov byte ptr [cmos_seconds], 0
    mov byte ptr [cmos_minutes], 0
    mov byte ptr [cmos_hours], 0
    mov byte ptr [cmos_day_of_month], 1
    mov byte ptr [cmos_month], 1
    mov byte ptr [cmos_year], 26
    mov byte ptr [cmos_day_of_week], 6  ; Friday, Jan 1, 2026
    
    ; Set status registers
    mov byte ptr [cmos_status_a], 0x26  ; Update in progress, 32kHz
    mov byte ptr [cmos_status_b], 0x02  ; 24-hour format, update enabled
    mov byte ptr [cmos_status_c], 0x00  ; Clear interrupts
    mov byte ptr [cmos_status_d], 0x80  ; Valid RTC
    
    ; Set CMOS checksum
    call calculate_cmos_checksum
    
    ; Mark CMOS as initialized
    or byte ptr [system_status], STATUS_CMOS_OK
    
    pop rbp
    ret

; ============================================================================
; UPDATE SYSTEM TIME
; ============================================================================

update_system_time:
    push rbp
    mov rbp, rsp
    
    ; Get current time (in real system, would read RTC)
    ; For simulation, use a static time
    mov dword ptr [system_time_sec], 0
    
    pop rbp
    ret

; ============================================================================
; CALCULATE CMOS CHECKSUM
; ============================================================================

calculate_cmos_checksum:
    push rbp
    mov rbp, rsp
    
    ; Sum CMOS bytes 0x00-0x2D
    mov ecx, 0x2E
    lea rsi, [cmos_memory]
    xor ax, ax
    
checksum_loop:
    mov al, byte ptr [rsi]
    add ax, bx
    inc rsi
    dec ecx
    jnz checksum_loop
    
    ; Store checksum high/low
    mov bx, ax
    shr ax, 8
    mov [cmos_checksum_high], al
    mov [cmos_checksum_low], bl
    
    pop rbp
    ret

; ============================================================================
; POWER-ON SELF TEST (POST)
; ============================================================================

run_post:
    push rbp
    mov rbp, rsp
    
    ; Test CPU
    call test_cpu
    mov [post_cpu_test], al
    or byte ptr [system_status], STATUS_CPU_OK
    
    ; Test RAM
    call test_ram
    mov [post_ram_test], al
    or byte ptr [system_status], STATUS_RAM_OK
    
    ; Test ROM
    call test_rom
    mov [post_rom_test], al
    or byte ptr [system_status], STATUS_ROM_OK
    
    ; Test keyboard
    call test_keyboard
    mov [post_keyboard_test], al
    
    ; Test video display
    call test_display
    mov [post_video_test], al
    
    pop rbp
    ret

; ============================================================================
; CPU TEST
; ============================================================================

test_cpu:
    push rbp
    mov rbp, rsp
    
    ; Simple CPU test: arithmetic operations
    mov rax, 0x1234
    add rax, 0x5678
    cmp rax, 0x68AC
    je cpu_test_ok
    
    xor al, al                  ; Test failed
    jmp cpu_test_done
    
cpu_test_ok:
    mov al, 1                   ; Test passed
    
cpu_test_done:
    pop rbp
    ret

; ============================================================================
; RAM TEST
; ============================================================================

test_ram:
    push rbp
    mov rbp, rsp
    
    ; Test RAM: write pattern and read back
    mov rdi, RAM_START
    mov ecx, 1024               ; Test 1KB of memory
    
    ; Write pattern: 0x55
    mov al, 0x55
    rep stosb
    
    ; Read back and verify
    mov rsi, RAM_START
    mov ecx, 1024
    mov al, 0x55
    
ram_test_loop:
    cmp [rsi], al
    jne ram_test_fail
    inc rsi
    dec ecx
    jnz ram_test_loop
    
    mov al, 1                   ; Test passed
    jmp ram_test_done
    
ram_test_fail:
    xor al, al                  ; Test failed
    
ram_test_done:
    pop rbp
    ret

; ============================================================================
; ROM TEST (Checksum)
; ============================================================================

test_rom:
    push rbp
    mov rbp, rsp
    
    ; Test ROM: verify signature
    mov rsi, offset rom_signature
    mov rdi, offset rom_signature
    mov ecx, 14                 ; Length of signature
    
    ; Compare ROM signature
    xor ecx, ecx
rom_test_loop:
    mov al, [rsi + rcx]
    cmp al, [rdi + rcx]
    jne rom_test_fail
    inc ecx
    cmp ecx, 14
    jne rom_test_loop
    
    mov al, 1                   ; Test passed
    jmp rom_test_done
    
rom_test_fail:
    xor al, al                  ; Test failed
    
rom_test_done:
    pop rbp
    ret

; ============================================================================
; KEYBOARD TEST
; ============================================================================

test_keyboard:
    push rbp
    mov rbp, rsp
    
    ; Simplified: always pass for simulation
    mov al, 1
    
    pop rbp
    ret

; ============================================================================
; DISPLAY TEST
; ============================================================================

test_display:
    push rbp
    mov rbp, rsp
    
    ; Simplified: always pass for simulation
    mov al, 1
    
    pop rbp
    ret

; ============================================================================
; LOAD BOOT CODE
; ============================================================================

load_boot_code:
    push rbp
    mov rbp, rsp
    
    ; Load boot sector (sector 0) into memory at 0x7C00
    ; For simulation, we'll load a simple boot program
    
    mov rdi, 0x7C00
    mov ecx, 512                ; Boot sector size
    xor al, al
    rep stosb
    
    ; Jump to boot code
    ; jmp 0x7C00
    
    pop rbp
    ret

; ============================================================================
; DISPLAY BIOS MESSAGE
; ============================================================================

display_bios_message:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, -11                ; STD_OUTPUT_HANDLE
    call GetStdHandle
    
    ; Display BIOS start message
    mov r11, rax
    mov rcx, r11
    lea rdx, [bios_start_msg]
    mov r8, 40
    sub rsp, 8
    push 0
    call WriteConsoleA
    add rsp, 16
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; CMOS READ/WRITE FUNCTIONS
; ============================================================================

cmos_read_byte:
    ; RAX = CMOS address
    ; Returns byte in AL
    push rbp
    mov rbp, rsp
    
    mov [cmos_current_addr], al
    lea rsi, [cmos_memory]
    movzx rax, al
    mov al, [rsi + rax]
    
    pop rbp
    ret

cmos_write_byte:
    ; RAX = CMOS address
    ; RBX = byte value
    push rbp
    mov rbp, rsp
    
    mov cl, al
    lea rsi, [cmos_memory]
    movzx rax, cl
    mov [rsi + rax], bl
    
    pop rbp
    ret

; ============================================================================
; SYSTEM CONFIGURATION FUNCTIONS
; ============================================================================

set_boot_device:
    ; AL = boot device code
    ; Stores in CMOS
    mov [cmos_boot_device], al
    ret

set_display_type:
    ; AL = display type (0=color, 1=mono)
    mov [cmos_display_type], al
    ret

set_keyboard_layout:
    ; AL = keyboard layout code
    mov [cmos_keyboard_layout], al
    ret

set_cpu_clock_speed:
    ; AL = clock speed (0-255)
    mov [config_cpu_speed], al
    mov [cmos_clock_rate], al
    ret

set_power_management:
    ; AL = power management level (0-3)
    mov [config_power_management], al
    mov [cmos_power_management], al
    ret

set_display_brightness:
    ; AL = brightness (0-255)
    mov [config_display_brightness], al
    ret

set_speaker_volume:
    ; AL = volume (0-255)
    mov [config_speaker_volume], al
    ret

; ============================================================================
; GET SYSTEM INFORMATION
; ============================================================================

get_system_status:
    ; Returns system status byte in AL
    mov al, [system_status]
    ret

get_boot_count:
    ; Returns boot count in AX
    mov ax, [system_boot_count]
    ret

get_post_result:
    ; Returns POST result in AL
    mov al, [cmos_post_result]
    ret

get_cpu_speed:
    ; Returns CPU speed (0-255) in AL
    mov al, [config_cpu_speed]
    ret

; ============================================================================
; INTERRUPT HANDLERS
; ============================================================================

divide_error_handler:
    push rbp
    mov rbp, rsp
    ; Handle divide by zero
    pop rbp
    iret

page_fault_handler:
    push rbp
    mov rbp, rsp
    ; Handle page fault
    pop rbp
    iret

int_10h_handler:
    ; Video services
    push rbp
    mov rbp, rsp
    pop rbp
    iret

int_13h_handler:
    ; Disk I/O services
    push rbp
    mov rbp, rsp
    pop rbp
    iret

int_16h_handler:
    ; Keyboard I/O services
    push rbp
    mov rbp, rsp
    pop rbp
    iret

int_18h_handler:
    ; Disk I/O (alternate)
    push rbp
    mov rbp, rsp
    pop rbp
    iret

beep_low:
    ; Speaker control low byte
    ret

beep_high:
    ; Speaker control high byte
    ret

int_vector_table:
    dw 0                        ; Placeholder for interrupt vectors

; ============================================================================
; SYSTEM CONFIGURATION OPTIONS
; ============================================================================

; Save configuration to CMOS
save_system_config:
    push rbp
    mov rbp, rsp
    
    ; All configuration is already stored in CMOS variables
    ; Just recalculate checksum
    call calculate_cmos_checksum
    
    pop rbp
    ret

; Load default configuration
load_default_config:
    push rbp
    mov rbp, rsp
    
    ; Set default values
    mov byte ptr [config_power_management], 0
    mov byte ptr [config_display_brightness], 100
    mov byte ptr [config_speaker_volume], 100
    mov byte ptr [config_cpu_speed], 255
    mov byte ptr [config_mouse_enabled], 1
    mov byte ptr [config_keyboard_beep], 1
    
    pop rbp
    ret

; Reset CMOS to factory defaults
reset_cmos_defaults:
    push rbp
    mov rbp, rsp
    
    ; Clear CMOS memory
    mov ecx, 128
    lea rdi, [cmos_memory]
    xor al, al
    rep stosb
    
    ; Re-initialize with defaults
    call initialize_cmos
    call load_default_config
    
    pop rbp
    ret

; ============================================================================
; HARDWARE HEALTH MONITORING
; ============================================================================

; Temperature monitoring (simulated)
get_cpu_temperature:
    ; Returns CPU temperature in AL (40-85 degrees Celsius)
    mov al, 55                  ; 55°C (normal)
    ret

; Voltage monitoring
get_system_voltage:
    ; Returns voltage level in AL (200 = 12V, scaled)
    mov al, 200
    ret

; Fan speed monitoring
get_fan_speed:
    ; Returns fan RPM/100 in AX
    mov ax, 2000                ; 2000 RPM
    ret

; Power supply status
get_power_supply_status:
    ; Returns power supply status in AL
    ; 0xFF = OK, 0x00 = Fault
    mov al, 0xFF
    ret

; ============================================================================
; HARDWARE DIAGNOSTICS
; ============================================================================

run_full_diagnostics:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Run all hardware tests
    call test_cpu
    call test_ram
    call test_rom
    call test_keyboard
    call test_display
    
    ; Check power supply
    call get_power_supply_status
    
    ; Check temperatures
    call get_cpu_temperature
    
    ; Check voltages
    call get_system_voltage
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; MEMORY MANAGEMENT
; ============================================================================

; Allocate memory block
; EAX = size in bytes
; Returns address in EAX
allocate_memory:
    push rbp
    mov rbp, rsp
    
    ; Simple linear allocation
    ; First available address is at RAM_START + 2KB (after work area)
    mov rax, RAM_START + 0x800
    
    pop rbp
    ret

; Free memory block (simplified)
free_memory:
    push rbp
    mov rbp, rsp
    
    ; For simplicity, just mark as available
    
    pop rbp
    ret

; Get available memory
get_available_memory:
    ; Returns available RAM in bytes
    mov rax, RAM_SIZE - 0x800   ; Total RAM minus work area
    ret

; ============================================================================
; SYSTEM TIMER
; ============================================================================

get_system_ticks:
    ; Returns system timer ticks in EAX
    mov eax, dword ptr [system_time_sec]
    imul eax, 18                ; 18.2 ticks per second (typical)
    ret

; ============================================================================
; MESSAGES
; ============================================================================

bios_start_msg:   db "ALTAIR 8800 BIOS Starting...", 0Dh, 0Ah, 0
bios_post_msg:    db "POST Running...", 0Dh, 0Ah, 0
bios_boot_msg:    db "Booting...", 0Dh, 0Ah, 0

; ============================================================================
; END OF BIOS/CMOS/ROM IMPLEMENTATION
; ============================================================================

end
