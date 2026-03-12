; offset_lea.asm
; 偏移量和LEA指令示例 - 对应Lesson 2
; 使用MASM语法

.CODE

; ============================================================
; 1. 基础偏移量示例
; uint64_t get_element(uint64_t *arr, int index)
; rcx = arr, rdx = index
get_element PROC
    mov rax, [rcx + rdx * 8]
    ret
get_element ENDP


; ============================================================
; 2. LEA指令 - 算术运算
; uint64_t lea_arithmetic(uint64_t a, uint64_t b)
; rcx = a, rdx = b
lea_arithmetic PROC
    lea rax, [rcx + rdx * 8]
    ret
lea_arithmetic ENDP


; ============================================================
; 3. LEA指令 - 简化算术
; uint64_t lea_complex(uint64_t a, uint64_t b)
; rcx = a, rdx = b
lea_complex PROC
    lea rax, [rcx + rdx * 8]
    ret
lea_complex ENDP


; ============================================================
; 4. SIMD循环示例
; void simple_simd_loop(const uint8_t *src, uint8_t *dst, int count)
; rcx = src, rdx = dst, r8 = count
simple_simd_loop PROC
    push rbx
    
    mov rbx, r8
    shr rbx, 4
    test rbx, rbx
    jz remainder
    
simd_loop:
    movdqu xmm0, XMMWORD PTR [rcx]
    movdqu xmm1, XMMWORD PTR [rcx + 16]
    
    movdqu XMMWORD PTR [rdx], xmm0
    movdqu XMMWORD PTR [rdx + 16], xmm1
    
    add rcx, 32
    add rdx, 32
    
    dec rbx
    jnz simd_loop

remainder:
    mov rbx, r8
    and rbx, 15
    test rbx, rbx
    jz done
    
remainder_loop:
    movzx eax, BYTE PTR [rcx]
    mov [rdx], al
    
    inc rcx
    inc rdx
    
    dec rbx
    jnz remainder_loop

done:
    pop rbx
    ret
simple_simd_loop ENDP


; ============================================================
; 5. 优化复制
; void optimized_copy(uint8_t *src, uint8_t *dst, int count)
; rcx = src, rdx = dst, r8 = count
optimized_copy PROC
    push rbx
    
    mov rbx, r8
    shr rbx, 4
    test rbx, rbx
    jz remainder_opt
    
opt_loop:
    movdqu xmm0, XMMWORD PTR [rcx]
    movdqu xmm1, XMMWORD PTR [rcx + 16]
    movdqu xmm2, XMMWORD PTR [rcx + 32]
    movdqu xmm3, XMMWORD PTR [rcx + 48]
    
    movdqu XMMWORD PTR [rdx], xmm0
    movdqu XMMWORD PTR [rdx + 16], xmm1
    movdqu XMMWORD PTR [rdx + 32], xmm2
    movdqu XMMWORD PTR [rdx + 48], xmm3
    
    lea rcx, [rcx + 64]
    lea rdx, [rdx + 64]
    
    dec rbx
    jnz opt_loop

remainder_opt:
    mov rbx, r8
    and rbx, 15
    test rbx, rbx
    jz done_opt
    
remainder_loop_opt:
    movzx eax, BYTE PTR [rcx]
    mov [rdx], al
    
    inc rcx
    inc rdx
    
    dec rbx
    jnz remainder_loop_opt

done_opt:
    pop rbx
    ret
optimized_copy ENDP


; ============================================================
; 6. LEA vs ADD比较
; int compare_lea_add(uint64_t a, uint64_t b)
; rcx = a, rdx = b
compare_lea_add PROC
    lea rax, [rcx + rdx]
    
    cmp rax, 10
    ja greater
    mov eax, 0
    ret
greater:
    mov eax, 1
    ret
compare_lea_add ENDP


; ============================================================
; 7. 带偏移的复制 - 简化版本
; void copy_with_offset(uint8_t *src, uint8_t *dst, int count, int offset)
; rcx = src, rdx = dst, r8 = count, r9 = offset
copy_with_offset PROC
    push rbx
    
    mov rbx, r9         ; 保存offset
    
    xor r9, r9
copy_loop:
    lea r11, [rcx + r9]
    add r11, rbx
    movzx eax, BYTE PTR [r11]
    mov [rdx + r9], al
    
    inc r9
    cmp r9, r8
    jl copy_loop
    
    pop rbx
    ret
copy_with_offset ENDP


; ============================================================
; 8. 文档示例 - simple_loop
; void simple_loop_example(const uint8_t *src, uint8_t *dst)
; rcx = src, rdx = dst
simple_loop_example PROC
    push rbx
    
    mov rbx, 3
loop_example:
    movdqu xmm0, XMMWORD PTR [rcx]
    
    ; 计算偏移: rbx*2 + 3 + 16 = rbx*2 + 19
    lea r11, [rbx * 2 + 19]
    movdqu xmm1, XMMWORD PTR [rcx + r11]
    
    paddb xmm0, xmm1
    
    movdqu XMMWORD PTR [rdx], xmm0
    
    add rcx, 16
    add rdx, 16
    
    dec rbx
    jg loop_example
    
    pop rbx
    ret
simple_loop_example ENDP

END
