# ALTAIR 8800 SYSTEM COMPONENTS - COMPREHENSIVE DOCUMENTATION

## Overview

The emulator now includes complete implementations of:
- **BIOS** (Basic Input/Output System)
- **CMOS** (Complementary Metal-Oxide-Semiconductor) memory
- **ROM** (Read-Only Memory)
- **RAM** (Random Access Memory) organization
- **Power Management System**
- **Interrupt Controller**
- **Thermal Management**
- **DMA Controller**
- **Device Drivers**
- **Interactive Setup Utility**

---

## System Memory Layout

```
Memory Map (64 KB Total):
┌─────────────────┬─────────┐
│ ROM (8 KB)      │ 0x0000  │  BIOS code, bootloader, fonts
│ 0x0000-0x1FFF   │         │
├─────────────────┼─────────┤
│ RAM (56 KB)     │ 0x2000  │  Programs, data, stack
│ 0x2000-0xDFFF   │         │
├─────────────────┼─────────┤
│ CMOS (2 KB)     │ 0xF800  │  Configuration storage
│ 0xF800-0xFFFF   │         │
└─────────────────┴─────────┘
```

---

## ROM - READ-ONLY MEMORY (8 KB)

### Purpose
Permanent storage of system firmware and boot code.

### Contents

**Signature & Version** (16 bytes)
```
Offset 0x0000: "ALTAIR8800BIOS"
Offset 0x000E: Version 1.0
Offset 0x0010: Build date (20260304)
```

**Entry Point Table** (16 bytes)
```
0x0000-0x0001: BIOS startup address
0x0002-0x0003: POST (Power-On Self Test) address
0x0004-0x0005: Boot loader address
0x0006-0x0007: Interrupt vector table
0x0008-0x0009: Speaker control (low)
0x000A-0x000B: Speaker control (high)
0x000C-0x000D: Disk I/O (INT 18h)
0x000E-0x000F: Video I/O (INT 10h)
0x0010-0x0011: Keyboard I/O (INT 16h)
```

**Font Data** (256 bytes)
```
Character bitmap fonts (5x7 pixels per character)
```

**ROM Subroutines**
```
- read_disk: Disk read operations
- write_disk: Disk write operations
- read_kbd: Keyboard input
- write_screen: Screen output
```

---

## CMOS - NON-VOLATILE MEMORY (2 KB)

### Purpose
Permanent storage of system configuration that persists across power cycles.

### CMOS Memory Map

**Real-Time Clock (RTC) - Bytes 0x00-0x0D**

```
Address | Register              | Purpose
--------|----------------------|----------------------------------
0x00    | Seconds              | Current seconds (0-59)
0x01    | Seconds Alarm        | Alarm seconds
0x02    | Minutes              | Current minutes (0-59)
0x03    | Minutes Alarm        | Alarm minutes
0x04    | Hours                | Current hours (0-23, 24-hour format)
0x05    | Hours Alarm          | Alarm hours
0x06    | Day of Week          | 1=Sunday, 2=Monday, ..., 7=Saturday
0x07    | Day of Month         | Date (1-31)
0x08    | Month                | Month (1-12)
0x09    | Year                 | Year (00-99, 26=2026)
0x0A    | Status Register A    | Rate selection (0x26 = 1024 Hz)
0x0B    | Status Register B    | Control flags (0x02 = 24-hour format)
0x0C    | Status Register C    | Interrupt flags
0x0D    | Status Register D    | Valid RTC indicator (0x80 = valid)
```

**System Configuration - Bytes 0x10-0x1F**

```
Address | Register              | Purpose
--------|----------------------|----------------------------------
0x10    | Boot Device 1        | Primary boot device (0=ROM, 1=Floppy, 2=Hard)
0x11    | Boot Device 2        | Secondary boot device
0x12    | Boot Device 3        | Tertiary boot device
0x13    | System Features      | Feature flags
0x14    | Extended Config      | Extended features
0x15    | Base Memory Low      | Memory size low byte
0x16    | Base Memory High     | Memory size high byte
0x17    | Diagnostics Status   | POST results
0x18    | POST Result Code     | Self-test result code
0x19    | Display Type         | 0=Color (EGA), 1=Monochrome (MDA)
0x1A    | Hard Drive 0 Type    | Drive type code
0x1B    | Hard Drive 1 Type    | Drive type code
0x1C    | Parallel Ports       | Number of parallel ports
0x1D    | Serial Ports         | Number of serial ports
0x1E    | Keyboard Layout      | 0=US, 1=UK, 2=German, etc.
0x1F    | Keyboard Repeat      | Repeat rate (0x20 = 20 chars/sec)
```

