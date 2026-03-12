; scalar_branch_mac.asm
; Scalar branch and loop examples - Lesson 2 - macOS version
; Compile: nasm -f macho64 scalar_branch_mac.asm -o scalar_branch_mac.o
;
; macOS uses System V AMD64 ABI calling convention:
; - First 6 integer arguments: RDI, RSI, RDX, RCX, R8, R9
; - Return value: RAX

section .text

; void infinite_loop_example()
global _infinite_loop_example
_infinite_loop_example:
    mov rax, 3
.loop:
    dec rax
    jmp .loop


; void do_while_loop(int *counter)
; rdi = counter
global _do_while_loop
_do_while_loop:
    mov rax, 3
.loop:
    dec rax
    jg .loop
    mov [rdi], eax
    ret


; void for_loop_example(int *counter)
; rdi = counter
global _for_loop_example
_for_loop_example:
    xor rax, rax
.loop:
    inc rax
    cmp rax, 3
    jl .loop
    mov [rdi], eax
    ret


; void conditional_jumps(int a, int b, int *result)
; rdi = a, rsi = b, rdx = result
global _conditional_jumps
_conditional_jumps:
    ; Initialize all results to 0
    mov qword [rdx], 0
    mov qword [rdx + 8], 0
    
    cmp edi, esi
    je .equal
    jg .a_gt_b
    ; a < b
    mov dword [rdx + 16], 1  ; JL = 1
    mov dword [rdx + 24], 1  ; JLE = 1
    ret
.a_gt_b:
    ; a > b
    mov dword [rdx + 8], 1   ; JNE = 1
    mov dword [rdx + 12], 1  ; JG = 1
    mov dword [rdx + 16], 1  ; JGE = 1
    ret
.equal:
    ; a == b
    mov dword [rdx], 1       ; JE = 1
    mov dword [rdx + 20], 1  ; JGE = 1
    mov dword [rdx + 24], 1  ; JLE = 1
    ret


; void while_loop_example(int *arr, int count)
; rdi = arr, rsi = count
global _while_loop_example
_while_loop_example:
    xor rax, rax
.loop:
    cmp rax, rsi
    jge .done
    mov [rdi + rax * 4], eax
    inc rax
    jmp .loop
.done:
    ret


; void xor_zero_example(uint64_t *result)
; rdi = result
global _xor_zero_example
_xor_zero_example:
    xor rax, rax
    mov [rdi], rax
    ret


; int64_t sum_array(int64_t *arr, int count)
; rdi = arr, rsi = count
global _sum_array
_sum_array:
    xor eax, eax
    xor r11, r11
.loop:
    cmp r11, rsi
    jge .done
    add rax, [rdi + r11 * 8]
    inc r11
    jmp .loop
.done:
    ret


; int64_t find_max(int64_t *arr, int count)
; rdi = arr, rsi = count
global _find_max
_find_max:
    xor rax, rax
    xor r11, r11
    mov r10, -1
.loop:
    cmp r11, rsi
    jge .done
    cmp qword [rdi + r11 * 8], r10
    cmovg r10, qword [rdi + r11 * 8]
    inc r11
    jmp .loop
.done:
    mov rax, r10
    ret


; int count_positive(int64_t *arr, int count)
; rdi = arr, rsi = count
global _count_positive
_count_positive:
    xor eax, eax
    xor r11, r11
.loop:
    cmp r11, rsi
    jge .done
    cmp qword [rdi + r11 * 8], 0
    jle .skip
    inc eax
.skip:
    inc r11
    jmp .loop
.done:
    ret
