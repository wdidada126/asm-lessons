; shuffle_mac.asm
; 洗牌示例 - Lesson 3 - macOS version
; Compile: nasm -f macho64 shuffle_mac.asm -o shuffle_mac.o
;
; macOS uses System V AMD64 ABI calling convention:
; - First 6 integer arguments: RDI, RSI, RDX, RCX, R8, R9
; - Return value: RAX

section .data

align 16
_shuffle_mask: db 4, 3, 1, 2, -1, 2, 3, 7, 5, 4, 3, 8, 12, 13, 15, -1

align 16
_reverse_mask: db 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

align 16
_mask_low: dq 0F0F0F0F0F0F0F0Fh, 0F0F0F0F0F0F0F0Fh

section .text

; ============================================================
; 文档中的pshufb示例
; void pshufb_example(uint8_t *src, uint8_t *dst)
; rdi = src, rsi = dst
global _pshufb_example
_pshufb_example:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rel _shuffle_mask]
    pshufb xmm0, xmm1
    movdqu [rsi], xmm0
    ret


; ============================================================
; 反转字节顺序
; void reverse_bytes(uint8_t *src, uint8_t *dst)
; rdi = src, rsi = dst
global _reverse_bytes
_reverse_bytes:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rel _reverse_mask]
    pshufb xmm0, xmm1
    movdqu [rsi], xmm0
    ret


; ============================================================
; 使用PALIGNR进行字节对齐
; void align_bytes(uint8_t *src, uint8_t *dst)
; rdi = src, rsi = dst
global _align_bytes
_align_bytes:
    ; 简化版: 使用固定的8字节偏移演示
    movdqu xmm0, [rdi]
    movdqu xmm1, [rdi + 8]
    palignr xmm0, xmm1, 8
    movdqu [rsi], xmm0
    ret


; ============================================================
; 混合洗牌 - 半字节交换
; void swap_nibbles(uint8_t *src, uint8_t *dst)
; rdi = src, rsi = dst
global _swap_nibbles
_swap_nibbles:
    movdqu xmm0, [rdi]
    movdqu xmm1, xmm0
    movdqu xmm2, [rel _mask_low]
    pand xmm0, xmm2
    pand xmm1, xmm2
    psllw xmm0, 4
    psrlw xmm1, 4
    packuswb xmm0, xmm1
    movdqu [rsi], xmm0
    ret
