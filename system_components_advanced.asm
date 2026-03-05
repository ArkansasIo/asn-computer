; ============================================================================
; ALTAIR 8800 - ADVANCED SYSTEM COMPONENTS & CONFIGURATION
; Power Management, I/O Control, Device Drivers, System Settings
; ============================================================================

.code

extern ExitProcess:proc

; ============================================================================
; POWER MANAGEMENT SUBSYSTEM
; ============================================================================

.data

; Power state modes
power_mode_full:            equ 0x00    ; Full power
power_mode_sleep:           equ 0x01    ; Sleep mode (low power)
power_mode_suspend:         equ 0x02    ; Suspend mode (very low power)
power_mode_hibernate:       equ 0x03    ; Hibernate (power off)

; Current power state
current_power_mode:         db power_mode_full
power_consumption_watts:    dw 100      ; Current consumption in watts

; Idle counter for power management
idle_counter:               dd 0        ; Increments when CPU is idle
sleep_timer_seconds:        dd 300      ; Time before sleep (300 seconds)

; Power supply voltage levels
voltage_12v:                db 120      ; 12V supply (scaled: 120 = 12.0V)
voltage_5v:                 db 50       ; 5V supply (scaled: 50 = 5.0V)
voltage_neg5v:              db -50      ; -5V supply (scaled)

; Power supply current limits
current_12v_limit:          dw 10       ; 10A max
current_5v_limit:           dw 30       ; 30A max

; Battery backup status
battery_installed:          db 1        ; Battery installed for CMOS
battery_charge_percent:     db 100      ; Battery charge level
battery_low_threshold:      db 20       ; Low battery threshold

; ============================================================================
; THERMAL MANAGEMENT
; ============================================================================

; Temperature sensors
cpu_temperature:            db 55       ; CPU temperature (°C)
chipset_temperature:        db 45       ; Chipset temperature (°C)
power_supply_temperature:   db 40       ; Power supply temperature (°C)

; Temperature thresholds
temp_warning:               db 75       ; Warning threshold
temp_critical:              db 85       ; Critical threshold
temp_shutdown:              db 90       ; Shutdown threshold

; Fan control
fan_pwm_duty:               db 50       ; PWM duty cycle (0-100%)
fan_rpm:                    dw 2500     ; Current fan RPM

; Thermal throttling
throttle_enabled:           db 1        ; Thermal throttling enabled
throttle_factor:            db 100      ; Throttle factor (100 = full speed)

; ============================================================================
; INTERRUPT CONTROLLER
; ============================================================================

; PIC (Programmable Interrupt Controller) registers
pic_master_cmd:             db 0x20     ; Master PIC command port
pic_master_data:            db 0x21     ; Master PIC data port
pic_slave_cmd:              db 0xA0     ; Slave PIC command port
pic_slave_data:             db 0xA1     ; Slave PIC data port

; PIC interrupt masks
pic_master_imr:             db 0xFF     ; Master interrupt mask (all masked)
pic_slave_imr:              db 0xFF     ; Slave interrupt mask (all masked)

; IRQ settings
irq_routing_table:
    db 0x00, 0x01, 0x02, 0x03          ; IRQ0-3
    db 0x04, 0x05, 0x06, 0x07          ; IRQ4-7
    db 0x08, 0x09, 0x0A, 0x0B          ; IRQ8-11
    db 0x0C, 0x0D, 0x0E, 0x0F          ; IRQ12-15

; ISR (In-Service Register)
isr_register_master:        db 0
isr_register_slave:         db 0

; ============================================================================
; DMA CONTROLLER
; ============================================================================

; DMA channel parameters (8 channels)
dma_channel_address:        dd 8 dup(0) ; Base addresses for each channel
dma_channel_count:          dw 8 dup(0) ; Byte counts for each channel
dma_channel_mode:           db 8 dup(0) ; Transfer mode for each channel

; DMA control register
dma_command_register:       db 0x00     ; DMA command
dma_status_register:        db 0x00     ; DMA status

