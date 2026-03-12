@echo off
REM ============================================================
REM FFmpeg 汇编语言第一课 - 构建脚本
REM 
REM 依赖工具:
REM   1. NASM (https://nasm.us/) - 用于汇编
REM   2. GCC (MinGW-w64) - 用于编译C代码和链接
REM
REM 安装方法:
REM   - NASM: 下载安装包并添加到PATH
REM   - MinGW-w64: https://www.mingw-w64.org/ 或使用 MSYS2
REM
REM ============================================================

echo ========================================
echo FFmpeg 汇编语言第一课 - 构建脚本
echo ========================================
echo.

REM 检查NASM
echo [1/4] 检查 NASM...
nasm -v >nul 2>&1
if errorlevel 1 (
    echo   错误: 未找到 NASM
    echo   请从 https://nasm.us/ 下载并安装
    echo   安装后将 nasm 添加到系统 PATH
    goto :error
)
echo   NASM 版本: 
nasm -v

REM 检查GCC
echo [2/4] 检查 GCC (MinGW-w64)...
gcc --version >nul 2>&1
if errorlevel 1 (
    echo   错误: 未找到 GCC
    echo   请安装 MinGW-w64: https://www.mingw-w64.org/
    echo   或使用 MSYS2: pacman -S mingw-w64-x86_64-gcc
    goto :error
)
echo   GCC 版本:
gcc --version | findstr /C:"gcc"

echo.
echo [3/4] 编译汇编文件...
REM 编译标量汇编
nasm -f win64 scalar_asm.asm -o scalar_asm.obj
if errorlevel 1 (
    echo   错误: 汇编文件编译失败
    goto :error
)
echo   - scalar_asm.asm 编译完成

REM 编译SIMD汇编
nasm -f win64 simd_asm.asm -o simd_asm.obj
if errorlevel 1 (
    echo   错误: SIMD汇编文件编译失败
    goto :error
)
echo   - simd_asm.asm 编译完成

echo.
echo [4/4] 链接生成可执行文件...
gcc -m64 main.c scalar_asm.obj simd_asm.obj -o lesson01.exe -O2
if errorlevel 1 (
    echo   错误: 链接失败
    goto :error
)
echo   - lesson01.exe 生成完成

echo.
echo ========================================
echo 构建成功!
echo 运行: lesson01.exe
echo ========================================
goto :end

:error
echo.
echo ========================================
echo 构建失败! 请安装必要的工具后重试。
echo ========================================
exit /b 1

:end
pause
