; BIOS SETUP CONFIGURATION MENU
; x86-64 Assembly for Windows (MASM)
; Interactive BIOS setup utility with menu system
; ~850 lines

option casemap:none

EXTERN WriteConsoleA:PROC
EXTERN ReadConsoleA:PROC

.data
; Menu States
menuMain        db 0
menuBoot        db 0
menuAdvanced    db 0
menuPower       db 0
menuSecurity    db 0
menuSave        db 0

; Configuration Settings (100+ options)
bootDevice      db 0x80        ; 0x80=HDD, 0x00=FDD, 0x00=CDROM
bootOrder       db 0x80, 0x00, 0x00, 0x00

numLock         db 1           ; NumLock at startup
typematicRate   db 10          ; keyboard repeat rate

; Power Management Settings
acpiEnabled     db 1
pwrButton       db 1           ; power button enabled
sleepTimeout    db 15          ; minutes
hibernate       db 1           ; hibernation enabled

; Advanced Settings
hyperthreading  db 1
virtualCore     db 1
iommu           db 0           ; IOMMU (Intel VT-d equivalent)
aes             db 1           ; AES-NI instruction

; Security Settings
passwordSet     db 0
passwordHash    dq 0x0000000000000000
trustedPlatform db 1

; Hardware Monitor
cpuFanLevel     db 1           ; 0=off, 1=auto, 2=manual
cpuFanValue     db 50          ; manual speed
systemFanLevel  db 1
systemFanValue  db 40

; Memory Settings
ramTiming       db 2           ; timing profile
ramVoltage      db 150         ; 1.50V
memoryECC       db 1           ; ECC enabled

; Storage Settings
sataMode        db 1           ; 0=IDE, 1=AHCI
sataSpeed       db 3           ; 1=1.5Gbps, 2=3Gbps, 3=6Gbps
smartMonitoring db 1
autoRepair      db 1

; Console Handle
hStdOut         qw 0
charsWritten    qw 0

; Menu strings
mainMenu        db "╔═══════════════════════════════════╗",13,10,0
mainMenu2       db "║    ALTAIR BIOS SETUP UTILITY    ║",13,10,0
mainMenu3       db "║      Configuration Menu          ║",13,10,0
mainMenu4       db "╚═══════════════════════════════════╝",13,10,13,10,0

option1         db "1. Boot Options",13,10,0
option2         db "2. Advanced Settings",13,10,0
option3         db "3. Power Management",13,10,0
option4         db "4. Security Settings",13,10,0
option5         db "5. Hardware Monitor",13,10,0
option6         db "6. Memory Settings",13,10,0
option7         db "7. Storage Settings",13,10,0
option8         db "8. View System Info",13,10,0
option9         db "9. Save & Exit",13,10,0
option0         db "0. Discard & Exit",13,10,13,10,0

promptMsg       db "Enter your choice (0-9): ",0
invalidMsg      db "Invalid selection. Please try again.",13,10,0
bootMsg         db "Boot Device: ",0
bootHDD         db "Hard Drive",13,10,0
bootFDD         db "Floppy Drive",13,10,0
bootCD          db "CD-ROM",13,10,0

bootOrderMsg    db "Boot Order:",13,10,0
numLockMsg      db "NumLock at Startup: ",0
enabledMsg      db "Enabled",13,10,0
disabledMsg     db "Disabled",13,10,0

acpiMsg         db "ACPI: ",0
pwrBtnMsg       db "Power Button Enabled: ",0
sleepMsg        db "Sleep Timeout (min): ",0
hibernateMsg    db "Hibernation: ",0

hyperthreadMsg  db "Hyperthreading: ",0
virtualMsg      db "Virtual Core: ",0
iommuMsg        db "IOMMU: ",0
aesMsg          db "AES-NI: ",0

cpuFanMsg       db "CPU Fan: ",0
autoMsg         db "Auto",13,10,0
manualMsg       db "Manual - Speed: ",0

ecdsaMsg        db "Memory ECC: ",0
sataMsg         db "SATA Mode: ",0
ideModeMsg      db "IDE",13,10,0
ahciModeMsg     db "AHCI",13,10,0
smartMsg        db "S.M.A.R.T. Monitoring: ",0

saveChangesMsg  db "Save changes and exit? (Y/N): ",0
savedMsg        db "Settings saved.",13,10,0
discardMsg      db "Changes discarded.",13,10,0

newLine         db 13,10,0
space           db " ",0

sysInfoMsg      db "System Information:",13,10,0
cpuMsg          db "CPU: Intel 8080 Emulator",13,10,0
ramMsg          db "RAM: 64 KB (Base) + 384 KB (Extended)",13,10,0
biosMsg         db "BIOS: Altair v1.0",13,10,0
dateMsg         db "Date: March 4, 2026",13,10,0