; DMA modes
DMA_MODE_VERIFY             equ 0x00
DMA_MODE_WRITE              equ 0x01
DMA_MODE_READ               equ 0x02
DMA_MODE_CASCADED           equ 0x03

; ============================================================================
; I/O PORT CONFIGURATION
; ============================================================================

; Port configuration table (256 ports)
io_port_type:               db 256 dup(0)   ; Port type (0=unused, 1=I/O, 2=mem)
io_port_function:          db 256 dup(0)   ; Port function designation
io_port_access_count:       dd 256 dup(0)   ; Access counter for each port

; Port types
PORT_TYPE_UNUSED            equ 0x00
PORT_TYPE_PARALLEL          equ 0x01
PORT_TYPE_SERIAL            equ 0x02
PORT_TYPE_FLOPPY            equ 0x03
PORT_TYPE_HARD_DRIVE        equ 0x04
PORT_TYPE_TIMER             equ 0x05
PORT_TYPE_KEYBOARD          equ 0x06
PORT_TYPE_DISPLAY           equ 0x07
PORT_TYPE_SPEAKER           equ 0x08

; ============================================================================
; SYSTEM TIME & CLOCK
; ============================================================================

; Real-time clock (RTC) state
rtc_register_a:             db 0x26     ; Rate selection, divider chain
rtc_register_b:             db 0x02     ; 24-hour format
rtc_register_c:             db 0x00     ; Interrupt flags
rtc_register_d:             db 0x80     ; Valid RTC bit

; System time (GMT in seconds since 1970)
system_time_unix:           dd 1741968000   ; Seconds since Unix epoch

; CPU frequency / performance counter
cpu_frequency_mhz:          dw 3072     ; 3.072 MHz (Altair 8800 speed)
performance_counter:        dq 0        ; Cycle counter

; Bus speed
system_bus_speed_khz:       dw 3072     ; System bus speed in kHz

; ============================================================================
; MEMORY CONTROLLER
; ============================================================================

; Memory configuration
memory_banks:               db 4        ; Number of memory banks
memory_bank_size:           dw 4 dup(16384)  ; Size of each bank (64KB total)
memory_bank_enabled:        db 4 dup(1)      ; Enable status of each bank

; Memory error detection
ecc_enabled:                db 0        ; ECC (Error Correcting Code)
parity_enabled:             db 0        ; Parity check
memory_test_pattern:        dd 0xAAAAAAAA, 0x55555555

; Memory address translation
memory_page_size:           dw 4096     ; Page size in bytes
memory_pages:               dw 16       ; Number of pages (64KB / 4KB)

; ============================================================================
; BUS CONTROL
; ============================================================================

; ISA Bus parameters (Industry Standard Architecture)
bus_clock_divisor:          db 1        ; Divisor from CPU clock
bus_frequency_mhz:          dw 8        ; ISA bus frequency
bus_arbitration_mode:       db 0        ; Bus arbitration scheme

; Bus status
bus_grant:                  db 0x00     ; Bus grant control
bus_request:                db 0x00     ; Bus request status
bus_busy:                   db 0x00     ; Bus busy flag

; ============================================================================
; CHIPSET CONFIGURATION
; ============================================================================

; Chipset identification
chipset_vendor:             db "INTEL", 0
chipset_model:              db "8086", 0
chipset_revision:           db 0x01     ; Revision level

; Chipset features
feature_cache:              db 1        ; L1 cache available
feature_floating_point:     db 0        ; FPU available
feature_mmu:                db 0        ; MMU available
feature_paging:             db 0        ; Paging support

; Chipset configuration registers (simulated)
chipset_config_0:           db 0
chipset_config_1:           db 0
chipset_config_2:           db 0
chipset_config_3:           db 0

; ============================================================================
; DEVICE DRIVERS
; ============================================================================

; Driver table (max 16 drivers)
driver_count:               db 0
driver_names:
    db "KEYBOARD", 0
    db "DISPLAY", 0
    db "FLOPPY", 0
    db "SERIAL", 0
    db "PARALLEL", 0
    db "TIMER", 0
    db "SOUND", 0
    db "PRINTER", 0
    db 0