**Device Configuration - Bytes 0x20-0x2D**

```
Address | Register              | Purpose
--------|----------------------|----------------------------------
0x20    | Floppy A Type        | 0=None, 1=360K, 2=1.2M, 3=1.44M
0x21    | Floppy B Type        | Second floppy drive type
0x22    | Feature Set 1        | Extended features 1
0x23    | Feature Set 2        | Extended features 2
0x24    | CPU Clock Multiplier | CPU speed control
0x25-0x2D | Reserved            | Reserved for future use
```

**Checksum - Bytes 0x2E-0x2F**

```
Address | Register              | Purpose
--------|----------------------|----------------------------------
0x2E    | Checksum High        | High byte of CRC16 checksum
0x2F    | Checksum Low         | Low byte of CRC16 checksum
```

**Extended CMOS - Bytes 0x30+**

```
Address | Register              | Purpose
--------|----------------------|----------------------------------
0x30    | Extended Flags       | Feature flags
0x31    | Power Management     | Power management settings
0x32    | Temperature Monitor  | Temperature monitoring enable
0x33    | Fan Control          | Fan control settings
0x34-0x37 | CPU Frequency      | CPU frequency in Hz (32-bit)
0x38-0x3B | PCI IRQ Routing    | PCI interrupt routing
0x3C    | ACPI Settings        | ACPI enable/configuration
```

---

## RAM - RANDOM ACCESS MEMORY (56 KB)

### Purpose
Dynamic storage for programs, data, and runtime operations.

### Memory Organization

**Interrupt Vector Table** (256 bytes, 0x0000-0x00FF)
```
Each interrupt has a 2-byte vector (offset into ROM/RAM)
Supports 256 interrupt types (0x00-0xFF)
```

**System Work Area** (256 bytes, 0x0100-0x01FF)
```
Global variables
System state variables
Temporary storage
```

**Memory Allocation Table** (128 bytes, 0x0200-0x027F)
```
Bitmap for tracking allocated/free memory blocks
```

**User Program Area** (Variable, 0x0800+)
```
Where user programs are loaded
Typically grows upward from 0x0800
```

**Stack** (Variable, grows downward)
```
Starts near top of memory
Grows downward toward program code
```

---

## BIOS - BASIC INPUT/OUTPUT SYSTEM

### BIOS Functions

#### 1. Initialization (`bios_startup`)
- Clears interrupt vector table
- Sets up interrupt vectors
- Initializes CMOS with defaults
- Updates system time
- Increments boot counter
- Displays startup messages
- Runs Power-On Self Test (POST)
- Loads boot code

#### 2. Interrupt Vector Setup (`setup_interrupt_vectors`)
- Maps interrupt handlers:
  - INT 0x00: Divide by zero
  - INT 0x0E: Page fault
  - INT 0x10: Video services
  - INT 0x13: Disk I/O
  - INT 0x16: Keyboard I/O

#### 3. CMOS Initialization (`initialize_cmos`)
- Sets RTC to default: 00:00:00, 01/01/2026
- Sets status registers
- Calculates and stores CMOS checksum
- Sets STATUS_CMOS_OK flag

#### 4. System Time Update (`update_system_time`)
- Reads current time
- Updates system uptime counter
- Available for timer interrupts

#### 5. Power-On Self Test (`run_post`)
Tests system components:
- **CPU Test**: Arithmetic operations verification
- **RAM Test**: Pattern write/read verification (1 KB)
- **ROM Test**: Signature verification
- **Keyboard Test**: Controller detection
- **Display Test**: Video card detection

#### 6. Boot Code Loading (`load_boot_code`)
- Initializes boot sector (sector 0)
- Loads at address 0x7C00
- Prepares for OS loading

### BIOS Status Register

```
Bit | Flag              | Meaning
----|-------------------|----------------------------------
0   | STATUS_POWER_OK   | Power supply OK
1   | STATUS_CPU_OK     | CPU functional
2   | STATUS_RAM_OK     | RAM test passed
3   | STATUS_ROM_OK     | ROM checksum valid
4   | STATUS_CMOS_OK    | CMOS initialized
```

---

## POWER MANAGEMENT SYSTEM

### Power States

**Mode 0: Full Power**
```
Full CPU speed (100%)
All systems active
Normal fan speed
Full voltage supplies
```

