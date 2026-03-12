# FFmpeg 汇编语言第一课 - 可运行代码

## 概述

本目录包含对应 FFmpeg 汇编语言教程第一课的可运行代码示例。代码演示了标量汇编和SIMD（单指令多数据）汇编的基础概念。

## 文件说明

### 汇编文件
- **scalar_asm.asm** - NASM语法的标量汇编函数
- **simd_asm.asm** - NASM语法的SIMD汇编函数 (SSE2)
- **scalar_asm_masm.asm** - MASM语法的标量汇编函数
- **simd_asm_masm.asm** - MASM语法的SIMD汇编函数

### C接口
- **main.c** - C测试程序，调用汇编函数并验证结果

### 构建脚本
- **build.bat** - NASM + GCC 构建脚本
- **build_masm.bat** - MASM + MSVC/GCC 构建脚本

## 快速开始

### 方法一: 使用 NASM + GCC (推荐)

1. 安装工具:
   - **NASM**: https://nasm.us/
   - **MinGW-w64**: https://www.mingw-w64.org/
   - 或使用 MSYS2: `pacman -S mingw-w64-x86_64-nasm mingw-w64-x86_64-gcc`

2. 将工具添加到系统 PATH

3. 运行构建:
   ```
   cd lesson_01
   build.bat
   ```

4. 运行程序:
   ```
   lesson01.exe
   ```

### 方法二: 使用 MASM + MSVC

1. 安装 Visual Studio

2. 打开 "Developer Command Prompt for VS"

3. 运行构建:
   ```
   cd lesson_01
   build_masm.bat
   ```

4. 运行程序:
   ```
   lesson01.exe
   ```

## 代码功能说明

### 标量汇编函数

| 函数名 | 说明 |
|--------|------|
| scalar_example | 基础算术: 3+1-1*5=15 |
| add_values_scalar | 标量数组逐字节加法 |
| scalar_loop_example | 循环计数器示例 |
| scalar_arithmetic | LEA指令算术运算 |

### SIMD汇编函数

| 函数名 | 说明 |
|--------|------|
| add_values_sse2 | 16字节并行打包加法 |
| add_values_sse2_simple | 简单16字节加法 |
| subtract_values_sse2 | 16字节并行打包减法 |
| max_values_sse2 | 16字节并行取最大值 |
| average_values_sse2 | 16字节并行平均值 |
| saturating_add_sse2 | 饱和加法 (上限255) |

## 测试输出示例

```
=========================================
FFmpeg 汇编语言第一课 - 可运行代码示例
=========================================

操作系统: Windows 64-bit
汇编器: NASM
编译器: GCC (MinGW-w64)

=== 标量汇编函数测试 ===

1. scalar_example - 基础算术操作
   预期: 3 + 1 - 1 * 5 = 15
   结果: 15

2. add_values_scalar - 标量数组加法
   结果: 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17
   
...

=========================================
所有测试完成！
=========================================
```

## 硬件要求

- x86-64 处理器 (Intel/AMD)
- 支持 SSE2 指令集 (大多数现代CPU都支持)

## 扩展阅读

- 第一课文档: [index.zh.md](index.zh.md)
- 第二课: [../lesson_02/index.zh.md](../lesson_02/index.zh.md)

## 故障排除

### NASM 未找到
```
错误: 未找到 NASM
```
**解决方案**: 下载并安装 NASM，将其添加到 PATH

### GCC 未找到
```
错误: 未找到 GCC
```
**解决方案**: 安装 MinGW-w64 或 MSYS2

### 链接错误
如果出现 "undefined reference" 错误，确保汇编函数名与C代码中的extern声明一致。

## 许可

本代码仅用于学习目的。