; Driver status
driver_installed:           db 8 dup(0) ; 1 = installed, 0 = not installed
driver_enabled:             db 8 dup(0) ; 1 = enabled, 0 = disabled
driver_vector:              dd 8 dup(0) ; Driver entry points

; ============================================================================
; KEYBOARD CONTROLLER
; ============================================================================

; Keyboard parameters
keyboard_layout_id:         db 0        ; 0 = US, 1 = UK, 2 = DE, etc.
keyboard_type:              db 0        ; 0 = XT, 1 = AT, 2 = PS/2
keyboard_repeat_rate:       db 0x20     ; Repeat rate (20-30 chars/sec typical)
keyboard_repeat_delay:      db 0x06     ; Delay before repeat (250-1000ms)

; Keyboard status
keyboard_buffer_head:       db 0        ; Keyboard buffer head pointer
keyboard_buffer_tail:       db 0        ; Keyboard buffer tail pointer
keyboard_buffer:            db 32 dup(0)    ; Keyboard buffer (32 bytes)

; Keyboard LED status
keyboard_numlock_led:       db 0
keyboard_capslock_led:      db 0
keyboard_scrolllock_led:    db 0

; ============================================================================
; DISPLAY/VIDEO CONTROLLER
; ============================================================================

; Display mode
display_mode_current:       db 0        ; Current display mode
display_columns:            db 80       ; Text columns
display_rows:               db 25       ; Text rows
display_colors:             db 16       ; Number of colors

; Display adapter type
display_adapter_type:       db 0        ; 0=MDA, 1=CGA, 2=EGA, 3=VGA
display_adapter_memory_kb:  dw 4        ; Video memory (4KB for MDA)

; Cursor position
cursor_column:              db 0
cursor_row:                 db 0
cursor_start_scanline:      db 0x0B     ; Starting scanline for cursor
cursor_end_scanline:        db 0x0C     ; Ending scanline for cursor

; Display parameters
display_brightness:        db 100      ; Brightness (0-255)
display_contrast:          db 100      ; Contrast (0-255)

; ============================================================================
; SERIAL PORT CONFIGURATION
; ============================================================================

; Serial port parameters
serial_baud_rate:           dw 9600     ; Baud rate
serial_data_bits:           db 8        ; Data bits (7 or 8)
serial_parity:              db 0        ; 0=None, 1=Odd, 2=Even
serial_stop_bits:           db 1        ; Stop bits (1 or 2)

; Serial port status
serial_status:              db 0        ; Status flags
serial_control:             db 0        ; Control register
serial_int_enable:          db 0x00     ; Interrupt enable flags

; Serial buffers
serial_tx_buffer:           db 256 dup(0)   ; Transmit buffer
serial_rx_buffer:           db 256 dup(0)   ; Receive buffer
serial_tx_head:             db 0
serial_tx_tail:             db 0
serial_rx_head:             db 0
serial_rx_tail:             db 0

; ============================================================================
; PARALLEL PORT CONFIGURATION
; ============================================================================

; Parallel port parameters
parallel_mode:              db 0        ; 0=Centronics, 1=EPP, 2=ECP
parallel_base_address:      dw 0x378    ; Base I/O address

; Parallel port status
parallel_status:            db 0
parallel_control:           db 0x04     ; Initialize signal

; Parallel data register
parallel_data:              db 0

; ============================================================================
; FLOPPY DRIVE CONTROLLER
; ============================================================================

; Floppy drive configuration
floppy_drive_a_type:        db 1        ; 0=none, 1=360K, 2=1.2M, 3=1.44M
floppy_drive_b_type:        db 0        ; Second drive type
floppy_drive_count:         db 1        ; Number of floppy drives

; Floppy controller status
floppy_status_register:     db 0
floppy_data_register:       db 0
floppy_int_status:          db 0

; Floppy motor status
floppy_motor_on:            db 0        ; Motor on flag
floppy_motor_timeout:       dd 0        ; Motor timeout counter

