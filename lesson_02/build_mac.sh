#!/bin/bash
# Mac build script for lesson_02

set -e

echo "========================================"
echo "FFmpeg Assembly Lesson 2 - Mac Build"
echo "========================================"
echo ""

# Check for NASM
echo "[1/6] Checking NASM..."
if ! command -v nasm &> /dev/null; then
    echo "   Error: NASM not found"
    echo "   Install with: brew install nasm"
    exit 1
fi
echo "   Found NASM: $(nasm -v)"

# Check for GCC/Clang
echo "[2/6] Checking C compiler..."
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
echo "[3/6] Assembling scalar_branch_mac.asm..."
nasm -f macho64 scalar_branch_mac.asm -o scalar_branch_mac.o
if [ $? -ne 0 ]; then
    echo "   Error: scalar_branch_mac.asm assembly failed"
    exit 1
fi
echo "   - scalar_branch_mac.asm"

echo ""
echo "[4/6] Assembling constants_mac.asm..."
nasm -f macho64 constants_mac.asm -o constants_mac.o
if [ $? -ne 0 ]; then
    echo "   Error: constants_mac.asm assembly failed"
    exit 1
fi
echo "   - constants_mac.asm"

echo ""
echo "[5/6] Assembling offset_lea_mac.asm..."
nasm -f macho64 offset_lea_mac.asm -o offset_lea_mac.o
if [ $? -ne 0 ]; then
    echo "   Error: offset_lea_mac.asm assembly failed"
    exit 1
fi
echo "   - offset_lea_mac.asm"

echo ""
echo "[6/6] Assembling simd_loop_mac.asm..."
nasm -f macho64 simd_loop_mac.asm -o simd_loop_mac.o
if [ $? -ne 0 ]; then
    echo "   Error: simd_loop_mac.asm assembly failed"
    exit 1
fi
echo "   - simd_loop_mac.asm"

echo ""
echo "[7/7] Compiling and linking..."
$CC -arch x86_64 main.c scalar_branch_mac.o constants_mac.o offset_lea_mac.o simd_loop_mac.o -o lesson02 -O2
if [ $? -ne 0 ]; then
    echo "   Error: Linking failed"
    exit 1
fi
echo "   - lesson02 created"

echo ""
echo "========================================"
echo "Build SUCCESS!"
echo "Run: ./lesson02"
echo "========================================"
