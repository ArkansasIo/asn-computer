cmake_minimum_required(VERSION 3.20)
project(altair2026 LANGUAGES C ASM_NASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)

include_directories(include)

add_executable(altair2026
    src/main.c
    src/platform.c
    asm/boot64.asm
    asm/cpu.asm
    asm/memory.asm
    asm/io.asm
    asm/display.asm
    asm/frontpanel.asm
    asm/compat8080.asm
)

set_source_files_properties(
    asm/boot64.asm asm/cpu.asm asm/memory.asm asm/io.asm
    asm/display.asm asm/frontpanel.asm asm/compat8080.asm
    PROPERTIES LANGUAGE ASM_NASM
)
