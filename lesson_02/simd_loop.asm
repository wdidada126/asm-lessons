; simd_loop.asm
; SIMD循环示例 - 对应Lesson 2
; 使用SSE2/SSSE3指令集
; 编译: nasm -f win64 simd_loop.asm -o simd_loop.obj

section .data

; 演示用的常量 - 加载到SIMD寄存器
align 16
ones_vector: dq 0x0101010101010101, 0x0101010101010101
twos_vector: dq 0x0202020202020202, 0x0202020202020202

section .text

; ============================================================
; 1. SIMD基本循环 - 16字节块处理
; void simd_basic_loop(uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global simd_basic_loop
simd_basic_loop:
    push rbx
    
    ; 计算16字节块数量
    mov rax, rdx
    shr rax, 4          ; count / 16
    test rax, rax
    jz .remainder
    
.loop:
    ; 加载16字节
    movdqu xmm0, [rdi]
    
    ; 处理 - 这里简单复制
    movdqu [rsi], xmm0
    
    ; 更新指针
    add rdi, 16
    add rsi, 16
    
    dec rax
    jnz .loop

.remainder:
    ; 处理剩余字节
    mov rax, rdx
    and rax, 15         ; count % 16
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


; ============================================================
; 2. 使用PXOR清零SIMD寄存器
; void simd_zero_demo(uint8_t *dst, int count)
; rdi = dst, rsi = count
global simd_zero_demo
simd_zero_demo:
    push rbx
    
    mov rbx, rsi
    shr rbx, 4
    test rbx, rbx
    jz .remainder_zero
    
.loop:
    ; PXOR - SIMD寄存器清零的最佳方法
    pxor xmm0, xmm0
    pxor xmm1, xmm1
    
    ; 存储零向量
    movdqu [rdi], xmm0
    movdqu [rdi + 16], xmm1
    
    add rdi, 32
    
    dec rbx
    jnz .loop

.remainder_zero:
    mov rbx, rsi
    and rbx, 15
    test rbx, rbx
    jz .done_zero
    
.remainder_loop_zero:
    pxor xmm0, xmm0
    movq [rdi], xmm0
    
    inc rdi
    dec rbx
    jnz .remainder_loop_zero

.done_zero:
    pop rbx
    ret


; ============================================================
; 3. SIMD加法循环 - PaddB
; void simd_add_loop(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
; rdi = src1, rsi = src2, rdx = dst, rcx = count
global simd_add_loop
simd_add_loop:
    push r12
    
    mov r12, rcx        ; count
    shr r12, 4
    test r12, r12
    jz .remainder_add
    
.loop_add:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    paddb xmm0, xmm1   ; 打包字节加法
    
    movdqu [rdx], xmm0
    
    add rdi, 16
    add rsi, 16
    add rdx, 16
    
    dec r12
    jnz .loop_add

.remainder_add:
    mov r12, rcx
    and r12, 15
    test r12, r12
    jz .done_add
    
.remainder_loop_add:
    movzx eax, byte [rdi]
    add al, byte [rsi]
    mov [rdx], al
    
    inc rdi
    inc rsi
    inc rdx
    
    dec r12
    jnz .remainder_loop_add

.done_add:
    pop r12
    ret


; ============================================================
; 4. SIMD减法循环 - PsubB
; void simd_sub_loop(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
global simd_sub_loop
simd_sub_loop:
    push r12
    
    mov r12, rcx
    shr r12, 4
    test r12, r12
    jz .remainder_sub
    
.loop_sub:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    psubb xmm0, xmm1
    
    movdqu [rdx], xmm0
    
    add rdi, 16
    add rsi, 16
    add rdx, 16
    
    dec r12
    jnz .loop_sub

.remainder_sub:
    mov r12, rcx
    and r12, 15
    test r12, r12
    jz .done_sub
    
.remainder_loop_sub:
    movzx eax, byte [rdi]
    sub al, byte [rsi]
    mov [rdx], al
    
    inc rdi
    inc rsi
    inc rdx
    
    dec r12
    jnz .remainder_loop_sub

.done_sub:
    pop r12
    ret


; ============================================================
; 5. 使用常量 - 加载常量到SIMD寄存器
; void simd_constant_add(uint8_t *dst, int count)
; rdi = dst, rsi = count
global simd_constant_add
simd_constant_add:
    push rbx
    
    ; 加载常量到xmm1
    movdqu xmm1, [rel ones_vector]
    
    mov rbx, rsi
    shr rbx, 4
    test rbx, rbx
    jz .remainder_const
    
.loop_const:
    movdqu xmm0, [rdi]
    paddb xmm0, xmm1   ; 每个字节加1
    movdqu [rdi], xmm0
    
    add rdi, 16
    
    dec rbx
    jnz .loop_const

.remainder_const:
    mov rbx, rsi
    and rbx, 15
    test rbx, rbx
    jz .done_const
    
.remainder_loop_const:
    movzx eax, byte [rdi]
    add al, 1
    mov [rdi], al
    
    inc rdi
    
    dec rbx
    jnz .remainder_loop_const

.done_const:
    pop rbx
    ret


; ============================================================
; 6. 双通道SIMD处理
; void simd_dual_channel(uint8_t *ch1, uint8_t *ch2, uint8_t *dst, int count)
; rdi = ch1, rsi = ch2, rdx = dst, rcx = count
global simd_dual_channel
simd_dual_channel:
    push r12
    
    mov r12, rcx
    shr r12, 4
    test r12, r12
    jz .remainder_dual
    
.loop_dual:
    movdqu xmm0, [rdi]      ; 通道1
    movdqu xmm1, [rsi]     ; 通道2
    
    ; 交换通道
    movdqu [rdx], xmm1
    movdqu [rdx + 16], xmm0
    
    add rdi, 16
    add rsi, 16
    add rdx, 32
    
    dec r12
    jnz .loop_dual

.remainder_dual:
    mov r12, rcx
    and r12, 15
    test r12, r12
    jz .done_dual
    
.remainder_loop_dual:
    movzx eax, byte [rdi]
    movzx ebx, byte [rsi]
    mov [rdx], bl
    mov [rdx + 1], al
    
    inc rdi
    inc rsi
    inc rdx
    inc rdx
    
    dec r12
    jnz .remainder_loop_dual

.done_dual:
    pop r12
    ret


; ============================================================
; 7. 使用LEA优化指针更新
; void simd_lea_optimized(uint8_t *src, uint8_t *dst, int count)
global simd_lea_optimized
simd_lea_optimized:
    push rbx
    
    mov rbx, rdx
    shr rbx, 4
    test rbx, rbx
    jz .remainder_lea_opt
    
.loop_lea_opt:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rdi + 16]
    movdqu xmm2, [rdi + 32]
    movdqu xmm3, [rdi + 48]
    
    movdqu [rsi], xmm0
    movdqu [rsi + 16], xmm1
    movdqu [rsi + 32], xmm2
    movdqu [rsi + 48], xmm3
    
    ; 使用LEA更新指针 - 不改变FLAGS
    lea rdi, [rdi + 64]
    lea rsi, [rsi + 64]
    
    dec rbx
    jnz .loop_lea_opt

.remainder_lea_opt:
    mov rbx, rdx
    and rbx, 15
    test rbx, rbx
    jz .done_lea_opt
    
.remainder_loop_lea_opt:
    movzx eax, byte [rdi]
    mov [rsi], al
    
    lea rdi, [rdi + 1]
    lea rsi, [rsi + 1]
    
    dec rbx
    jnz .remainder_loop_lea_opt

.done_lea_opt:
    pop rbx
    ret


; ============================================================
; 8. 饱和加法 - SaddB
; void simd_saturating_add(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
global simd_saturating_add
simd_saturating_add:
    push r12
    
    mov r12, rcx
    shr r12, 4
    test r12, r12
    jz .remainder_sat
    
.loop_sat:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    paddusb xmm0, xmm1  ; 饱和无符号字节加法
    
    movdqu [rdx], xmm0
    
    add rdi, 16
    add rsi, 16
    add rdx, 16
    
    dec r12
    jnz .loop_sat

.remainder_sat:
    mov r12, rcx
    and r12, 15
    test r12, r12
    jz .done_sat
    
.remainder_loop_sat:
    movzx eax, byte [rdi]
    add al, byte [rsi]
    jnc .no_overflow
    mov al, 255
.no_overflow:
    mov [rdx], al
    
    inc rdi
    inc rsi
    inc rdx
    
    dec r12
    jnz .remainder_loop_sat

.done_sat:
    pop r12
    ret


; ============================================================
; 9. PMaxUB - 最大值
; void simd_max(uint8_t *src1, uint8_t *src2, uint8_t *dst, int count)
global simd_max
simd_max:
    push r12
    
    mov r12, rcx
    shr r12, 4
    test r12, r12
    jz .remainder_max
    
.loop_max:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    pmaxub xmm0, xmm1
    
    movdqu [rdx], xmm0
    
    add rdi, 16
    add rsi, 16
    add rdx, 16
    
    dec r12
    jnz .loop_max

.remainder_max:
    mov r12, rcx
    and r12, 15
    test r12, r12
    jz .done_max
    
.remainder_loop_max:
    movzx eax, byte [rdi]
    movzx ebx, byte [rsi]
    cmp al, bl
    ja .keep_a
    mov al, bl
.keep_a:
    mov [rdx], al
    
    inc rdi
    inc rsi
    inc rdx
    
    dec r12
    jnz .remainder_loop_max

.done_max:
    pop r12
    ret
