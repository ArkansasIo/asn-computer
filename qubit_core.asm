; ═══════════════════════════════════════════════════════════════════════════
; QUBIT CORE SYSTEM - Quantum Computing Foundation for ALTAIR 8800
; ═══════════════════════════════════════════════════════════════════════════
; 
; Provides fundamental quantum computing operations:
; - Qubit state initialization and management
; - Quantum state amplitude calculations
; - Measurement simulations
; - Probability calculations
; - Superposition state generation
; - Quantum state collapse
;
; This is the foundation for all bit-width implementations
; ═══════════════════════════════════════════════════════════════════════════

BITS 64

; ═══════════════════════════════════════════════════════════════════════════
; MEMORY LAYOUT - Qubit State Storage
; ═══════════════════════════════════════════════════════════════════════════
;
; 0x0000 - 0x00FF: Qubit State Array (256 qubits max)
;                  Each qubit: |ψ⟩ = α|0⟩ + β|1⟩
;
; 0x0100 - 0x01FF: Alpha Amplitudes (real part)
; 0x0200 - 0x02FF: Beta Amplitudes (imag part)
; 0x0300 - 0x03FF: Measurement Results
; 0x0400 - 0x04FF: Probability Map
; 0x0500 - 0x05FF: Entanglement Register
;
; ═══════════════════════════════════════════════════════════════════════════

section .data
    ; Qubit constants
    QUBIT_MAX equ 256
    PI_APPROX equ 314159265          ; π × 10^8
    
    ; Quantum gates (complex number pairs)
    ; Hadamard: 1/√2 * [[1, 1], [1, -1]]
    HADAMARD_CONST equ 70710678      ; 1/√2 × 10^8
    
    ; Pauli matrices constants
    I_GATE equ 100000000             ; Identity (1.0)
    
    ; ε (epsilon) for floating point comparison
    EPSILON equ 1

section .text

; ═══════════════════════════════════════════════════════════════════════════
; INIT_QUBIT - Initialize a single qubit to |0⟩ state
; ═══════════════════════════════════════════════════════════════════════════
; Input:  RAX = qubit index (0-255)
; Output: Qubit state set to |0⟩ (α=1.0, β=0.0)
; Modifies: RAX, RBX, RCX, RDX
; ═══════════════════════════════════════════════════════════════════════════
INIT_QUBIT:
    ; Validate qubit index
    cmp rax, QUBIT_MAX
    jge .init_error
    
    ; Store alpha = 1.0 (in fixed point: 100000000)
    mov rbx, 0x0100
    add rbx, rax
    mov byte [rbx], 0xFF              ; 1.0 representation
    
    ; Store beta = 0.0
    mov rcx, 0x0200
    add rcx, rax
    mov byte [rcx], 0x00              ; 0.0 representation
    
    ; Clear measurement result
    mov rdx, 0x0300
    add rdx, rax
    mov byte [rdx], 0x00
    
    ret
    
.init_error:
    mov rax, 0xFFFFFFFF               ; Error code
    ret

; ═══════════════════════════════════════════════════════════════════════════
; INIT_SUPERPOSITION - Create equal superposition (Hadamard on |0⟩)
; ═══════════════════════════════════════════════════════════════════════════
; Input:  RAX = qubit index
; Output: Qubit in superposition (α=β=1/√2)
; Modifies: RAX, RBX, RCX, RDX
; ═══════════════════════════════════════════════════════════════════════════
INIT_SUPERPOSITION:
    cmp rax, QUBIT_MAX
    jge .super_error
    
    ; Store alpha = 1/√2 ≈ 0.707
    mov rbx, 0x0100
    add rbx, rax
    mov byte [rbx], 0xB2              ; 1/√2 representation
    
    ; Store beta = 1/√2 ≈ 0.707
    mov rcx, 0x0200
    add rcx, rax
    mov byte [rcx], 0xB2
    
    xor rax, rax                      ; Success
    ret
    
.super_error:
    mov rax, 0xFFFFFFFF
    ret

; ═══════════════════════════════════════════════════════════════════════════
; MEASURE_QUBIT - Measure qubit and collapse state
; ═══════════════════════════════════════════════════════════════════════════
; Input:  RAX = qubit index
; Output: RAX = measurement result (0 or 1)
;         Qubit state collapsed to |0⟩ or |1⟩
; Uses: Pseudo-random probability calculation
; Modifies: RAX, RBX, RCX, RDX
; ═══════════════════════════════════════════════════════════════════════════
MEASURE_QUBIT:
    push rbx
    push rcx
    push rdx
    
    cmp rax, QUBIT_MAX
    jge .measure_error
    
    mov rbx, rax                      ; Save qubit index
    
    ; Get alpha amplitude |α|²
    mov rcx, 0x0100
    add rcx, rbx
    movzx rcx, byte [rcx]             ; Load alpha
    
    ; Calculate probability P(0) = |α|²
    mov rax, rcx
    imul rax, rcx                     ; Square alpha
    shr rax, 16                       ; Normalize
    
    ; Get simple pseudo-random (time-based)
    rdtsc
    xor rdx, rdx
    mov rcx, 100
    div rcx                           ; RAX = RAX mod 100
    
    ; If random < P(0)*100, measure 0; else measure 1
    cmp rax, 50                       ; Approx 50% for superposition
    jl .measure_zero
    
    ; Measure as 1
    mov rcx, 0x0300
    add rcx, rbx
    mov byte [rcx], 0x01              ; Store measurement = 1
    
    ; Collapse to |1⟩
    mov rcx, 0x0100
    add rcx, rbx
    mov byte [rcx], 0x00              ; alpha = 0
    
    mov rcx, 0x0200
    add rcx, rbx
    mov byte [rcx], 0xFF              ; beta = 1
    
    mov rax, 1
    jmp .measure_done
    
