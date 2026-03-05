/*
 * ===================================================================
 * ALTAIR 8800 C/C++ STANDARD LIBRARY (altair_stdlib.h)
 * Complete standard library for ALTAIR 8800 C/C++ programs
 * ===================================================================
 */

#ifndef ALTAIR_STDLIB_H
#define ALTAIR_STDLIB_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

/* ===================================================================
 * TYPE DEFINITIONS
 * =================================================================== */

typedef unsigned char byte;
typedef unsigned short word;
typedef unsigned int dword;
typedef signed char sbyte;
typedef signed short sword;
typedef signed int sdword;

/* Memory address types */
typedef void* ptr_t;
typedef uint16_t addr_t;

/* I/O Port definitions */
#define INPUT_PORT   0x00
#define OUTPUT_PORT  0x01
#define STATUS_PORT  0x02
#define CONTROL_PORT 0x03

/* ===================================================================
 * MEMORY MANAGEMENT
 * =================================================================== */

/* Memory boundaries */
#define MEM_ZERO_PAGE   0x0000
#define MEM_STACK       0x0100
#define MEM_PROGRAM     0x0200
#define MEM_VIDEO       0x8000
#define MEM_SIZE        0x10000

/* Memory operations */
void* memcpy(void* dest, const void* src, size_t n);
void* memset(void* s, int c, size_t n);
int memcmp(const void* s1, const void* s2, size_t n);
void* memmove(void* dest, const void* src, size_t n);

/* Dynamic memory (if available) */
void* malloc(size_t size);
void free(void* ptr);

/* ===================================================================
 * STRING OPERATIONS
 * =================================================================== */

/* String manipulation */
size_t strlen(const char* s);
char* strcpy(char* dest, const char* src);
char* strncpy(char* dest, const char* src, size_t n);
int strcmp(const char* s1, const char* s2);
int strncmp(const char* s1, const char* s2, size_t n);
char* strcat(char* dest, const char* src);
char* strncat(char* dest, const char* src, size_t n);
char* strchr(const char* s, int c);
char* strrchr(const char* s, int c);
char* strstr(const char* haystack, const char* needle);

/* String reversal */
void strrev(char* s);

/* String case conversion */
void strupr(char* s);
void strlwr(char* s);

/* ===================================================================
 * CHARACTER OPERATIONS
 * =================================================================== */

int isalpha(int c);
int isdigit(int c);
int isalnum(int c);
int isspace(int c);
int isupper(int c);
int islower(int c);
int isprint(int c);
int isgraph(int c);
int iscntrl(int c);
int isxdigit(int c);

int toupper(int c);
int tolower(int c);

/* ===================================================================
 * ARITHMETIC & MATH
 * =================================================================== */

/* Integer arithmetic */
typedef struct {
    int quot;
    int rem;
} div_t;

typedef struct {
    long quot;
    long rem;
} ldiv_t;

int abs(int j);
long labs(long j);
div_t div(int numer, int denom);
ldiv_t ldiv(long numer, long denom);

/* Math functions */
int min(int a, int b);
int max(int a, int b);
int clamp(int val, int min_val, int max_val);
int sign(int val);

/* Fast multiplication/division by powers of 2 */
#define mul2(x)  ((x) << 1)
#define mul4(x)  ((x) << 2)
#define mul8(x)  ((x) << 3)
#define mul16(x) ((x) << 4)

#define div2(x)  ((x) >> 1)
#define div4(x)  ((x) >> 2)
#define div8(x)  ((x) >> 3)
#define div16(x) ((x) >> 4)

/* ===================================================================
 * BIT OPERATIONS
 * =================================================================== */

/* Bit manipulation macros */
#define BIT_SET(x, n)      ((x) |= (1 << (n)))
#define BIT_CLR(x, n)      ((x) &= ~(1 << (n)))
#define BIT_GET(x, n)      (((x) >> (n)) & 1)
#define BIT_TOGGLE(x, n)   ((x) ^= (1 << (n)))
#define BIT_CHECK(x, n)    (((x) >> (n)) & 1)

/* Bit manipulation functions */
int bitcount(unsigned int x);
int bitrev(unsigned int x);
int highest_bit(unsigned int x);
int lowest_bit(unsigned int x);
int popcount(unsigned int x);

/* ===================================================================
 * I/O OPERATIONS
 * =================================================================== */

/* Character I/O */
int getchar(void);
int putchar(int c);
int peekchar(void);

/* String I/O */
char* gets(char* s);
int puts(const char* s);

/* Formatted I/O */
int printf(const char* format, ...);
int sprintf(char* str, const char* format, ...);
int scanf(const char* format, ...);
int sscanf(const char* str, const char* format, ...);

