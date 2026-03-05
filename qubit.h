// ═══════════════════════════════════════════════════════════════════════════
// QUBIT LIBRARY - C/C++ API Header for ALTAIR 8800 Quantum Computing
// ═══════════════════════════════════════════════════════════════════════════
//
// Complete C/C++ interface for quantum computing on ALTAIR 8800
// Supports: 8-bit, 16-bit, 32-bit, and 64-bit systems
// Features: Qubit state management, quantum gates, algorithms
//
// ═══════════════════════════════════════════════════════════════════════════

#ifndef QUBIT_H
#define QUBIT_H

#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

// ═══════════════════════════════════════════════════════════════════════════
// TYPE DEFINITIONS
// ═══════════════════════════════════════════════════════════════════════════

// Complex amplitude representation
typedef struct {
    double real;
    double imag;
} Complex;

// Qubit state |ψ⟩ = α|0⟩ + β|1⟩
typedef struct {
    Complex alpha;
    Complex beta;
    uint32_t measurement;             // Last measurement result
    uint8_t is_entangled;             // Entanglement flag
} QubitState;

// Quantum register (collection of qubits)
typedef struct {
    QubitState* qubits;
    uint32_t num_qubits;
    uint32_t max_qubits;
    uint8_t bit_width;                // 8, 16, 32, or 64
} QuantumRegister;

// Measurement statistics
typedef struct {
    uint32_t count_0;
    uint32_t count_1;
    double probability_0;
    double probability_1;
} MeasurementStats;

// Circuit operation
typedef struct {
    uint32_t gate_type;
    uint32_t control_qubit;
    uint32_t target_qubit;
    double parameter;                 // For rotation gates
} CircuitOp;

// ═══════════════════════════════════════════════════════════════════════════
// GATE TYPE ENUMERATION
// ═══════════════════════════════════════════════════════════════════════════

typedef enum {
    // Single-qubit gates
    GATE_I = 0,            // Identity
    GATE_X = 1,            // Pauli-X (bit flip)
    GATE_Y = 2,            // Pauli-Y
    GATE_Z = 3,            // Pauli-Z (phase flip)
    GATE_H = 4,            // Hadamard
    GATE_S = 5,            // S phase gate
    GATE_T = 6,            // T phase gate
    GATE_RX = 7,           // Rotation X
    GATE_RY = 8,           // Rotation Y
    GATE_RZ = 9,           // Rotation Z
    
    // Two-qubit gates
    GATE_CNOT = 10,        // Controlled-NOT
    GATE_SWAP = 11,        // SWAP
    GATE_CZ = 12,          // Controlled-Z
    GATE_CH = 13,          // Controlled-Hadamard
    
    // Three-qubit gates
    GATE_TOFFOLI = 20,     // Controlled-Controlled-NOT
    GATE_FREDKIN = 21,     // Controlled-SWAP
} GateType;

// ═══════════════════════════════════════════════════════════════════════════
// ALGORITHM TYPE ENUMERATION
// ═══════════════════════════════════════════════════════════════════════════

typedef enum {
    ALG_QFT = 0,               // Quantum Fourier Transform
    ALG_SHOR = 1,              // Shor's factoring
    ALG_GROVER = 2,            // Grover search
    ALG_DEUTSCH_JOZSA = 3,     // Deutsch-Jozsa
    ALG_HHL = 4,               // HHL algorithm (linear systems)
    ALG_VQE = 5,               // Variational Quantum Eigensolver
    ALG_QAOA = 6,              // Quantum Approximate Optimization
} AlgorithmType;

// ═══════════════════════════════════════════════════════════════════════════
// CORE QUBIT OPERATIONS - 8-Bit System
// ═══════════════════════════════════════════════════════════════════════════

// Initialize 8-bit qubit system
void qubit_init_8bit(QuantumRegister* reg, uint32_t num_qubits);

// Free 8-bit qubit system
void qubit_free_8bit(QuantumRegister* reg);

// Initialize single qubit to |0⟩
int qubit_init_state_8bit(QuantumRegister* reg, uint32_t index);

// Initialize superposition |+⟩
int qubit_init_superposition_8bit(QuantumRegister* reg, uint32_t index);

// Measure qubit (returns 0 or 1)
int qubit_measure_8bit(QuantumRegister* reg, uint32_t index);

// Get qubit state
QubitState qubit_get_state_8bit(QuantumRegister* reg, uint32_t index);

// Apply 8-bit gates
int qubit_hadamard_8bit(QuantumRegister* reg, uint32_t index);
int qubit_pauli_x_8bit(QuantumRegister* reg, uint32_t index);
int qubit_pauli_y_8bit(QuantumRegister* reg, uint32_t index);
int qubit_pauli_z_8bit(QuantumRegister* reg, uint32_t index);