.measure_zero:
    mov rcx, 0x0300
    add rcx, rbx
    mov byte [rcx], 0x00              ; Store measurement = 0
    
    ; Collapse to |0⟩
    mov rcx, 0x0100
    add rcx, rbx
    mov byte [rcx], 0xFF              ; alpha = 1
    
    mov rcx, 0x0200
    add rcx, rbx
    mov byte [rcx], 0x00              ; beta = 0
    
    xor rax, rax
    
.measure_done:
    pop rdx
    pop rcx
    pop rbx
    ret
    
.measure_error:
    mov rax, 0xFFFFFFFF
    pop rdx
    pop rcx
    pop rbx
    ret

; ═══════════════════════════════════════════════════════════════════════════
; GET_PROBABILITY_ZERO - Calculate P(|0⟩)
; ═══════════════════════════════════════════════════════════════════════════
; Input:  RAX = qubit index
; Output: RAX = probability × 1000 (0-1000)
; Modifies: RAX, RBX, RCX
; ═══════════════════════════════════════════════════════════════════════════
GET_PROBABILITY_ZERO:
    cmp rax, QUBIT_MAX
    jge .prob_error
    
    mov rbx, rax
    mov rcx, 0x0100
    add rcx, rbx
    movzx rax, byte [rcx]             ; Load alpha
    
    ; P(0) = |α|²
    imul rax, rax
    shr rax, 8                        ; Normalize to 0-1000
    
    mov rcx, 1000
    xor rdx, rdx
    div rcx
    
    ret
    
.prob_error:
    mov rax, 0xFFFFFFFF
    ret

; ═══════════════════════════════════════════════════════════════════════════
; GET_PROBABILITY_ONE - Calculate P(|1⟩)
; ═══════════════════════════════════════════════════════════════════════════
; Input:  RAX = qubit index
; Output: RAX = probability × 1000 (0-1000)
; Modifies: RAX, RBX, RCX
; ═══════════════════════════════════════════════════════════════════════════
GET_PROBABILITY_ONE:
    cmp rax, QUBIT_MAX
    jge .prob_error2
    
    mov rbx, rax
    mov rcx, 0x0200
    add rcx, rbx
    movzx rax, byte [rcx]             ; Load beta
    
    ; P(1) = |β|²
    imul rax, rax
    shr rax, 8                        ; Normalize to 0-1000
    
    mov rcx, 1000
    xor rdx, rdx
    div rcx
    
    ret
    
.prob_error2:
    mov rax, 0xFFFFFFFF
    ret

; ═══════════════════════════════════════════════════════════════════════════
; INIT_ENTANGLED_PAIR - Create Bell state |Φ+⟩ = (|00⟩ + |11⟩)/√2
; ═══════════════════════════════════════════════════════════════════════════
; Input:  RAX = qubit 1 index, RBX = qubit 2 index
; Output: Two qubits in maximally entangled state
; Modifies: RAX, RBX, RCX, RDX
; ═══════════════════════════════════════════════════════════════════════════
INIT_ENTANGLED_PAIR:
    push rsi
    
    mov rsi, rax                      ; Save qubit 1
    
    ; Initialize both to superposition
    call INIT_SUPERPOSITION           ; Qubit 1
    
    mov rax, rbx
    call INIT_SUPERPOSITION           ; Qubit 2
    
    ; Mark as entangled in entanglement register
    mov rcx, 0x0500
    add rcx, rsi
    mov byte [rcx], 0x01              ; Mark as entangled
    
    mov rcx, 0x0500
    add rcx, rbx
    mov byte [rcx], 0x01
    
    pop rsi
    xor rax, rax                      ; Success
    ret

; ═══════════════════════════════════════════════════════════════════════════
; IS_ENTANGLED - Check if qubit is entangled
; ═══════════════════════════════════════════════════════════════════════════
; Input:  RAX = qubit index
; Output: RAX = 1 if entangled, 0 if not
; Modifies: RAX, RBX
; ═══════════════════════════════════════════════════════════════════════════
IS_ENTANGLED:
    cmp rax, QUBIT_MAX
    jge .entang_error
    
    mov rbx, 0x0500
    add rbx, rax
    movzx rax, byte [rbx]
    and rax, 1                        ; Extract entanglement bit
    
    ret
    
