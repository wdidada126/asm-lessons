; range_expand.asm
; 范围扩展示例 - 对应Lesson 3
; 使用NASM语法
; 编译: nasm -f win64 range_expand.asm -o range_expand.obj

section .text

; ============================================================
; 无符号字节零扩展到字
; void zero_extend_bytes(uint8_t *src, uint16_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global zero_extend_bytes
zero_extend_bytes:
    push rbx
    
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
    pop rbx
    ret


; ============================================================
; 有符号字节符号扩展到字
; void sign_extend_bytes(int8_t *src, int16_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global sign_extend_bytes
sign_extend_bytes:
    push rbx
    
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
    pop rbx
    ret


; ============================================================
; 无符号字饱和打包到字节
; void pack_unsigned_words(uint16_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global pack_unsigned_words
pack_unsigned_words:
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
global pack_signed_words
pack_signed_words:
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
; 字节乘法 - 需要先扩展到字
; void multiply_bytes(uint8_t *src1, uint8_t *src2, uint16_t *dst, int count)
; rdi = src1, rsi = src2, rdx = dst, rcx = count
global multiply_bytes
multiply_bytes:
    push rbx
    push r12
    
    mov r12, rcx
    
    mov rbx, r12
    shr rbx, 3
    test rbx, rbx
    jz .remainder_mul
    
.mul_loop:
    ; 加载两个8字节
    movq xmm0, [rdi]
    movq xmm1, [rsi]
    
    ; 零扩展到字
    pxor xmm2, xmm2
    movq xmm3, xmm0
    movq xmm4, xmm1
    punpcklbw xmm0, xmm2
    punpcklbw xmm1, xmm2
    
    ; 字乘法 (pmullw - 打包乘法，低位)
    pmullw xmm0, xmm1
    
    ; 存储结果 (8个字 = 16字节)
    movdqu [rdx], xmm0
    
    add rdi, 8
    add rsi, 8
    add rdx, 16
    
    dec rbx
    jnz .mul_loop

.remainder_mul:
    mov rbx, r12
    and rbx, 7
    test rbx, rbx
    jz .done_mul
    
.remainder_mul_loop:
    movzx eax, byte [rdi]
    movzx ebx, byte [rsi]
    mul ebx             ; ax = al * bl
    mov [rdx], ax
    
    inc rdi
    inc rsi
    add rdx, 2
    
    dec rbx
    jnz .remainder_mul_loop

.done_mul:
    pop r12
    pop rbx
    ret


; ============================================================
; 饱和加法示例
; void saturating_add(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
global saturating_add
saturating_add:
    push rbx
    
    mov rbx, rdx
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
    mov rbx, rdx
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
