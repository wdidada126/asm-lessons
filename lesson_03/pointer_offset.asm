; pointer_offset.asm
; 指针偏移技巧示例 - 对应Lesson 3
; 使用NASM语法
; 编译: nasm -f win64 pointer_offset.asm -o pointer_offset.obj

section .text

; ============================================================
; 文档中的 add_values 函数示例 - 指针偏移技巧
; void add_values(uint8_t *src, const uint8_t *src2, ptrdiff_t width)
; rdi = src, rsi = src2, rdx = width
global add_values_ptr_offset
add_values_ptr_offset:
    ; width被加到每个指针上，使它们指向缓冲区末尾
    add rdi, rdx
    add rsi, rdx
    
    ; width被取反，变成负值
    neg rdx
    
.loop:
    ; 加载时widthq为负值，第一次迭代指向缓冲区开头
    movdqu xmm0, [rdi + rdx]
    movdqu xmm1, [rsi + rdx]
    
    ; 打包字节加法
    paddb xmm0, xmm1
    
    ; 存储结果
    movdqu [rdi + rdx], xmm0
    
    ; mmsize被加到负的widthq上，逐渐趋近于零
    ; jl = 小于零则跳转
    add rdx, 16         ; mmsize = 16
    jl .loop
    
    ret


; ============================================================
; 简化版本 - 演示指针偏移技巧
; void pointer_offset_demo(uint8_t *src, uint8_t *dst, int width)
; rdi = src, rsi = dst, rdx = width
global pointer_offset_demo
pointer_offset_demo:
    ; 指针移到末尾
    add rdi, rdx
    add rsi, rdx
    neg rdx
    
.loop:
    movzx eax, byte [rdi + rdx]
    mov [rsi + rdx], al
    
    add rdx, 1
    jl .loop
    
    ret


; ============================================================
; 多重偏移示例 - 演示在多次加载/存储中复用偏移量
; void multi_offset_example(uint8_t *src, uint8_t *dst, int width)
; rdi = src, rsi = dst, rdx = width
global multi_offset_example
multi_offset_example:
    push rbx
    
    mov rbx, rdx
    add rdi, rdx
    add rsi, rdx
    neg rdx
    
.loop:
    ; 使用偏移量的倍数 (rdx, rdx+16, rdx+32)
    movdqu xmm0, [rdi + rdx]
    movdqu xmm1, [rdi + rdx + 16]
    movdqu xmm2, [rdi + rdx + 32]
    
    ; 处理
    paddb xmm0, xmm1
    paddb xmm0, xmm2
    
    ; 存储
    movdqu [rsi + rdx], xmm0
    
    ; 更新偏移量 (一次处理48字节)
    add rdx, 48
    jl .loop
    
    pop rbx
    ret


; ============================================================
; 使用scale的偏移技巧
; void scale_offset_example(uint8_t *src, uint16_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global scale_offset_example
scale_offset_example:
    push rbx
    
    ; 计算总字节数
    lea rbx, [rdx * 2]   ; count * 2 (每个uint16_t 2字节)
    add rsi, rbx
    add rdi, rdx         ; count字节
    neg rdx
    
.loop:
    ; src是字节数组，dst是字数组
    movzx eax, byte [rdi + rdx]
    mov [rsi + rdx * 2], ax
    
    add rdx, 1
    jl .loop
    
    pop rbx
    ret


; ============================================================
; 负向遍历数组
; void reverse_copy(uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global reverse_copy
reverse_copy:
    ; 从数组末尾开始
    add rdi, rdx
    add rsi, rdx
    neg rdx
    
.loop:
    dec rdx             ; 先递减，让第一个元素从count-1开始
    movzx eax, byte [rdi + rdx]
    mov [rsi + rdx], al
    
    inc rdx             ; 恢复用于比较
    jnz .loop           ; rdx != 0时继续
    
    ret


; ============================================================
; 双向指针技巧
; void bidirectional_process(uint8_t *start, uint8_t *end, uint8_t *dst)
; rdi = start, rsi = end, rdx = dst
global bidirectional_process
bidirectional_process:
    push rbx
    
    ; 计算长度
    mov rax, rsi
    sub rax, rdi        ; end - start
    
    ; dst从中间向两边扩展
    lea rdx, [rdx + rax]
    neg rax
    
.loop:
    ; 从两端读取
    movzx ebx, byte [rdi + rax]
    movzx ecx, byte [rsi + rax]
    
    ; 写入dst两端
    mov [rdx + rax], bl
    ; 计算右侧地址: rdx - rax + 1
    mov r11, rdx
    sub r11, rax
    inc r11
    mov [r11], cl
    
    add rax, 1
    jnz .loop
    
    pop rbx
    ret