**Mode 1: Sleep**
```
CPU throttled to 25%
Most systems idle
Fan speed reduced to 30%
Reduced voltage supplies
```

**Mode 2: Suspend**
```
CPU minimal power
Only CMOS RAM powered
Fan off
Minimal voltage
```

**Mode 3: Hibernate**
```
All systems powered off
CMOS RAM (battery backed)
Ultra-low power
Can resume from saved state
```

### Power Management Functions

- `enter_sleep_mode()`: Transition to sleep mode
- `exit_sleep_mode()`: Wake from sleep
- `check_battery_status()`: Battery charge level
- `adjust_fan_speed()`: Dynamic fan control

### Battery Backup

- **Type**: Backup battery for CMOS
- **Status**: Tracked in `battery_installed` (0/1)
- **Charge Level**: 0-100%
- **Low Threshold**: 20%

### Power Supply Voltage Levels

```
Nominal | Scaled | Register
--------|--------|-------------------------
+12V    | 120    | voltage_12v
+5V     | 050    | voltage_5v
-5V     | -50    | voltage_neg5v
```

---

## THERMAL MANAGEMENT

### Temperature Monitoring

Three temperature sensors track:
- CPU temperature (default: 55°C)
- Chipset temperature (default: 45°C)
- Power supply temperature (default: 40°C)

### Temperature Thresholds

```
Level       | Temperature | Action
------------|-------------|----------------------------------
Normal      | < 65°C      | Fan: 25% (low)
Moderate    | 65-75°C     | Fan: 50% (medium)
Elevated    | 75-85°C     | Fan: 80% (high)
Critical    | 85-90°C     | Fan: 100% (maximum)
Shutdown    | > 90°C      | System shutdown
```

### Fan Control

- PWM duty cycle: 0-100%
- RPM monitoring: Current speed available
- Auto/Manual modes
- Thermal throttling capability

### Thermal Throttling

When temperature exceeds warning threshold:
- CPU speed reduced by `throttle_factor`
- Frequency reduced to lower power consumption
- Can be disabled in BIOS

---

## INTERRUPT CONTROLLER (PIC)

### PIC Registers

**Master PIC (8259A)**
```
Port 0x20: Command/Status
Port 0x21: Interrupt Mask Register (IMR)
```

**Slave PIC (8259A)**
```
Port 0xA0: Command/Status
Port 0xA1: Interrupt Mask Register (IMR)
```

### IRQ Allocation

```
IRQ  | Primary Use
-----|-----------------------------------
0    | System timer
1    | Keyboard
2    | Cascade (from slave PIC)
3    | Serial port 2
4    | Serial port 1
5    | Parallel port 2
6    | Floppy disk
7    | Parallel port 1
8    | Real-time clock
9-15 | Maskable interrupts
```

### Functions

- `init_pic()`: Initialize PIC controller
- `mask_irq(AL)`: Disable IRQ
- `unmask_irq(AL)`: Enable IRQ

---

## DMA CONTROLLER

### DMA Channels (8 total)

```
Channel | Primary Use
--------|----------------------------
0       | Memory refresh / Available
1       | Audio / Modem
2       | Floppy disk
3       | Hard disk / Parallel port
4       | Cascade (from slave DMA)
5       | Sound card
6       | Tape backup
7       | RAM
```

### DMA Modes

```
Mode | Type        | Description
-----|-------------|----------------------------------
0    | Verify      | Verify transfer without data move
1    | Write       | Transfer data from I/O to memory
2    | Read        | Transfer data from memory to I/O
3    | Cascaded    | Cascade to another DMA controller
```

### DMA Functions

- `allocate_dma_channel()`: Request DMA channel
- `setup_dma_transfer()`: Configure transfer parameters
- `start_dma_transfer()`: Begin DMA operation

---

## I/O PORT CONFIGURATION

### Port Types

```
Type | Code | Examples
-----|------|-------------------------------
0    | 0x00 | Unused ports
1    | 0x01 | Parallel ports (LPT)
2    | 0x02 | Serial ports (COM)
3    | 0x03 | Floppy disk controller
4    | 0x04 | Hard disk controller
5    | 0x05 | Timer/Clock
6    | 0x06 | Keyboard controller
7    | 0x07 | Display controller
8    | 0x08 | Speaker/Audio
```

### Port Access Tracking

Each port maintains an access counter for diagnostics:
- Monitors I/O activity
- Detects port failures
- Helps identify malfunctioning devices

