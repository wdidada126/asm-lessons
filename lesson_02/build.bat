@echo off
setlocal enabledelayedexpansion

set "NASM=C:\Program Files\NASM\nasm.exe"
set "GCC=D:\develops\tools\mingw64\bin\gcc.exe"

echo ========================================
echo FFmpeg Assembly Lesson 2 - Build
echo ========================================
echo.

echo [1/5] Checking NASM...
"%NASM%" -v >nul 2>&1
if errorlevel 1 (
    echo   Error: NASM not found at: %NASM%
    goto :error
)
echo   Found NASM

echo [2/5] Checking GCC...
"%GCC%" --version >nul 2>&1
if errorlevel 1 (
    echo   Error: GCC not found at: %GCC%
    goto :error
)
echo   Found GCC

echo.
echo [3/5] Assembling...

"%NASM%" -f win64 scalar_branch.asm -o scalar_branch.obj
if errorlevel 1 goto :asm_error
echo   - scalar_branch.asm

"%NASM%" -f win64 constants.asm -o constants.obj
if errorlevel 1 goto :asm_error
echo   - constants.asm

"%NASM%" -f win64 offset_lea.asm -o offset_lea.obj
if errorlevel 1 goto :asm_error
echo   - offset_lea.asm

"%NASM%" -f win64 simd_loop.asm -o simd_loop.obj
if errorlevel 1 goto :asm_error
echo   - simd_loop.asm

echo.
echo [4/5] Compiling C file...
"%GCC%" -m64 -c main.c -o main.obj
if errorlevel 1 goto :c_error

echo.
echo [5/5] Linking...
"%GCC%" -m64 main.obj scalar_branch.obj constants.obj offset_lea.obj simd_loop.obj -o lesson02.exe -O2
if errorlevel 1 goto :link_error

echo   - lesson02.exe created

echo.
echo ========================================
echo Build SUCCESS!
echo ========================================
goto :end

:asm_error
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
