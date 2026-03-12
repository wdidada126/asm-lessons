# Mac 构建说明

## 概述

本目录包含适用于 macOS 的汇编代码示例。原代码是为 Windows 设计的，已适配为在 macOS 上运行。

## 主要区别

### Windows vs macOS (System V AMD64 ABI)

| 特性 | Windows | macOS |
|------|---------|-------|
| 二进制格式 | PE/COFF | Mach-O |
| 汇编格式 | `-f win64` | `-f macho64` |
| 第1个参数 | RCX | RDI |
| 第2个参数 | RDX | RSI |
| 第3个参数 | R8 | RDX |
| 第4个参数 | R9 | RCX |
| 符号命名 | `function_name` | `_function_name` |

## 文件说明

### macOS 专用文件
- **scalar_asm_mac.asm** - 标量汇编函数 (macOS 版本)
- **simd_asm_mac.asm** - SIMD 汇编函数 (macOS 版本)
- **main_mac.c** - C 测试程序 (macOS 版本)
- **build_mac.sh** - macOS 构建脚本

### 原始文件 (Windows)
- **scalar_asm.asm** - 标量汇编函数 (NASM + Windows)
- **simd_asm.asm** - SIMD 汇编函数 (NASM + Windows)
- **main.c** - C 测试程序 (Windows)
- **build.bat** - Windows 构建脚本

## 快速开始

### 1. 安装依赖

```bash
# 使用 Homebrew 安装 NASM
brew install nasm
```

### 2. 构建

```bash
cd lesson_01
./build_mac.sh
```

### 3. 运行

```bash
./lesson01
```

## 手动构建步骤

如果需要手动构建，可以执行以下命令：

```bash
# 编译汇编文件
nasm -f macho64 scalar_asm_mac.asm -o scalar_asm_mac.o
nasm -f macho64 simd_asm_mac.asm -o simd_asm_mac.o

# 编译 C 代码并链接
clang -arch x86_64 main_mac.c scalar_asm_mac.o simd_asm_mac.o -o lesson01 -O2
```

## 预期输出

```
=========================================
FFmpeg Assembly Lesson 1 - macOS
=========================================

=== Scalar Functions ===

1. scalar_example
   Expected: 15
   Result: 15

2. add_values_scalar
   Result: 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 
   Expected: 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17

3. scalar_loop_example
   Expected: 0
   Result: 0

4. scalar_arithmetic
   Expected: 20 (1 + 2*8 + 3)
   Result: 20

=== SIMD (SSE2) Functions ===

1. add_values_sse2_simple
   Result: 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 
   Expected: 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17

2. add_values_sse2 (20 bytes)
   Result: 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 
   Expected: 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21

3. saturating_add_sse2
   Result: 255 255 255 255 255 255 255 255 255 255 255 255 6 7 8 9 
   Expected: 255 255 255 255 255 255 255 255 255 255 255 255 6 7 8 9

4. max_values_sse2
   Result: 75 70 65 60 55 50 45 40 40 45 50 55 60 65 70 75 
   Expected: 75 70 65 60 55 50 45 40 40 45 50 55 60 65 70 75

All tests completed!
```

## 故障排除

### NASM 未找到

```bash
# 检查 NASM 是否安装
which nasm

# 如果未安装，使用 Homebrew 安装
brew install nasm
```

### 架构不匹配

确保你的 Mac 是 Intel 架构（x86_64）。Apple Silicon (M1/M2/M3) 需要 Rosetta 2 转换：

```bash
# 安装 Rosetta 2（如果尚未安装）
softwareupdate --install-rosetta

# 使用 arch -x86_64 运行
arch -x86_64 ./lesson01
```

### 链接错误

如果出现 "undefined reference" 错误，确保：
1. 汇编函数名以下划线开头（macOS 约定）
2. C 代码中的 extern 声明与汇编函数名匹配
3. 所有 .o 文件都已正确生成

## 硬件要求

- x86_64 处理器 (Intel Mac 或 Apple Silicon + Rosetta 2)
- 支持 SSE2 指令集（大多数现代 CPU 都支持）

## 扩展阅读

- 第一课文档: [index.zh.md](index.zh.md)
- 第二课: [../lesson_02/index.zh.md](../lesson_02/index.zh.md)
- System V AMD64 ABI: https://gitlab.com/x86-psABIs/x86-64-ABI
