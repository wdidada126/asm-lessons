; range_expand_mac.asm
; 范围扩展示例 - Lesson 3 - macOS version
; Compile: nasm -f macho64 range_expand_mac.asm -o range_expand_mac.o
;
; macOS uses System V AMD64 ABI calling convention:
; - First 6 integer arguments: RDI, RSI, RDX, RCX, R8, R9
; - Return value: RAX

section .text

; ============================================================
; 无符号字节零扩展到字
; void zero_extend_bytes(uint8_t *src, uint16_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _zero_extend_bytes
_zero_extend_bytes:
    push rdi
    push rsi
    
    mov rbx, rdx
    shr rbx, 3          ; 8字节块
    test rbx, rbx
    jz .remainder_zero
    
.zero_loop:
    ; 加载8字节
    movq xmm0, [rdi]
    
    ; 将m0复制到m1
    movq xmm1, xmm0
    
    ; punpcklbw - 低位字节零扩展到字
    ; m0的低4字节与m2(全0)交错，结果存入m0
    pxor xmm2, xmm2
    punpcklbw xmm0, xmm2
    
    ; punpckhbw - 高位字节零扩展到字
    punpckhbw xmm1, xmm2
    
    ; 存储8个字 (16字节)
    movdqu [rsi], xmm0
    movdqu [rsi + 16], xmm1
    
    add rdi, 8
    add rsi, 32         ; 8个字 = 16字节
    
    dec rbx
    jnz .zero_loop

.remainder_zero:
    mov rbx, rdx
    and rbx, 7
    test rbx, rbx
    jz .done_zero
    
.remainder_zero_loop:
    movzx eax, byte [rdi]
    mov [rsi], ax
    
    inc rdi
    add rsi, 2
    
    dec rbx
    jnz .remainder_zero_loop

.done_zero:
    pop rsi
    pop rdi
    ret


; ============================================================
; 有符号字节符号扩展到字
; void sign_extend_bytes(int8_t *src, int16_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _sign_extend_bytes
_sign_extend_bytes:
    push rdi
    push rsi
    
    mov rbx, rdx
    shr rbx, 3
    test rbx, rbx
    jz .remainder_sign
    
.sign_loop:
    movq xmm0, [rdi]
    movq xmm1, xmm0
    
    ; pcmpgtb - 比较: 如果m2(0) > m0，则结果为全1
    pxor xmm2, xmm2
    pcmpgtb xmm2, xmm0
    
    ; 符号扩展
    punpcklbw xmm0, xmm2
    punpckhbw xmm1, xmm2
    
    movdqu [rsi], xmm0
    movdqu [rsi + 16], xmm1
    
    add rdi, 8
    add rsi, 32
    
    dec rbx
    jnz .sign_loop

.remainder_sign:
    mov rbx, rdx
    and rbx, 7
    test rbx, rbx
    jz .done_sign
    
.remainder_sign_loop:
    movsx ax, byte [rdi]
    mov [rsi], ax
    
    inc rdi
    add rsi, 2
    
    dec rbx
    jnz .remainder_sign_loop

.done_sign:
    pop rsi
    pop rdi
    ret


; ============================================================
; 无符号字饱和打包到字节
; void pack_unsigned_words(uint16_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _pack_unsigned_words
_pack_unsigned_words:
    push rbx
    
    mov rbx, rdx
    shr rbx, 3          ; 8个字块
    test rbx, rbx
    jz .remainder_pack
    
.pack_loop:
    ; 加载8个字
    movdqu xmm0, [rdi]
    movdqu xmm1, [rdi + 16]
    
    ; packuswb - 无符号饱和打包到字节
    ; 超过255的值被饱和到255
    packuswb xmm0, xmm1
    
    ; 存储8字节
    movq [rsi], xmm0
    
    add rdi, 32
    add rsi, 8
    
    dec rbx
    jnz .pack_loop

.remainder_pack:
    mov rbx, rdx
    and rbx, 7
    test rbx, rbx
    jz .done_pack
    
.remainder_pack_loop:
    movzx eax, word [rdi]
    cmp eax, 255
    ja .saturate
    mov [rsi], al
    jmp .next
.saturate:
    mov byte [rsi], 255
.next:
    add rdi, 2
    inc rsi
    
    dec rbx
    jnz .remainder_pack_loop

.done_pack:
    pop rbx
    ret


; ============================================================
; 有符号字饱和打包到字节
; void pack_signed_words(int16_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _pack_signed_words
_pack_signed_words:
    push rbx
    
    mov rbx, rdx
    shr rbx, 3
    test rbx, rbx
    jz .remainder_spack
    
.spack_loop:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rdi + 16]
    
    ; packsswb - 有符号饱和打包到字节
    ; 负值变成0，正值超过127变成127
    packsswb xmm0, xmm1
    
    movq [rsi], xmm0
    
    add rdi, 32
    add rsi, 8
    
    dec rbx
    jnz .spack_loop

.remainder_spack:
    mov rbx, rdx
    and rbx, 7
    test rbx, rbx
    jz .done_spack
    
.remainder_spack_loop:
    movsx eax, word [rdi]
    cmp eax, 127
    jg .saturate_pos
    cmp eax, -128
    jl .saturate_neg
    mov [rsi], al
    jmp .next_spack
.saturate_pos:
    mov byte [rsi], 127
    jmp .next_spack
.saturate_neg:
    mov byte [rsi], -128
.next_spack:
    add rdi, 2
    inc rsi
    
    dec rbx
    jnz .remainder_spack_loop

.done_spack:
    pop rbx
    ret


; ============================================================
; 饱和加法示例
; void saturating_add(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rdi = src1, rsi = src2, rdx = dst, rcx = count
global _saturating_add
_saturating_add:
    push rbx
    
    mov rbx, rcx
    shr rbx, 4
    test rbx, rbx
    jz .remainder_sat
    
.sat_loop:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    paddusb xmm0, xmm1    ; 饱和无符号加法
    movdqu [rdx], xmm0
    
    add rdi, 16
    add rsi, 16
    add rdx, 16
    
    dec rbx
    jnz .sat_loop

.remainder_sat:
    mov rbx, rcx
    and rbx, 15
    test rbx, rbx
    jz .done_sat
    
.remainder_sat_loop:
    movzx eax, byte [rdi]
    add al, byte [rsi]
    jnc .no_overflow
    mov al, 255
.no_overflow:
    mov [rdx], al
    
    inc rdi
    inc rsi
    inc rdx
    
    dec rbx
    jnz .remainder_sat_loop

.done_sat:
    pop rbx
    ret