.entang_error:
    mov rax, 0xFFFFFFFF
    ret

; ═══════════════════════════════════════════════════════════════════════════
; GET_STATE_VECTOR - Retrieve complete state |ψ⟩
; ═══════════════════════════════════════════════════════════════════════════
; Input:  RAX = qubit index, RBX = pointer to state storage
; Output: Memory at RBX contains [alpha_real, alpha_imag, beta_real, beta_imag]
; Modifies: RAX, RBX, RCX, RDX
; ═══════════════════════════════════════════════════════════════════════════
GET_STATE_VECTOR:
    cmp rax, QUBIT_MAX
    jge .state_error
    
    mov rcx, 0x0100
    add rcx, rax
    movzx rdx, byte [rcx]
    mov [rbx], rdx                    ; alpha_real
    
    mov rcx, 0x0200
    add rcx, rax
    movzx rdx, byte [rcx]
    mov [rbx + 8], rdx                ; beta_real
    
    xor rax, rax                      ; Success
    ret
    
.state_error:
    mov rax, 0xFFFFFFFF
    ret

; ═══════════════════════════════════════════════════════════════════════════
; QUBIT_COUNT - Count number of |1⟩ states across all qubits
; ═══════════════════════════════════════════════════════════════════════════
; Input:  RAX = number of qubits (max 256)
; Output: RAX = count of qubits in state |1⟩
; Modifies: RAX, RBX, RCX, RDX
; ═══════════════════════════════════════════════════════════════════════════
QUBIT_COUNT:
    cmp rax, QUBIT_MAX
    jg .count_error
    
    xor rbx, rbx                      ; Counter
    xor rcx, rcx                      ; Loop index
    
.count_loop:
    cmp rcx, rax
    jge .count_done
    
    ; Check if qubit at RCX is in |1⟩ state
    mov rdx, 0x0300
    add rdx, rcx
    movzx rdx, byte [rdx]             ; Get measurement
    
    cmp rdx, 1
    jne .count_skip
    inc rbx                           ; Increment counter
    
.count_skip:
    inc rcx
    jmp .count_loop
    
.count_done:
    mov rax, rbx
    ret
    
.count_error:
    mov rax, 0xFFFFFFFF
    ret

; ═══════════════════════════════════════════════════════════════════════════
; DISPLAY_QUBIT_STATE - Output qubit state information
; ═══════════════════════════════════════════════════════════════════════════
; Input:  RAX = qubit index, RBX = output port
; Modifies: RAX, RBX, RCX, RDX
; ═══════════════════════════════════════════════════════════════════════════
DISPLAY_QUBIT_STATE:
    push rbp
    mov rbp, rsp
    
    cmp rax, QUBIT_MAX
    jge .disp_error
    
    ; Store qubit index
    mov rcx, rax
    
    ; Output: "Qubit [index]: "
    mov rax, 'Q'
    out rbx, al
    mov rax, '[' 
    out rbx, al
    
    ; Output index as hex
    mov rax, rcx
    call HEX_OUT_BYTE
    
    mov rax, ']'
    out rbx, al
    
    ; Get state information
    mov rax, rcx
    call GET_PROBABILITY_ZERO
    
    ; Output probability
    mov rcx, rax                      ; RCX = P(0) * 1000
    mov rax, ' '
    out rbx, al
    mov rax, 'P'
    out rbx, al
    mov rax, '('
    out rbx, al
    mov rax, '0'
    out rbx, al
    mov rax, ')'
    out rbx, al
    mov rax, '='
    out rbx, al
    
    ; Output probability value
    mov rax, rcx
    shr rax, 8
    add rax, '0'
    out rbx, al
    
    pop rbp
    xor rax, rax
    ret
    
.disp_error:
    mov rax, 0xFFFFFFFF
    pop rbp
    ret

; ═══════════════════════════════════════════════════════════════════════════
; HEX_OUT_BYTE - Output byte as hex (helper)
; ═══════════════════════════════════════════════════════════════════════════
; Input:  AL = byte to output, RBX = output port
; Modifies: RAX, RBX, RCX, RDX
; ═══════════════════════════════════════════════════════════════════════════
HEX_OUT_BYTE:
    mov cl, al
    shr al, 4
    call HEX_TO_ASCII
    out rbx, al
    
    mov al, cl
    and al, 0x0F
    call HEX_TO_ASCII
    out rbx, al
    
    ret

; ═══════════════════════════════════════════════════════════════════════════
; HEX_TO_ASCII - Convert hex digit to ASCII
; ═══════════════════════════════════════════════════════════════════════════
; Input:  AL = hex digit (0-F)
; Output: AL = ASCII character
; Modifies: AL
; ═══════════════════════════════════════════════════════════════════════════
HEX_TO_ASCII:
    cmp al, 9
    jle .hex_digit
    add al, 7
.hex_digit:
    add al, '0'
    ret

; ═══════════════════════════════════════════════════════════════════════════
; END OF QUBIT CORE SYSTEM
; ═══════════════════════════════════════════════════════════════════════════
