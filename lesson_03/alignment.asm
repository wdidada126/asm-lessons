; alignment.asm
; 对齐示例 - 对应Lesson 3
; 使用NASM语法 (Win64调用约定)
; 编译: nasm -f win64 alignment.asm -o alignment.obj

section .data

; 对齐到64字节的RODATA段
section .rodata align=64

; 对齐的常量数据
aligned_constants: db 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
align 64
more_constants: db 0

section .data

; 对齐的变量
align 16
global aligned_buffer
aligned_buffer: times 256 db 0

align 32
global aligned_buffer_32
aligned_buffer_32: times 64 db 0

align 64
global aligned_buffer_64
aligned_buffer_64: times 64 db 0

section .text

; ============================================================
; 使用movdqa (对齐加载/存储) - 16字节对齐
; void aligned_load_store(uint8_t *src, uint8_t *dst, int count)
; rcx = src, rdx = dst, r8 = count
global aligned_load_store
aligned_load_store:
    push rcx
    push rdx
    push rbx
    
    mov rbx, r8
    shr rbx, 4          ; 16字节块
    test rbx, rbx
    jz .remainder
    
.loop:
    ; 使用movdqa (对齐加载) - 必须16字节对齐，否则崩溃
    movdqa xmm0, [rcx]
    
    ; 处理
    paddb xmm0, xmm0
    
    ; 使用movdqa (对齐存储)
    movdqa [rdx], xmm0
    
    add rcx, 16
    add rdx, 16
    
    dec rbx
    jnz .loop

.remainder:
    mov rbx, r8
    and rbx, 15
    test rbx, rbx
    jz .done
    
.remainder_loop:
    movzx eax, byte [rcx]
    add al, al
    mov [rdx], al
    
    inc rcx
    inc rdx
    
    dec rbx
    jnz .remainder_loop

.done:
    pop rbx
    pop rdx
    pop rcx
    ret


; ============================================================
; 使用movdqu (未对齐加载/存储) - 任意对齐
; void unaligned_load_store(uint8_t *src, uint8_t *dst, int count)
global unaligned_load_store
unaligned_load_store:
    push rbx
    
    mov rbx, r8
    shr rbx, 4
    test rbx, rbx
    jz .remainder_u
    
.loop_u:
    ; movdqu可以处理任意对齐
    movdqu xmm0, [rcx]
    paddb xmm0, xmm0
    movdqu [rdx], xmm0
    
    add rcx, 16
    add rdx, 16
    
    dec rbx
    jnz .loop_u

.remainder_u:
    mov rbx, r8
    and rbx, 15
    test rbx, rbx
    jz .done_u
    
.remainder_loop_u:
    movzx eax, byte [rcx]
    add al, al
    mov [rdx], al
    
    inc rcx
    inc rdx
    
    dec rbx
    jnz .remainder_loop_u

.done_u:
    pop rbx
    ret


; ============================================================
; 混合使用 - 处理未对齐边界
; void hybrid_load_store(uint8_t *src, uint8_t *dst, int count)
global hybrid_load_store
hybrid_load_store:
    push rbx
    
    ; 先处理未对齐的头部
    test rcx, 15
    jz .check_tail
    
.head_loop:
    movzx eax, byte [rcx]
    add al, al
    mov [rdx], al
    
    inc rcx
    inc rdx
    dec r8
    
    test rcx, 15
    jnz .head_loop
    jz .check_tail

.check_tail:
    mov rbx, r8
    shr rbx, 4
    test rbx, rbx
    jz .remainder
    
.loop:
    ; 中间部分对齐，使用movdqa
    movdqa xmm0, [rcx]
    paddb xmm0, xmm0
    movdqa [rdx], xmm0
    
    add rcx, 16
    add rdx, 16
    
    dec rbx
    jnz .loop

.remainder:
    mov rbx, r8
    and rbx, 15
    test rbx, rbx
    jz .done
    
.remainder_loop:
    movzx eax, byte [rcx]
    add al, al
    mov [rdx], al
    
    inc rcx
    inc rdx
    
    dec rbx
    jnz .remainder_loop

.done:
    pop rbx
    ret


; ============================================================
; AVX对齐示例 (256位)
; void avx_aligned_load_store(uint8_t *src, uint8_t *dst, int count)
global avx_aligned_load_store
avx_aligned_load_store:
    push rbx
    
    mov rbx, r8
    shr rbx, 5          ; 32字节块
    test rbx, rbx
    jz .remainder_avx
    
.loop_avx:
    ; 使用vmovdqa (AVX对齐加载)
    vmovdqu ymm0, [rcx]
    vpaddb ymm0, ymm0, ymm0
    vmovdqu [rdx], ymm0
    
    add rcx, 32
    add rdx, 32
    
    dec rbx
    jnz .loop_avx

.remainder_avx:
    mov rbx, r8
    and rbx, 31
    test rbx, rbx
    jz .done_avx
    
.remainder_loop_avx:
    movzx eax, byte [rcx]
    add al, al
    mov [rdx], al
    
    inc rcx
    inc rdx
    
    dec rbx
    jnz .remainder_loop_avx

.done_avx:
    vzeroupper
    pop rbx
    ret


; ============================================================
; 对齐检测示例
; int is_aligned(const void *ptr, int alignment)
; rcx = ptr, rdx = alignment
; 返回1如果对齐，否则返回0
global is_aligned
is_aligned:
    mov rax, rcx
    dec rdx             ; alignment - 1
    and rax, rdx        ; 如果alignment是2的幂，检查低位是否为0
    test rax, rax
    jz .aligned
    mov eax, 0
    ret
.aligned:
    mov eax, 1
    ret
