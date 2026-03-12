@echo off
REM ============================================================
REM FFmpeg 汇编语言第一课 - MASM 构建脚本
REM 
REM 依赖工具:
REM   1. MASM (ml64) - Microsoft Macro Assembler (Visual Studio自带)
REM   2. CL (MSVC) 或 GCC (MinGW-w64) - 用于编译C代码和链接
REM
REM 使用方法:
REM   - 使用Visual Studio开发者命令提示符运行
REM   - 或手动设置环境变量后运行
REM
REM ============================================================

echo ========================================
echo FFmpeg 汇编语言第一课 - MASM构建脚本
echo ========================================
echo.

REM 检查ML64
echo [1/4] 检查 MASM (ml64)...
ml64 /? >nul 2>&1
if errorlevel 1 (
    echo   警告: 未找到 ml64.exe
    echo   请使用 Visual Studio 开发者命令提示符运行
    echo   或安装 Visual Studio 并运行 "Developer Command Prompt"
    goto :error
)
echo   找到 MASM (ml64)

REM 检查CL或GCC
echo [2/4] 检查 C 编译器...
cl /? >nul 2>&1
if not errorlevel 1 (
    set "CC=cl"
    echo   使用 Microsoft C 编译器 (CL)
    goto :compile
)

gcc --version >nul 2>&1
if not errorlevel 1 (
    set "CC=gcc"
    echo   使用 GCC 编译器
    goto :compile
)

echo   错误: 未找到 C 编译器
echo   请安装 Visual Studio 或 MinGW-w64
goto :error

:compile
echo.
echo [3/4] 编译汇编文件 (MASM)...
REM 编译标量汇编
ml64 /c /Fo:scalar_asm_masm.obj scalar_asm_masm.asm
if errorlevel 1 (
    echo   错误: 标量汇编文件编译失败
    goto :error
)
echo   - scalar_asm_masm.asm 编译完成

REM 编译SIMD汇编
ml64 /c /Fo:simd_asm_masm.obj simd_asm_masm.asm
if errorlevel 1 (
    echo   错误: SIMD汇编文件编译失败
    goto :error
)
echo   - simd_asm_masm.asm 编译完成

echo.
echo [4/4] 链接生成可执行文件...
if "%CC%"=="cl" (
    cl /O2 main.c scalar_asm_masm.obj simd_asm_masm.obj /Fe:lesson01.exe
) else (
    gcc -m64 main.c scalar_asm_masm.obj simd_asm_masm.obj -o lesson01.exe -O2
)
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
