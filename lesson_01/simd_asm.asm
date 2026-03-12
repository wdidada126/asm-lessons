; simd_asm.asm
; SIMD vector functions for Lesson 1
; SSE2 instruction set
; Compile: nasm -f win64 simd_asm.asm -o simd_asm.obj

section .text

; void add_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; rcx = src, rdx = src2, r8 = count
global add_values_sse2
add_values_sse2:
    push rbx
    
    mov rax, r8
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    paddb xmm0, xmm1
    movdqu [rcx], xmm0
    
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
    movzx ebx, byte [rdx]
    add bl, [rcx]
    mov [rcx], bl
    
    inc rcx
    inc rdx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void saturating_add_sse2(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, int count)
; rcx = dst, rdx = src1, r8 = src2, r9 = count
global saturating_add_sse2
saturating_add_sse2:
    push rbx
    
    mov rax, r9
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rdx]
    movdqu xmm1, [r8]
    paddusb xmm0, xmm1
    movdqu [rcx], xmm0
    
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
    movzx ebx, byte [rdx]
    add bl, [r8]
    jnc .no_saturate
    mov bl, 255
.no_saturate:
    mov [rcx], bl
    
    inc rcx
    inc rdx
    inc r8
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void max_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; rcx = src, rdx = src2, r8 = count
global max_values_sse2
max_values_sse2:
    push rbx
    
    mov rax, r8
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    pmaxub xmm0, xmm1
    movdqu [rcx], xmm0
    
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
    cmp bl, [rdx]
    ja .skip
    movzx ebx, byte [rdx]
    mov [rcx], bl
.skip:
    inc rcx
    inc rdx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void add_values_sse2_simple(uint8_t *src, const uint8_t *src2)
; rcx = src, rdx = src2
global add_values_sse2_simple
add_values_sse2_simple:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    paddb xmm0, xmm1
    movdqu [rcx], xmm0
    ret


; void subtract_values_sse2(uint8_t *src, const uint8_t *src2, int count)
global subtract_values_sse2
subtract_values_sse2:
    push rbx
    
    mov rax, r8
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    psubb xmm0, xmm1
    movdqu [rcx], xmm0
    
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
    movzx ebx, byte [rdx]
    sub bl, [rcx]
    mov [rcx], bl
    
    inc rcx
    inc rdx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret
