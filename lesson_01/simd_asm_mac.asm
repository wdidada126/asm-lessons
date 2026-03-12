; simd_asm_mac.asm
; SIMD vector functions for Lesson 1 - macOS version
; SSE2 instruction set
; Compile: nasm -f macho64 simd_asm_mac.asm -o simd_asm_mac.o
;
; macOS uses System V AMD64 ABI calling convention:
; - First 6 integer arguments: RDI, RSI, RDX, RCX, R8, R9
; - Return value: RAX

section .text

; void add_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; rdi = src, rsi = src2, rdx = count
global _add_values_sse2
_add_values_sse2:
    push rbx
    
    mov rax, rdx
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    paddb xmm0, xmm1
    movdqu [rdi], xmm0
    
    add rdi, 16
    add rsi, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, rdx
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    movzx ebx, byte [rsi]
    add bl, [rdi]
    mov [rdi], bl
    
    inc rdi
    inc rsi
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void saturating_add_sse2(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, int count)
; rdi = dst, rsi = src1, rdx = src2, rcx = count
global _saturating_add_sse2
_saturating_add_sse2:
    push rbx
    
    mov rax, rcx
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rsi]
    movdqu xmm1, [rdx]
    paddusb xmm0, xmm1
    movdqu [rdi], xmm0
    
    add rdi, 16
    add rsi, 16
    add rdx, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, rcx
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    movzx ebx, byte [rsi]
    add bl, [rdx]
    jnc .no_saturate
    mov bl, 255
.no_saturate:
    mov [rdi], bl
    
    inc rdi
    inc rsi
    inc rdx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void max_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; rdi = src, rsi = src2, rdx = count
global _max_values_sse2
_max_values_sse2:
    push rbx
    
    mov rax, rdx
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    pmaxub xmm0, xmm1
    movdqu [rdi], xmm0
    
    add rdi, 16
    add rsi, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, rdx
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    movzx ebx, byte [rdi]
    cmp bl, [rsi]
    ja .skip
    movzx ebx, byte [rsi]
    mov [rdi], bl
.skip:
    inc rdi
    inc rsi
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void add_values_sse2_simple(uint8_t *src, const uint8_t *src2)
; rdi = src, rsi = src2
global _add_values_sse2_simple
_add_values_sse2_simple:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    paddb xmm0, xmm1
    movdqu [rdi], xmm0
    ret


; void subtract_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; rdi = src, rsi = src2, rdx = count
global _subtract_values_sse2
_subtract_values_sse2:
    push rbx
    
    mov rax, rdx
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    psubb xmm0, xmm1
    movdqu [rdi], xmm0
    
    add rdi, 16
    add rsi, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, rdx
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    movzx ebx, byte [rsi]
    sub bl, [rdi]
    mov [rdi], bl
    
    inc rdi
    inc rsi
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret
