; scalar_branch.asm
; 标量分支和循环示例 - 对应Lesson 2
; 使用NASM语法 (Win64)
; 编译: nasm -f win64 scalar_branch.asm -o scalar_branch.obj

section .text

; ============================================================
; 1. 无限循环示例 (人工示例，对应文档)
; void infinite_loop_example()
; 这个函数展示了一个无限循环的结构
global infinite_loop_example
infinite_loop_example:
    mov rax, 3          ; rax = 3
.loop:                  ; 标签
    dec rax             ; rax = rax - 1
    jmp .loop           ; 无条件跳转回.loop


; ============================================================
; 2. 条件循环 - do-while 形式
; void do_while_loop(int *counter)
; rdi = counter指针
; 对应文档中的: do { ... } while(i > 0)
global do_while_loop
do_while_loop:
    mov rax, 3          ; i = 3
.loop:
    ; 在这里可以添加其他操作
    
    dec rax             ; i--
    jg .loop            ; if (i > 0) goto .loop
    
    ; 循环结束后将最终值写入
    mov [rdi], eax
    ret


; ============================================================
; 3. 条件循环 - for形式模拟
; void for_loop_example(int *counter)
; rdi = counter指针
; 对应文档中的: for(i = 0; i < 3; i++) { ... }
global for_loop_example
for_loop_example:
    xor rax, rax        ; i = 0 (xor比mov更快)
.loop:
    ; 在这里可以添加其他操作
    
    inc rax             ; i++
    cmp rax, 3          ; 比较 i 和 3
    jl .loop            ; if (i < 3) goto .loop
    
    ; 循环结束
    mov [rdi], eax
    ret


; ============================================================
; 4. 各种跳转指令示例
; void conditional_jumps(int a, int b, int *result)
; rdi = a, rsi = b, rdx = result指针
; 根据比较结果设置result
global conditional_jumps
conditional_jumps:
    ; 保存用的寄存器
    push rbx
    
    mov eax, edi        ; eax = a
    mov ebx, esi        ; ebx = b
    
    ; 测试JE/JZ (相等/为零跳转)
    cmp eax, ebx
    je .equal           ; if (a == b) goto equal
    mov ecx, 0          ; result = 0 (不相等)
    jmp .done_je
    
.equal:
    mov ecx, 1          ; result = 1 (相等)
    
.done_je:
    mov [rdx], ecx
    inc rdx             ; 移动到下一个result位置
    
    ; 测试JNE/JNZ (不相等跳转)
    cmp eax, ebx
    jne .not_equal      ; if (a != b) goto not_equal
    mov ecx, 0
    jmp .done_jne
    
.not_equal:
    mov ecx, 1
    
.done_jne:
    mov [rdx], ecx
    inc rdx
    
    ; 测试JG (大于跳转，有符号)
    cmp eax, ebx
    jg .greater         ; if (a > b) goto greater
    mov ecx, 0
    jmp .done_jg
    
.greater:
    mov ecx, 1
    
.done_jg:
    mov [rdx], ecx
    inc rdx
    
    ; 测试JGE (大于等于跳转)
    cmp eax, ebx
    jge .greater_equal  ; if (a >= b) goto greater_equal
    mov ecx, 0
    jmp .done_jge
    
.greater_equal:
    mov ecx, 1
    
.done_jge:
    mov [rdx], ecx
    inc rdx
    
    ; 测试JL (小于跳转)
    cmp eax, ebx
    jl .less            ; if (a < b) goto less
    mov ecx, 0
    jmp .done_jl
    
.less:
    mov ecx, 1
    
.done_jl:
    mov [rdx], ecx
    inc rdx
    
    ; 测试JLE (小于等于跳转)
    cmp eax, ebx
    jle .less_equal     ; if (a <= b) goto less_equal
    mov ecx, 0
    jmp .done_jle
    
.less_equal:
    mov ecx, 1
    
.done_jle:
    mov [rdx], ecx
    
    pop rbx
    ret


; ============================================================
; 5. XOR清零示例
; void xor_zero_example(uint64_t *result)
; rdi = result指针
global xor_zero_example
xor_zero_example:
    ; 使用xor清零寄存器（比mov reg, 0更快）
    xor rax, rax        ; rax = 0
    xor rbx, rbx        ; rbx = 0
    xor rcx, rcx        ; rcx = 0
    
    ; 在循环中使用
    mov rdx, 5          ; 设置计数器
.loop:
    ; 做些事情
    dec rdx
    jnz .loop           ; 使用nz测试
    
    mov [rdi], rax
    ret


; ============================================================
; 6. 计算数组元素和 - 综合示例
; int64_t sum_array(int64_t *arr, int count)
; rdi = arr指针, rsi = count
; 返回值在rax中
global sum_array
sum_array:
    xor rax, rax        ; sum = 0
    xor rcx, rcx        ; i = 0
    
.sum_loop:
    ; arr[i] = *(arr + i*8)
    add rax, [rdi + rcx*8]
    
    inc rcx
    cmp rcx, rsi
    jl .sum_loop
    
    ret


; ============================================================
; 7. 查找最大值
; int64_t find_max(int64_t *arr, int count)
; rdi = arr指针, rsi = count
; 返回值在rax中
global find_max
find_max:
    xor rcx, rcx
    mov rax, [rdi]      ; max = arr[0]
    
.max_loop:
    inc rcx
    cmp rcx, rsi
    jge .max_done       ; if (i >= count) done
    
    ; 比较arr[i]和max
    cmp [rdi + rcx*8], rax
    jle .max_loop       ; if (arr[i] <= max) continue
    
    mov rax, [rdi + rcx*8]  ; max = arr[i]
    jmp .max_loop
    
.max_done:
    ret


; ============================================================
; 8. 条件计数
; int count_positive(int64_t *arr, int count)
; rdi = arr指针, rsi = count
; 返回值在rax中
global count_positive
count_positive:
    xor rax, rax        ; count = 0
    xor rcx, rcx        ; i = 0
    
.count_loop:
    cmp rcx, rsi
    jge .count_done
    
    ; 检查arr[i] > 0
    cmp qword [rdi + rcx*8], 0
    jle .not_positive
    
    inc rax             ; count++
    
.not_positive:
    inc rcx
    jmp .count_loop
    
.count_done:
    ret
