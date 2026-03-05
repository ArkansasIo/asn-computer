; SYSTEM COMPONENTS - ADVANCED FEATURES
; x86-64 Assembly for Windows (MASM)
; Power management, thermal control, DMA, interrupt controller, devices
; ~950 lines

option casemap:none

.data
; Power Management Modes
POWER_ON        equ 0
POWER_STANDBY   equ 1
POWER_SLEEP     equ 2
POWER_SHUTDOWN  equ 3

powerState      db POWER_ON
powerConsumption dw 0    ; in watts

; Thermal Management
cpuTemp         db 45   ; degrees Celsius
cpuTempMax      db 85   ; temperature limit
cpuFanSpeed     db 0    ; fan speed 0-100%
fanAutoMode     db 1    ; automatic fan control
sensorCount     db 3    ; number of thermal sensors

; Thermal Sensors
sensor1Temp     db 45   ; CPU core
sensor2Temp     db 42   ; System
sensor3Temp     db 38   ; Chipset

; Interrupt Controller (PIC)
masterICW1      db 0x11 ; initialization word 1
masterICW4      db 0x01
slaveICW1       db 0x11
slaveICW4       db 0x01
masterOCW1      db 0x00 ; operation control word
slaveOCW1       db 0x00
interruptMask   dw 0    ; 16 interrupts

; DMA Controller (8237 style)
dmaChannels     equ 8
dmaChannel0Addr dw 0x0000
dmaChannel0Cnt  dw 0
dmaChannel1Addr dw 0x0000
dmaChannel1Cnt  dw 0
dmaChannel2Addr dw 0x0000
dmaChannel2Cnt  dw 0
dmaChannel3Addr dw 0x0000
dmaChannel3Cnt  dw 0
dmaStatus       db 0    ; DMA status byte

; Device Drivers (8 devices)
device1Type     db 0x01 ; serial port
device1Status   db 0x01 ; enabled
device2Type     db 0x02 ; parallel port
device2Status   db 0x01 ; enabled
device3Type     db 0x03 ; disk drive
device3Status   db 0x01 ; enabled
device4Type     db 0x04 ; keyboard
device4Status   db 0x01 ; enabled
device5Type     db 0x05 ; mouse
device5Status   db 0x00 ; disabled
device6Type     db 0x06 ; tape drive
device6Status   db 0x00 ; disabled
device7Type     db 0x07 ; scanner
device7Status   db 0x00 ; disabled
device8Type     db 0x08 ; printer
device8Status   db 0x00 ; disabled

; I/O Port Status
activeIOPorts   dw 0

; Timer Frequency
timerFreq       dw 1193180  ; standard PC timer frequency (Hz)
timerDiv        dw 1
timerCount      dw 0

; Messages
powerMsg        db "Power State: ",0
onMsg           db "ON",13,10,0
standbyMsg      db "STANDBY",13,10,0
sleepMsg        db "SLEEP",13,10,0
shutdownMsg     db "SHUTDOWN",13,10,0
tempMsg         db "CPU Temp: ",0
fanMsg          db "Fan Speed: ",0
dmaPendingMsg   db "DMA Transfer Pending",13,10,0
intMsg          db "Interrupts Enabled",13,10,0

.code

; ============================================================================
; POWER MANAGEMENT
; ============================================================================

set_power_state PROC
    ; RCX = power state (0-3)
    cmp rcx, 3
    ja power_err
    
    mov byte ptr [powerState], cl
    
    ; Adjust power consumption based on state
    cmp cl, POWER_ON
    je power_set_full
    cmp cl, POWER_STANDBY
    je power_set_standby
    cmp cl, POWER_SLEEP
    je power_set_sleep
    
    xor ax, ax
    jmp power_set_end
    
power_set_full:
    mov ax, 150         ; 150W
    jmp power_set_end
power_set_standby:
    mov ax, 40          ; 40W
    jmp power_set_end
power_set_sleep:
    mov ax, 10          ; 10W
    
power_set_end:
    mov [powerConsumption], ax
    ret
    
power_err:
    ret
set_power_state ENDP

get_power_state PROC
    mov al, [powerState]
    ret
get_power_state ENDP

