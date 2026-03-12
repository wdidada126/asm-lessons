#include <stdio.h>
#include <stdint.h>
#include <string.h>

// ============================================================
// scalar_branch.asm 函数声明
// ============================================================
extern void do_while_loop(int *counter);
extern void for_loop_example(int *counter);
extern void conditional_jumps(int a, int b, int *result);
extern void xor_zero_example(uint64_t *result);
extern int64_t sum_array(int64_t *arr, int count);
extern int64_t find_max(int64_t *arr, int count);
extern int count_positive(int64_t *arr, int count);

// ============================================================
// constants.asm 函数声明
// ============================================================
extern void load_constants(uint8_t *dest);
extern void fill_zeros(uint8_t *dest, int count);
extern void load_aligned(uint8_t *dest);
extern uint8_t lookup_table(int index);
extern void load_words(uint16_t *dest);
extern void load_qwords(uint64_t *dest);

// ============================================================
// offset_lea.asm 函数声明
// ============================================================
extern uint64_t get_element(uint64_t *arr, int index);
extern uint64_t get_element_offset(uint64_t *arr, int index, int offset);
extern uint64_t* calculate_address(uint64_t *base, int index);
extern uint64_t lea_arithmetic(uint64_t a, uint64_t b);
extern uint64_t lea_complex(uint64_t a, uint64_t b, uint64_t c);
extern void simple_simd_loop(const uint8_t *src, uint8_t *dst, int count);
extern void multi_type_array(uint8_t *byte_arr, uint16_t *word_arr, 
                            uint32_t *dword_arr, uint64_t *qword_arr, int index);
extern void copy_with_offset(uint8_t *src, uint8_t *dst, int count, int src_offset, int dst_offset);
extern int compare_lea_add(uint64_t a, uint64_t b);
extern void optimized_copy(uint8_t *src, uint8_t *dst, int count);
extern void simple_loop_example(const uint8_t *src, uint8_t *dst);

// ============================================================
// simd_loop.asm 函数声明
// ============================================================
extern void simd_basic_loop(uint8_t *src, uint8_t *dst, int count);
extern void simd_zero_demo(uint8_t *dst, int count);
extern void simd_add_loop(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count);
extern void simd_sub_loop(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count);
extern void simd_constant_add(uint8_t *dst, int count);
extern void simd_dual_channel(uint8_t *ch1, uint8_t *ch2, uint8_t *dst, int count);
extern void simd_lea_optimized(uint8_t *src, uint8_t *dst, int count);
extern void simd_saturating_add(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count);
extern void simd_max(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count);

// 打印辅助函数
void print_array_int64(const char *name, int64_t *arr, int count) {
    printf("%s: ", name);
    for (int i = 0; i < count; i++) {
        printf("%lld ", (long long)arr[i]);
    }
    printf("\n");
}