; ============================================================================
; HARD DRIVE CONTROLLER
; ============================================================================

; Hard drive configuration
hard_drive_count:           db 0        ; Number of hard drives
hard_drive_0_type:          db 0        ; Drive 0 type code
hard_drive_1_type:          db 0        ; Drive 1 type code

; Drive geometry
drive_cylinders:            dw 256      ; Number of cylinders
drive_heads:                db 4        ; Number of heads
drive_sectors_per_track:    db 17       ; Sectors per track

; Hard drive status
hard_drive_status:          db 0
hard_drive_error:           db 0

; ============================================================================
; SYSTEM BOOT OPTIONS
; ============================================================================

; Boot sequence
boot_order:
    db 0x02                 ; First: ROM
    db 0x00                 ; Second: Floppy
    db 0x01                 ; Third: Hard drive
    db 0xFF                 ; End of list

; Boot flags
boot_from_network_enabled:  db 0
boot_from_usb_enabled:      db 0
boot_verbose_mode:          db 0        ; Show detailed boot info
boot_quick_boot:            db 1        ; Skip full POST

; Boot last known device
boot_last_device:           db 0x01     ; Device code

; ============================================================================
; ADVANCED CONFIGURATION OPTIONS
; ============================================================================

; CPU configuration
cpu_turbo_mode:             db 0        ; Turbo mode enable (non-functional)
cpu_cache_enabled:          db 0        ; L1 cache enable
cpu_multiplier:             db 1        ; CPU multiplier (1x for 8086)

; Memory configuration
memory_interleaving:        db 0        ; Memory interleaving mode
memory_shadowing:           db 0        ; ROM shadowing enable

; Security settings
security_password_set:      db 0        ; Password protection flag
security_hard_drive_lock:   db 0        ; Hard drive lock
security_bios_lock:         db 0        ; BIOS modification lock

; Network boot
network_boot_enabled:       db 0
network_boot_address:       dd 0        ; Network boot server

; ============================================================================
; SYSTEM INFORMATION STRINGS
; ============================================================================

system_manufacturer:        db "ALTAIR", 0
system_product_name:        db "Altair 8800 Emulator", 0
system_version:             db "1.0", 0
system_serial_number:       db "ALT-2026-0001", 0
system_uuid:                db "550E8400-E29B-41D4-A716-446655440000", 0

bios_vendor:                db "Altair BIOS Corporation", 0
bios_version:               db "1.0.0", 0
bios_release_date:          db "03/04/2026", 0

; ============================================================================
; CONFIGURATION MANAGEMENT FUNCTIONS
; ============================================================================

.code

; Save all system configuration to CMOS
save_all_config:
    push rbp
    mov rbp, rsp
    
    ; Save power settings
    mov al, [current_power_mode]
    ; Store in CMOS
    
    ; Save thermal settings
    mov al, [cpu_temperature]
    ; Store in CMOS
    
    ; Save device configuration
    mov al, [driver_count]
    ; Store in CMOS
    
    pop rbp
    ret

; Load all system configuration from CMOS
load_all_config:
    push rbp
    mov rbp, rsp
    
    ; Load power settings
    ; from CMOS
    
    ; Load thermal settings
    ; from CMOS
    
    ; Load device configuration
    ; from CMOS
    
    pop rbp
    ret

; Reset all settings to factory defaults
reset_to_defaults:
    push rbp
    mov rbp, rsp
    
    ; Reset power management
    mov byte ptr [current_power_mode], power_mode_full
    mov word ptr [power_consumption_watts], 100
    
    ; Reset thermal settings
    mov byte ptr [cpu_temperature], 55
    mov byte ptr [fan_pwm_duty], 50
    
    ; Reset all driver states
    mov ecx, 8
    lea rdi, [driver_enabled]
    xor al, al
    rep stosb
    
    pop rbp
    ret

; ============================================================================
; POWER MANAGEMENT FUNCTIONS
; ============================================================================

