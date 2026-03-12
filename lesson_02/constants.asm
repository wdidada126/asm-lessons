; constants.asm
; Constants definition examples - Lesson 2

section .text

; void load_constants(uint8_t *dest)
; rcx = dest
global load_constants
load_constants:
    mov dword [rcx], 0x04030201
    ret


; void fill_zeros(uint8_t *dest, int count)
; rcx = dest, rdx = count
global fill_zeros
fill_zeros:
    xor rax, rax
.loop:
    mov [rcx + rax], byte 0
    inc rax
    cmp rax, rdx
    jb .loop
    ret


; void fill_with_value(uint8_t *dest, uint8_t value, int count)
; rcx = dest, rdx = value, r8 = count
global fill_with_value
fill_with_value:
    xor rax, rax
.loop:
    mov [rcx + rax], dl
    inc rax
    cmp rax, r8
    jb .loop
    ret


; void copy_4_bytes(const uint8_t *src, uint8_t *dst)
; rcx = src, rdx = dst
global copy_4_bytes
copy_4_bytes:
    mov eax, [rcx]
    mov [rdx], eax
    ret


; uint32_t sum_constants()
global sum_constants
sum_constants:
    mov eax, 10000
    ret


; uint8_t lookup_table(int index)
; rcx = index
global lookup_table
lookup_table:
    cmp ecx, 10
    ja .out_of_range
    mov eax, 1
    imul eax, ecx
    jmp .done
.out_of_range:
    xor eax, eax
.done:
    ret


; void load_words(uint16_t *dest)
; rcx = dest
global load_words
load_words:
    mov word [rcx], 100
    mov word [rcx + 2], 200
    ret


; void load_qwords(uint64_t *dest)
; rcx = dest
global load_qwords
load_qwords:
    mov qword [rcx], 10000
    ret
