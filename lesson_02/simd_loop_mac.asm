; simd_loop_mac.asm
; SIMD loop examples - Lesson 2 - macOS version
; SSE2/SSSE3 instruction set
; Compile: nasm -f macho64 simd_loop_mac.asm -o simd_loop_mac.o
;
; macOS uses System V AMD64 ABI calling convention:
; - First 6 integer arguments: RDI, RSI, RDX, RCX, R8, R9
; - Return value: RAX

section .text

; void simd_basic_loop(uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _simd_basic_loop
_simd_basic_loop:
    push rbx
    
    mov rax, rdx
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rdi]
    movdqu [rsi], xmm0
    
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
    mov [rsi], bl
    
    inc rdi
    inc rsi
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_zero_demo(uint8_t *dst, int count)
; rdi = dst, rsi = count
global _simd_zero_demo
_simd_zero_demo:
    push rbx
    
    mov rax, rsi
    shr rax, 4
    test rax, rax
    jz .remainder
    
    pxor xmm0, xmm0
    
.loop:
    movdqu [rdi], xmm0
    
    add rdi, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, rsi
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    mov [rdi], byte 0
    
    inc rdi
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_sub_loop(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rdi = src1, rsi = src2, rdx = dst, rcx = count
global _simd_sub_loop
_simd_sub_loop:
    push rbx
    
    mov rax, rcx
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    psubb xmm0, xmm1
    movdqu [rdx], xmm0
    
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
    movzx ebx, byte [rdi]
    sub bl, [rsi]
    mov [rdx], bl
    
    inc rdi
    inc rsi
    inc rdx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_constant_add(uint8_t *dst, uint8_t value, int count)
; rdi = dst, rsi = value, rdx = count
global _simd_constant_add
_simd_constant_add:
    push rbx
    
    mov rax, rsi
    movd xmm1, eax
    pshufb xmm1, xmm1
    pshufb xmm1, xmm1
    
    mov rax, rdx
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rdi]
    paddb xmm0, xmm1
    movdqu [rdi], xmm0
    
    add rdi, 16
    
    dec rax
    jnz .loop

.remainder:
    mov rax, rdx
    and rax, 15
    test rax, rax
    jz .done
    
.remainder_loop:
    add byte [rdi], sil
    
    inc rdi
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_saturating_add(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rdi = src1, rsi = src2, rdx = dst, rcx = count
global _simd_saturating_add
_simd_saturating_add:
    push rbx
    
    mov rax, rcx
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    paddusb xmm0, xmm1
    movdqu [rdx], xmm0
    
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
    movzx ebx, byte [rdi]
    add bl, [rsi]
    jnc .no_sat
    mov bl, 255
.no_sat:
    mov [rdx], bl
    
    inc rdi
    inc rsi
    inc rdx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_max(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rdi = src1, rsi = src2, rdx = dst, rcx = count
global _simd_max
_simd_max:
    push rbx
    
    mov rax, rcx
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    pmaxub xmm0, xmm1
    movdqu [rdx], xmm0
    
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
    movzx ebx, byte [rdi]
    cmp bl, [rsi]
    ja .skip
    movzx ebx, byte [rsi]
.skip:
    mov [rdx], bl
    
    inc rdi
    inc rsi
    inc rdx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret


; void simd_add_loop(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rdi = src1, rsi = src2, rdx = dst, rcx = count
global _simd_add_loop
_simd_add_loop:
    push rbx
    
    mov rax, rcx
    shr rax, 4
    test rax, rax
    jz .remainder
    
.loop:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    paddb xmm0, xmm1
    movdqu [rdx], xmm0
    
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
    movzx ebx, byte [rdi]
    add bl, [rsi]
    mov [rdx], bl
    
    inc rdi
    inc rsi
    inc rdx
    
    dec rax
    jnz .remainder_loop

.done:
    pop rbx
    ret