; Enter sleep mode
enter_sleep_mode:
    push rbp
    mov rbp, rsp
    
    mov byte ptr [current_power_mode], power_mode_sleep
    
    ; Reduce CPU speed
    mov byte ptr [throttle_factor], 25
    
    ; Reduce fan speed
    mov byte ptr [fan_pwm_duty], 30
    
    pop rbp
    ret

; Exit sleep mode (wake)
exit_sleep_mode:
    push rbp
    mov rbp, rsp
    
    mov byte ptr [current_power_mode], power_mode_full
    
    ; Restore CPU speed
    mov byte ptr [throttle_factor], 100
    
    ; Restore fan speed
    mov byte ptr [fan_pwm_duty], 50
    
    pop rbp
    ret

; Check battery status
check_battery_status:
    ; Returns battery percentage in AL
    mov al, [battery_charge_percent]
    ret

; ============================================================================
; THERMAL MANAGEMENT FUNCTIONS
; ============================================================================

; Adjust fan speed based on temperature
adjust_fan_speed:
    push rbp
    mov rbp, rsp
    
    mov al, [cpu_temperature]
    
    cmp al, 65
    jle fan_speed_low
    cmp al, 75
    jle fan_speed_medium
    cmp al, 85
    jle fan_speed_high
    
    ; Critical - max speed
    mov byte ptr [fan_pwm_duty], 100
    jmp fan_speed_done
    
fan_speed_high:
    mov byte ptr [fan_pwm_duty], 80
    jmp fan_speed_done
    
fan_speed_medium:
    mov byte ptr [fan_pwm_duty], 50
    jmp fan_speed_done
    
fan_speed_low:
    mov byte ptr [fan_pwm_duty], 25
    
fan_speed_done:
    pop rbp
    ret

; ============================================================================
; INTERRUPT CONTROLLER SETUP
; ============================================================================

; Initialize PIC (Programmable Interrupt Controller)
init_pic:
    push rbp
    mov rbp, rsp
    
    ; Send ICW1 - Initialize command
    mov al, 0x11            ; ICW1: edge triggered, single, ICW4 needed
    ; out [pic_master_cmd], al
    
    ; Send ICW2 - Interrupt vector offset
    mov al, 0x20            ; Master PIC vectors start at 0x20
    ; out [pic_master_data], al
    
    ; Send ICW3 - Slave PIC configuration
    mov al, 0x04            ; Slave PIC on IRQ2
    ; out [pic_master_data], al
    
    ; Send ICW4 - 8086 mode
    mov al, 0x01            ; 8086 mode
    ; out [pic_master_data], al
    
    ; Enable all interrupts initially
    mov byte ptr [pic_master_imr], 0x00
    ; out [pic_master_data], al
    
    pop rbp
    ret

; Mask specific IRQ
mask_irq:
    ; AL = IRQ number
    push rbp
    mov rbp, rsp
    
    mov ecx, eax
    mov al, 1
    shl al, cl
    or [pic_master_imr], al
    
    pop rbp
    ret

; Unmask specific IRQ
unmask_irq:
    ; AL = IRQ number
    push rbp
    mov rbp, rsp
    
    mov ecx, eax
    mov al, 1
    shl al, cl
    not al
    and [pic_master_imr], al
    
    pop rbp
    ret

; ============================================================================
; MEMORY CONTROLLER FUNCTIONS
; ============================================================================

; Get total memory
get_total_memory:
    ; Returns total memory in bytes in RAX
    mov rax, 0x10000        ; 64KB for Altair 8800
    ret

; Get available memory
get_available_memory:
    ; Returns available memory in bytes in RAX
    mov rax, 0x0E000        ; 56KB (excluding ROM and CMOS)
    ret

; ============================================================================
; TIME/CLOCK FUNCTIONS
; ============================================================================

; Get system clock speed
get_system_clock_mhz:
    ; Returns clock speed in MHz in AX
    mov ax, [cpu_frequency_mhz]
    ret

; Get performance counter
get_performance_counter:
    ; Returns performance counter in RAX
    mov rax, [performance_counter]
    ret

; ============================================================================
; END OF ADVANCED COMPONENTS
; ============================================================================

end
