$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$compiler = if (Get-Command clang -ErrorAction SilentlyContinue) { 'clang' }
            elseif (Get-Command gcc -ErrorAction SilentlyContinue) { 'gcc' }
            elseif (Get-Command cl -ErrorAction SilentlyContinue) { 'cl' }
            else { throw 'Install clang, GCC, or MSVC Build Tools.' }

New-Item -ItemType Directory -Force -Path build | Out-Null
if ($compiler -eq 'cl') {
    & cl /nologo /W4 /std:c11 /Iinclude src/main.c src/platform.c /Fe:build/altair2026.exe
} else {
    & $compiler -std=c11 -O2 -Wall -Wextra -Wpedantic -Iinclude src/main.c src/platform.c -o build/altair2026
}
if ($LASTEXITCODE -ne 0) { throw "Compiler failed with exit code $LASTEXITCODE" }
if ($compiler -eq 'cl') { & build/altair2026.exe } else { & build/altair2026 }
if ($LASTEXITCODE -ne 0) { throw "Self-test failed with exit code $LASTEXITCODE" }