/* ===================================================================
 * CONVERSION ROUTINES
 * =================================================================== */

/* String conversions */
int atoi(const char* s);
long atol(const char* s);
double atof(const char* s);

/* Number to string conversions */
char* itoa(int value, char* str, int radix);
char* ltoa(long value, char* str, int radix);
char* ultoa(unsigned long value, char* str, int radix);

/* Hex conversions */
byte hex_to_byte(const char* hex);
void byte_to_hex(byte b, char* hex);
void word_to_hex(word w, char* hex);

/* ===================================================================
 * SYSTEM ROUTINES
 * =================================================================== */

/* System control */
void halt(void);
void reset(void);
void delay(unsigned int ms);
void beep(unsigned int freq, unsigned int duration);

/* Hardware access */
byte in_port(byte port);
void out_port(byte port, byte value);

/* Interrupts */
void enable_interrupts(void);
void disable_interrupts(void);
void set_interrupt_handler(int vector, void (*handler)(void));

/* ===================================================================
 * DISPLAY/VIDEO OPERATIONS
 * =================================================================== */

/* Display modes */
#define DISPLAY_WIDTH  80
#define DISPLAY_HEIGHT 24

/* Cursor operations */
void gotoxy(int x, int y);
void clrscr(void);
void clreol(void);

/* Character/color output */
void putch_at(int x, int y, char c);
void putch_color(char c, byte color);

/* ===================================================================
 * RANDOM NUMBER GENERATION
 * =================================================================== */

void srand(unsigned int seed);
int rand(void);
int rand_range(int min, int max);

/* ===================================================================
 * DEBUGGING & DIAGNOSTICS
 * =================================================================== */

/* Debug output */
void debug_print(const char* msg);
void debug_hex(unsigned int val);
void debug_break(void);

/* Diagnostics */
void self_test(void);
void memory_test(void);
void io_test(void);

/* ===================================================================
 * DATA STRUCTURES
 * =================================================================== */

/* Generic linked list */
typedef struct list_node {
    void* data;
    struct list_node* next;
} list_node_t;

list_node_t* list_new(void);
void list_push(list_node_t* list, void* data);
void* list_pop(list_node_t* list);
void list_free(list_node_t* list);

/* Queue */
typedef struct {
    byte buffer[256];
    byte head;
    byte tail;
} queue_t;

queue_t* queue_new(void);
void queue_push(queue_t* q, byte val);
byte queue_pop(queue_t* q);
int queue_empty(queue_t* q);
int queue_full(queue_t* q);

/* ===================================================================
 * ARRAY OPERATIONS
 * =================================================================== */

/* Sorting */
void qsort(void* base, size_t nitems, size_t size,
           int (*compare)(const void*, const void*));

void bubble_sort(int* arr, int n);
void insertion_sort(int* arr, int n);

/* Searching */
void* bsearch(const void* key, const void* base, size_t nitems, size_t size,
              int (*compare)(const void*, const void*));

int linear_search(int* arr, int n, int value);
int binary_search(int* arr, int n, int value);

/* Array operations */
void array_reverse(int* arr, int n);
int array_sum(int* arr, int n);
int array_max(int* arr, int n);
int array_min(int* arr, int n);

/* ===================================================================
 * TIME & DATE
 * =================================================================== */

typedef struct {
    byte hour;
    byte minute;
    byte second;
} time_t;

typedef struct {
    byte year;      /* 0-99 (2000-2099) */
    byte month;     /* 1-12 */
    byte day;       /* 1-31 */
} date_t;

time_t get_time(void);
date_t get_date(void);
void set_time(time_t t);
void set_date(date_t d);

/* ===================================================================
 * FILE I/O (if supported)
 * =================================================================== */

/*
FILE* fopen(const char* filename, const char* mode);
int fclose(FILE* stream);
size_t fread(void* ptr, size_t size, size_t nmemb, FILE* stream);
size_t fwrite(const void* ptr, size_t size, size_t nmemb, FILE* stream);
int fgets(char* s, int n, FILE* stream);
int fputs(const char* s, FILE* stream);
*/

/* ===================================================================
 * ASSERTION & ERROR HANDLING
 * =================================================================== */

#define ASSERT(condition) \
    if (!(condition)) { \
        debug_print("ASSERTION FAILED"); \
        debug_break(); \
    }

void perror(const char* s);
int errno_get(void);
void errno_set(int err);

/* ===================================================================
 * END OF ALTAIR STDLIB
 * =================================================================== */

#endif /* ALTAIR_STDLIB_H */
