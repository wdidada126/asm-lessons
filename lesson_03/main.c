#include <stdio.h>
#include <stdint.h>
#include <string.h>

extern void add_values_ptr_offset(uint8_t *src, const uint8_t *src2, int width);
extern void reverse_copy(uint8_t *src, uint8_t *dst, int count);
extern void aligned_load_store(uint8_t *src, uint8_t *dst, int count);
extern void unaligned_load_store(uint8_t *src, uint8_t *dst, int count);
extern int is_aligned(const void *ptr, int alignment);
extern void zero_extend_bytes(uint8_t *src, uint16_t *dst, int count);
extern void sign_extend_bytes(int8_t *src, int16_t *dst, int count);
extern void pack_unsigned_words(uint16_t *src, uint8_t *dst, int count);
extern void pack_signed_words(int16_t *src, uint8_t *dst, int count);
extern void saturating_add(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count);
extern void pshufb_example(uint8_t *src, uint8_t *dst);
extern void reverse_bytes(uint8_t *src, uint8_t *dst);
extern void swap_nibbles(uint8_t *src, uint8_t *dst);

void print_bytes(const char *name, uint8_t *data, int count) {
    printf("%s: ", name);
    for (int i = 0; i < count && i < 16; i++) {
        printf("%d ", data[i]);
    }
    printf("\n");
}

int main() {
    printf("=== Lesson 3: Pointer Offset, Alignment, Range Expand, Shuffle ===\n\n");

    // Test 1: Pointer offset - add values
    printf("1. add_values_ptr_offset\n");
    uint8_t src1[32], src2[32], dst1[32];
    for (int i = 0; i < 32; i++) { src1[i] = i + 1; src2[i] = 32 - i; }
    memcpy(dst1, src1, 32);
    print_bytes("   src1", src1, 16);
    print_bytes("   src2", src2, 16);
    add_values_ptr_offset(dst1, src2, 32);
    print_bytes("   result", dst1, 16);
    printf("\n");

    // Test 2: Reverse copy (从后往前复制)
    printf("2. reverse_copy\n");
    uint8_t rev_src[16] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
    uint8_t rev_dst[16] = {0};
    print_bytes("   src", rev_src, 16);
    reverse_copy(rev_src, rev_dst, 16);
    print_bytes("   dst", rev_dst, 16);
    printf("\n");

    // Test 3: Alignment detection
    printf("3. is_aligned\n");
    uint8_t buf[64];
    printf("   buf aligned to 16: %d\n", is_aligned(buf, 16));
    printf("   buf aligned to 32: %d\n", is_aligned(buf, 32));
    printf("\n");

    // Test 4: Zero extend
    printf("4. zero_extend_bytes\n");
    uint8_t ze_src[8] = {1, 2, 3, 4, 5, 6, 7, 8};
    uint16_t ze_dst[8] = {0};
    printf("   input: "); for (int i = 0; i < 8; i++) printf("%d ", ze_src[i]); printf("\n");
    zero_extend_bytes(ze_src, ze_dst, 8);
    printf("   output: "); for (int i = 0; i < 8; i++) printf("%d ", ze_dst[i]); printf("\n\n");

    // Test 5: Sign extend
    printf("5. sign_extend_bytes\n");
    int8_t se_src[8] = {1, 2, -3, 4, -5, 6, -7, 8};
    int16_t se_dst[8] = {0};
    printf("   input: "); for (int i = 0; i < 8; i++) printf("%d ", se_src[i]); printf("\n");
    sign_extend_bytes(se_src, se_dst, 8);
    printf("   output: "); for (int i = 0; i < 8; i++) printf("%d ", se_dst[i]); printf("\n\n");

    // Test 6: Pack unsigned
    printf("6. pack_unsigned_words\n");
    uint16_t pu_src[8] = {100, 200, 300, 400, 50, 60, 70, 80};
    uint8_t pu_dst[8] = {0};
    printf("   input: "); for (int i = 0; i < 8; i++) printf("%d ", pu_src[i]); printf("\n");
    pack_unsigned_words(pu_src, pu_dst, 8);
    printf("   output: "); for (int i = 0; i < 8; i++) printf("%d ", pu_dst[i]); printf("\n\n");

    // Test 7: Saturating add
    printf("7. saturating_add\n");
    uint8_t sat_a[16], sat_b[16], sat_dst[16];
    for (int i = 0; i < 16; i++) { sat_a[i] = 250; sat_b[i] = 10; }
    saturating_add(sat_a, sat_b, sat_dst, 16);
    print_bytes("   result", sat_dst, 16);
    printf("\n");

    // Test 8: pshufb
    printf("8. pshufb_example\n");
    uint8_t pshufb_src[16], pshufb_dst[16];
    for (int i = 0; i < 16; i++) pshufb_src[i] = i;
    print_bytes("   src", pshufb_src, 16);
    pshufb_example(pshufb_src, pshufb_dst);
    print_bytes("   dst", pshufb_dst, 16);
    printf("\n");

    // Test 9: Reverse bytes
    printf("9. reverse_bytes\n");
    uint8_t revb_src[16], revb_dst[16];
    for (int i = 0; i < 16; i++) revb_src[i] = i + 1;
    print_bytes("   src", revb_src, 16);
    reverse_bytes(revb_src, revb_dst);
    print_bytes("   dst", revb_dst, 16);
    printf("\n");

    // Test 10: Swap nibbles
    printf("10. swap_nibbles\n");
    uint8_t nib_src[16], nib_dst[16];
    for (int i = 0; i < 16; i++) nib_src[i] = (i << 4) | (15 - i);
    print_bytes("   src", nib_src, 16);
    swap_nibbles(nib_src, nib_dst);
    print_bytes("   dst", nib_dst, 16);
    printf("\n");

    printf("All tests completed!\n");
    return 0;
}
