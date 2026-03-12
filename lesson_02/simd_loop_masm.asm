; simd_loop.asm
; SIMD循环示例 - 对应Lesson 2
; 使用MASM语法

.DATA

ALIGN 16
ones_vector DQ 0101010101010101h, 0101010101010101h

.CODE

; ============================================================
; 1. SIMD基本循环
; void simd_basic_loop(uint8_t *src, uint8_t *dst, int count)
; rcx = src, rdx = dst, r8 = count
simd_basic_loop PROC
    push rbx
    
    mov rax, r8
    shr rax, 4
    test rax, rax
    jz remainder
    
simd_loop:
    movdqu xmm0, XMMWORD PTR [rcx]
    movdqu XMMWORD PTR [rdx], xmm0
    
    add rcx, 16
    add rdx, 16
    
    dec rax
    jnz simd_loop

remainder:
    mov rax, r8
    and rax, 15
    test rax, rax
    jz done
    
remainder_loop:
    movzx ebx, BYTE PTR [rcx]
    mov [rdx], bl
    
    inc rcx
    inc rdx
    
    dec rax
    jnz remainder_loop

done:
    pop rbx
    ret
simd_basic_loop ENDP


; ============================================================
; 2. PXOR清零
; void simd_zero_demo(uint8_t *dst, int count)
; rcx = dst, rdx = count
simd_zero_demo PROC
    push rbx
    
    mov rbx, rdx
    shr rbx, 4
    test rbx, rbx
    jz remainder_zero
    
zero_loop:
    pxor xmm0, xmm0
    pxor xmm1, xmm1
    
    movdqu XMMWORD PTR [rcx], xmm0
    movdqu XMMWORD PTR [rcx + 16], xmm1
    
    add rcx, 32
    
    dec rbx
    jnz zero_loop

remainder_zero:
    mov rbx, rdx
    and rbx, 15
    test rbx, rbx
    jz done_zero
    
remainder_zero_loop:
    pxor xmm0, xmm0
    movdqu [rcx], xmm0
    
    inc rcx
    dec rbx
    jnz remainder_zero_loop

done_zero:
    pop rbx
    ret
simd_zero_demo ENDP


