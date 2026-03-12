; simd_asm.asm
; SIMD向量汇编函数示例 - 对应Lesson 1中的add_values函数
; 使用SSE2指令集
; 编译: nasm -f win64 simd_asm.asm -o simd_asm.obj

section .text

; void add_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; rdi = src, rsi = src2, rdx = count
; 使用SSE2指令集进行16字节打包字节加法
global add_values_sse2
add_values_sse2:
    ; 保存rbx寄存器（Caller-saved寄存器需要手动保存）
    push rbx
    
    ; 将count转换为16字节块的数量
    mov rax, rdx
    shr rax, 4      ; count / 16
    test rax, rax
    jz .remainder   ; 如果没有完整的16字节块，处理剩余部分
    
.loop:
    ; 加载16字节从src和src2
    movdqu xmm0, [rdi]      ; xmm0 = 16字节从src
    movdqu xmm1, [rsi]      ; xmm1 = 16字节从src2
    
    ; 打包字节加法 (paddb = packed add bytes)
    paddb xmm0, xmm1        ; xmm0[i] = xmm0[i] + xmm1[i]
    
    ; 存储结果回src
    movdqu [rdi], xmm0
    
    ; 更新指针
    add rdi, 16
    add rsi, 16
    
    dec rax
    jnz .loop

.remainder:
    ; 处理剩余的字节（少于16字节的情况）
    mov rax, rdx
    and rax, 15      ; count % 16
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


; void add_values_sse2_simple(uint8_t *src, const uint8_t *src2)
; 简单版本，处理固定的16字节
; rdi = src, rsi = src2
global add_values_sse2_simple
add_values_sse2_simple:
    movdqu xmm0, [rdi]      ; 加载16字节从src
    movdqu xmm1, [rsi]      ; 加载16字节从src2
    paddb xmm0, xmm1        ; 16字节并行加法
    movdqu [rdi], xmm0      ; 存储结果
    
    ret


; void subtract_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; 演示psubb（打包字节减法）
global subtract_values_sse2
subtract_values_sse2:
    push rbx
    
    mov rax, rdx
    shr rax, 4
    test rax, rax
    jz .remainder_sub
    
.loop_sub:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    psubb xmm0, xmm1        ; 打包字节减法
    movdqu [rdi], xmm0
    
    add rdi, 16
    add rsi, 16
    
    dec rax
    jnz .loop_sub

.remainder_sub:
    mov rax, rdx
    and rax, 15
    test rax, rax
    jz .done_sub
    
.remainder_loop_sub:
    movzx ebx, byte [rsi]
    sub bl, [rdi]
    mov [rdi], bl
    
    inc rdi
    inc rsi
    
    dec rax
    jnz .remainder_loop_sub

.done_sub:
    pop rbx
    ret


; void max_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; 演示pmaxub（打包无符号字节最大值）
global max_values_sse2
max_values_sse2:
    push rbx
    
    mov rax, rdx
    shr rax, 4
    test rax, rax
    jz .remainder_max
    
.loop_max:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    pmaxub xmm0, xmm1        ; 打包无符号字节最大值
    movdqu [rdi], xmm0
    
    add rdi, 16
    add rsi, 16
    
    dec rax
    jnz .loop_max

.remainder_max:
    mov rax, rdx
    and rax, 15
    test rax, rax
    jz .done_max
    
.remainder_loop_max:
    movzx ebx, byte [rsi]
    cmp bl, [rdi]
    ja .update_max
    jmp .skip_max
    
.update_max:
    mov [rdi], bl
    
.skip_max:
    inc rdi
    inc rsi
    
    dec rax
    jnz .remainder_loop_max

.done_max:
    pop rbx
    ret


; void average_values_sse2(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, int count)
; 演示pavgub（打包无符号字节平均值）
global average_values_sse2
average_values_sse2:
    push rbx
    
    mov rax, rdx
    shr rax, 4
    test rax, rax
    jz .remainder_avg
    
.loop_avg:
    movdqu xmm0, [rsi]       ; src1
    movdqu xmm1, [rdx]       ; src2
    pavgb xmm0, xmm1         ; 打包无符号字节平均值（带舍入）
    movdqu [rdi], xmm0       ; dst
    
    add rdi, 16
    add rsi, 16
    add rdx, 16
    
    dec rax
    jnz .loop_avg

.remainder_avg:
    mov rax, rdx
    and rax, 15
    test rax, rax
    jz .done_avg
    
.remainder_loop_avg:
    movzx ebx, byte [rsi]
    add ebx, [rdx]
    shr ebx, 1               ; (a + b) / 2
    mov [rdi], bl
    
    inc rdi
    inc rsi
    inc rdx
    
    dec rax
    jnz .remainder_loop_avg

.done_avg:
    pop rbx
    ret


; void multiply_add_sse2(uint8_t *dst, const uint8_t *src, int count)
; 演示pmaddwd（打包乘加：16位乘法，然后32位相加）
; 这是一个简单的饱和加法示例
global multiply_add_sse2
multiply_add_sse2:
    push rbx
    
    mov rax, rdx
    shr rax, 3               ; 8个字（16字节/2）
    test rax, rax
    jz .remainder_ma
    
.loop_ma:
    movdqu xmm0, [rsi]
    movdqa xmm1, xmm0
    pand xmm0, [rel mask_low]       ; 获取低8位
    psrlw xmm1, 8                   ; 获取高8位
    
    ; 这里简化处理，实际应用需要更多操作
    paddw xmm0, xmm1
    
    movdqu [rdi], xmm0
    
    add rdi, 16
    add rsi, 16
    
    dec rax
    jnz .loop_ma

.remainder_ma:
    mov rax, rdx
    and rax, 7
    test rax, rax
    jz .done_ma
    
.remainder_loop_ma:
    movzx ebx, word [rsi]
    add bx, [rdi]
    mov [rdi], bx
    
    add rdi, 2
    add rsi, 2
    
    dec rax
    jnz .remainder_loop_ma

.done_ma:
    pop rbx
    ret


; void saturating_add_sse2(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, int count)
; 演示饱和加法 (paddusb = packed add unsigned saturated bytes)
global saturating_add_sse2
saturating_add_sse2:
    push rbx
    
    mov rax, rdx
    shr rax, 4
    test rax, rax
    jz .remainder_sat
    
.loop_sat:
    movdqu xmm0, [rsi]
    movdqu xmm1, [rdx]
    paddusb xmm0, xmm1       ; 饱和无符号字节加法
    movdqu [rdi], xmm0
    
    add rdi, 16
    add rsi, 16
    add rdx, 16
    
    dec rax
    jnz .loop_sat

.remainder_sat:
    mov rax, rdx
    and rax, 15
    test rax, rax
    jz .done_sat
    
.remainder_loop_sat:
    movzx ebx, byte [rsi]
    add bl, [rdx]
    jnc .no_saturate
    mov bl, 255              ; 饱和到255
    
.no_saturate:
    mov [rdi], bl
    
    inc rdi
    inc rsi
    inc rdx
    
    dec rax
    jnz .remainder_loop_sat

.done_sat:
    pop rbx
    ret


section .data
align 16
mask_low: dq 0FF00FF00FF00FF00h, 0FF00FF00FF00FF00h
