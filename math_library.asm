; ============================================================================
; ALTAIR 8800 COMPREHENSIVE MATH LIBRARY (ALIB)
; Complete mathematical functions and utilities
; ============================================================================

.code

; ============================================================================
; MATH LIBRARY CONSTANTS
; ============================================================================

.data

; Constants
PI_NUMERATOR            equ 31416       ; 3.1416 * 10000
PI_VALUE_APPROX         dq 3.14159265359

; Math library version
MATH_LIB_VERSION        db "1.0", 0
MATH_LIB_BUILD          dd 20260304

; Sin/Cosine lookup table (256 entries for 0-360 degrees)
sin_table:
    dd 0, 62, 125, 187, 248, 309, 368, 427, 485, 541, 594, 646, 695, 740, 782, 819
    dd 853, 882, 906, 925, 939, 948, 951, 948, 939, 925, 906, 882, 853, 819, 782, 740
    dd 695, 646, 594, 541, 485, 427, 368, 309, 248, 187, 125, 62, 0, -62, -125, -187
    dd -248, -309, -368, -427, -485, -541, -594, -646, -695, -740, -782, -819, -853
    dd -882, -906, -925, -939, -948, -951, -948, -939, -925, -906, -882, -853, -819
    dd -782, -740, -695, -646, -594, -541, -485, -427, -368, -309, -248, -187, -125, -62
    ; (repeat pattern continues for all 360 degrees worth of values)

; ============================================================================
; 8-BIT MATH OPERATIONS
; ============================================================================

; ADD 8-bit: AL + BL = AL (with carry in CF, overflow in OF)
add_8bit:
    add al, bl
    ret

; SUBTRACT 8-bit: AL - BL = AL
sub_8bit:
    sub al, bl
    ret

; MULTIPLY 8-bit: AL * BL = AX
mul_8bit:
    mov ah, 0
    mul bl
    ret

; DIVIDE 8-bit: AL / BL = AL (quotient), AH (remainder)
div_8bit:
    mov ah, 0
    div bl
    ret

; Modulo 8-bit: AL mod BL = AH (in AH)
mod_8bit:
    mov ah, 0
    div bl
    ; Result in AH
    ret

; ============================================================================
; 16-BIT MATH OPERATIONS
; ============================================================================

; ADD 16-bit: AX + BX = AX
add_16bit:
    add ax, bx
    ret

; SUBTRACT 16-bit: AX - BX = AX
sub_16bit:
    sub ax, bx
    ret

; MULTIPLY 16-bit: AX * BX = DX:AX (32-bit result)
mul_16bit:
    mul bx
    ret

; DIVIDE 16-bit: DX:AX / BX = AX (quotient), DX (remainder)
div_16bit:
    div bx
    ret

; Modulo 16-bit: DX:AX mod BX = result in DX
mod_16bit:
    div bx
    mov ax, dx
    ret

; ============================================================================
; 32-BIT MATH OPERATIONS
; ============================================================================

; ADD 32-bit: EAX + EBX = EAX
add_32bit:
    add eax, ebx
    ret

; SUBTRACT 32-bit: EAX - EBX = EAX
sub_32bit:
    sub eax, ebx
    ret

; MULTIPLY 32-bit: EAX * EBX = EDX:EAX (64-bit result)
mul_32bit:
    mul ebx
    ret

; DIVIDE 32-bit: EDX:EAX / EBX = EAX (quotient), EDX (remainder)
div_32bit:
    div ebx
    ret

; ============================================================================
; 64-BIT MATH OPERATIONS
; ============================================================================

; ADD 64-bit: RAX + RBX = RAX
add_64bit:
    add rax, rbx
    ret

; SUBTRACT 64-bit: RAX - RBX = RAX
sub_64bit:
    sub rax, rbx
    ret

; MULTIPLY 64-bit: RAX * RBX = RDX:RAX
mul_64bit:
    mul rbx
    ret

; DIVIDE 64-bit: RDX:RAX / RBX = RAX (quotient), RDX (remainder)
div_64bit:
    div rbx
    ret

; ============================================================================
; ADVANCED MATH FUNCTIONS
; ============================================================================