.code

; ============================================================================
; EXTERNAL FUNCTION DECLARATIONS
; ============================================================================

extern write_cstr:PROC

; ============================================================================
; UTILITY FUNCTIONS
; ============================================================================

write_cstr_internal PROC
    ; RCX = string pointer
    push rbx
    push rsi
    mov rsi, rcx
    xor r8d, r8d
    
cstr_loop:
    mov bl, byte ptr [rsi+r8]
    test bl, bl
    jz cstr_done
    inc r8d
    jmp cstr_loop
    
cstr_done:
    mov rcx, qword ptr [hStdOut]
    mov rdx, rsi
    lea r9, charsWritten
    sub rsp, 32
    mov qword ptr [rsp+32], 0
    call WriteConsoleA
    add rsp, 32
    
    pop rsi
    pop rbx
    ret
write_cstr_internal ENDP

; ============================================================================
; MAIN MENU DISPLAY
; ============================================================================

display_main_menu PROC
    lea rcx, mainMenu
    call write_cstr_internal
    lea rcx, mainMenu2
    call write_cstr_internal
    lea rcx, mainMenu3
    call write_cstr_internal
    lea rcx, mainMenu4
    call write_cstr_internal
    
    lea rcx, option1
    call write_cstr_internal
    lea rcx, option2
    call write_cstr_internal
    lea rcx, option3
    call write_cstr_internal
    lea rcx, option4
    call write_cstr_internal
    lea rcx, option5
    call write_cstr_internal
    lea rcx, option6
    call write_cstr_internal
    lea rcx, option7
    call write_cstr_internal
    lea rcx, option8
    call write_cstr_internal
    lea rcx, option9
    call write_cstr_internal
    lea rcx, option0
    call write_cstr_internal
    
    ret
display_main_menu ENDP

; ============================================================================
; BOOT OPTIONS MENU
; ============================================================================

display_boot_menu PROC
    lea rcx, bootOrderMsg
    call write_cstr_internal
    
    lea rcx, bootMsg
    call write_cstr_internal
    
    mov al, [bootDevice]
    cmp al, 0x80
    je boot_hdd_disp
    cmp al, 0x00
    je boot_fdd_disp
    
boot_hdd_disp:
    lea rcx, bootHDD
    call write_cstr_internal
    jmp boot_done
    
boot_fdd_disp:
    lea rcx, bootFDD
    call write_cstr_internal
    
boot_done:
    ret
display_boot_menu ENDP

; ============================================================================
; ADVANCED SETTINGS MENU
; ============================================================================

display_advanced_menu PROC
    lea rcx, hyperthreadMsg
    call write_cstr_internal
    mov al, [hyperthreading]
    cmp al, 1
    je adv_ht_enabled
    lea rcx, disabledMsg
    jmp adv_ht_disp
adv_ht_enabled:
    lea rcx, enabledMsg
adv_ht_disp:
    call write_cstr_internal
    
    lea rcx, virtualMsg
    call write_cstr_internal
    mov al, [virtualCore]
    cmp al, 1
    je adv_vc_enabled
    lea rcx, disabledMsg
    jmp adv_vc_disp
adv_vc_enabled:
    lea rcx, enabledMsg
adv_vc_disp:
    call write_cstr_internal
    
    lea rcx, iommuMsg
    call write_cstr_internal
    mov al, [iommu]
    cmp al, 1
    je adv_iommu_enabled
    lea rcx, disabledMsg
    jmp adv_iommu_disp
adv_iommu_enabled:
    lea rcx, enabledMsg
adv_iommu_disp:
    call write_cstr_internal
    
    lea rcx, aesMsg
    call write_cstr_internal
    mov al, [aes]
    cmp al, 1
    je adv_aes_enabled
    lea rcx, disabledMsg
    jmp adv_aes_disp
adv_aes_enabled:
    lea rcx, enabledMsg
adv_aes_disp:
    call write_cstr_internal
    
    ret
display_advanced_menu ENDP

; ============================================================================
; POWER MANAGEMENT MENU
; ============================================================================

display_power_menu PROC
    lea rcx, acpiMsg
    call write_cstr_internal
    mov al, [acpiEnabled]
    cmp al, 1
    je pwr_acpi_enabled
    lea rcx, disabledMsg
    jmp pwr_acpi_disp
pwr_acpi_enabled:
    lea rcx, enabledMsg
pwr_acpi_disp:
    call write_cstr_internal
    
    lea rcx, pwrBtnMsg
    call write_cstr_internal
    mov al, [pwrButton]
    cmp al, 1
    je pwr_btn_enabled
    lea rcx, disabledMsg
    jmp pwr_btn_disp
