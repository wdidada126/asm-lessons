; scalar_asm.asm
; 标量汇编函数示例 - 对应Lesson 1中的标量asm片段
; 编译: nasm -f win64 scalar_asm.asm -o scalar_asm.obj

section .text

; void scalar_example(uint64_t *result)
; rdi = result (第一个参数)
global scalar_example
scalar_example:
    mov rax, 3      ; rax = 3 (立即数3存储到rax)
    inc rax         ; rax = rax + 1 = 4
    dec rax         ; rax = rax - 1 = 3
    imul rax, 5     ; rax = rax * 5 = 15

    ; 将结果存储到指针指向的内存
    mov [rdi], rax

    ret


; void add_values_scalar(uint8_t *src, uint8_t *src2, int count)
; rdi = src, rsi = src2, rdx = count
global add_values_scalar
add_values_scalar:
    xor rcx, rcx    ; rcx = 0 (循环计数器)

.loop:
    movzx eax, byte [rdi + rcx]    ; eax = src[rcx] (零扩展)
    add al, [rsi + rcx]            ; eax = eax + src2[rcx]
    mov [rdi + rcx], al            ; src[rcx] = al

    inc rcx
    cmp rcx, rdx
    jl .loop

    ret


; void scalar_loop_example(int *counter)
; rdi = counter指针
global scalar_loop_example
scalar_loop_example:
    mov rax, 3      ; 设置循环计数器为3

.loop:
    dec rax         ; 计数器递减

    ; 可以在这里添加其他操作

    jg .loop        ; 如果rax > 0则跳转回.loop

    ; 循环结束后将最终值写入
    mov [rdi], eax

    ret


; uint64_t scalar_arithmetic(uint64_t a, uint64_t b, uint64_t c)
; rdi = a, rsi = b, rdx = c
; 返回值在rax中
global scalar_arithmetic
scalar_arithmetic:
    ; 演示lea指令用于算术运算
    ; 计算: rax = a + b*8 + c
    lea rax, [rdi + 8*rsi + rdx]
    
    ret