; ============================================================
; 3. SIMD加法循环
; void simd_add_loop(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rcx = src1, rdx = src2, r8 = dst, [rsp+40] = count
simd_add_loop PROC
    push rbx
    push r12
    
    mov r12, r8
    mov rbx, [rsp + 48]
    shr rbx, 4
    test rbx, rbx
    jz remainder_add
    
add_loop:
    movdqu xmm0, XMMWORD PTR [rcx]
    movdqu xmm1, XMMWORD PTR [rdx]
    paddb xmm0, xmm1
    
    movdqu XMMWORD PTR [r12], xmm0
    
    add rcx, 16
    add rdx, 16
    add r12, 16
    
    dec rbx
    jnz add_loop

remainder_add:
    mov r12, r8
    mov rbx, [rsp + 48]
    and rbx, 15
    test rbx, rbx
    jz done_add
    
remainder_add_loop:
    movzx eax, BYTE PTR [rcx]
    add al, BYTE PTR [rdx]
    mov [r12], al
    
    inc rcx
    inc rdx
    inc r12
    
    dec rbx
    jnz remainder_add_loop

done_add:
    pop r12
    pop rbx
    ret
simd_add_loop ENDP


; ============================================================
; 4. SIMD减法循环
; void simd_sub_loop(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rcx = src1, rdx = src2, r8 = dst, [rsp+40] = count
simd_sub_loop PROC
    push rbx
    push r12
    
    mov r12, r8
    mov rbx, [rsp + 48]
    shr rbx, 4
    test rbx, rbx
    jz remainder_sub
    
sub_loop:
    movdqu xmm0, XMMWORD PTR [rcx]
    movdqu xmm1, XMMWORD PTR [rdx]
    psubb xmm0, xmm1
    
    movdqu XMMWORD PTR [r12], xmm0
    
    add rcx, 16
    add rdx, 16
    add r12, 16
    
    dec rbx
    jnz sub_loop

remainder_sub:
    mov r12, r8
    mov rbx, [rsp + 48]
    and rbx, 15
    test rbx, rbx
    jz done_sub
    
remainder_sub_loop:
    movzx eax, BYTE PTR [rcx]
    sub al, BYTE PTR [rdx]
    mov [r12], al
    
    inc rcx
    inc rdx
    inc r12
    
    dec rbx
    jnz remainder_sub_loop

done_sub:
    pop r12
    pop rbx
    ret
simd_sub_loop ENDP


; ============================================================
; 5. 常量加法
; void simd_constant_add(uint8_t *dst, int count)
; rcx = dst, rdx = count
simd_constant_add PROC
    push rbx
    
    movdqu xmm1, XMMWORD PTR ones_vector
    
    mov rbx, rdx
    shr rbx, 4
    test rbx, rbx
    jz remainder_const
    
const_loop:
    movdqu xmm0, XMMWORD PTR [rcx]
    paddb xmm0, xmm1
    movdqu XMMWORD PTR [rcx], xmm0
    
    add rcx, 16
    
    dec rbx
    jnz const_loop

remainder_const:
    mov rbx, rdx
    and rbx, 15
    test rbx, rbx
    jz done_const
    
remainder_const_loop:
    movzx eax, BYTE PTR [rcx]
    add al, 1
    mov [rcx], al
    
    inc rcx
    
    dec rbx
    jnz remainder_const_loop

done_const:
    pop rbx
    ret
simd_constant_add ENDP


; ============================================================
; 6. 饱和加法
; void simd_saturating_add(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rcx = src1, rdx = src2, r8 = dst, [rsp+40] = count
simd_saturating_add PROC
    push rbx
    push r12
    
    mov r12, r8
    mov rbx, [rsp + 48]
    shr rbx, 4
    test rbx, rbx
    jz remainder_sat
    
sat_loop:
    movdqu xmm0, XMMWORD PTR [rcx]
    movdqu xmm1, XMMWORD PTR [rdx]
    paddusb xmm0, xmm1
    
    movdqu XMMWORD PTR [r12], xmm0
    
    add rcx, 16
    add rdx, 16
    add r12, 16
    
    dec rbx
    jnz sat_loop

remainder_sat:
    mov r12, r8
    mov rbx, [rsp + 48]
    and rbx, 15
    test rbx, rbx
    jz done_sat
    
remainder_sat_loop:
    movzx eax, BYTE PTR [rcx]
    add al, BYTE PTR [rdx]
    jnc no_overflow
    mov al, 255
no_overflow:
    mov [r12], al
    
    inc rcx
    inc rdx
    inc r12
    
    dec rbx
    jnz remainder_sat_loop

done_sat:
    pop r12
    pop rbx
    ret
simd_saturating_add ENDP


; ============================================================
; 7. PMaxUB - 最大值
; void simd_max(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rcx = src1, rdx = src2, r8 = dst, [rsp+40] = count
simd_max PROC
    push rbx
    push r12
    
    mov r12, r8
    mov rbx, [rsp + 48]
    shr rbx, 4
    test rbx, rbx
    jz remainder_max
    
max_loop:
    movdqu xmm0, XMMWORD PTR [rcx]
    movdqu xmm1, XMMWORD PTR [rdx]
    pmaxub xmm0, xmm1
    
    movdqu XMMWORD PTR [r12], xmm0
    
    add rcx, 16
    add rdx, 16
    add r12, 16
    
    dec rbx
    jnz max_loop

remainder_max:
    mov r12, r8
    mov rbx, [rsp + 48]
    and rbx, 15
    test rbx, rbx
    jz done_max
    
remainder_max_loop:
    movzx eax, BYTE PTR [rcx]
    movzx ebx, BYTE PTR [rdx]
    cmp al, bl
    ja keep_a
    mov al, bl
keep_a:
    mov [r12], al
    
    inc rcx
    inc rdx
    inc r12
    
    dec rbx
    jnz remainder_max_loop

done_max:
    pop r12
    pop rbx
    ret
simd_max ENDP

END