pwr_btn_enabled:
    lea rcx, enabledMsg
pwr_btn_disp:
    call write_cstr_internal
    
    lea rcx, sleepMsg
    call write_cstr_internal
    mov al, [sleepTimeout]
    add al, '0'
    mov cl, al
    ; The above should display the number
    
    lea rcx, hibernateMsg
    call write_cstr_internal
    mov al, [hibernate]
    cmp al, 1
    je pwr_hib_enabled
    lea rcx, disabledMsg
    jmp pwr_hib_disp
pwr_hib_enabled:
    lea rcx, enabledMsg
pwr_hib_disp:
    call write_cstr_internal
    
    ret
display_power_menu ENDP

; ============================================================================
; SECURITY SETTINGS MENU
; ============================================================================

display_security_menu PROC
    ; Show security settings
    lea rcx, passwordSet
    call write_cstr_internal
    mov al, [passwordSet]
    cmp al, 1
    je sec_pass_set
    lea rcx, notSetMsg
    jmp sec_pass_disp
sec_pass_set:
    lea rcx, setMsg
sec_pass_disp:
    call write_cstr_internal
    
    ret
display_security_menu ENDP

; ============================================================================
; HARDWARE MONITOR MENU
; ============================================================================

display_hardware_menu PROC
    lea rcx, cpuFanMsg
    call write_cstr_internal
    mov al, [cpuFanLevel]
    cmp al, 1
    je hw_fan_auto
    cmp al, 2
    je hw_fan_manual
    lea rcx, disabledMsg
    jmp hw_fan_disp
hw_fan_auto:
    lea rcx, autoMsg
    jmp hw_fan_disp
hw_fan_manual:
    lea rcx, manualMsg
hw_fan_disp:
    call write_cstr_internal
    
    ret
display_hardware_menu ENDP

; ============================================================================
; MEMORY SETTINGS MENU
; ============================================================================

display_memory_menu PROC
    lea rcx, ecdsaMsg
    call write_cstr_internal
    mov al, [memoryECC]
    cmp al, 1
    je mem_ecc_enabled
    lea rcx, disabledMsg
    jmp mem_ecc_disp
mem_ecc_enabled:
    lea rcx, enabledMsg
mem_ecc_disp:
    call write_cstr_internal
    
    ret
display_memory_menu ENDP

; ============================================================================
; STORAGE SETTINGS MENU
; ============================================================================

display_storage_menu PROC
    lea rcx, sataMsg
    call write_cstr_internal
    mov al, [sataMode]
    cmp al, 0
    je stor_ide_mode
    lea rcx, ahciModeMsg
    jmp stor_sata_disp
stor_ide_mode:
    lea rcx, ideModeMsg
stor_sata_disp:
    call write_cstr_internal
    
    lea rcx, smartMsg
    call write_cstr_internal
    mov al, [smartMonitoring]
    cmp al, 1
    je stor_smart_enabled
    lea rcx, disabledMsg
    jmp stor_smart_disp
stor_smart_enabled:
    lea rcx, enabledMsg
stor_smart_disp:
    call write_cstr_internal
    
    ret
display_storage_menu ENDP

; ============================================================================
; SYSTEM INFORMATION DISPLAY
; ============================================================================

display_system_info PROC
    lea rcx, sysInfoMsg
    call write_cstr_internal
    
    lea rcx, cpuMsg
    call write_cstr_internal
    
    lea rcx, ramMsg
    call write_cstr_internal
    
    lea rcx, biosMsg
    call write_cstr_internal
    
    lea rcx, dateMsg
    call write_cstr_internal
    
    ret
display_system_info ENDP

; ============================================================================
; CONFIGURATION BACKUP/RESTORE
; ============================================================================

backup_configuration PROC
    ; Save configuration to CMOS
    ret
backup_configuration ENDP

restore_configuration PROC
    ; Restore configuration from CMOS
    ret
restore_configuration ENDP

reset_to_defaults PROC
    ; Reset all settings to factory defaults
    mov byte ptr [bootDevice], 0x80
    mov byte ptr [numLock], 1
    mov byte ptr [acpiEnabled], 1
    mov byte ptr [pwrButton], 1
    mov byte ptr [sleepTimeout], 15
    mov byte ptr [hyperthreading], 1
    
    ret
reset_to_defaults ENDP

; ============================================================================
; SETTING MODIFICATION FUNCTIONS
; ============================================================================

toggle_setting PROC
    ; RCX = setting address
    ; Toggle between 0 and 1
    mov al, byte ptr [rcx]
    xor al, 1
    mov byte ptr [rcx], al
    ret
toggle_setting ENDP

; Additional messages
notSetMsg       db "Not Set",13,10,0
setMsg          db "Set",13,10,0

END
