#!/bin/bash
# Mac build script for lesson_01

set -e

echo "========================================"
echo "FFmpeg Assembly Lesson 1 - Mac Build"
echo "========================================"
echo ""

# Check for NASM
echo "[1/4] Checking NASM..."
if ! command -v nasm &> /dev/null; then
    echo "   Error: NASM not found"
    echo "   Install with: brew install nasm"
    exit 1
fi
echo "   Found NASM: $(nasm -v)"

# Check for GCC/Clang
echo "[2/4] Checking C compiler..."
if command -v clang &> /dev/null; then
    CC=clang
    echo "   Using Clang"
elif command -v gcc &> /dev/null; then
    CC=gcc
    echo "   Using GCC"
else
    echo "   Error: No C compiler found"
    exit 1
fi

echo ""
echo "[3/4] Assembling..."

# Assemble scalar_asm_mac.asm for macOS (macho64 format)
nasm -f macho64 scalar_asm_mac.asm -o scalar_asm_mac.o
if [ $? -ne 0 ]; then
    echo "   Error: scalar_asm_mac.asm assembly failed"
    exit 1
fi
echo "   - scalar_asm_mac.asm"

# Assemble simd_asm_mac.asm for macOS
nasm -f macho64 simd_asm_mac.asm -o simd_asm_mac.o
if [ $? -ne 0 ]; then
    echo "   Error: simd_asm_mac.asm assembly failed"
    exit 1
fi
echo "   - simd_asm_mac.asm"

echo ""
echo "[4/4] Compiling and linking..."

# Compile C code and link with object files
$CC -arch x86_64 main_mac.c scalar_asm_mac.o simd_asm_mac.o -o lesson01 -O2
if [ $? -ne 0 ]; then
    echo "   Error: Linking failed"
    exit 1
fi
echo "   - lesson01 created"

echo ""
echo "========================================"
echo "Build SUCCESS!"
echo "Run: ./lesson01"
echo "========================================"
