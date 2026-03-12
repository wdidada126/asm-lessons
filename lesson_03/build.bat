@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM FFmpeg Assembly Language Lesson 3 - Build Script
REM ============================================================

set "NASM=C:\Program Files\NASM\nasm.exe"
set "GCC=D:\develops\tools\mingw64\bin\gcc.exe"

echo ========================================
echo FFmpeg Assembly Lesson 3 - Build
echo ========================================
echo.

echo [1/5] Checking NASM...
if not exist "%NASM%" (
    echo   NASM not found at: %NASM%
    echo   Searching in PATH...
    nasm -v >nul 2>&1
    if errorlevel 1 (
        echo   Error: NASM not found
        goto :error
    )
    set "NASM=nasm"
)
"%NASM%" -v >nul 2>&1
if errorlevel 1 (
    echo   Error: NASM not working
    goto :error
)
echo   Found NASM

echo [2/5] Checking GCC...
if not exist "%GCC%" (
    gcc --version >nul 2>&1
    if errorlevel 1 (
        echo   Error: GCC not found
        goto :error
    )
    set "GCC=gcc"
) else (
    echo   Found GCC
)

echo.
echo [3/5] Assembling...

"%NASM%" -f win64 pointer_offset.asm -o pointer_offset.obj
if errorlevel 1 goto :asm_error
echo   - pointer_offset.asm

"%NASM%" -f win64 alignment.asm -o alignment.obj
if errorlevel 1 goto :asm_error
echo   - alignment.asm

"%NASM%" -f win64 range_expand.asm -o range_expand.obj
if errorlevel 1 goto :asm_error
echo   - range_expand.asm

"%NASM%" -f win64 shuffle.asm -o shuffle.obj
if errorlevel 1 goto :asm_error
echo   - shuffle.asm

echo.
echo [4/5] Compiling C file...
"%GCC%" -m64 -c main.c -o main.obj
if errorlevel 1 goto :c_error
echo   - main.c

echo.
echo [5/5] Linking...
"%GCC%" -m64 main.obj pointer_offset.obj alignment.obj range_expand.obj shuffle.obj -o lesson03.exe -O2
if errorlevel 1 goto :link_error
echo   - lesson03.exe created

echo.
echo ========================================
echo Build SUCCESS!
echo Run: lesson03.exe
echo ========================================
goto :end

:asm_error
echo.
echo   Error: Assembly failed
goto :error

:c_error
echo   Error: C compilation failed
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
