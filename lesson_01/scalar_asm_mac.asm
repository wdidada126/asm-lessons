; scalar_asm_mac.asm
; Scalar assembly functions for Lesson 1 - macOS version
; Compile: nasm -f macho64 scalar_asm_mac.asm -o scalar_asm_mac.o
;
; macOS uses System V AMD64 ABI calling convention:
; - First 6 integer arguments: RDI, RSI, RDX, RCX, R8, R9
; - Return value: RAX

section .text

; void scalar_example(uint64_t *result)
; rdi = result (first argument)
global _scalar_example
_scalar_example:
    mov rax, 3
    inc rax
    dec rax
    imul rax, 5

    mov [rdi], rax
    ret


; void add_values_scalar(uint8_t *src, uint8_t *src2, int count)
; rdi = src, rsi = src2, rdx = count
global _add_values_scalar
_add_values_scalar:
    xor rax, rax

.loop:
    movzx rcx, byte [rdi + rax]
    add cl, [rsi + rax]
    mov [rdi + rax], cl

    inc rax
    cmp rax, rdx
    jl .loop

    ret


; void scalar_loop_example(int *counter)
; rdi = counter
global _scalar_loop_example
_scalar_loop_example:
    mov rax, 3

.loop:
    dec rax
    jg .loop

    mov [rdi], eax
    ret


; uint64_t scalar_arithmetic(uint64_t a, uint64_t b, uint64_t c)
; rdi = a, rsi = b, rdx = c
; Return in rax
global _scalar_arithmetic
_scalar_arithmetic:
    mov rax, rsi
    shl rax, 3      ; rax = b * 8
    add rax, rdi    ; rax = a + b*8
    add rax, rdx    ; rax = a + b*8 + c
    ret
