#include <stdio.h>
#include <stdint.h>
#include <string.h>

// pointer_offset.asm
extern void add_values_ptr_offset(uint8_t *src, const uint8_t *src2, intptr_t width);
extern void pointer_offset_demo(uint8_t *src, uint8_t *dst, int width);
extern void multi_offset_example(uint8_t *src, uint8_t *dst, int width);
extern void reverse_copy(uint8_t *src, uint8_t *dst, int count);

// alignment.asm
extern void aligned_load_store(uint8_t *src, uint8_t *dst, int count);
extern void unaligned_load_store(uint8_t *src, uint8_t *dst, int count);
extern void hybrid_load_store(uint8_t *src, uint8_t *dst, int count);
extern int is_aligned(const void *ptr, int alignment);

// range_expand.asm
extern void zero_extend_bytes(uint8_t *src, uint16_t *dst, int count);
extern void sign_extend_bytes(int8_t *src, int16_t *dst, int count);
extern void pack_unsigned_words(uint16_t *src, uint8_t *dst, int count);
extern void pack_signed_words(int16_t *src, uint8_t *dst, int count);
extern void multiply_bytes(uint8_t *src1, uint8_t *src2, uint16_t *dst, int count);
extern void saturating_add(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count);

// shuffle.asm
extern void pshufb_example(uint8_t *src, uint8_t *dst);
extern void reverse_bytes(uint8_t *src, uint8_t *dst);
extern void broadcast_byte(uint8_t *src, uint8_t *dst, int index);
extern void lookup_pshufb(uint8_t *src, uint8_t *dst, uint8_t *table);
extern void simple_shuffle(uint8_t *src, uint8_t *dst, uint8_t *mask);

void print_bytes(const char *name, uint8_t *data, int count) {
    printf("%s: ", name);
    for (int i = 0; i < count && i < 32; i++) {
        printf("%d ", data[i]);
    }
    if (count > 32) printf("...");
    printf("\n");
}

void print_words(const char *name, uint16_t *data, int count) {
    printf("%s: ", name);
    for (int i = 0; i < count && i < 16; i++) {
        printf("%d ", data[i]);
    }
    if (count > 16) printf("...");
    printf("\n");
}

void test_pointer_offset() {
    printf("=== 测试1: 指针偏移技巧 ===\n\n");
    
    // 测试 add_values_ptr_offset
    printf("1. add_values_ptr_offset (文档示例)\n");
    uint8_t src1[32], src2[32], dst1[32];
    for (int i = 0; i < 32; i++) {
        src1[i] = i + 1;
        src2[i] = 32 - i;
    }
    memcpy(dst1, src1, 32);
    add_values_ptr_offset(dst1, src2, 32);
    print_bytes("   src1", src1, 16);
    print_bytes("   src2", src2, 16);
    print_bytes("   结果", dst1, 16);
    printf("   预期: 33 33 33 ...\n\n");
    
    // 测试 reverse_copy
    printf("2. reverse_copy\n");
    uint8_t rev_src[] = {1, 2, 3, 4, 5, 6, 7, 8};
    uint8_t rev_dst[8] = {0};
    reverse_copy(rev_src, rev_dst, 8);
    print_bytes("   源", rev_src, 8);
    print_bytes("   反转后", rev_dst, 8);
    printf("   预期: 8 7 6 5 4 3 2 1\n\n");
}

void test_alignment() {
    printf("=== 测试2: 对齐示例 ===\n\n");
    
    // 测试对齐检测
    printf("1. is_aligned\n");
    uint8_t buf[64];
    printf("   buf addr: %p\n", buf);
    printf("   is_aligned(buf, 16): %d (预期: %d)\n", is_aligned(buf, 16), ((uintptr_t)buf % 16) == 0);
    printf("   is_aligned(buf, 32): %d\n", is_aligned(buf, 32));
    printf("\n");
    
    // 测试对齐加载
    printf("2. aligned_load_store vs unaligned_load_store\n");
    uint8_t align_src[64], align_dst1[64], align_dst2[64];
    for (int i = 0; i < 64; i++) align_src[i] = i;
    memset(align_dst1, 0, 64);
    memset(align_dst2, 0, 64);
    
    aligned_load_store(align_src, align_dst1, 64);
    unaligned_load_store(align_src, align_dst2, 64);
    
    printf("   前16字节 - 对齐: ");
    for (int i = 0; i < 16; i++) printf("%d ", align_dst1[i]);
    printf("\n   前16字节 - 非对齐: ");
    for (int i = 0; i < 16; i++) printf("%d ", align_dst2[i]);
    printf("\n\n");
}