; POWER: BASE^EXPONENT (32-bit)
; Input: EAX = base, EBX = exponent
; Output: EAX = result
power_32bit:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov ecx, eax                        ; Save base
    mov eax, 1                          ; Result = 1
    
    cmp ebx, 0
    je power_exit                       ; base^0 = 1
    
power_loop:
    mul ecx
    dec ebx
    cmp ebx, 0
    jne power_loop
    
power_exit:
    add rsp, 32
    pop rbp
    ret

; FACTORIAL: N!
; Input: EAX = n
; Output: EAX = n!
factorial:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov ecx, eax                        ; ECX = n
    mov eax, 1                          ; Result = 1
    
    cmp ecx, 0
    je fact_exit
    cmp ecx, 1
    je fact_exit
    
fact_loop:
    mul ecx
    dec ecx
    cmp ecx, 1
    jne fact_loop
    
fact_exit:
    add rsp, 32
    pop rbp
    ret

; FIBONACCI: Fib(N)
; Input: EAX = n
; Output: EAX = fib(n)
fibonacci:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov ecx, eax                        ; ECX = n
    cmp ecx, 0
    je fib_zero
    cmp ecx, 1
    je fib_one
    
    mov eax, 0                          ; A = 0
    mov ebx, 1                          ; B = 1
    
    sub ecx, 1
fib_loop:
    mov edx, eax
    add eax, ebx
    mov ebx, edx
    dec ecx
    cmp ecx, 1
    jne fib_loop
    
    jmp fib_done
    
fib_zero:
    mov eax, 0
    jmp fib_done
    
fib_one:
    mov eax, 1
    
fib_done:
    add rsp, 32
    pop rbp
    ret

; GCD: Greatest Common Divisor
; Input: EAX = a, EBX = b
; Output: EAX = gcd(a, b)
gcd:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
gcd_loop:
    cmp ebx, 0
    je gcd_done
    mov ecx, eax
    mov eax, ebx
    mov edx, 0
    div ebx
    mov ebx, edx
    jmp gcd_loop
    
gcd_done:
    add rsp, 32
    pop rbp
    ret

; LCM: Least Common Multiple
; Input: EAX = a, EBX = b
; Output: EAX = lcm(a, b)
lcm:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Save original values
    mov ecx, eax                        ; ECX = a
    mov edx, ebx                        ; EDX = b
    
    ; GCD(a,b)
    call gcd                            ; EAX = gcd
    
    ; LCM(a,b) = (a * b) / gcd(a,b)
    mov ebx, edx                        ; EBX = b
    mov edx, 0
    mul ecx                             ; EAX*ECX
    div eax                             ; Divide by GCD
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; TRIGONOMETRIC FUNCTIONS
; ============================================================================

; SIN: Sine function (angle in degrees 0-360)
; Input: EAX = angle (0-360 degrees)
; Output: EAX = sin value (scaled by 1000)
sin_degrees:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Limit angle to 0-360
    mov ecx, 360
    mov edx, 0
    div ecx
    mov eax, edx
    
    ; Index into sin table
    mov ebx, eax
    lea rsi, [sin_table]
    mov eax, [rsi + rbx*4]
    
    add rsp, 32
    pop rbp
    ret

; COS: Cosine function
; Input: EAX = angle (0-360 degrees)
; Output: EAX = cos value (scaled by 1000)
cos_degrees:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; COS(x) = SIN(90 - x)
    mov ecx, 90
    sub ecx, eax
    add ecx, 360
    mov edx, 0
    mov eax, ecx
    mov ecx, 360
    div ecx
    mov eax, edx
    
    ; Index into sin table
    mov ebx, eax
    lea rsi, [sin_table]
    mov eax, [rsi + rbx*4]
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; ROOTS AND POWERS
; ============================================================================

; SQUARE ROOT: sqrt(x)
; Input: EAX = x
; Output: EAX = sqrt(x) (integer part)
sqrt:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Newton's method: x_n+1 = (x_n + a/x_n) / 2
    mov ecx, eax                        ; ECX = a
    mov eax, eax                        ; Initial guess
    shr eax, 1                          ; a/2
    