get_power_consumption PROC
    mov ax, [powerConsumption]
    ret
get_power_consumption ENDP

; ============================================================================
; THERMAL MANAGEMENT
; ============================================================================

read_thermal_sensor PROC
    ; RCX = sensor number (0-2)
    ; Returns temperature in AL
    
    cmp rcx, 0
    je read_sensor_cpu
    cmp rcx, 1
    je read_sensor_sys
    cmp rcx, 2
    je read_sensor_chip
    
    xor al, al
    ret
    
read_sensor_cpu:
    mov al, [sensor1Temp]
    ret
read_sensor_sys:
    mov al, [sensor2Temp]
    ret
read_sensor_chip:
    mov al, [sensor3Temp]
    ret
read_thermal_sensor ENDP

update_thermal_readings PROC
    ; Simulate temperature changes
    mov al, [sensor1Temp]
    add al, 1
    cmp al, 85
    jl store_cpu_temp
    mov al, 85
    
store_cpu_temp:
    mov [sensor1Temp], al
    mov [cpuTemp], al
    
    ; Update other sensors
    mov al, [sensor2Temp]
    add al, 1
    cmp al, 80
    jl store_sys_temp
    mov al, 80
    
store_sys_temp:
    mov [sensor2Temp], al
    
    ret
update_thermal_readings ENDP

set_fan_speed PROC
    ; RCX = fan speed (0-100%)
    
    cmp rcx, 100
    ja fan_error
    
    mov byte ptr [cpuFanSpeed], cl
    ret
    
fan_error:
    ret
set_fan_speed ENDP

get_fan_speed PROC
    mov al, [cpuFanSpeed]
    ret
get_fan_speed ENDP

enable_auto_fan PROC
    ; Enable automatic fan control
    mov byte ptr [fanAutoMode], 1
    ret
enable_auto_fan ENDP

auto_adjust_fan PROC
    ; Automatically adjust fan based on temperature
    
    mov al, [cpuTemp]
    
    ; If < 50C, set fan to 20%
    cmp al, 50
    jge temp_50
    mov cl, 20
    call set_fan_speed
    ret
    
temp_50:
    ; If < 65C, set fan to 50%
    cmp al, 65
    jge temp_65
    mov cl, 50
    call set_fan_speed
    ret
    
temp_65:
    ; If < 80C, set fan to 75%
    cmp al, 80
    jge temp_80
    mov cl, 75
    call set_fan_speed
    ret
    
temp_80:
    ; If >= 80C, full speed
    mov cl, 100
    call set_fan_speed
    ret
auto_adjust_fan ENDP

; ============================================================================
; INTERRUPT CONTROLLER (PIC)
; ============================================================================

init_pic PROC
    ; Initialize Programmable Interrupt Controller
    
    ; Master PIC initialization
    mov al, [masterICW1]
    ; mov port 0x20, al       ; would be actual I/O
    
    mov al, 0x08
    ; mov port 0x21, al       ; interrupt vector base
    
    mov al, 0x04
    ; mov port 0x21, al       ; slave on IRQ 2
    
    mov al, [masterICW4]
    ; mov port 0x21, al       ; ICW4
    
    mov al, 0x00
    mov [masterOCW1], al    ; unmask all interrupts
    
    ret
init_pic ENDP

set_interrupt_mask PROC
    ; RCX = interrupt number (0-15)
    ; Set interrupt mask bit
    
    cmp rcx, 15
    ja mask_err
    
    mov rax, 1
    shl rax, cl
    or [interruptMask], rax
    
mask_err:
    ret
set_interrupt_mask ENDP

clear_interrupt_mask PROC
    ; RCX = interrupt number (0-15)
    ; Clear interrupt mask bit
    
    cmp rcx, 15
    ja mask_err2
    
    mov rax, 1
    shl rax, cl
    not rax
    and [interruptMask], rax
    ret
    
mask_err2:
    ret
clear_interrupt_mask ENDP

; ============================================================================
; DMA CONTROLLER
; ============================================================================

init_dma PROC
    ; Initialize DMA controller
    
    xor rcx, rcx
