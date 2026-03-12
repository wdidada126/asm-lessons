; offset_lea_mac.asm
; Offset and LEA instruction examples - Lesson 2 - macOS version
; Compile: nasm -f macho64 offset_lea_mac.asm -o offset_lea_mac.o
;
; macOS uses System V AMD64 ABI calling convention:
; - First 6 integer arguments: RDI, RSI, RDX, RCX, R8, R9
; - Return value: RAX

section .text

; uint64_t get_element(uint64_t *arr, int index)
; rdi = arr, rsi = index
global _get_element
_get_element:
    mov rax, [rdi + rsi * 8]
    ret


; uint64_t get_element_offset(uint64_t *arr, int index, int offset)
; rdi = arr, rsi = index, rdx = offset
global _get_element_offset
_get_element_offset:
    lea rax, [rdi + rsi * 8]
    add rax, rdx
    mov rax, [rax]
    ret


; uint64_t* calculate_address(uint64_t *base, int index)
; rdi = base, rsi = index
global _calculate_address
_calculate_address:
    lea rax, [rdi + rsi * 8]
    ret


; ============================================================
; 4. 复杂地址计算 - 结构体数组
; struct { int x, y; } arr[10];
; 获取 arr[index].y 的地址
; void* get_struct_member(int *arr, int index)
; rdi = arr, rsi = index (each struct is 8 bytes: 4 bytes x + 4 bytes y)
global _get_struct_member
_get_struct_member:
    lea rax, [rdi + rsi * 8 + 4]
    ret


; ============================================================
; 5. 使用LEA进行快速乘法
; uint64_t multiply_by_8_add_5(uint64_t a, uint64_t b)
; rdi = a, rsi = b
global _multiply_by_8_add_5
_multiply_by_8_add_5:
    lea rax, [rdi + rsi * 8]
    add rax, 5
    ret


; ============================================================
; 6. 多维数组访问示例
; int arr[5][10]; // 5行, 10列
; 获取 arr[row][col]
; int get_2d_array_element(int *arr, int row, int col)
; rdi = arr, rsi = row, rdx = col (each row has 10 elements)
global _get_2d_array_element
_get_2d_array_element:
    imul rsi, 10
    add rsi, rdx
    mov eax, [rdi + rsi * 4]
    ret


; ============================================================
; 7. LEA用于栈帧设置
; 设置局部变量区域
; void setup_stack_frame()
global _setup_stack_frame
_setup_stack_frame:
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
; rdi = str
global _strlen_simd
_strlen_simd:
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret


; ============================================================
; 9. 内存复制示例
; void memcpy_simple(void *dst, const void *src, size_t count)
; rdi = dst, rsi = src, rdx = count
global _memcpy_simple
_memcpy_simple:
    test rdx, rdx
    jz .done
    xor rax, rax
.loop:
    mov r9b, [rsi + rax]
    mov [rdi + rax], r9b
    inc rax
    cmp rax, rdx
    jb .loop
.done:
    ret


; ============================================================
; 10. 指针运算综合示例
; void process_array(int *arr, int *result, int count)
; rdi = arr, rsi = result, rdx = count
global _process_array
_process_array:
    xor rax, rax
.loop:
    mov r9, [rdi + rax * 4]
    imul r9, 2
    add r9, 10
    mov [rsi + rax * 4], r9
    inc rax
    cmp rax, rdx
    jl .loop
    ret


; ============================================================
; LEA arithmetic functions needed by main.c
; uint64_t lea_arithmetic(uint64_t a, uint64_t b)
; rdi = a, rsi = b
global _lea_arithmetic
_lea_arithmetic:
    lea rax, [rdi + rsi * 8]
    ret


; uint64_t lea_complex(uint64_t a, uint64_t b, uint64_t c)
; rdi = a, rsi = b, rdx = c
global _lea_complex
_lea_complex:
    mov rax, rsi
    shl rax, 3      ; rax = b * 8
    add rax, rdi    ; rax = a + b*8
    add rax, rdx    ; rax = a + b*8 + c
    ret


; void copy_with_offset(uint8_t *src, uint8_t *dst, int count, int src_offset, int dst_offset)
; rdi = src, rsi = dst, rdx = count, rcx = src_offset, r8 = dst_offset
global _copy_with_offset
_copy_with_offset:
    xor rax, rax
.loop:
    mov r11, rax
    add r11, rcx
    mov r10b, [rdi + r11]
    mov r11, rax
    add r11, r8
    mov [rsi + r11], r10b
    inc rax
    cmp rax, rdx
    jb .loop
    ret


; int compare_lea_add(int a, int b)
; rdi = a, rsi = b
global _compare_lea_add
_compare_lea_add:
    lea eax, [rdi + rsi]
    ret


; void optimized_copy(uint8_t *src, uint8_t *dst, int count)
; rdi = src, rsi = dst, rdx = count
global _optimized_copy
_optimized_copy:
    xor rax, rax
.loop:
    mov r9b, [rdi + rax]
    mov [rsi + rax], r9b
    inc rax
    cmp rax, rdx
    jb .loop
    ret


; void simple_loop_example(const uint8_t *src, uint8_t *dst)
; rdi = src, rsi = dst
global _simple_loop_example
_simple_loop_example:
    xor rax, rax
.loop:
    movzx ecx, byte [rdi + rax]
    mov [rsi + rax], cl
    inc rax
    cmp rax, 64
    jb .loop
    ret
