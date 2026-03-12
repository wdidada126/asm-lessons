; offset_lea.asm
; 偏移量和LEA指令示例 - 对应Lesson 2
; 编译: nasm -f win64 offset_lea.asm -o offset_lea.obj

section .text

; ============================================================
; 1. 基础偏移量示例 - 数组元素访问
; uint64_t get_element(uint64_t *arr, int index)
; rdi = arr, rsi = index
; 返回值在rax中
global get_element
get_element:
    ; arr[index] = *(arr + index * 8)
    ; 使用偏移量: [rdi + rsi*8]
    mov rax, [rdi + rsi * 8]
    ret


; ============================================================
; 2. 带位移的偏移量
; uint64_t get_element_offset(uint64_t *arr, int index, int offset)
; rdi = arr, rsi = index, rdx = offset
; 返回值在rax中
global get_element_offset
get_element_offset:
    ; arr[index] + offset
    mov rax, [rdi + rsi * 8 + rdx]
    ret


; ============================================================
; 3. LEA指令 - 地址计算
; uint64_t* calculate_address(uint64_t *base, int index)
; rdi = base, rsi = index
; 返回计算出的地址在rax中
global calculate_address
calculate_address:
    ; 计算: rax = base + index * 8
    lea rax, [rdi + rsi * 8]
    ret


; ============================================================
; 4. LEA指令 - 算术运算 (不改变FLAGS)
; uint64_t lea_arithmetic(uint64_t a, uint64_t b)
; rdi = a, rsi = b
; 返回值在rax中 = a + b * 8
global lea_arithmetic
lea_arithmetic:
    ; lea 可以执行: rax = rdi + rsi * 8
    ; 这相当于: rax = a + b * 8
    ; 注意: 这不影响FLAGS!
    lea rax, [rdi + rsi * 8]
    ret


; ============================================================
; 5. LEA指令 - 复杂算术
; uint64_t lea_complex(uint64_t a, uint64_t b, uint64_t c)
; rdi = a, rsi = b, rdx = c
; 返回: a + b * 8 + c
global lea_complex
lea_complex:
    ; 可以链式使用多个lea
    lea rax, [rdi + rsi * 8 + rdx]
    ret