// ═══════════════════════════════════════════════════════════════════════════
// CORE QUBIT OPERATIONS - 16-Bit System
// ═══════════════════════════════════════════════════════════════════════════

// Initialize 16-bit system
void qubit_init_16bit(QuantumRegister* reg, uint32_t num_qubits);
void qubit_free_16bit(QuantumRegister* reg);

// 16-bit operations
int qubit_init_state_16bit(QuantumRegister* reg, uint32_t index);
int qubit_measure_16bit(QuantumRegister* reg, uint32_t index);
int qubit_hadamard_16bit(QuantumRegister* reg, uint32_t index);
int qubit_cnot_16bit(QuantumRegister* reg, uint32_t control, uint32_t target);

// ═══════════════════════════════════════════════════════════════════════════
// CORE QUBIT OPERATIONS - 32-Bit System
// ═══════════════════════════════════════════════════════════════════════════

void qubit_init_32bit(QuantumRegister* reg, uint32_t num_qubits);
void qubit_free_32bit(QuantumRegister* reg);

int qubit_init_state_32bit(QuantumRegister* reg, uint32_t index);
int qubit_measure_32bit(QuantumRegister* reg, uint32_t index);
int qubit_hadamard_32bit(QuantumRegister* reg, uint32_t index);
int qubit_pauli_gate_32bit(QuantumRegister* reg, uint32_t index, GateType gate);
int qubit_rotation_32bit(QuantumRegister* reg, uint32_t index, GateType gate, double angle);

// ═══════════════════════════════════════════════════════════════════════════
// CORE QUBIT OPERATIONS - 64-Bit System
// ═══════════════════════════════════════════════════════════════════════════

void qubit_init_64bit(QuantumRegister* reg, uint32_t num_qubits);
void qubit_free_64bit(QuantumRegister* reg);

int qubit_init_state_64bit(QuantumRegister* reg, uint32_t index);
int qubit_measure_64bit(QuantumRegister* reg, uint32_t index);
int qubit_hadamard_64bit(QuantumRegister* reg, uint32_t index);
int qubit_pauli_gate_64bit(QuantumRegister* reg, uint32_t index, GateType gate);
int qubit_rotation_64bit(QuantumRegister* reg, uint32_t index, GateType gate, double angle);

// ═══════════════════════════════════════════════════════════════════════════
// TWO-QUBIT GATES (All Systems)
// ═══════════════════════════════════════════════════════════════════════════

// CNOT gate (controlled NOT)
int qubit_cnot(QuantumRegister* reg, uint32_t control, uint32_t target);

// SWAP gate
int qubit_swap(QuantumRegister* reg, uint32_t qubit1, uint32_t qubit2);

// Controlled-Z gate
int qubit_cz(QuantumRegister* reg, uint32_t control, uint32_t target);

// Controlled-Hadamard
int qubit_ch(QuantumRegister* reg, uint32_t control, uint32_t target);

// ═══════════════════════════════════════════════════════════════════════════
// THREE-QUBIT GATES
// ═══════════════════════════════════════════════════════════════════════════

// Toffoli gate (CCX - Controlled-Controlled-NOT)
int qubit_toffoli(QuantumRegister* reg, uint32_t ctrl1, uint32_t ctrl2, uint32_t target);

// Fredkin gate (CSWAP - Controlled-SWAP)
int qubit_fredkin(QuantumRegister* reg, uint32_t control, uint32_t tgt1, uint32_t tgt2);

// ═══════════════════════════════════════════════════════════════════════════
// ENTANGLEMENT OPERATIONS
// ═══════════════════════════════════════════════════════════════════════════

// Create Bell state |Φ+⟩ = (|00⟩ + |11⟩)/√2
int qubit_create_bell_state(QuantumRegister* reg, uint32_t qubit1, uint32_t qubit2);

// Create GHZ state (n-qubit entanglement)
int qubit_create_ghz_state(QuantumRegister* reg, uint32_t* qubits, uint32_t count);

// Check if two qubits are entangled
int qubit_are_entangled(QuantumRegister* reg, uint32_t qubit1, uint32_t qubit2);

// ═══════════════════════════════════════════════════════════════════════════
// QUANTUM ALGORITHMS
// ═══════════════════════════════════════════════════════════════════════════

// Quantum Fourier Transform
int qubit_qft(QuantumRegister* reg, uint32_t* qubits, uint32_t count);

// Shor's algorithm for factoring
uint64_t qubit_shor_factor(uint64_t n, uint32_t num_qubits);

// Grover's search algorithm
uint32_t qubit_grover_search(QuantumRegister* reg, uint32_t search_space);

// Deutsch-Jozsa algorithm
int qubit_deutsch_jozsa(QuantumRegister* reg, uint32_t num_qubits);

// ═══════════════════════════════════════════════════════════════════════════
// MEASUREMENT AND STATISTICS
// ═══════════════════════════════════════════════════════════════════════════