---

## DEVICE DRIVERS

### Supported Drivers

1. **Keyboard Driver** - Input capture and translation
2. **Display Driver** - Screen output
3. **Floppy Driver** - 5.25" diskette I/O
4. **Serial Driver** - RS-232 communication
5. **Parallel Driver** - Centronics parallel I/O
6. **Timer Driver** - System timer control
7. **Sound Driver** - Speaker control
8. **Printer Driver** - Printer output

### Driver Status

Each driver has:
- **Installed**: Whether present in system
- **Enabled**: Whether active
- **Entry Vector**: Function address for driver

---

## KEYBOARD CONTROLLER

### Keyboard Settings

```
Parameter          | Default | Range
-------------------|---------|----------------------------------
Layout             | US      | US, UK, German, etc.
Type               | XT      | XT, AT, PS/2
Repeat Rate        | 20      | 10-30 chars/second
Repeat Delay       | 250 ms  | 250-1000 milliseconds
```

### Keyboard Buffer

- Size: 32 bytes
- Head/tail pointers for FIFO operation
- Overflow protection

### Keyboard LED Status

- NumLock LED
- CapsLock LED
- ScrollLock LED

---

## DISPLAY CONTROLLER

### Display Modes

```
Mode | Type   | Adapter    | Columns | Rows | Colors
-----|--------|------------|---------|------|--------
0    | Text   | MDA        | 80      | 25   | 1
1    | Text   | CGA        | 40      | 25   | 16
2    | Text   | CGA        | 80      | 25   | 16
3    | Text   | EGA        | 80      | 25   | 16
7    | Text   | MDA        | 80      | 25   | Mono
```

### Display Parameters

- Brightness: 0-255 (100 default)
- Contrast: 0-255 (100 default)
- Cursor position (row, column)
- Video memory: 4 KB (MDA typical)

---

## SERIAL PORT CONFIGURATION

### Serial Parameters

```
Parameter      | Default | Options
----------------|---------|-----------------------------------
Baud Rate      | 9600    | 1200, 2400, 4800, 9600, 19200, 38400
Data Bits      | 8       | 7, 8
Parity         | None    | None, Odd, Even
Stop Bits      | 1       | 1, 2
Flow Control   | None    | None, Xon/Xoff, RTS/CTS
```

### Serial Buffers

- Transmit buffer: 256 bytes
- Receive buffer: 256 bytes
- Head/tail pointers for each

---

## FLOPPY DRIVE CONFIGURATION

### Floppy Types

```
Code | Capacity | Type
-----|----------|----------------------------------
0    | None     | No drive installed
1    | 360 KB   | 5.25" 360K
2    | 1.2 MB   | 5.25" 1.2MB HD
3    | 1.44 MB  | 3.5" 1.44MB
```

### Floppy Parameters

- Motor timeout: Automatic motor off
- Motor control status
- Drive type for A and B

---

## HARD DRIVE CONFIGURATION

### Hard Drive Geometry

```
Parameter              | Default | Description
----------------------|---------|----------------------------------
Cylinders             | 256     | Disk cylinders
Heads                 | 4       | Disk heads
Sectors per Track     | 17      | Sectors per track
Total Capacity        | ~17 MB  | (256 * 4 * 17 * 512)
```

---

## BIOS SETUP UTILITY

### Access Methods

- Press designated key during startup (typically `Delete`, `F2`, or `F10`)
- Enter configuration menu at boot

### Main Menu Options

1. **System Time Configuration**
   - Set hours, minutes, seconds
   - Set date (month, day, year)

2. **Boot Sequence Settings**
   - Primary boot device
   - Secondary boot device
   - Tertiary boot device
   - Boot mode (quick/full POST)

3. **Hardware Configuration**
   - Display type (Color/Mono)
   - Keyboard layout
   - Floppy drives
   - Hard drives
   - Serial port speed

4. **Power Management**
   - Sleep mode timeout
   - CPU throttling
   - Fan control
   - Display brightness
   - Hard drive standby

5. **Thermal Settings**
   - Temperature monitoring
   - Fan speed control
   - Thermal throttling

6. **Security Options**
   - BIOS password protection
   - Hard drive lock
   - Boot device lock
   - BIOS modification lock

7. **Advanced Settings**
   - CPU cache control
   - Memory interleaving
   - ROM shadowing
   - PCI IRQ routing
   - ACPI support
   - Network boot

