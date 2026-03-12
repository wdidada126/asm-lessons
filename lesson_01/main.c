#include <stdio.h>
#include <stdint.h>
#include <string.h>

// 标量汇编函数声明
extern void scalar_example(uint64_t *result);
extern void add_values_scalar(uint8_t *src, uint8_t *src2, int count);
extern void scalar_loop_example(int *counter);
extern uint64_t scalar_arithmetic(uint64_t a, uint64_t b, uint64_t c);

// SIMD汇编函数声明
extern void add_values_sse2(uint8_t *src, const uint8_t *src2, int count);
extern void add_values_sse2_simple(uint8_t *src, const uint8_t *src2);
extern void subtract_values_sse2(uint8_t *src, const uint8_t *src2, int count);
extern void max_values_sse2(uint8_t *src, const uint8_t *src2, int count);
extern void average_values_sse2(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, int count);
extern void saturating_add_sse2(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, int count);

// 打印字节数组（用于调试）
void print_bytes(const char *name, uint8_t *data, int count) {
    printf("%s: ", name);
    for (int i = 0; i < count; i++) {
        printf("%d ", data[i]);
    }
    printf("\n");
}

// 测试标量函数
void test_scalar_functions() {
    printf("=== 标量汇编函数测试 ===\n\n");
    
    // 测试 scalar_example
    printf("1. scalar_example - 基础算术操作\n");
    uint64_t result = 0;
    scalar_example(&result);
    printf("   预期: 3 + 1 - 1 * 5 = 15\n");
    printf("   结果: %lu\n\n", result);
    
    // 测试 add_values_scalar
    printf("2. add_values_scalar - 标量数组加法\n");
    uint8_t src1[16] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
    uint8_t src2[16] = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
    add_values_scalar(src1, src2, 16);
    print_bytes("   结果", src1, 16);
    printf("   预期: 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17\n\n");
    
    // 测试 scalar_loop_example
    printf("3. scalar_loop_example - 循环示例\n");
    int counter = 0;
    scalar_loop_example(&counter);
    printf("   预期: 循环3次后结果为 0\n");
    printf("   结果: %d\n\n", counter);
    
    // 测试 scalar_arithmetic (lea指令)
    printf("4. scalar_arithmetic - LEA指令算术\n");
    uint64_t lea_result = scalar_arithmetic(1, 2, 3);
    printf("   预期: 1 + 2*8 + 3 = 1 + 16 + 3 = 20\n");
    printf("   结果: %lu\n\n", lea_result);
}

// 测试SIMD函数
void test_sse2_functions() {
    printf("=== SIMD (SSE2) 汇编函数测试 ===\n\n");
    
    // 测试 add_values_sse2_simple
    printf("1. add_values_sse2_simple - 简单16字节加法\n");
    uint8_t simd_src1[16] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
    uint8_t simd_src2[16] = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
    add_values_sse2_simple(simd_src1, simd_src2);
    print_bytes("   结果", simd_src1, 16);
    printf("   预期: 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17\n\n");
    
    // 重置数据
    memcpy(simd_src1, (uint8_t[16]){1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}, 16);
    memcpy(simd_src2, (uint8_t[16]){16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1}, 16);
    
    // 测试 add_values_sse2 (带计数)
    printf("2. add_values_sse2 - 带计数的16字节块加法\n");
    add_values_sse2(simd_src1, simd_src2, 16);
    print_bytes("   结果", simd_src1, 16);
    printf("   预期: 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17\n\n");
    
    // 测试 add_values_sse2 处理剩余字节
    memcpy(simd_src1, (uint8_t[20]){1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}, 20);
    memcpy(simd_src2, (uint8_t[20]){20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1}, 20);
    printf("3. add_values_sse2 - 处理20字节（16+4剩余）\n");
    add_values_sse2(simd_src1, simd_src2, 20);
    print_bytes("   结果", simd_src1, 20);
    printf("   预期: 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21\n\n");
    
    // 测试 saturating_add_sse2 (饱和加法)
    printf("4. saturating_add_sse2 - 饱和加法（255上限）\n");
    uint8_t sat_src1[16] = {250, 250, 250, 250, 10, 10, 10, 10, 100, 100, 100, 100, 1, 2, 3, 4};
    uint8_t sat_src2[16] = {10, 10, 10, 10, 250, 250, 250, 250, 200, 200, 200, 200, 5, 5, 5, 5};
    saturating_add_sse2(simd_src1, sat_src1, sat_src2, 16);
    print_bytes("   结果", simd_src1, 16);
    printf("   预期: 255 255 255 255 255 255 255 255 255 255 255 255 6 7 8 9 (饱和到255)\n\n");
    
    // 测试 max_values_sse2
    printf("5. max_values_sse2 - 取最大值\n");
    uint8_t max_src1[16] = {1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75};
    uint8_t max_src2[16] = {75, 70, 65, 60, 55, 50, 45, 40, 35, 30, 25, 20, 15, 10, 5, 1};
    max_values_sse2(max_src1, max_src2, 16);
    print_bytes("   结果", max_src1, 16);
    printf("   预期: 75 70 65 60 55 50 45 40 40 45 50 55 60 65 70 75\n\n");
}

int main() {
    printf("=========================================\n");
    printf("FFmpeg 汇编语言第一课 - 可运行代码示例\n");
    printf("=========================================\n\n");
    printf("操作系统: Windows 64-bit\n");
    printf("汇编器: NASM\n");
    printf("编译器: GCC (MinGW-w64)\n\n");
    
    test_scalar_functions();
    test_sse2_functions();
    
    printf("=========================================\n");
    printf("所有测试完成！\n");
    printf("=========================================\n");
    
    return 0;
}
