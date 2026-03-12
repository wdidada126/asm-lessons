; shuffle.asm
; 洗牌示例 - 对应Lesson 3
; 使用NASM语法
; 编译: nasm -f win64 shuffle.asm -o shuffle.obj

section .data

; 洗牌掩码 - 对应文档中的示例
align 16
shuffle_mask: db 4, 3, 1, 2, -1, 2, 3, 7, 5, 4, 3, 8, 12, 13, 15, -1

; 更多洗牌掩码
; 反转字节顺序
reverse_mask: db 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

; 广播第一个字节到所有位置
broadcast_first: db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; 广播最后一个字节
broadcast_last: db 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15

; 交错掩码 (ab cd ef gh -> aabb ccdd eeff gghh)
interleave_mask_low: db 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7

section .text

; ============================================================
; 文档中的pshufb示例
; void pshufb_example(uint8_t *src, uint8_t *dst)
; rdi = src, rsi = dst
global pshufb_example
pshufb_example:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rel shuffle_mask]
    pshufb xmm0, xmm1       ; 基于mask洗牌
    movdqu [rsi], xmm0
    ret


; ============================================================
; 反转字节顺序
; void reverse_bytes(uint8_t *src, uint8_t *dst)
global reverse_bytes
reverse_bytes:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rel reverse_mask]
    pshufb xmm0, xmm1
    movdqu [rsi], xmm0
    ret


; ============================================================
; 广播单个字节
; void broadcast_byte(uint8_t *src, uint8_t *dst, int index)
; rdi = src, rsi = dst, rdx = index (0-15)
global broadcast_byte
broadcast_byte:
    push rbx
    
    ; 创建广播掩码
    xor rax, rax
    mov al, dl         ; index
    mov [rsp + 8], rax
    
    ; 广播该字节
    movdqu xmm0, [rdi]
    pxor xmm1, xmm1
    
    ; 简单的广播实现：使用pshuflw等
    ; 这里简化处理
    movzx eax, byte [rdi + rdx]
    movdqu xmm0, [rdi]
    
    ; 扩展到字
    movq xmm1, xmm0
    punpcklbw xmm0, xmm1
    punpckhbw xmm1, xmm1
    
    ; 广播
    pshuflw xmm0, xmm0, 0    ; 广播低4字节
    pshufhw xmm1, xmm1, 0    ; 广播高4字节
    
    ; 合并
    punpcklwd xmm0, xmm1
    punpckhwd xmm1, xmm1
    
    movdqu [rsi], xmm0
    
    pop rbx
    ret


; ============================================================
; 字节交换 (奇偶位置交换)
; void swap_bytes(uint8_t *src, uint8_t *dst)
global swap_bytes
swap_bytes:
    movdqu xmm0, [rdi]
    ; 交换奇偶位置: 0<->1, 2<->3, ...
    ; 掩码: 1, 0, 3, 2, 5, 4, 7, 6, ...
    db 0x0F, 0x6E, 0xC9, 0x00  ; 简化版
    ; 使用pshufb
    movdqu xmm1, [rdi]
    ; 更简单的交换方法
    movdqu xmm0, [rdi]
    pxor xmm1, xmm1
    punpcklbw xmm0, xmm1
    punpckhbw xmm1, xmm1
    psllw xmm0, 8
    psrlw xmm1, 8
    packuswb xmm0, xmm1
    movdqu [rsi], xmm0
    ret


; ============================================================
; 提取特定字节
; void extract_bytes(uint8_t *src, uint8_t *dst, uint8_t mask)
global extract_bytes
extract_bytes:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]       ; 加载mask
    
    ; pshufb - 如果mask的MSB被设置，目标字节被清零
    ; 这里的mask指定要保留的位置
    pshufb xmm0, xmm1
    
    movdqu [rsi], xmm0
    ret


