#include <stdio.h>
#include <stdint.h>
#include <string.h>

extern void scalar_example(uint64_t *result);
extern void add_values_scalar(uint8_t *src, uint8_t *src2, int count);
extern void scalar_loop_example(int *counter);
extern uint64_t scalar_arithmetic(uint64_t a, uint64_t b, uint64_t c);

extern void add_values_sse2(uint8_t *src, const uint8_t *src2, int count);
extern void add_values_sse2_simple(uint8_t *src, const uint8_t *src2);
extern void subtract_values_sse2(uint8_t *src, const uint8_t *src2, int count);
extern void max_values_sse2(uint8_t *src, const uint8_t *src2, int count);
extern void saturating_add_sse2(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, int count);

void print_bytes(const char *name, uint8_t *data, int count) {
    printf("%s: ", name);
    for (int i = 0; i < count; i++) {
        printf("%d ", data[i]);
    }
    printf("\n");
}

void test_scalar_functions() {
    printf("=== Scalar Functions ===\n\n");
    
    printf("1. scalar_example\n");
    uint64_t result = 0;
    scalar_example(&result);
    printf("   Expected: 15\n");
    printf("   Result: %llu\n\n", (unsigned long long)result);
    
    printf("2. add_values_scalar\n");
    uint8_t src1[16] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
    uint8_t src2[16] = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
    add_values_scalar(src1, src2, 16);
    print_bytes("   Result", src1, 16);
    printf("   Expected: 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17\n\n");
    
    printf("3. scalar_loop_example\n");
    int counter = 0;
    scalar_loop_example(&counter);
    printf("   Expected: 0\n");
    printf("   Result: %d\n\n", counter);
    
    printf("4. scalar_arithmetic\n");
    uint64_t lea_result = scalar_arithmetic(1, 2, 3);
    printf("   Expected: 20 (1 + 2*8 + 3)\n");
    printf("   Result: %llu\n\n", (unsigned long long)lea_result);
}

void test_sse2_functions() {
    printf("=== SIMD (SSE2) Functions ===\n\n");
    
    printf("1. add_values_sse2_simple\n");
    uint8_t simd_src1[16] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
    uint8_t simd_src2[16] = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
    add_values_sse2_simple(simd_src1, simd_src2);
    print_bytes("   Result", simd_src1, 16);
    printf("   Expected: 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17\n\n");
    
    printf("2. add_values_sse2 (20 bytes)\n");
    uint8_t simd_a[32], simd_b[32];
    for (int i = 0; i < 20; i++) { simd_a[i] = 1; simd_b[i] = 20; }
    add_values_sse2(simd_a, simd_b, 20);
    print_bytes("   Result", simd_a, 20);
    printf("   Expected: 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21\n\n");
    
    printf("3. saturating_add_sse2\n");
    uint8_t sat_src1[16] = {250, 250, 250, 250, 10, 10, 10, 10, 100, 100, 100, 100, 1, 2, 3, 4};
    uint8_t sat_src2[16] = {10, 10, 10, 10, 250, 250, 250, 250, 200, 200, 200, 200, 5, 5, 5, 5};
    uint8_t sat_dst[16];
    saturating_add_sse2(sat_dst, sat_src1, sat_src2, 16);
    print_bytes("   Result", sat_dst, 16);
    printf("   Expected: 255 255 255 255 255 255 255 255 255 255 255 255 6 7 8 9\n\n");
    
    printf("4. max_values_sse2\n");
    uint8_t max_src1[16] = {1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75};
    uint8_t max_src2[16] = {75, 70, 65, 60, 55, 50, 45, 40, 35, 30, 25, 20, 15, 10, 5, 1};
    max_values_sse2(max_src1, max_src2, 16);
    print_bytes("   Result", max_src1, 16);
    printf("   Expected: 75 70 65 60 55 50 45 40 40 45 50 55 60 65 70 75\n\n");
}

int main() {
    printf("=========================================\n");
    printf("FFmpeg Assembly Lesson 1 - macOS\n");
    printf("=========================================\n\n");
    
    test_scalar_functions();
    test_sse2_functions();
    
    printf("All tests completed!\n");
    return 0;
}