void print_array_uint8(const char *name, uint8_t *arr, int count) {
    printf("%s: ", name);
    for (int i = 0; i < count; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}

void print_array_uint64(const char *name, uint64_t *arr, int count) {
    printf("%s: ", name);
    for (int i = 0; i < count; i++) {
        printf("%llu ", (unsigned long long)arr[i]);
    }
    printf("\n");
}

// ============================================================
// 测试: 分支和循环
// ============================================================
void test_branch_and_loop() {
    printf("=== 测试1: 分支和循环 ===\n\n");
    
    // 测试 do-while 循环
    printf("1. do_while_loop (计数器从3递减到0)\n");
    int counter1 = 0;
    do_while_loop(&counter1);
    printf("   预期: 0 (循环3次后)\n");
    printf("   结果: %d\n\n", counter1);
    
    // 测试 for 循环模拟
    printf("2. for_loop_example (计数器从0递增到3)\n");
    int counter2 = 0;
    for_loop_example(&counter2);
    printf("   预期: 3 (循环3次后)\n");
    printf("   结果: %d\n\n", counter2);
    
    // 测试条件跳转
    printf("3. conditional_jumps (测试各种跳转条件)\n");
    int results[6] = {0};
    conditional_jumps(5, 5, results);  // a == b
    printf("   a=5, b=5: JE=%d, JNE=%d, JG=%d, JGE=%d, JL=%d, JLE=%d\n\n",
           results[0], results[1], results[2], results[3], results[4], results[5]);
    
    // 测试XOR清零
    printf("4. xor_zero_example\n");
    uint64_t zero_result = 0;
    xor_zero_example(&zero_result);
    printf("   预期: 0\n");
    printf("   结果: %llu\n\n", (unsigned long long)zero_result);
    
    // 测试数组求和
    printf("5. sum_array\n");
    int64_t arr[] = {1, 2, 3, 4, 5};
    int64_t sum = sum_array(arr, 5);
    print_array_int64("   输入数组", arr, 5);
    printf("   预期和: 15\n");
    printf("   结果和: %lld\n\n", (long long)sum);
    
    // 测试查找最大值
    printf("6. find_max\n");
    int64_t arr2[] = {3, 7, 2, 9, 1, 9, 5};
    int64_t max_val = find_max(arr2, 7);
    print_array_int64("   输入数组", arr2, 7);
    printf("   预期最大值: 9\n");
    printf("   结果最大值: %lld\n\n", (long long)max_val);
    
    // 测试条件计数
    printf("7. count_positive\n");
    int64_t arr3[] = {-3, 5, -2, 8, 0, -1, 7};
    int pos_count = count_positive(arr3, 7);
    print_array_int64("   输入数组", arr3, 7);
    printf("   预期正数个数: 3 (5, 8, 7)\n");
    printf("   结果正数个数: %d\n\n", pos_count);
}

// ============================================================
// 测试: 常量
// ============================================================
void test_constants() {
    printf("=== 测试2: 常量定义 ===\n\n");
    
    printf("1. load_constants\n");
    uint8_t dest[4] = {0};
    load_constants(dest);
    printf("   预期: 1 2 3 4\n");
    print_array_uint8("   结果", dest, 4);
    printf("\n");
    
    printf("2. lookup_table (查找表)\n");
    for (int i = 0; i < 4; i++) {
        uint8_t val = lookup_table(i);
        printf("   index[%d] = %d\n", i, val);
    }
    printf("\n");
    
    printf("3. load_words\n");
    uint16_t words[4] = {0};
    load_words(words);
    printf("   预期: 100 200 300 400\n");
    printf("   结果: ");
    for (int i = 0; i < 4; i++) printf("%d ", words[i]);
    printf("\n\n");
    
    printf("4. load_qwords\n");
    uint64_t qwords[4] = {0};
    load_qwords(qwords);
    printf("   预期: 10000 20000 30000 40000\n");
    print_array_uint64("   结果", qwords, 4);
    printf("\n");
}

// ============================================================
// 测试: 偏移量和LEA
// ============================================================
void test_offset_lea() {
    printf("=== 测试3: 偏移量和LEA ===\n\n");
    
    printf("1. get_element (偏移量访问)\n");
    uint64_t arr[] = {10, 20, 30, 40, 50};
    printf("   数组: ");
    for (int i = 0; i < 5; i++) printf("%llu ", (unsigned long long)arr[i]);
    printf("\n");
    printf("   arr[2] = %llu (预期: 30)\n\n", (unsigned long long)get_element(arr, 2));
    
    printf("2. lea_arithmetic (LEA指令算术)\n");
    uint64_t lea_result = lea_arithmetic(5, 3);  // 5 + 3*8 = 29
    printf("   a=5, b=3, 计算 a + b*8 = 5 + 24 = 29\n");
    printf("   结果: %llu\n\n", (unsigned long long)lea_result);
    
    printf("3. lea_complex (复杂LEA)\n");
    uint64_t lea_complex_result = lea_complex(1, 2, 3);  // 1 + 2*8 + 3 = 20
    printf("   a=1, b=2, c=3, 计算 a + b*8 + c = 1 + 16 + 3 = 20\n");
    printf("   结果: %llu\n\n", (unsigned long long)lea_complex_result);
    
    printf("4. copy_with_offset (带偏移量复制)\n");
    uint8_t src[] = {1, 2, 3, 4, 5, 6, 7, 8};
    uint8_t dst[16] = {0};
    copy_with_offset(src, dst, 4, 2, 5);
    printf("   源数组[偏移2]: ");
    for (int i = 0; i < 8; i++) printf("%d ", src[i]);
    printf("\n");
    printf("   目标数组[偏移5开始]: ");
    for (int i = 0; i < 16; i++) printf("%d ", dst[i]);
    printf("\n   预期: 前5个0, 然后 3 4 5 6\n\n");
    
    printf("5. compare_lea_add (LEA vs ADD)\n");
    int cmp_result1 = compare_lea_add(3, 5);  // 3+5=8 <= 10, 返回0
    int cmp_result2 = compare_lea_add(6, 6);   // 6+6=12 > 10, 返回1
    printf("   compare_lea_add(3, 5): 3+5=8 <= 10, 预期: 0, 结果: %d\n", cmp_result1);
    printf("   compare_lea_add(6, 6): 6+6=12 > 10, 预期: 1, 结果: %d\n\n", cmp_result2);
    
    printf("6. optimized_copy (使用LEA优化)\n");
    uint8_t src2[64], dst2[64];
    for (int i = 0; i < 64; i++) src2[i] = i + 1;
    optimized_copy(src2, dst2, 64);
    printf("   前16字节: ");
    for (int i = 0; i < 16; i++) printf("%d ", dst2[i]);
    printf("\n   预期: 1 2 3 ... 16\n\n");
}

// ============================================================
// 测试: SIMD循环
// ============================================================
void test_simd_loop() {
    printf("=== 测试4: SIMD循环 ===\n\n");
    
    printf("1. simd_basic_loop (基本SIMD循环)\n");
    uint8_t src1[32], dst1[32];
    for (int i = 0; i < 32; i++) src1[i] = i + 1;
    simd_basic_loop(src1, dst1, 32);
    print_array_uint8("   输入", src1, 32);
    print_array_uint8("   输出", dst1, 32);
    printf("\n");
    
    printf("2. simd_zero_demo (PXOR清零)\n");
    uint8_t zeros[32];
    for (int i = 0; i < 32; i++) zeros[i] = 0xFF;
    simd_zero_demo(zeros, 32);
    print_array_uint8("   输出(应全为0)", zeros, 32);
    printf("\n");
    
    printf("3. simd_add_loop (打包字节加法)\n");
    uint8_t a2[32], b2[32], dst2[32];
    for (int i = 0; i < 32; i++) {
        a2[i] = i + 1;
        b2[i] = 32 - i;
    }
    simd_add_loop(a2, b2, dst2, 32);
    print_array_uint8("   A", a2, 32);
    print_array_uint8("   B", b2, 32);
    print_array_uint8("   A+B", dst2, 32);
    printf("   预期: 全部为33\n\n");
    
    printf("4. simd_sub_loop (打包字节减法)\n");
    simd_sub_loop(a2, b2, dst2, 32);
    print_array_uint8("   A-B", dst2, 32);
    printf("   预期: 2*i - 31 (负数截断为0)\n\n");
    
    printf("5. simd_constant_add (常量加法)\n");
    uint8_t c5[32];
    for (int i = 0; i < 32; i++) c5[i] = i;
    simd_constant_add(c5, 32);
    print_array_uint8("   输入+1", c5, 32);
    printf("   预期: 1 2 3 ... 32\n\n");
    
    printf("6. simd_saturating_add (饱和加法)\n");
    uint8_t sat_a[32], sat_b[32], sat_dst[32];
    for (int i = 0; i < 32; i++) {
        sat_a[i] = 250;
        sat_b[i] = 10;
    }
    simd_saturating_add(sat_a, sat_b, sat_dst, 32);
    print_array_uint8("   饱和加法结果", sat_dst, 32);
    printf("   预期: 255 (饱和)\n\n");
    
    printf("7. simd_max (最大值)\n");
    uint8_t max_a[32], max_b[32], max_dst[32];
    for (int i = 0; i < 32; i++) {
        max_a[i] = i;
        max_b[i] = 31 - i;
    }
    simd_max(max_a, max_b, max_dst, 32);
    print_array_uint8("   A", max_a, 32);
    print_array_uint8("   B", max_b, 32);
    print_array_uint8("   max(A,B)", max_dst, 32);
    printf("   预期: 15 15 15 ... 15\n\n");
    
    printf("8. simple_loop_example (文档示例)\n");
    uint8_t doc_src[64], doc_dst[64];
    for (int i = 0; i < 64; i++) doc_src[i] = i + 1;
    simple_loop_example(doc_src, doc_dst);
    print_array_uint8("   源", doc_src, 64);
    print_array_uint8("   目标", doc_dst, 64);
    printf("\n");
}

int main() {
    printf("=========================================\n");
    printf("FFmpeg 汇编语言第二课 - 可运行代码示例\n");
    printf("=========================================\n\n");
    
    test_branch_and_loop();
    test_constants();
    test_offset_lea();
    test_simd_loop();
    
    printf("=========================================\n");
    printf("所有测试完成!\n");
    printf("=========================================\n");
    
    return 0;
}
