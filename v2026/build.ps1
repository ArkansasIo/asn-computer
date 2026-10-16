$ErrorActionPreference = 'Stop'

if (-not (Get-Command nasm -ErrorAction SilentlyContinue)) { throw 'NASM is required' }
if (-not (Get-Command clang -ErrorAction SilentlyContinue) -and -not (Get-Command gcc -ErrorAction SilentlyContinue)) { throw 'clang or gcc is required' }

if (Get-Command make -ErrorAction SilentlyContinue) {
    make clean
    make
} else {
    Write-Host 'Install Make, NASM and a C compiler, then run this script again.'
}
