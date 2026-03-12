; alignment_mac.asm
; 对齐示例 - Lesson 3 - macOS version
; Compile: nasm -f macho64 alignment_mac.asm -o alignment_mac.o
;
; macOS uses System V AMD64 ABI calling convention:
; - First 6 integer arguments: RDI, RSI, RDX, RCX, R8, R9
; - Return value: RAX

section .data

; 对齐的变量
align 16
global _aligned_buffer
_aligned_buffer: times 256 db 0

align 32
global _aligned_buffer_32
_aligned_buffer_32: times 64 db 0

align 64
global _aligned_buffer_64
_aligned_buffer_64: times 64 db 0

section .text

; ============================================================
; 使用movdqa (对齐加载/存储) - 16字节对齐
; void aligned_load_store(uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _aligned_load_store
_aligned_load_store:
    push rdi
    push rsi
    push rbx
    
    mov rbx, rdx
    shr rbx, 4          ; 16字节块
    test rbx, rbx
    jz .remainder
    
.loop:
    ; 使用movdqa (对齐加载) - 必须16字节对齐，否则崩溃
    movdqa xmm0, [rdi]
    
    ; 处理
    paddb xmm0, xmm0
    
    ; 使用movdqa (对齐存储)
    movdqa [rsi], xmm0
    
    add rdi, 16
    add rsi, 16
    
    dec rbx
    jnz .loop

.remainder:
    mov rbx, rdx
    and rbx, 15
    test rbx, rbx
    jz .done
    
.remainder_loop:
    movzx eax, byte [rdi]
    add al, al
    mov [rsi], al
    
    inc rdi
    inc rsi
    
    dec rbx
    jnz .remainder_loop

.done:
    pop rbx
    pop rsi
    pop rdi
    ret


; ============================================================
; 使用movdqu (未对齐加载/存储) - 任意对齐
; void unaligned_load_store(uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _unaligned_load_store
_unaligned_load_store:
    push rbx
    
    mov rbx, rdx
    shr rbx, 4
    test rbx, rbx
    jz .remainder_u
    
.loop_u:
    ; movdqu可以处理任意对齐
    movdqu xmm0, [rdi]
    paddb xmm0, xmm0
    movdqu [rsi], xmm0
    
    add rdi, 16
    add rsi, 16
    
    dec rbx
    jnz .loop_u

.remainder_u:
    mov rbx, rdx
    and rbx, 15
    test rbx, rbx
    jz .done_u
    
.remainder_loop_u:
    movzx eax, byte [rdi]
    add al, al
    mov [rsi], al
    
    inc rdi
    inc rsi
    
    dec rbx
    jnz .remainder_loop_u

.done_u:
    pop rbx
    ret


; ============================================================
; 混合使用 - 处理未对齐边界
; void hybrid_load_store(uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _hybrid_load_store
_hybrid_load_store:
    push rbx
    
    ; 先处理未对齐的头部
    test rdi, 15
    jz .check_tail
    
.head_loop:
    movzx eax, byte [rdi]
    add al, al
    mov [rsi], al
    
    inc rdi
    inc rsi
    dec rdx
    
    test rdi, 15
    jnz .head_loop
    jz .check_tail

.check_tail:
    mov rbx, rdx
    shr rbx, 4
    test rbx, rbx
    jz .remainder
    
.loop:
    ; 中间部分对齐，使用movdqa
    movdqa xmm0, [rdi]
    paddb xmm0, xmm0
    movdqa [rsi], xmm0
    
    add rdi, 16
    add rsi, 16
    
    dec rbx
    jnz .loop

.remainder:
    mov rbx, rdx
    and rbx, 15
    test rbx, rbx
    jz .done
    
.remainder_loop:
    movzx eax, byte [rdi]
    add al, al
    mov [rsi], al
    
    inc rdi
    inc rsi
    
    dec rbx
    jnz .remainder_loop

.done:
    pop rbx
    ret


; ============================================================
; AVX对齐示例 (256位)
; void avx_aligned_load_store(uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _avx_aligned_load_store
_avx_aligned_load_store:
    push rbx
    
    mov rbx, rdx
    shr rbx, 5          ; 32字节块
    test rbx, rbx
    jz .remainder_avx
    
.loop_avx:
    ; 使用vmovdqu (AVX未对齐加载)
    vmovdqu ymm0, [rdi]
    vpaddb ymm0, ymm0, ymm0
    vmovdqu [rsi], ymm0
    
    add rdi, 32
    add rsi, 32
    
    dec rbx
    jnz .loop_avx

.remainder_avx:
    mov rbx, rdx
    and rbx, 31
    test rbx, rbx
    jz .done_avx
    
.remainder_loop_avx:
    movzx eax, byte [rdi]
    add al, al
    mov [rsi], al
    
    inc rdi
    inc rsi
    
    dec rbx
    jnz .remainder_loop_avx

.done_avx:
    vzeroupper
    pop rbx
    ret


; ============================================================
; 对齐检测示例
; int is_aligned(const void *ptr, int alignment)
; rdi = ptr, rsi = alignment
; 返回1如果对齐，否则返回0
global _is_aligned
_is_aligned:
    mov rax, rdi
    dec rsi             ; alignment - 1
    and rax, rsi        ; 如果alignment是2的幂，检查低位是否为0
    test rax, rax
    jz .aligned
    mov eax, 0
    ret
.aligned:
    mov eax, 1
    ret
