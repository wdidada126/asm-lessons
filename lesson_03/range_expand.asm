; range_expand.asm
; 范围扩展示例 - 对应Lesson 3
; 使用NASM语法 (Win64调用约定)
; 编译: nasm -f win64 range_expand.asm -o range_expand.obj

section .text

; ============================================================
; 无符号字节零扩展到字
; void zero_extend_bytes(uint8_t *src, uint16_t *dst, int count)
; rcx = src, rdx = dst, r8 = count
global zero_extend_bytes
zero_extend_bytes:
    push rcx
    push rdx
    
    mov rbx, r8
    shr rbx, 3          ; 8字节块
    test rbx, rbx
    jz .remainder_zero
    
.zero_loop:
    ; 加载8字节
    movq xmm0, [rcx]
    
    ; 将m0复制到m1
    movq xmm1, xmm0
    
    ; punpcklbw - 低位字节零扩展到字
    ; m0的低4字节与m2(全0)交错，结果存入m0
    pxor xmm2, xmm2
    punpcklbw xmm0, xmm2
    
    ; punpckhbw - 高位字节零扩展到字
    punpckhbw xmm1, xmm2
    
    ; 存储8个字 (16字节)
    movdqu [rdx], xmm0
    movdqu [rdx + 16], xmm1
    
    add rcx, 8
    add rdx, 32         ; 8个字 = 16字节
    
    dec rbx
    jnz .zero_loop

.remainder_zero:
    mov rbx, r8
    and rbx, 7
    test rbx, rbx
    jz .done_zero
    
.remainder_zero_loop:
    movzx eax, byte [rcx]
    mov [rdx], ax
    
    inc rcx
    add rdx, 2
    
    dec rbx
    jnz .remainder_zero_loop

.done_zero:
    pop rdx
    pop rcx
    ret


; ============================================================
; 有符号字节符号扩展到字
; void sign_extend_bytes(int8_t *src, int16_t *dst, int count)
; rcx = src, rdx = dst, r8 = count
global sign_extend_bytes
sign_extend_bytes:
    push rcx
    push rdx
    
    mov rbx, r8
    shr rbx, 3
    test rbx, rbx
    jz .remainder_sign
    
.sign_loop:
    movq xmm0, [rcx]
    movq xmm1, xmm0
    
    ; pcmpgtb - 比较: 如果m2(0) > m0，则结果为全1
    pxor xmm2, xmm2
    pcmpgtb xmm2, xmm0
    
    ; 符号扩展
    punpcklbw xmm0, xmm2
    punpckhbw xmm1, xmm2
    
    movdqu [rdx], xmm0
    movdqu [rdx + 16], xmm1
    
    add rcx, 8
    add rdx, 32
    
    dec rbx
    jnz .sign_loop

.remainder_sign:
    mov rbx, r8
    and rbx, 7
    test rbx, rbx
    jz .done_sign
    
.remainder_sign_loop:
    movsx ax, byte [rcx]
    mov [rdx], ax
    
    inc rcx
    add rdx, 2
    
    dec rbx
    jnz .remainder_sign_loop

.done_sign:
    pop rdx
    pop rcx
    ret


; ============================================================
; 无符号字饱和打包到字节
; void pack_unsigned_words(uint16_t *src, uint8_t *dst, int count)
; rcx = src, rdx = dst, r8 = count
global pack_unsigned_words
pack_unsigned_words:
    push rbx
    
    mov rbx, r8
    shr rbx, 3          ; 8个字块
    test rbx, rbx
    jz .remainder_pack
    
.pack_loop:
    ; 加载8个字
    movdqu xmm0, [rcx]
    movdqu xmm1, [rcx + 16]
    
    ; packuswb - 无符号饱和打包到字节
    ; 超过255的值被饱和到255
    packuswb xmm0, xmm1
    
    ; 存储8字节
    movq [rdx], xmm0
    
    add rcx, 32
    add rdx, 8
    
    dec rbx
    jnz .pack_loop

.remainder_pack:
    mov rbx, r8
    and rbx, 7
    test rbx, rbx
    jz .done_pack
    
.remainder_pack_loop:
    movzx eax, word [rcx]
    cmp eax, 255
    ja .saturate
    mov [rdx], al
    jmp .next
.saturate:
    mov byte [rdx], 255
.next:
    add rcx, 2
    inc rdx
    
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
    
    mov rbx, r8
    shr rbx, 3
    test rbx, rbx
    jz .remainder_spack
    
.spack_loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rcx + 16]
    
    ; packsswb - 有符号饱和打包到字节
    ; 负值变成0，正值超过127变成127
    packsswb xmm0, xmm1
    
    movq [rdx], xmm0
    
    add rcx, 32
    add rdx, 8
    
    dec rbx
    jnz .spack_loop

.remainder_spack:
    mov rbx, r8
    and rbx, 7
    test rbx, rbx
    jz .done_spack
    
.remainder_spack_loop:
    movsx eax, word [rcx]
    cmp eax, 127
    jg .saturate_pos
    cmp eax, -128
    jl .saturate_neg
    mov [rdx], al
    jmp .next_spack
.saturate_pos:
    mov byte [rdx], 127
    jmp .next_spack
.saturate_neg:
    mov byte [rdx], -128
.next_spack:
    add rcx, 2
    inc rdx
    
    dec rbx
    jnz .remainder_spack_loop

.done_spack:
    pop rbx
    ret


; ============================================================
; 饱和加法示例
; void saturating_add(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rcx = src1, rdx = src2, r8 = dst, r9 = count
global saturating_add
saturating_add:
    push rbx
    
    mov rbx, r9
    shr rbx, 4
    test rbx, rbx
    jz .remainder_sat
    
.sat_loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    paddusb xmm0, xmm1    ; 饱和无符号加法
    movdqu [r8], xmm0
    
    add rcx, 16
    add rdx, 16
    add r8, 16
    
    dec rbx
    jnz .sat_loop

.remainder_sat:
    mov rbx, r9
    and rbx, 15
    test rbx, rbx
    jz .done_sat
    
.remainder_sat_loop:
    movzx eax, byte [rcx]
    add al, byte [rdx]
    jnc .no_overflow
    mov al, 255
.no_overflow:
    mov [r8], al
    
    inc rcx
    inc rdx
    inc r8
    
    dec rbx
    jnz .remainder_sat_loop

.done_sat:
    pop rbx
    ret
