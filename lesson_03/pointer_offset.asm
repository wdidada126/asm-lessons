; pointer_offset.asm
; 指针偏移技巧示例 - 对应Lesson 3
; 使用NASM语法 (Win64调用约定: RCX, RDX, R8, R9)
; 编译: nasm -f win64 pointer_offset.asm -o pointer_offset.obj

section .text

; ============================================================
; 文档中的 add_values 函数示例 - 指针偏移技巧
; void add_values(uint8_t *src, const uint8_t *src2, ptrdiff_t width)
; rcx = src, rdx = src2, r8 = width
global add_values_ptr_offset
add_values_ptr_offset:
    ; 保存原始src
    push rcx
    push rdx
    
    ; width被加到每个指针上，使它们指向缓冲区末尾
    add rcx, r8
    add rdx, r8
    
    ; width被取反，变成负值
    neg r8
    
.loop:
    ; 加载时r8为负值，第一次迭代指向缓冲区开头
    movdqu xmm0, [rcx + r8]
    movdqu xmm1, [rdx + r8]
    
    ; 打包字节加法
    paddb xmm0, xmm1
    
    ; 存储结果
    movdqu [rcx + r8], xmm0
    
    add r8, 16         ; mmsize = 16
    jl .loop
    
    pop rdx
    pop rcx
    ret


; ============================================================
; 指针偏移 - 从后向前遍历
; void reverse_add(uint8_t *src, uint8_t *dst, int width)
; rcx = src, rdx = dst, r8 = width
global reverse_add
reverse_add:
    ; 调整指针指向末尾
    add rcx, r8
    add rdx, r8
    neg r8
    
.loop:
    movzx eax, byte [rcx + r8]
    add eax, eax
    mov [rdx + r8], al
    
    inc r8
    jnz .loop
    ret


; ============================================================
; 指针偏移 - 多指针同时遍历
; void multi_pointer_demo(uint8_t *a, uint8_t *b, uint8_t *c, uint8_t *d, int width)
; rcx=a, rdx=b, r8=c, r9=d, [rsp+32]=width
global multi_pointer_demo
multi_pointer_demo:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    and rsp, -16
    
    ; 保存width到栈
    mov [rsp+24], r10
    
    ; 调整所有指针
    mov r10, [rsp+40]  ; width
    add rcx, r10
    add rdx, r10
    add r8, r10
    add r9, r10
    neg r10
    
.loop:
    movzx eax, byte [rcx + r10]
    movzx r11d, byte [rdx + r10]
    add eax, r11d
    movzx r11d, byte [r8 + r10]
    add eax, r11d
    movzx r11d, byte [r9 + r10]
    add eax, r11d
    mov [rcx + r10], al
    
    add r10, 1
    jnz .loop
    
    leave
    ret


; ============================================================
; 指针偏移 - 反向复制
; void reverse_copy(uint8_t *src, uint8_t *dst, int count)
; rcx = src, rdx = dst, r8 = count
global reverse_copy
reverse_copy:
    ; 保存指针
    push rcx
    push rdx
    
    ; r8是count，保存它
    push r8
    
    ; 指向末尾 (最后一个字节的位置)
    add rcx, r8
    dec rcx
    add rdx, r8
    dec rdx
    
    ; 用r8作为循环计数器，从count-1开始
    dec r8
    
.loop:
    movzx eax, byte [rcx]
    mov [rdx], al
    dec rcx
    dec rdx
    dec r8
    jns .loop
    
    pop r8
    pop rdx
    pop rcx
    ret
