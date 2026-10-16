cmake_minimum_required(VERSION 3.20)
project(altair2026 VERSION 0.2.0 LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

add_executable(altair2026
    src/main.c
    src/platform.c
)
target_include_directories(altair2026 PRIVATE include)
if(MSVC)
    target_compile_options(altair2026 PRIVATE /W4)
else()
    target_compile_options(altair2026 PRIVATE -Wall -Wextra -Wpedantic)
endif()

enable_testing()
add_test(NAME hosted_smoke COMMAND altair2026)
