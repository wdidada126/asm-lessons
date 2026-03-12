; scalar_branch.asm
; 标量分支和循环示例 - 对应Lesson 2
; 使用MASM语法 (ML64)
; 编译: ml64 /c /Fo:scalar_branch.obj scalar_branch.asm

.CODE

; ============================================================
; 2. 条件循环 - do-while 形式
; void do_while_loop(int *counter)
; rcx = counter指针
do_while_loop PROC
    mov rax, 3          ; i = 3
loop_label:
    dec rax             ; i--
    jg loop_label       ; if (i > 0) goto loop_label

    mov [rcx], eax
    ret
do_while_loop ENDP


; ============================================================
; 3. 条件循环 - for形式模拟
; void for_loop_example(int *counter)
; rcx = counter指针
for_loop_example PROC
    xor rax, rax        ; i = 0 (xor比mov更快)
for_loop:
    inc rax             ; i++
    cmp rax, 3          ; 比较 i 和 3
    jl for_loop         ; if (i < 3) goto for_loop
    
    mov [rcx], eax
    ret
for_loop_example ENDP


; ============================================================
; 4. 各种跳转指令示例
; void conditional_jumps(int a, int b, int *result)
; rcx = a, rdx = b, r8 = result指针
conditional_jumps PROC
    mov eax, ecx        ; eax = a
    mov ebx, edx        ; ebx = b
    
    ; 测试JE/JZ (相等/为零跳转)
    cmp eax, ebx
    je equal_label
    mov ecx, 0
    jmp done_je
equal_label:
    mov ecx, 1
done_je:
    mov [r8], ecx
    lea r8, [r8 + 4]
    
    ; 测试JNE/JNZ (不相等跳转)
    cmp eax, ebx
    jne not_equal_label
    mov ecx, 0
    jmp done_jne
not_equal_label:
    mov ecx, 1
done_jne:
    mov [r8], ecx
    lea r8, [r8 + 4]
    
    ; 测试JG (大于跳转，有符号)
    cmp eax, ebx
    jg greater_label
    mov ecx, 0
    jmp done_jg
greater_label:
    mov ecx, 1
done_jg:
    mov [r8], ecx
    lea r8, [r8 + 4]
    
    ; 测试JGE (大于等于跳转)
    cmp eax, ebx
    jge greater_equal_label
    mov ecx, 0
    jmp done_jge
greater_equal_label:
    mov ecx, 1
done_jge:
    mov [r8], ecx
    lea r8, [r8 + 4]
    
    ; 测试JL (小于跳转)
    cmp eax, ebx
    jl less_label
    mov ecx, 0
    jmp done_jl
less_label:
    mov ecx, 1
done_jl:
    mov [r8], ecx
    lea r8, [r8 + 4]
    
    ; 测试JLE (小于等于跳转)
    cmp eax, ebx
    jle less_equal_label
    mov ecx, 0
    jmp done_jle
less_equal_label:
    mov ecx, 1
done_jle:
    mov [r8], ecx
    
    ret
conditional_jumps ENDP


; ============================================================
; 5. XOR清零示例
; void xor_zero_example(uint64_t *result)
; rcx = result指针
xor_zero_example PROC
    xor rax, rax        ; rax = 0
    xor rbx, rbx        ; rbx = 0
    xor rcx, rcx        ; rcx = 0
    
    mov rdx, 5          ; 设置计数器
xor_loop:
    dec rdx
    jnz xor_loop
    
    mov [rcx], rax
    ret
xor_zero_example ENDP


; ============================================================
; 6. 计算数组元素和
; int64_t sum_array(int64_t *arr, int count)
; rcx = arr指针, rdx = count
sum_array PROC
    xor rax, rax        ; sum = 0
    xor r8, r8          ; i = 0
    
sum_loop:
    add rax, [rcx + r8 * 8]
    
    inc r8
    cmp r8, rdx
    jl sum_loop
    
    ret
sum_array ENDP


; ============================================================
; 7. 查找最大值
; int64_t find_max(int64_t *arr, int count)
; rcx = arr指针, rdx = count
find_max PROC
    xor r8, r8
    mov rax, [rcx]      ; max = arr[0]
    
max_loop:
    inc r8
    cmp r8, rdx
    jge max_done
    
    cmp [rcx + r8 * 8], rax
    jle max_loop
    
    mov rax, [rcx + r8 * 8]
    jmp max_loop
    
max_done:
    ret
find_max ENDP


; ============================================================
; 8. 条件计数
; int count_positive(int64_t *arr, int count)
; rcx = arr指针, rdx = count
count_positive PROC
    xor rax, rax        ; count = 0
    xor r8, r8          ; i = 0
    
count_loop:
    cmp r8, rdx
    jge count_done
    
    cmp qword ptr [rcx + r8 * 8], 0
    jle not_positive
    
    inc rax
    
not_positive:
    inc r8
    jmp count_loop
    
count_done:
    ret
count_positive ENDP

END