dma_clear:
    cmp rcx, dmaChannels
    jge dma_clear_done
    
    ; Clear channel addresses and counts
    mov word ptr [dmaChannel0Addr], 0x0000
    mov word ptr [dmaChannel0Cnt], 0x0000
    
    inc rcx
    jmp dma_clear
    
dma_clear_done:
    ret
init_dma ENDP

setup_dma_transfer PROC
    ; RCX = channel (0-3)
    ; RDX = source address
    ; R8 = transfer count
    
    cmp rcx, 3
    ja dma_err
    
    ; Set up channel
    mov eax, edx
    mov [dmaChannel0Addr], ax
    mov [dmaChannel0Cnt], r8w
    
    ret
dma_err:
    ret
setup_dma_transfer ENDP

start_dma_transfer PROC
    ; Start DMA transfer on current channel
    mov byte ptr [dmaStatus], 0x80  ; transfer in progress
    ret
start_dma_transfer ENDP

; ============================================================================
; DEVICE DRIVERS
; ============================================================================

init_serial_port PROC
    ; Initialize serial port device
    mov byte ptr [device1Status], 1
    ret
init_serial_port ENDP

init_parallel_port PROC
    ; Initialize parallel port device
    mov byte ptr [device2Status], 1
    ret
init_parallel_port ENDP

init_disk_drive PROC
    ; Initialize disk drive device
    mov byte ptr [device3Status], 1
    ret
init_disk_drive ENDP

init_keyboard PROC
    ; Initialize keyboard device
    mov byte ptr [device4Status], 1
    ret
init_keyboard ENDP

get_device_status PROC
    ; RCX = device number (1-8)
    ; Returns status in AL
    
    cmp rcx, 1
    je get_dev1
    cmp rcx, 2
    je get_dev2
    cmp rcx, 3
    je get_dev3
    cmp rcx, 4
    je get_dev4
    cmp rcx, 5
    je get_dev5
    cmp rcx, 6
    je get_dev6
    cmp rcx, 7
    je get_dev7
    cmp rcx, 8
    je get_dev8
    
    xor al, al
    ret
    
get_dev1:
    mov al, [device1Status]
    ret
get_dev2:
    mov al, [device2Status]
    ret
get_dev3:
    mov al, [device3Status]
    ret
get_dev4:
    mov al, [device4Status]
    ret
get_dev5:
    mov al, [device5Status]
    ret
get_dev6:
    mov al, [device6Status]
    ret
get_dev7:
    mov al, [device7Status]
    ret
get_dev8:
    mov al, [device8Status]
    ret
get_device_status ENDP

; ============================================================================
; I/O PORT MANAGEMENT
; ============================================================================

register_io_port PROC
    ; RCX = port address
    ; Register port in use
    or [activeIOPorts], rcx
    ret
register_io_port ENDP

unregister_io_port PROC
    ; RCX = port address
    ; Unregister port
    not rcx
    and [activeIOPorts], rcx
    ret
unregister_io_port ENDP

; ============================================================================
; TIMER MANAGEMENT
; ============================================================================

set_timer_divisor PROC
    ; RCX = divisor
    ; Set timer frequency divisor
    mov [timerDiv], cx
    ret
set_timer_divisor ENDP

get_timer_frequency PROC
    ; Returns timer frequency in RAX
    mov ax, [timerFreq]
    mov cx, [timerDiv]
    xor edx, edx
    div ecx
    ret
get_timer_frequency ENDP

; ============================================================================
; SYSTEM STATUS
; ============================================================================

get_system_status PROC
    ; Returns system status byte in AL
    
    xor al, al
    
    ; Bit 0: Power on
    mov cl, [powerState]
    cmp cl, POWER_ON
    jne skip_power_bit
    or al, 0x01
    
skip_power_bit:
    ; Bit 1: Thermal alert
    mov cl, [cpuTemp]
    cmp cl, 80
    jl skip_thermal_bit
    or al, 0x02
    
skip_thermal_bit:
    ; Bit 2: DMA in progress
    mov cl, [dmaStatus]
    and cl, 0x80
    jz skip_dma_bit
    or al, 0x04
    
skip_dma_bit:
    ret
get_system_status ENDP

END
