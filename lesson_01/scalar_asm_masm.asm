; scalar_asm.asm
; 标量汇编函数示例 - 对应Lesson 1中的标量asm片段
; 使用MASM语法 (ML64)
; 编译: ml64 scalar_asm.asm /c /Fo:scalar_asm.obj

.CODE

; void scalar_example(uint64_t *result)
; rcx = result (第一个参数)
scalar_example PROC
    mov rax, 3      ; rax = 3 (立即数3存储到rax)
    inc rax         ; rax = rax + 1 = 4
    dec rax         ; rax = rax - 1 = 3
    imul rax, 5     ; rax = rax * 5 = 15

    ; 将结果存储到指针指向的内存
    mov [rcx], rax

    ret
scalar_example ENDP

; void add_values_scalar(uint8_t *src, uint8_t *src2, int count)
; rcx = src, rdx = src2, r8 = count
add_values_scalar PROC
    xor r9, r9      ; r9 = 0 (循环计数器)

add_loop:
    movzx eax, byte ptr [rcx + r9]    ; eax = src[r9] (零扩展)
    add al, byte ptr [rdx + r9]       ; eax = eax + src2[r9]
    mov byte ptr [rcx + r9], al        ; src[r9] = al

    inc r9
    cmp r9, r8
    jl add_loop

    ret
add_values_scalar ENDP


; void scalar_loop_example(int *counter)
; rcx = counter指针
scalar_loop_example PROC
    mov rax, 3      ; 设置循环计数器为3

loop_label:
    dec rax         ; 计数器递减

    ; 可以在这里添加其他操作

    jg loop_label   ; 如果rax > 0则跳转回loop_label
    ; 循环结束后将最终值写入
    mov [rcx], eax

    ret
scalar_loop_example ENDP

; uint64_t scalar_arithmetic(uint64_t a, uint64_t b, uint64_t c)
; rcx = a, rdx = b, r8 = c
; 返回值在rax中
scalar_arithmetic PROC
    ; 演示lea指令用于算术运算
    ; 计算: rax = a + b*8 + c
    lea rax, [rcx + 8*rdx + r8]

    ret
scalar_arithmetic ENDP

END
