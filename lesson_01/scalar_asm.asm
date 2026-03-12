; scalar_asm.asm
; Scalar assembly functions for Lesson 1
; Compile: nasm -f win64 scalar_asm.asm -o scalar_asm.obj

section .text

; void scalar_example(uint64_t *result)
; rcx = result
global scalar_example
scalar_example:
    mov rax, 3
    inc rax
    dec rax
    imul rax, 5

    mov [rcx], rax
    ret


; void add_values_scalar(uint8_t *src, uint8_t *src2, int count)
; rcx = src, rdx = src2, r8 = count
global add_values_scalar
add_values_scalar:
    xor rax, rax

.loop:
    movzx r9, byte [rcx + rax]
    add r9b, [rdx + rax]
    mov [rcx + rax], r9b

    inc rax
    cmp rax, r8
    jl .loop

    ret


; void scalar_loop_example(int *counter)
; rcx = counter
global scalar_loop_example
scalar_loop_example:
    mov rax, 3

.loop:
    dec rax
    jg .loop

    mov [rcx], eax
    ret


; uint64_t scalar_arithmetic(uint64_t a, uint64_t b, uint64_t c)
; rcx = a, rdx = b, r8 = c
; Return in rax
global scalar_arithmetic
scalar_arithmetic:
    mov rax, rdx
    shl rax, 3      ; rax = b * 8
    add rax, rcx    ; rax = a + b*8
    add rax, r8     ; rax = a + b*8 + c
    ret
