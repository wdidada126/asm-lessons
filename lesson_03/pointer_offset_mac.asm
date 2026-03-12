; pointer_offset_mac.asm
; 指针偏移技巧示例 - Lesson 3 - macOS version
; Compile: nasm -f macho64 pointer_offset_mac.asm -o pointer_offset_mac.o
;
; macOS uses System V AMD64 ABI calling convention:
; - First 6 integer arguments: RDI, RSI, RDX, RCX, R8, R9
; - Return value: RAX

section .text

; ============================================================
; 文档中的 add_values 函数示例 - 指针偏移技巧
; void add_values_ptr_offset(uint8_t *src, const uint8_t *src2, int width)
; rdi = src, rsi = src2, rdx = width
global _add_values_ptr_offset
_add_values_ptr_offset:
    ; 保存原始src
    push rdi
    push rsi
    
    ; width被加到每个指针上，使它们指向缓冲区末尾
    add rdi, rdx
    add rsi, rdx
    
    ; width被取反，变成负值
    neg rdx
    
.loop:
    ; 加载时rdx为负值，第一次迭代指向缓冲区开头
    movdqu xmm0, [rdi + rdx]
    movdqu xmm1, [rsi + rdx]
    
    ; 打包字节加法
    paddb xmm0, xmm1
    
    ; 存储结果
    movdqu [rdi + rdx], xmm0
    
    add rdx, 16         ; mmsize = 16
    jl .loop
    
    pop rsi
    pop rdi
    ret


; ============================================================
; 指针偏移 - 从后向前遍历
; void reverse_add(uint8_t *src, uint8_t *dst, int width)
; rdi = src, rsi = dst, rdx = width
global _reverse_add
_reverse_add:
    ; 调整指针指向末尾
    add rdi, rdx
    add rsi, rdx
    neg rdx
    
.loop:
    movzx eax, byte [rdi + rdx]
    add eax, eax
    mov [rsi + rdx], al
    
    inc rdx
    jnz .loop
    ret


; ============================================================
; 指针偏移 - 多指针同时遍历
; void multi_pointer_demo(uint8_t *a, uint8_t *b, uint8_t *c, uint8_t *d, int width)
; rdi=a, rsi=b, rdx=c, rcx=d, r8=width
global _multi_pointer_demo
_multi_pointer_demo:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    and rsp, -16
    
    ; 调整所有指针
    add rdi, r8
    add rsi, r8
    add rdx, r8
    add rcx, r8
    neg r8
    
.loop:
    movzx eax, byte [rdi + r8]
    movzx r11d, byte [rsi + r8]
    add eax, r11d
    movzx r11d, byte [rdx + r8]
    add eax, r11d
    movzx r11d, byte [rcx + r8]
    add eax, r11d
    mov [rdi + r8], al
    
    add r8, 1
    jnz .loop
    
    leave
    ret


; ============================================================
; 指针偏移 - 反向复制
; void reverse_copy(uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _reverse_copy
_reverse_copy:
    ; 保存原始src指针
    push rdi
    
    ; rdi = src + count - 1 (指向最后一个元素)
    lea rdi, [rdi + rdx - 1]
    
.loop:
    movzx eax, byte [rdi]
    mov [rsi], al
    inc rsi
    dec rdi
    dec rdx
    jnz .loop
    
    pop rdi
    ret
