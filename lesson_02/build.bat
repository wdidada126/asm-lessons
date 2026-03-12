@echo off
REM ============================================================
REM FFmpeg 汇编语言第二课 - 构建脚本
REM 
REM 依赖工具:
REM   1. NASM (https://nasm.us/) - 用于汇编
REM   2. GCC (MinGW-w64) - 用于编译C代码和链接
REM
REM ============================================================

echo ========================================
echo FFmpeg 汇编语言第二课 - 构建脚本
echo ========================================
echo.

REM 检查NASM
echo [1/5] 检查 NASM...
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
echo [2/5] 检查 GCC (MinGW-w64)...
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
echo [3/5] 编译汇编文件...
REM 编译标量分支汇编
nasm -f win64 scalar_branch.asm -o scalar_branch.obj
if errorlevel 1 (
    echo   错误: scalar_branch.asm 编译失败
    goto :error
)
echo   - scalar_branch.asm 编译完成

REM 编译常量汇编
nasm -f win64 constants.asm -o constants.obj
if errorlevel 1 (
    echo   错误: constants.asm 编译失败
    goto :error
)
echo   - constants.asm 编译完成

REM 编译偏移量汇编
nasm -f win64 offset_lea.asm -o offset_lea.obj
if errorlevel 1 (
    echo   错误: offset_lea.asm 编译失败
    goto :error
)
echo   - offset_lea.asm 编译完成

REM 编译SIMD循环汇编
nasm -f win64 simd_loop.asm -o simd_loop.obj
if errorlevel 1 (
    echo   错误: simd_loop.asm 编译失败
    goto :error
)
echo   - simd_loop.asm 编译完成

echo.
echo [4/5] 编译C文件...
gcc -m64 -c main.c -o main.obj
if errorlevel 1 (
    echo   错误: main.c 编译失败
    goto :error
)
echo   - main.c 编译完成

echo.
echo [5/5] 链接生成可执行文件...
gcc -m64 main.obj scalar_branch.obj constants.obj offset_lea.obj simd_loop.obj -o lesson02.exe -O2
if errorlevel 1 (
    echo   错误: 链接失败
    goto :error
)
echo   - lesson02.exe 生成完成

echo.
echo ========================================
echo 构建成功!
echo 运行: lesson02.exe
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