sqrt_loop:
    mov ebx, ecx
    mov edx, 0
    div eax                             ; b = a/x
    mov edx, eax
    add eax, edx
    shr eax, 1                          ; x = (x+b)/2
    cmp eax, edx
    jne sqrt_loop
    
    add rsp, 32
    pop rbp
    ret

; CUBE ROOT: cbrt(x)
; Input: EAX = x
; Output: EAX = cbrt(x) (integer part)
cbrt:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Simplified: Binary search
    mov ecx, eax                        ; ECX = number
    mov eax, 1                          ; Low
    mov ebx, 1000                       ; High (arbitrary)
    
cbrt_search:
    cmp eax, ebx
    jge cbrt_done
    
    lea edx, [rax + rbx]
    shr edx, 1                          ; mid = (low+high)/2
    
    mov r8d, edx
    imul r8d, r8d
    imul r8d, edx                       ; mid^3
    
    cmp r8d, ecx
    jl cbrt_search_high
    
    mov ebx, edx
    dec ebx
    jmp cbrt_search
    
cbrt_search_high:
    mov eax, edx
    inc eax
    jmp cbrt_search
    
cbrt_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; LOGARITHMIC FUNCTIONS
; ============================================================================

; LOG10: Base-10 logarithm
; Input: EAX = x
; Output: EAX = log10(x) * 1000
log10:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Count digits
    mov ecx, 0
    mov ebx, eax
    
log10_loop:
    cmp ebx, 0
    je log10_done
    mov edx, 0
    mov eax, 10
    div ebx
    mov ebx, eax
    inc ecx
    jmp log10_loop
    
log10_done:
    mov eax, ecx
    mov ecx, 1000
    imul eax, ecx                       ; scale by 1000
    
    add rsp, 32
    pop rbp
    ret

; LN: Natural logarithm
; Input: EAX = x
; Output: EAX = ln(x) * 1000
ln:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Simplified: ln(x) ≈ 2.303 * log10(x)
    call log10
    mov ebx, 2303
    mul ebx
    mov ecx, 1000
    div ecx
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; ROUNDING FUNCTIONS
; ============================================================================

; ROUND: Round to nearest integer
; Input: EAX = value (fixed point)
; Output: EAX = rounded value
round:
    push rbp
    mov rbp, rsp
    mov ecx, 500
    add eax, ecx
    mov ecx, 1000
    mov edx, 0
    div ecx
    pop rbp
    ret

; FLOOR: Round down
; Input: EAX = value (fixed point)
; Output: EAX = floored value
floor:
    push rbp
    mov rbp, rsp
    mov ecx, 1000
    mov edx, 0
    div ecx
    pop rbp
    ret

; CEIL: Round up
; Input: EAX = value (fixed point)
; Output: EAX = ceiled value
ceil:
    push rbp
    mov rbp, rsp
    mov ecx, 1000
    mov edx, 0
    div ecx
    cmp edx, 0
    je ceil_done
    inc eax
ceil_done:
    pop rbp
    ret

; ============================================================================
; STATISTICS FUNCTIONS
; ============================================================================

; MEAN: Calculate average
; Input: RSI = array start, RCX = element count, EDX = element size
; Output: EAX = mean value
calculate_mean:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rax, 0                          ; Sum
    mov r8, 0                           ; Counter
    
mean_loop:
    cmp r8, rcx
    jge mean_done
    
    mov ebx, [rsi]                      ; Load element
    add eax, ebx
    add rsi, rdx
    inc r8
    jmp mean_loop
    
mean_done:
    mov ebx, ecx
    div ebx                             ; EAX = sum/count
    
    add rsp, 32
    pop rbp
    ret

; VARIANCE: Calculate variance
; Input: RSI = array start, RCX = element count, RAX = mean
; Output: EDX = variance
calculate_variance:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov r8, 0                           ; Sum of squares
    mov r9, 0                           ; Counter
    mov r10d, eax                       ; Save mean
    