; ============================================================
; 使用PSHUFB进行查找表
; void lookup_pshufb(uint8_t *src, uint8_t *dst, uint8_t *table)
; 使用pshufb实现快速查找表
global lookup_pshufb
lookup_pshufb:
    ; 将table加载到xmm1
    movdqu xmm1, [rdx]
    
    ; 使用src作为掩码进行查找
    movdqu xmm0, [rdi]
    pshufb xmm0, xmm1
    
    movdqu [rsi], xmm0
    ret


; ============================================================
; 简单的洗牌 - 选择重新排列
; void simple_shuffle(uint8_t *src, uint8_t *dst, uint8_t *mask)
global simple_shuffle
simple_shuffle:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rdx]
    pshufb xmm0, xmm1
    movdqu [rsi], xmm0
    ret


; ============================================================
; 使用PSHUFLW和PSHUFHW (128位洗牌优化)
; void shuffle_low_high(uint8_t *src, uint8_t *dst)
global shuffle_low_high
shuffle_low_high:
    movdqu xmm0, [rdi]
    
    ; 只洗牌低8字节
    pshuflw xmm1, xmm0, 0x1B   ; 反转低8字节
    
    ; 只洗牌高8字节
    pshufhw xmm2, xmm0, 0x1B   ; 反转高8字节
    
    ; 合并
    punpcklqdq xmm1, xmm2
    
    movdqu [rsi], xmm1
    ret


; ============================================================
; 使用PSWAPD进行双字交换
; void swap_dwords(uint32_t *src, uint32_t *dst)
global swap_dwords
swap_dwords:
    movdqu xmm0, [rdi]
    ; pswapd - 交换双字 (需要MMX/SSE2)
    ; 0,1,2,3 -> 1,0,3,2
    movdqu xmm1, xmm0
    punpckldq xmm0, xmm1
    punpckhdq xmm1, xmm1
    movdqu [rsi], xmm0
    ret


section .data
align 16
mask_low: dq 0F0F0F0F0F0F0F0Fh, 0F0F0F0F0F0F0F0Fh
mask_high: dq 0F0F0F0F0F0F0F0Fh, 0F0F0F0F0F0F0F0Fh

section .text

; ============================================================
; 混合洗牌 - 半字节交换
; void swap_nibbles(uint8_t *src, uint8_t *dst)
global swap_nibbles
swap_nibbles:
    movdqu xmm0, [rdi]
    
    ; 将每个字节分成高低4位
    movdqu xmm1, xmm0
    movdqu xmm2, [rel mask_low]
    pand xmm0, xmm2
    pand xmm1, xmm2
    psllw xmm0, 4
    psrlw xmm1, 4
    packuswb xmm0, xmm1
    
    movdqu [rsi], xmm0
    ret


; ============================================================
; 横向移动 - 字节移位
; void shift_bytes_left(uint8_t *src, uint8_t *dst, int shift)
global shift_bytes_left
shift_bytes_left:
    push rbx
    
    movdqu xmm0, [rdi]
    pxor xmm1, xmm1
    
    ; 创建移位掩码
    mov rbx, rdx
    cmp rbx, 16
    jge .all_zero
    
    ; 使用pshufb进行移位
    ; 简化版：使用punpck
    movdqu xmm1, [rdi]
    psrldq xmm1, 1
    punpcklbw xmm0, xmm1
    
    movdqu [rsi], xmm0
    
    pop rbx
    ret
    
.all_zero:
    pxor xmm0, xmm0
    movdqu [rsi], xmm0
    pop rbx
    ret


; ============================================================
; 使用PALIGNR进行字节对齐
; void align_bytes(uint8_t *src, uint8_t *dst, int offset)
; offset 必须是0-15之间
global align_bytes
align_bytes:
    push rbx
    
    mov rbx, rdx
    
    ; 加载两个16字节块
    movdqu xmm0, [rdi]
    movdqu xmm1, [rdi + 16 - 1]
    
    ; palignr - 字节对齐
    ; 从两个块中选择偏移量后的字节
    ; 使用rbx作为立即数需要先加载到寄存器
    movzx rbx, dl
    palignr xmm0, xmm1, rbxb
    
    movdqu [rsi], xmm0
    
    pop rbx
    ret