; ============================================================
; 6. SIMD偏移量 - 对应文档中的simple_loop示例
; void simple_simd_loop(const uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global simple_simd_loop
simple_simd_loop:
    push rbx
    
    mov rbx, rdx        ; 保存count
    shr rbx, 4         ; count / 16 (16字节块)
    test rbx, rbx
    jz .remainder
    
.loop:
    ; 加载16字节 - 偏移量示例
    movdqu xmm0, [rdi]          ; src[0..15]
    movdqu xmm1, [rdi + 16]    ; src[16..31] - 使用偏移量
    
    ; 做些处理 - 这里简单复制
    movdqu [rsi], xmm0
    movdqu [rsi + 16], xmm1
    
    add rdi, 32
    add rsi, 32
    
    dec rbx
    jnz .loop

.remainder:
    mov rbx, rdx
    and rbx, 15         ; count % 16
    test rbx, rbx
    jz .done
    
.remainder_loop:
    movzx eax, byte [rdi]
    mov [rsi], al
    
    inc rdi
    inc rsi
    
    dec rbx
    jnz .remainder_loop

.done:
    pop rbx
    ret


; ============================================================
; 7. 使用scale的示例
; 不同scale对应不同大小的数据类型
; void multi_type_array(uint8_t *byte_arr, uint16_t *word_arr, 
;                       uint32_t *dword_arr, uint64_t *qword_arr, int index)
; rdi = byte_arr, rsi = word_arr, rdx = dword_arr, rcx = qword_arr, r8 = index
global multi_type_array
multi_type_array:
    ; 字节数组 - scale = 1
    movzx eax, byte [rdi + r8]
    ; 字数组 - scale = 2
    movzx ebx, word [rsi + r8 * 2]
    ; 双字数组 - scale = 4
    movzx ecx, dword [rdx + r8 * 4]
    ; 四字数组 - scale = 8
    mov r11, [rcx + r8 * 8]
    
    ; 返回四字值
    mov rax, r11
    ret


; ============================================================
; 8. 模拟C循环 - 带偏移量计算
; void copy_with_offset(uint8_t *src, uint8_t *dst, int count, int src_offset, int dst_offset)
; rdi = src, rsi = dst, rdx = count, rcx = src_offset, r8 = dst_offset
global copy_with_offset
copy_with_offset:
    push rbx
    push r12
    
    mov rbx, rcx        ; src_offset
    mov r12, r8         ; dst_offset
    
    xor rcx, rcx        ; i = 0
.loop:
    movzx eax, byte [rdi + rcx + rbx]  ; src[i + src_offset]
    mov [rsi + rcx + r12], al          ; dst[i + dst_offset]
    
    inc rcx
    cmp rcx, rdx
    jl .loop
    
    pop r12
    pop rbx
    ret


; ============================================================
; 9. 演示LEA vs ADD的区别
; LEA不改变FLAGS，ADD改变FLAGS
; int compare_lea_add(uint64_t a, uint64_t b)
; rdi = a, rsi = b
; 返回1如果 a+b > 10，否则返回0
global compare_lea_add
compare_lea_add:
    ; 使用LEA计算 (不改变FLAGS)
    lea rax, [rdi + rsi]
    
    ; 然后比较 (改变FLAGS)
    cmp rax, 10
    ja .greater
    mov eax, 0
    ret
.greater:
    mov eax, 1
    ret


; ============================================================
; 10. 优化循环 - 使用LEA更新指针
; void optimized_copy(uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global optimized_copy
optimized_copy:
    push rbx
    
    mov rbx, rdx        ; 块计数
    shr rbx, 4          ; 16字节块
    test rbx, rbx
    jz .remainder
    
.loop:
    movdqu xmm0, [rdi]
    movdqu xmm1, [rdi + 16]
    movdqu xmm2, [rdi + 32]
    movdqu xmm3, [rdi + 48]
    
    movdqu [rsi], xmm0
    movdqu [rsi + 16], xmm1
    movdqu [rsi + 32], xmm2
    movdqu [rsi + 48], xmm3
    
    ; 使用LEA更新指针 - 比ADD更快且不改变FLAGS
    lea rdi, [rdi + 64]
    lea rsi, [rsi + 64]
    
    dec rbx
    jnz .loop

.remainder:
    mov rbx, rdx
    and rbx, 15
    test rbx, rbx
    jz .done
    
.remainder_loop:
    movzx eax, byte [rdi]
    mov [rsi], al
    
    inc rdi
    inc rsi
    
    dec rbx
    jnz .remainder_loop

.done:
    pop rbx
    ret


; ============================================================
; 11. 模拟文档中的simple_loop函数
; void simple_loop_example(const uint8_t *src, uint8_t *dst)
; rdi = src, rsi = dst
; 对应文档中的: srcq + 2*r1q + 3 + mmsize
global simple_loop_example
simple_loop_example:
    push rbx
    
    mov rbx, 3          ; r1q = 3 (scale * index = 2*3 = 6)
.loop:
    ; 从 src 加载
    movdqu xmm0, [rdi]
    
    ; 从 src + 2*3 + 3 + 16 (mmsize=16) = src + 25 加载
    movdqu xmm1, [rdi + 2 * rbx + 3 + 16]
    
    ; 简单处理：两个向量相加
    paddb xmm0, xmm1
    
    ; 存储
    movdqu [rsi], xmm0
    
    ; 更新指针
    add rdi, 16         ; mmsize
    add rsi, 16
    
    ; 递减计数器
    dec rbx
    jg .loop            ; if (rbx > 0) goto .loop
    
    pop rbx
    ret
