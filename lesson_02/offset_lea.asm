; offset_lea.asm
; Offset and LEA instruction examples - Lesson 2
; Compile: nasm -f win64 offset_lea.asm -o offset_lea.obj

section .text

; uint64_t get_element(uint64_t *arr, int index)
; rcx = arr, rdx = index
global get_element
get_element:
    mov rax, [rcx + rdx * 8]
    ret


; uint64_t get_element_offset(uint64_t *arr, int index, int offset)
; rcx = arr, rdx = index, r8 = offset
global get_element_offset
get_element_offset:
    lea rax, [rcx + rdx * 8]
    add rax, r8
    mov rax, [rax]
    ret


; uint64_t* calculate_address(uint64_t *base, int index)
; rcx = base, rdx = index
global calculate_address
calculate_address:
    lea rax, [rcx + rdx * 8]
    ret


; ============================================================
; 4. 复杂地址计算 - 结构体数组
; struct { int x, y; } arr[10];
; 获取 arr[index].y 的地址
; void* get_struct_member(int *arr, int index)
; rcx = arr, rdx = index (each struct is 8 bytes: 4 bytes x + 4 bytes y)
global get_struct_member
get_struct_member:
    lea rax, [rcx + rdx * 8 + 4]
    ret


; ============================================================
; 5. 使用LEA进行快速乘法
; uint64_t multiply_by_8_add_5(uint64_t a, uint64_t b)
; rcx = a, rdx = b
global multiply_by_8_add_5
multiply_by_8_add_5:
    lea rax, [rcx + rdx * 8]
    add rax, 5
    ret


; ============================================================
; 6. 多维数组访问示例
; int arr[5][10]; // 5行, 10列
; 获取 arr[row][col]
; int get_2d_array_element(int *arr, int row, int col)
; rcx = arr, rdx = row, r8 = col (each row has 10 elements)
global get_2d_array_element
get_2d_array_element:
    imul rdx, 10
    add rdx, r8
    mov eax, [rcx + rdx * 4]
    ret


; ============================================================
; 7. LEA用于栈帧设置
; 设置局部变量区域
; void setup_stack_frame()
global setup_stack_frame
setup_stack_frame:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    ; 使用LEA访问局部变量
    lea rax, [rbp - 8]
    ; ... 使用栈空间
    leave
    ret


; ============================================================
; 8. 字符串处理示例
; 计算C字符串长度
; size_t strlen_simd(const char *str)
; rcx = str
global strlen_simd
strlen_simd:
    xor rax, rax
.loop:
    cmp byte [rcx + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret


; ============================================================
; 9. 内存复制示例
; void memcpy_simple(void *dst, const void *src, size_t count)
; rcx = dst, rdx = src, r8 = count
global memcpy_simple
memcpy_simple:
    test r8, r8
    jz .done
    xor rax, rax
.loop:
    mov r9b, [rdx + rax]
    mov [rcx + rax], r9b
    inc rax
    cmp rax, r8
    jb .loop
.done:
    ret


; ============================================================
; 10. 指针运算综合示例
; void process_array(int *arr, int *result, int count)
; rcx = arr, rdx = result, r8 = count
global process_array
process_array:
    xor rax, rax
.loop:
    mov r9, [rcx + rax * 4]
    imul r9, 2
    add r9, 10
    mov [rdx + rax * 4], r9
    inc rax
    cmp rax, r8
    jl .loop
    ret


; ============================================================
; LEA arithmetic functions needed by main.c
; uint64_t lea_arithmetic(uint64_t a, uint64_t b)
; rcx = a, rdx = b
global lea_arithmetic
lea_arithmetic:
    lea rax, [rcx + rdx * 8]
    ret


; uint64_t lea_complex(uint64_t a, uint64_t b, uint64_t c)
; rcx = a, rdx = b, r8 = c
global lea_complex
lea_complex:
    mov rax, rdx
    shl rax, 3      ; rax = b * 8
    add rax, rcx    ; rax = a + b*8
    add rax, r8     ; rax = a + b*8 + c
    ret


; void copy_with_offset(uint8_t *src, uint8_t *dst, int count, int offset)
; rcx = src, rdx = dst, r8 = count, r9 = offset
global copy_with_offset
copy_with_offset:
    xor rax, rax
.loop:
    mov r11, rax
    add r11, r9
    mov r10b, [rcx + r11]
    mov [rdx + rax], r10b
    inc rax
    cmp rax, r8
    jb .loop
    ret


; int compare_lea_add(int a, int b)
; rcx = a, rdx = b
global compare_lea_add
compare_lea_add:
    lea eax, [rcx + rdx]
    ret


; void optimized_copy(uint8_t *src, uint8_t *dst, int count)
; rcx = src, rdx = dst, r8 = count
global optimized_copy
optimized_copy:
    xor rax, rax
.loop:
    mov r9b, [rcx + rax]
    mov [rdx + rax], r9b
    inc rax
    cmp rax, r8
    jb .loop
    ret


; void simple_loop_example(int *arr, int count)
; rcx = arr, rdx = count
global simple_loop_example
simple_loop_example:
    xor rax, rax
.loop:
    mov [rcx + rax * 4], eax
    inc rax
    cmp rax, rdx
    jb .loop
    ret