8. **Exit Setup**
   - Save settings to CMOS
   - Return to POST/boot

### Navigation

- Use number keys (1-8) for menu selection
- Arrow keys or letter keys for options
- `ESC` to go back
- `Enter` to confirm selection

### Configuration Storage

All settings are stored in CMOS memory with checksum protection:
- Checksum calculated over bytes 0x00-0x2D
- Checksum stored at 0x2E (high) and 0x2F (low)
- Automatic validation on system startup

---

## SYSTEM INFORMATION

### Identification Strings

```
Manufacturer:   ALTAIR
Product Name:   Altair 8800 Emulator
Version:        1.0
Serial Number:  ALT-2026-0001
UUID:           550E8400-E29B-41D4-A716-446655440000
```

### BIOS Information

```
Vendor:         Altair BIOS Corporation
Version:        1.0.0
Release Date:   03/04/2026
```

---

## BOOT PROCESS

### Complete Boot Sequence

1. Power-On Self Test (POST)
   - Test CPU (arithmetic operations)
   - Test RAM (pattern write/read)
   - Test ROM (signature check)
   - Test peripherals

2. Load CMOS Settings
   - Restore system configuration
   - Verify CMOS checksum

3. Initialize Hardware
   - Setup interrupt vectors
   - Configure PIC
   - Setup DMA
   - Configure timers

4. Load Boot Device
   - Check boot order from CMOS
   - Read boot sector
   - Load bootloader

5. Run Bootloader
   - Initialize file system
   - Search for operating system
   - Load OS kernel

---

## CONFIGURATION FILE REFERENCE

### File: `bios_cmos_rom_components.asm`
- ROM definitions and storage
- CMOS memory layout and defaults
- BIOS startup routine
- Power-On Self Test
- Interrupt handlers
- Memory management

### File: `system_components_advanced.asm`
- Power management subsystem
- Thermal management
- Interrupt controller configuration
- DMA controller setup
- I/O port configuration
- Device drivers
- Serial/parallel port setup
- Floppy/hard drive configuration

### File: `bios_setup_configuration_menu.asm`
- Interactive setup utility
- Menu displays
- Configuration input/validation
- Settings storage
- Configuration menus for all subsystems

---

## API Reference

### Memory Functions
```
allocate_memory(EAX=size)       ; Allocate memory block
free_memory(EAX=address)        ; Free memory block
get_available_memory()          ; Returns available RAM size
```

### CMOS Functions
```
cmos_read_byte(AL=address)      ; Read CMOS byte
cmos_write_byte(AL=address, BL=value)  ; Write CMOS byte
save_system_config()            ; Save config to CMOS
load_default_config()           ; Load defaults
reset_cmos_defaults()           ; Factory reset
```

### Power Functions
```
enter_sleep_mode()              ; Enter sleep state
exit_sleep_mode()               ; Wake from sleep
get_power_supply_status()       ; Check PSU
check_battery_status()          ; Battery level (0-100)
```

### Thermal Functions
```
get_cpu_temperature()           ; Current CPU temp (°C)
get_fan_speed()                 ; Current RPM
adjust_fan_speed()              ; Auto fan control
```

### System Functions
```
get_system_status()             ; Status register
get_boot_count()                ; Times system booted
get_post_result()               ; POST result code
get_cpu_speed()                 ; CPU speed (0-255)
```

---

## Usage Examples

### Reading System Temperature

```assembly
call get_cpu_temperature        ; AL = temperature in Celsius
cmp al, 75
jl temp_ok
; Handle high temperature
```

### Saving Configuration

```assembly
; Update configuration values
mov byte ptr [config_cpu_speed], 200

; Save to CMOS
call save_system_config
call calculate_cmos_checksum
```

### Entering Setup Utility

```assembly
call enter_setup_utility
; User configures system through menu
; Settings saved to CMOS automatically
```

---

## Quick Reference

| Component | Purpose | Key File |
|-----------|---------|----------|
| BIOS | System firmware | bios_cmos_rom_components.asm |
| CMOS | Configuration storage | bios_cmos_rom_components.asm |
| ROM | Boot code & routines | bios_cmos_rom_components.asm |
| Power Mgmt | Power state control | system_components_advanced.asm |
| Thermal Control | Temperature monitoring | system_components_advanced.asm |
| PIC | Interrupt handling | system_components_advanced.asm |
| Setup Utility | Interactive configuration | bios_setup_configuration_menu.asm |

---

**Documentation Complete - March 4, 2026**
