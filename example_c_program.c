/*
 * ===================================================================
 * EXAMPLE PROGRAMS - ALTAIR 8800 C Program Examples
 * Demonstrates use of the ALTAIR standard library
 * ===================================================================
 */

#include "altair_stdlib.h"

/* ===================================================================
 * EXAMPLE 1: Hello World
 * =================================================================== */

void hello_world_example(void) {
    puts("╔═══════════════════════════════════════════╗");
    puts("║         HELLO WORLD - ALTAIR 8800        ║");
    puts("╚═══════════════════════════════════════════╝");
    puts("");
    puts("Welcome to the ALTAIR 8800 Emulator!");
    puts("This is a demonstration of text output.");
    puts("");
}

/* ===================================================================
 * EXAMPLE 2: Arithmetic Operations
 * =================================================================== */

void arithmetic_example(void) {
    printf("ARITHMETIC OPERATIONS\n");
    printf("────────────────────\n\n");
    
    int a = 15, b = 7;
    printf("A = %d, B = %d\n", a, b);
    printf("A + B = %d\n", a + b);
    printf("A - B = %d\n", a - b);
    printf("A * B = %d\n", a * b);
    printf("A / B = %d (remainder: %d)\n", a / b, a % b);
    printf("Absolute value of (B - A) = %d\n", abs(b - a));
    
    puts("");
}

/* ===================================================================
 * EXAMPLE 3: String Operations
 * =================================================================== */

void string_example(void) {
    char str1[] = "ALTAIR";
    char str2[] = "8800";
    char buffer[32];
    
    printf("STRING OPERATIONS\n");
    printf("─────────────────\n\n");
    
    printf("String 1: %s\n", str1);
    printf("String 2: %s\n", str2);
    printf("Length of String 1: %d\n", strlen(str1));
    printf("Length of String 2: %d\n", strlen(str2));
    
    strcpy(buffer, str1);
    strcat(buffer, " ");
    strcat(buffer, str2);
    printf("Concatenated: %s\n", buffer);
    
    strrev(buffer);
    printf("Reversed: %s\n", buffer);
    
    puts("");
}

/* ===================================================================
 * EXAMPLE 4: Character Classification
 * =================================================================== */

void char_class_example(void) {
    const char* test_str = "Test123!@#";
    int i = 0;
    
    printf("CHARACTER CLASSIFICATION\n");
    printf("────────────────────────\n\n");
    
    printf("String: %s\n", test_str);
    puts("Analysis:");
    
    while (test_str[i] != '\0') {
        char c = test_str[i];
        printf("  '%c': ", c);
        
        if (isalpha(c)) printf("[ALPHA] ");
        if (isdigit(c)) printf("[DIGIT] ");
        if (isspace(c)) printf("[SPACE] ");
        if (isalnum(c)) printf("[ALNUM] ");
        if (isprint(c)) printf("[PRINT] ");
        
        puts("");
        i++;
    }
    
    puts("");
}

/* ===================================================================
 * EXAMPLE 5: Bit Operations
 * =================================================================== */

void bit_example(void) {
    unsigned int val = 0b10110101;
    
    printf("BIT OPERATIONS\n");
    printf("──────────────\n\n");
    
    printf("Value: 0x%02X (binary: ", val);
    for (int i = 7; i >= 0; i--) {
        printf("%d", (val >> i) & 1);
    }
    printf(")\n\n");
    
    printf("Bit count: %d\n", bitcount(val));
    printf("Highest bit: %d\n", highest_bit(val));
    printf("Lowest bit: %d\n", lowest_bit(val));
    printf("Bit reversed: 0x%02X\n", bitrev(val));
    
    puts("");
}

/* ===================================================================
 * EXAMPLE 6: Array Operations
 * =================================================================== */

void array_example(void) {
    int arr[] = {45, 23, 67, 12, 89, 34, 56, 78, 90, 11};
    int size = 10;
    
    printf("ARRAY OPERATIONS\n");
    printf("────────────────\n\n");
    
    printf("Original array: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    puts("");
    
    printf("Sum: %d\n", array_sum(arr, size));
    printf("Max: %d\n", array_max(arr, size));
    printf("Min: %d\n", array_min(arr, size));
    
    puts("Sorted array: ");
    bubble_sort(arr, size);
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    puts("");
    
    puts("");
}

/* ===================================================================
 * EXAMPLE 7: Memory Operations
 * =================================================================== */

void memory_example(void) {
    unsigned char src[] = {0x01, 0x02, 0x03, 0x04, 0x05};
    unsigned char dest[10];
    
    printf("MEMORY OPERATIONS\n");
    printf("─────────────────\n\n");
    
    memcpy(dest, src, 5);
    printf("Copied 5 bytes\n");
    
    memset(dest + 5, 0xFF, 5);
    printf("Memset 5 bytes to 0xFF\n");
    
    printf("Memory compare: ");
    if (memcmp(src, dest, 5) == 0) {
        puts("Equal");
    } else {
        puts("Not equal");
    }
    
    puts("");
}

/* ===================================================================
 * EXAMPLE 8: System Information
 * =================================================================== */

void system_info_example(void) {
    printf("SYSTEM INFORMATION\n");
    printf("──────────────────\n\n");
    
    printf("CPU Type: Intel 8080A\n");
    printf("Clock Speed: 2 MHz\n");
    printf("Memory Size: 64 KB\n");
    printf("Address Bus: 16-bit\n");
    printf("Data Bus: 8-bit\n");
    printf("Stack Pointer: 0x%04X\n", 0x8000);
    printf("Program Counter: 0x%04X\n", 0x0200);
    
    puts("");
}

/* ===================================================================
 * MAIN PROGRAM
 * =================================================================== */

int main(void) {
    /* Display header */
    puts("╔═════════════════════════════════════════════════════════╗");
    puts("║   ALTAIR 8800 - EXAMPLE PROGRAMS & DEMONSTRATIONS      ║");
    puts("║   C Standard Library Examples                           ║");
    puts("╚═════════════════════════════════════════════════════════╝");
    puts("");
    puts("Executing examples...");
    delay(100);
    puts("");
    
    /* Run examples */
    hello_world_example();
    arithmetic_example();
    string_example();
    char_class_example();
    bit_example();
    array_example();
    memory_example();
    system_info_example();
    
    /* End message */
    puts("═══════════════════════════════════════════════════════════");
    puts("All examples completed successfully!");
    puts("═══════════════════════════════════════════════════════════");
    
    return 0;
}

/* ===================================================================
 * END OF EXAMPLES
 * =================================================================== */
