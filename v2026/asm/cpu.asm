bits 64

global cpu_cpuid_vendor

global cpu_enable_features

section .text
cpu_cpuid_vendor:
    push rbx
    xor eax, eax
    cpuid
    mov rax, rbx
    pop rbx
    ret

cpu_enable_features:
    ; Feature policy belongs to the OS/firmware on real x86-64 hardware.
    ; Keep this routine side-effect free in the hosted reference build.
    xor eax, eax
    ret