// Measure qubit and get result
int qubit_measure(QuantumRegister* reg, uint32_t index);

// Measure all qubits in register
uint32_t* qubit_measure_all(QuantumRegister* reg, uint32_t* results);

// Get probability of measuring |0⟩
double qubit_probability_0(QuantumRegister* reg, uint32_t index);

// Get probability of measuring |1⟩
double qubit_probability_1(QuantumRegister* reg, uint32_t index);

// Collect measurement statistics
MeasurementStats qubit_get_statistics(QuantumRegister* reg, uint32_t index, uint32_t trials);

// Display qubit state
void qubit_display_state(QuantumRegister* reg, uint32_t index);

// ═══════════════════════════════════════════════════════════════════════════
// QUANTUM STATE TOMOGRAPHY
// ═══════════════════════════════════════════════════════════════════════════

// Measure in different bases for state reconstruction
int qubit_tomography_Z(QuantumRegister* reg, uint32_t index);  // Z basis
int qubit_tomography_X(QuantumRegister* reg, uint32_t index);  // X basis
int qubit_tomography_Y(QuantumRegister* reg, uint32_t index);  // Y basis

// Reconstruct full quantum state from measurements
QubitState qubit_reconstruct_state(QuantumRegister* reg, uint32_t index, uint32_t trials);

// ═══════════════════════════════════════════════════════════════════════════
// QUANTUM ERROR CORRECTION
// ═══════════════════════════════════════════════════════════════════════════

// Detect and correct single-qubit errors (3-qubit repetition code)
int qubit_error_detect_3qubit(QuantumRegister* reg, uint32_t logical_idx);

// Surface code error correction
int qubit_surface_code_correction(QuantumRegister* reg, uint32_t code_distance);

// Get error rate estimate
double qubit_estimate_error_rate(QuantumRegister* reg, uint32_t trials);

// ═══════════════════════════════════════════════════════════════════════════
// QUANTUM TELEPORTATION
// ═══════════════════════════════════════════════════════════════════════════

// Teleport qubit state through Bell pair
int qubit_teleport(QuantumRegister* reg, uint32_t source, uint32_t dest, 
                   uint32_t bell1, uint32_t bell2);

// ═══════════════════════════════════════════════════════════════════════════
// UTILITY FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

// Print entire quantum state vector
void qubit_print_state_vector(QuantumRegister* reg);

// Calculate and print entanglement entropy
double qubit_entanglement_entropy(QuantumRegister* reg);

// Validate quantum state (check normalization)
int qubit_validate_state(QuantumRegister* reg, uint32_t index);

// Apply arbitrary unitary from matrix
int qubit_apply_unitary(QuantumRegister* reg, uint32_t index, 
                       Complex matrix[4]);

// Get qubit count
uint32_t qubit_get_count(QuantumRegister* reg);

// Reset specific qubit to |0⟩
int qubit_reset(QuantumRegister* reg, uint32_t index);

// Reset entire register
int qubit_reset_all(QuantumRegister* reg);

// ═══════════════════════════════════════════════════════════════════════════
// SIMULATION AND DEBUGGING
// ═══════════════════════════════════════════════════════════════════════════

// Enable/disable simulation tracing
void qubit_trace_enable(int enable);

// Print circuit depth
uint32_t qubit_get_circuit_depth(QuantumRegister* reg);

// Get total number of gates applied
uint64_t qubit_get_gate_count(QuantumRegister* reg);

// Benchmark gate performance
double qubit_benchmark_gates(uint32_t num_gates, uint32_t iterations);

// ═══════════════════════════════════════════════════════════════════════════
// CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════════

// Set precision level (affects simulation accuracy)
void qubit_set_precision(uint8_t bits);

// Set error model (noise simulation)
void qubit_set_error_model(double gate_error, double measurement_error);

// Enable/disable simplifications for performance
void qubit_set_optimization(int optimize);

// ═══════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════

#define SQRT2 1.41421356237
#define SQRT2_INV 0.70710678118
#define PI 3.14159265359
#define E 2.71828182846

#define DEFAULT_PRECISION 32
#define MAX_QUBITS_8 8
#define MAX_QUBITS_16 64
#define MAX_QUBITS_32 256
#define MAX_QUBITS_64 1024

// ═══════════════════════════════════════════════════════════════════════════
// ERROR CODES
// ═══════════════════════════════════════════════════════════════════════════

#define QUBIT_OK 0
#define QUBIT_ERR_INVALID_INDEX -1
#define QUBIT_ERR_INVALID_GATE -2
#define QUBIT_ERR_MEMORY -3
#define QUBIT_ERR_ENTANGLEMENT -4
#define QUBIT_ERR_ALGORITHM -5
#define QUBIT_ERR_NORMALIZATION -6

#endif // QUBIT_H