void test_range_expand() {
    printf("=== 测试3: 范围扩展 ===\n\n");
    
    // 测试零扩展
    printf("1. zero_extend_bytes (无符号字节->字)\n");
    uint8_t zero_src[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
    uint16_t zero_dst[16] = {0};
    zero_extend_bytes(zero_src, zero_dst, 16);
    print_bytes("   输入(字节)", zero_src, 16);
    print_words("   输出(字)", zero_dst, 16);
    printf("\n");
    
    // 测试符号扩展
    printf("2. sign_extend_bytes (有符号字节->字)\n");
    int8_t sign_src[] = {1, 2, -3, 4, -5, 6, -7, 8};
    int16_t sign_dst[8] = {0};
    sign_extend_bytes(sign_src, sign_dst, 8);
    printf("   输入: ");
    for (int i = 0; i < 8; i++) printf("%d ", sign_src[i]);
    printf("\n   输出: ");
    for (int i = 0; i < 8; i++) printf("%d ", sign_dst[i]);
    printf("\n\n");
    
    // 测试饱和打包
    printf("3. pack_unsigned_words (字->字节, 饱和)\n");
    uint16_t pack_src[] = {100, 200, 300, 400, 50, 60, 70, 80};
    uint8_t pack_dst[8] = {0};
    pack_unsigned_words(pack_src, pack_dst, 8);
    print_words("   输入", pack_src, 8);
    print_bytes("   输出", pack_dst, 8);
    printf("   预期: 100 200 255 255 50 60 70 80 (300,400饱和到255)\n\n");
    
    // 测试饱和加法
    printf("4. saturating_add\n");
    uint8_t sat_a[16], sat_b[16], sat_dst[16];
    for (int i = 0; i < 16; i++) {
        sat_a[i] = 250;
        sat_b[i] = 10;
    }
    saturating_add(sat_a, sat_b, sat_dst, 16);
    print_bytes("   A+B", sat_dst, 16);
    printf("   预期: 255 255 ... (全部饱和到255)\n\n");
}

void test_shuffle() {
    printf("=== 测试4: 洗牌示例 ===\n\n");
    
    // 测试pshufb
    printf("1. pshufb_example (文档示例)\n");
    uint8_t pshufb_src[16], pshufb_dst[16];
    for (int i = 0; i < 16; i++) pshufb_src[i] = i;
    pshufb_example(pshufb_src, pshufb_dst);
    print_bytes("   输入", pshufb_src, 16);
    print_bytes("   输出", pshufb_dst, 16);
    printf("   掩码: 4,3,1,2,-1,2,3,7,5,4,3,8,12,13,15,-1\n\n");
    
    // 测试反转
    printf("2. reverse_bytes\n");
    uint8_t rev_src[16], rev_dst[16];
    for (int i = 0; i < 16; i++) rev_src[i] = i + 1;
    reverse_bytes(rev_src, rev_dst);
    print_bytes("   输入", rev_src, 16);
    print_bytes("   反转", rev_dst, 16);
    printf("   预期: 16 15 14 13 ... 1\n\n");
    
    // 测试广播
    printf("3. broadcast_byte\n");
    uint8_t bc_src[16], bc_dst[16];
    for (int i = 0; i < 16; i++) bc_src[i] = i;
    broadcast_byte(bc_src, bc_dst, 5);  // 广播索引5的值
    print_bytes("   输入", bc_src, 16);
    print_bytes("   广播索引5", bc_dst, 16);
    printf("   预期: 5 5 5 5 5 5 5 5 ...\n\n");
    
    // 测试查找表
    printf("4. lookup_pshufb (查找表)\n");
    uint8_t lut_src[16], lut_dst[16], lut_table[16];
    for (int i = 0; i < 16; i++) {
        lut_src[i] = i;
        lut_table[i] = i * 2;  // 简单映射
    }
    lookup_pshufb(lut_src, lut_dst, lut_table);
    print_bytes("   输入索引", lut_src, 16);
    print_bytes("   表", lut_table, 16);
    print_bytes("   查找结果", lut_dst, 16);
    printf("   预期: 0 2 4 6 8 ... 30\n\n");
}

int main() {
    printf("=========================================\n");
    printf("FFmpeg 汇编语言第三课 - 可运行代码示例\n");
    printf("=========================================\n\n");
    
    test_pointer_offset();
    test_alignment();
    test_range_expand();
    test_shuffle();
    
    printf("=========================================\n");
    printf("所有测试完成!\n");
    printf("=========================================\n");
    
    return 0;
}
