; alignment.asm
; 对齐示例 - 对应Lesson 3
; 使用NASM语法
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
; rdi = src, rsi = dst, rdx = count
global aligned_load_store
aligned_load_store:
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
    ret


; ============================================================
; 使用movdqu (未对齐加载/存储) - 任意对齐
; void unaligned_load_store(uint8_t *src, uint8_t *dst, int count)
global unaligned_load_store
unaligned_load_store:
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
global hybrid_load_store
hybrid_load_store:
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
global avx_aligned_load_store
avx_aligned_load_store:
    push rbx
    
    mov rbx, rdx
    shr rbx, 5          ; 32字节块
    test rbx, rbx
    jz .remainder_avx
    
.loop_avx:
    ; 使用vmovdqa (AVX对齐加载)
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
global is_aligned
is_aligned:
    mov rax, rdi
    and rax, rsi        ; alignment是2的幂，所以mask = alignment - 1
    test rax, rax
    jz .aligned
    mov eax, 0
    ret
.aligned:
    mov eax, 1
    ret


; ============================================================
; 强制对齐到栈
; void stack_aligned_example(uint8_t *src, uint8_t *dst, int count)
global stack_aligned_example
stack_aligned_example:
    push rbp
    mov rbp, rsp
    
    ; 分配32字节对齐的栈空间
    sub rsp, 256 + 32
    and rsp, -32        ; 对齐到32字节
    
    ; 保存原始rsi (dst指针)
    push rsi
    
    ; 栈上的对齐缓冲区
    lea rsi, [rsp + 32]
    
    ; 复制源数据到对齐的栈缓冲区
    push rdi
    push rdx
    
    mov rdi, rsi
    xor rcx, rcx
.copy_loop:
    movzx eax, byte [rdx + rcx]
    mov [rdi + rcx], al
    inc rcx
    cmp rcx, rdx
    jl .copy_loop
    
    pop rdx
    pop rdi
    
    ; 现在可以安全使用对齐加载
    mov rcx, rdx
    shr rcx, 4
    test rcx, rcx
    jz .stack_remainder
    
.stack_loop:
    movdqa xmm0, [rsi]
    paddb xmm0, xmm0
    movdqa [rsi], xmm0
    
    add rsi, 16
    dec rcx
    jnz .stack_loop

.stack_remainder:
    mov rcx, rdx
    and rcx, 15
    test rcx, rcx
    jz .stack_done
    
.stack_remainder_loop:
    movzx eax, byte [rsi]
    add al, al
    mov [rsi], al
    
    inc rsi
    dec rcx
    jnz .stack_remainder_loop

.stack_done:
    pop rsi
    mov rsp, rbp
    pop rbp
    ret
