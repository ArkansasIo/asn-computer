bits 64

global frontpanel_mask_address
global frontpanel_mask_data

global frontpanel_set_switches

section .text
frontpanel_mask_address:
    mov eax, edi
    and eax, 0xffff
    ret

frontpanel_mask_data:
    mov eax, edi
    and eax, 0xff
    ret

frontpanel_set_switches:
    and edi, 0xffff
    mov eax, edi
    ret