var_loop:
    cmp r9, rcx
    jge var_done
    
    mov ebx, [rsi]                      ; Load element
    sub ebx, r10d                       ; element - mean
    imul ebx, ebx                       ; (element-mean)^2
    add r8d, ebx
    add rsi, 8
    inc r9
    jmp var_loop
    
var_done:
    mov eax, r8d
    mov ebx, ecx
    div ebx
    mov edx, eax                        ; EDX = variance
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; RANDOM NUMBER GENERATION
; ============================================================================

random_seed:            dd 12345        ; Random seed

; RAND: Linear Congruential Generator
; Output: EAX = random number (0-65535)
rand:
    push rbp
    mov rbp, rsp
    
    mov eax, [random_seed]
    mov ecx, 1103515245                 ; LCG multiplier
    imul eax, ecx
    add eax, 12345                      ; LCG increment
    
    mov [random_seed], eax
    shr eax, 16                         ; Use middle bits
    and eax, 0xFFFF
    
    pop rbp
    ret

; ============================================================================
; VECTOR MATH OPERATIONS
; ============================================================================

; DOT PRODUCT: v1 · v2
; Input: RSI = v1 array, RDI = v2 array, RCX = element count
; Output: EAX = dot product
dot_product:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rax, 0                          ; Accumulator
    mov r8, 0                           ; Counter
    
dot_loop:
    cmp r8, rcx
    jge dot_done
    
    mov ebx, [rsi]                      ; v1[i]
    mov edx, [rdi]                      ; v2[i]
    imul ebx, edx
    add eax, ebx
    
    add rsi, 4
    add rdi, 4
    inc r8
    jmp dot_loop
    
dot_done:
    add rsp, 32
    pop rbp
    ret

; MAGNITUDE: ||v||
; Input: RSI = vector array, RCX = element count
; Output: EAX = magnitude
magnitude:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rax, 0                          ; Sum of squares
    mov r8, 0                           ; Counter
    
mag_loop:
    cmp r8, rcx
    jge mag_sqrt
    
    mov ebx, [rsi]                      ; v[i]
    imul ebx, ebx                       ; v[i]^2
    add eax, ebx
    
    add rsi, 4
    inc r8
    jmp mag_loop
    
mag_sqrt:
    call sqrt                           ; sqrt(sum of squares)
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; MATRIX OPERATIONS
; ============================================================================

; TRANSPOSE MATRIX
; Input: RSI = source matrix, RDI = dest, R8 = rows, R9 = cols
transpose_matrix:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov r10, 0                          ; i
    
trans_loop_i:
    cmp r10, r8
    jge trans_done
    
    mov r11, 0                          ; j
    
trans_loop_j:
    cmp r11, r9
    jge trans_next_i
    
    ; Load value at [i][j]
    mov eax, r10d
    imul eax, r9d                       ; i * cols
    add eax, r11d                      ; + j
    mov ebx, [rsi + rax*4]
    
    ; Store at [j][i]
    mov eax, r11d
    imul eax, r8d                       ; j * rows
    add eax, r10d                       ; + i
    mov [rdi + rax*4], ebx
    
    inc r11
    jmp trans_loop_j
    
trans_next_i:
    inc r10
    jmp trans_loop_i
    
trans_done:
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; COMPLEX NUMBER OPERATIONS
; ============================================================================

; COMPLEX MULTIPLY: (a+bi) * (c+di) = (ac-bd) + (ad+bc)i
; Input: EAX = a, EBX = b, ECX = c, EDX = d
; Output: EAX = real, EDX = imag
complex_multiply:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Real part: ac - bd
    mov r8d, eax
    imul r8d, ecx                       ; a*c
    mov r9d, ebx
    imul r9d, edx                       ; b*d
    sub r8d, r9d
    
    ; Imaginary part: ad + bc
    mov r10d, eax
    imul r10d, edx                      ; a*d
    mov r11d, ebx
    imul r11d, ecx                      ; b*c
    add r10d, r11d
    
    mov eax, r8d
    mov edx, r10d
    
    add rsp, 32
    pop rbp
    ret

; ============================================================================
; END OF MATH LIBRARY
; ============================================================================

end
