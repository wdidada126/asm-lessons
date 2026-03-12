# FFmpeg 汇编语言第二课 - 可运行代码

## 概述

本目录包含对应 FFmpeg 汇编语言教程第二课的可运行代码示例。代码演示了分支、循环、常量、偏移量和LEA指令。

## 文件说明

### 汇编文件 (NASM语法)
- **scalar_branch.asm** - 标量分支和循环示例
- **constants.asm** - 常量定义示例
- **offset_lea.asm** - 偏移量和LEA指令示例
- **simd_loop.asm** - SIMD循环示例

### C接口
- **main.c** - C测试程序

### 构建脚本
- **build.bat** - 构建脚本

## 快速开始

1. 安装工具:
   - **NASM**: https://nasm.us/
   - **MinGW-w64**: https://www.mingw-w64.org/

2. 运行构建:
   ```
   cd lesson_02
   build.bat
   ```

3. 运行程序:
   ```
   lesson02.exe
   ```

## 代码功能说明

### 1. 分支和循环 (scalar_branch.asm)

| 函数名 | 说明 |
|--------|------|
| do_while_loop | do-while循环形式 |
| for_loop_example | for循环模拟 |
| conditional_jumps | 各种条件跳转(JE, JNE, JG, JGE, JL, JLE) |
| xor_zero_example | XOR清零寄存器 |
| sum_array | 数组求和 |
| find_max | 查找最大值 |
| count_positive | 条件计数 |

### 2. 常量 (constants.asm)

| 函数名 | 说明 |
|--------|------|
| load_constants | 从字节常量加载 |
| lookup_table | 查找表 |
| load_words | 加载字常量 |
| load_qwords | 加载四字常量 |

### 3. 偏移量和LEA (offset_lea.asm)

| 函数名 | 说明 |
|--------|------|
| get_element | 基础偏移量访问 |
| get_element_offset | 带位移的偏移量 |
| calculate_address | LEA计算地址 |
| lea_arithmetic | LEA算术运算 |
| lea_complex | 复杂LEA运算 |
| simple_simd_loop | SIMD偏移量示例 |
| optimized_copy | LEA优化指针更新 |

### 4. SIMD循环 (simd_loop.asm)

| 函数名 | 说明 |
|--------|------|
| simd_basic_loop | 基本SIMD循环 |
| simd_zero_demo | PXOR清零 |
| simd_add_loop | 打包字节加法 |
| simd_sub_loop | 打包字节减法 |
| simd_constant_add | SIMD常量加法 |
| simd_saturating_add | 饱和加法 |
| simd_max | 打包最大值 |

## 硬件要求

- x86-64 处理器 (Intel/AMD)
- 支持 SSE2 指令集

## 扩展阅读

- 第二课文档: [index.zh.md](index.zh.md)
- 第三课: [../lesson_03/index.zh.md](../lesson_03/index.zh.md)
