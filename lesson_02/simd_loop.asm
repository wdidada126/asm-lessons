; simd_loop.asm
; SIMD loop examples - Lesson 2
; SSE2/SSSE3 instruction set

section .text

; void simd_basic_loop(uint8_t *src, uint8_t *dst, int count)
; rcx = src, rdx = dst, r8 = count
global simd_basic_loop
simd_basic_loop:
    push rbx
    
    mov rax, r8
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    
    add rcx, 16
    add rdx, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, r8
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    movzx ebx, byte [rcx]
    mov [rdx], bl
    
    inc rcx
    inc rdx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_zero_demo(uint8_t *dst, int count)
; rcx = dst, rdx = count
global simd_zero_demo
simd_zero_demo:
    push rbx
    
    mov rax, rdx
    shr rax, 4
    test rax, rax
    jz .remainder
    
    pxor xmm0, xmm0
    
.loop:
    movdqu [rcx], xmm0
    
    add rcx, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, rdx
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    mov [rcx], byte 0
    
    inc rcx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_sub_loop(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rcx = src1, rdx = src2, r8 = dst, r9 = count
global simd_sub_loop
simd_sub_loop:
    push rbx
    
    mov rax, r9
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    psubb xmm0, xmm1
    movdqu [r8], xmm0
    
    add rcx, 16
    add rdx, 16
    add r8, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, r9
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    movzx ebx, byte [rcx]
    sub bl, [rdx]
    mov [r8], bl
    
    inc rcx
    inc rdx
    inc r8
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_constant_add(uint8_t *dst, uint8_t value, int count)
; rcx = dst, rdx = value, r8 = count
global simd_constant_add
simd_constant_add:
    push rbx
    
    mov rax, rdx
    movd xmm1, eax
    pshufb xmm1, xmm1
    pshufb xmm1, xmm1
    
    mov rax, r8
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rcx]
    paddb xmm0, xmm1
    movdqu [rcx], xmm0
    
    add rcx, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, r8
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    add byte [rcx], dl
    
    inc rcx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_saturating_add(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rcx = src1, rdx = src2, r8 = dst, r9 = count
global simd_saturating_add
simd_saturating_add:
    push rbx
    
    mov rax, r9
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    paddusb xmm0, xmm1
    movdqu [r8], xmm0
    
    add rcx, 16
    add rdx, 16
    add r8, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, r9
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    movzx ebx, byte [rcx]
    add bl, [rdx]
    jnc .no_sat
    mov bl, 255
.no_sat:
    mov [r8], bl
    
    inc rcx
    inc rdx
    inc r8
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_max(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rcx = src1, rdx = src2, r8 = dst, r9 = count
global simd_max
simd_max:
    push rbx
    
    mov rax, r9
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    pmaxub xmm0, xmm1
    movdqu [r8], xmm0
    
    add rcx, 16
    add rdx, 16
    add r8, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, r9
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    movzx ebx, byte [rcx]
    cmp bl, [rdx]
    ja .skip
    movzx ebx, byte [rdx]
.skip:
    mov [r8], bl
    
    inc rcx
    inc rdx
    inc r8
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_add_loop(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rcx = src1, rdx = src2, r8 = dst, r9 = count
global simd_add_loop
simd_add_loop:
    push rbx
    
    mov rax, r9
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    paddb xmm0, xmm1
    movdqu [r8], xmm0
    
    add rcx, 16
    add rdx, 16
    add r8, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, r9
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    movzx ebx, byte [rcx]
    add bl, [rdx]
    mov [r8], bl
    
    inc rcx
    inc rdx
    inc r8
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret
