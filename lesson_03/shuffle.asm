; shuffle.asm
; 洗牌示例 - 对应Lesson 3
; 使用NASM语法 (Win64调用约定)
; 编译: nasm -f win64 shuffle.asm -o shuffle.obj

section .data

align 16
shuffle_mask: db 4, 3, 1, 2, -1, 2, 3, 7, 5, 4, 3, 8, 12, 13, 15, -1

align 16
reverse_mask: db 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

align 16
mask_low: dq 0F0F0F0F0F0F0F0Fh, 0F0F0F0F0F0F0F0Fh

section .text

; ============================================================
; 文档中的pshufb示例
; void pshufb_example(uint8_t *src, uint8_t *dst)
; rcx = src, rdx = dst
global pshufb_example
pshufb_example:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rel shuffle_mask]
    pshufb xmm0, xmm1
    movdqu [rdx], xmm0
    ret


; ============================================================
; 反转字节顺序
; void reverse_bytes(uint8_t *src, uint8_t *dst)
global reverse_bytes
reverse_bytes:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rel reverse_mask]
    pshufb xmm0, xmm1
    movdqu [rdx], xmm0
    ret


; ============================================================
; 使用PALIGNR进行字节对齐
; void align_bytes(uint8_t *src, uint8_t *dst)
global align_bytes
align_bytes:
    ; 简化版: 使用固定的8字节偏移演示
    movdqu xmm0, [rcx]
    movdqu xmm1, [rcx + 8]
    palignr xmm0, xmm1, 8
    movdqu [rdx], xmm0
    ret


; ============================================================
; 混合洗牌 - 半字节交换
; void swap_nibbles(uint8_t *src, uint8_t *dst)
global swap_nibbles
swap_nibbles:
    movdqu xmm0, [rcx]
    movdqu xmm1, xmm0
    movdqu xmm2, [rel mask_low]
    pand xmm0, xmm2
    pand xmm1, xmm2
    psllw xmm0, 4
    psrlw xmm1, 4
    packuswb xmm0, xmm1
    movdqu [rdx], xmm0
    ret
