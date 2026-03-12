@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM FFmpeg Assembly Language Lesson 1 - Build Script
REM ============================================================

set "NASM=C:\Program Files\NASM\nasm.exe"
set "GCC=D:\develops\tools\mingw64\bin\gcc.exe"

echo ========================================
echo FFmpeg Assembly Lesson 1 - Build
echo ========================================
echo.

echo [1/4] Checking NASM...
"%NASM%" -v >nul 2>&1
if errorlevel 1 (
    echo   Error: NASM not found at: %NASM%
    goto :error
)
echo   Found NASM

echo [2/4] Checking GCC...
"%GCC%" --version >nul 2>&1
if errorlevel 1 (
    echo   Error: GCC not found at: %GCC%
    goto :error
)
echo   Found GCC

echo.
echo [3/4] Assembling...

"%NASM%" -f win64 scalar_asm.asm -o scalar_asm.obj
if errorlevel 1 goto :asm_error
echo   - scalar_asm.asm

"%NASM%" -f win64 simd_asm.asm -o simd_asm.obj
if errorlevel 1 goto :asm_error
echo   - simd_asm.asm

echo.
echo [4/4] Compiling and linking...
"%GCC%" -m64 main.c scalar_asm.obj simd_asm.obj -o lesson01.exe -O2
if errorlevel 1 goto :link_error
echo   - lesson01.exe created

echo.
echo ========================================
echo Build SUCCESS!
echo ========================================
goto :end

:asm_error
echo   Error: Assembly failed
goto :error

:link_error
echo   Error: Linking failed
goto :error

:error
echo.
echo ========================================
echo Build FAILED!
echo ========================================
exit /b 1

:end
