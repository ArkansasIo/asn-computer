$ErrorActionPreference = 'Stop'
Write-Host 'ASN Computer - portable validation build' -ForegroundColor Cyan

python --version
python -m compileall -q emulator_simulator.py tools tests
python tools/altair8080.py --self-test
python -m unittest discover -s tests -p 'test_*.py'

$ml64 = Get-Command ml64.exe -ErrorAction SilentlyContinue
$link = Get-Command link.exe -ErrorAction SilentlyContinue
if ($ml64 -and $link) {
    Write-Host 'MASM toolchain detected; invoking native build.bat.' -ForegroundColor Green
    cmd /c build.bat
} else {
    Write-Host 'MASM toolchain not detected. Portable build completed; native x64 build skipped.' -ForegroundColor Yellow
}
