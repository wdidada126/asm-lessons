; scalar_branch.asm
; Scalar branch and loop examples - Lesson 2

section .text

; void infinite_loop_example()
global infinite_loop_example
infinite_loop_example:
    mov rax, 3
.loop:
    dec rax
    jmp .loop


; void do_while_loop(int *counter)
; rcx = counter
global do_while_loop
do_while_loop:
    mov rax, 3
.loop:
    dec rax
    jg .loop
    mov [rcx], eax
    ret


; void for_loop_example(int *counter)
; rcx = counter
global for_loop_example
for_loop_example:
    xor rax, rax
.loop:
    inc rax
    cmp rax, 3
    jl .loop
    mov [rcx], eax
    ret


; int conditional_jumps(int a, int b)
; rcx = a, rdx = b
global conditional_jumps
conditional_jumps:
    cmp ecx, edx
    je .equal
    jg .a_gt_b
    mov eax, -1
    ret
.a_gt_b:
    mov eax, 1
    ret
.equal:
    xor eax, eax
    ret


; void while_loop_example(int *arr, int count)
; rcx = arr, rdx = count
global while_loop_example
while_loop_example:
    xor rax, rax
.loop:
    cmp rax, rdx
    jge .done
    mov [rcx + rax * 4], eax
    inc rax
    jmp .loop
.done:
    ret


; int xor_zero_example(int a, int b)
; rcx = a, rdx = b
global xor_zero_example
xor_zero_example:
    xor eax, eax
    test ecx, ecx
    setnz al
    test edx, edx
    setnz dl
    add eax, edx
    ret


; int sum_array(int *arr, int count)
; rcx = arr, rdx = count
global sum_array
sum_array:
    xor eax, eax
    xor r11, r11
.loop:
    cmp r11, rdx
    jge .done
    add eax, [rcx + r11 * 4]
    inc r11
    jmp .loop
.done:
    ret


; int find_max(int *arr, int count)
; rcx = arr, rdx = count
global find_max
find_max:
    xor rax, rax
    xor r11, r11
    mov r10d, -1
.loop:
    cmp r11, rdx
    jge .done
    cmp [rcx + r11 * 4], r10d
    cmovg r10d, [rcx + r11 * 4]
    inc r11
    jmp .loop
.done:
    mov eax, r10d
    ret


; int count_positive(int *arr, int count)
; rcx = arr, rdx = count
global count_positive
count_positive:
    xor eax, eax
    xor r11, r11
.loop:
    cmp r11, rdx
    jge .done
    cmp dword [rcx + r11 * 4], 0
    jle .skip
    inc eax
.skip:
    inc r11
    jmp .loop
.done:
    ret
