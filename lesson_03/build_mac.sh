#!/bin/bash
# Mac build script for lesson_03

set -e

echo "========================================"
echo "FFmpeg Assembly Lesson 3 - Mac Build"
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
echo "[3/6] Assembling pointer_offset_mac.asm..."
nasm -f macho64 pointer_offset_mac.asm -o pointer_offset_mac.o
if [ $? -ne 0 ]; then
    echo "   Error: pointer_offset_mac.asm assembly failed"
    exit 1
fi
echo "   - pointer_offset_mac.asm"

echo ""
echo "[4/6] Assembling alignment_mac.asm..."
nasm -f macho64 alignment_mac.asm -o alignment_mac.o
if [ $? -ne 0 ]; then
    echo "   Error: alignment_mac.asm assembly failed"
    exit 1
fi
echo "   - alignment_mac.asm"

echo ""
echo "[5/6] Assembling range_expand_mac.asm..."
nasm -f macho64 range_expand_mac.asm -o range_expand_mac.o
if [ $? -ne 0 ]; then
    echo "   Error: range_expand_mac.asm assembly failed"
    exit 1
fi
echo "   - range_expand_mac.asm"

echo ""
echo "[6/6] Assembling shuffle_mac.asm..."
nasm -f macho64 shuffle_mac.asm -o shuffle_mac.o
if [ $? -ne 0 ]; then
    echo "   Error: shuffle_mac.asm assembly failed"
    exit 1
fi
echo "   - shuffle_mac.asm"

echo ""
echo "[7/7] Compiling and linking..."
$CC -arch x86_64 main.c pointer_offset_mac.o alignment_mac.o range_expand_mac.o shuffle_mac.o -o lesson03 -O2
if [ $? -ne 0 ]; then
    echo "   Error: Linking failed"
    exit 1
fi
echo "   - lesson03 created"

echo ""
echo "========================================"
echo "Build SUCCESS!"
echo "Run: ./lesson03"
echo "========================================"
