@echo off
REM ============================================================
REM FFmpeg 汇编语言第二课 - MASM + MSVC 构建脚本
REM 
REM 使用方法:
REM   1. 打开 "x64 Native Tools Command Prompt for VS" 
REM      (Visual Studio安装后可在开始菜单找到)
REM   2. 运行此脚本
REM
REM ============================================================

echo ========================================
echo FFmpeg 汇编语言第二课 - 构建脚本
echo ========================================
echo.

REM 检查ML64
echo [1/5] 检查 MASM (ml64)...
ml64 /? >nul 2>&1
if errorlevel 1 (
    echo   错误: 未找到 ml64.exe
    echo   请使用 Visual Studio 的开发者命令提示符
    goto :error
)
echo   找到 MASM (ml64.exe)

REM 检查CL
echo [2/5] 检查 C 编译器 (cl)...
cl /? >nul 2>&1
if errorlevel 1 (
    echo   错误: 未找到 cl.exe 或环境变量未设置
    echo   请使用 "x64 Native Tools Command Prompt for VS"
    goto :error
)
echo   找到 Microsoft C 编译器 (cl.exe)

echo.
echo [3/5] 编译汇编文件 (MASM)...

ml64 /c /Fo:scalar_branch_masm.obj scalar_branch_masm.asm
if errorlevel 1 (
    echo   错误: scalar_branch_masm.asm 编译失败
    goto :error
)
echo   - scalar_branch_masm.asm

ml64 /c /Fo:constants_masm.obj constants_masm.asm
if errorlevel 1 (
    echo   错误: constants_masm.asm 编译失败
    goto :error
)
echo   - constants_masm.asm

ml64 /c /Fo:offset_lea_masm.obj offset_lea_masm.asm
if errorlevel 1 (
    echo   错误: offset_lea_masm.asm 编译失败
    goto :error
)
echo   - offset_lea_masm.asm

ml64 /c /Fo:simd_loop_masm.obj simd_loop_masm.asm
if errorlevel 1 (
    echo   错误: simd_loop_masm.asm 编译失败
    goto :error
)
echo   - simd_loop_masm.asm

echo.
echo [4/5] 编译C文件...
cl /O2 /c main.c
if errorlevel 1 (
    echo   错误: main.c 编译失败
    goto :error
)
echo   - main.c

echo.
echo [5/5] 链接生成可执行文件...
link /OUT:lesson02.exe main.obj scalar_branch_masm.obj constants_masm.obj offset_lea_masm.obj simd_loop_masm.obj /SUBSYSTEM:CONSOLE
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
echo 构建失败!
echo.
echo 请按以下步骤操作:
echo   1. 打开 Visual Studio Installer
echo   2. 安装 "Desktop development with C++"
echo   3. 打开 "x64 Native Tools Command Prompt for VS"
echo   4. 切换到此目录并运行 build_msvc.bat
echo ========================================
exit /b 1

:end
pause
