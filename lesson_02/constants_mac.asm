; constants_mac.asm
; Constants definition examples - Lesson 2 - macOS version
; Compile: nasm -f macho64 constants_mac.asm -o constants_mac.o
;
; macOS uses System V AMD64 ABI calling convention:
; - First 6 integer arguments: RDI, RSI, RDX, RCX, R8, R9
; - Return value: RAX

section .text

; void load_constants(uint8_t *dest)
; rdi = dest
global _load_constants
_load_constants:
    mov dword [rdi], 0x04030201
    ret


; void fill_zeros(uint8_t *dest, int count)
; rdi = dest, rsi = count
global _fill_zeros
_fill_zeros:
    xor rax, rax
.loop:
    mov [rdi + rax], byte 0
    inc rax
    cmp rax, rsi
    jb .loop
    ret


; void fill_with_value(uint8_t *dest, uint8_t value, int count)
; rdi = dest, rsi = value, rdx = count
global _fill_with_value
_fill_with_value:
    xor rax, rax
.loop:
    mov [rdi + rax], sil
    inc rax
    cmp rax, rdx
    jb .loop
    ret


; void copy_4_bytes(const uint8_t *src, uint8_t *dst)
; rdi = src, rsi = dst
global _copy_4_bytes
_copy_4_bytes:
    mov eax, [rdi]
    mov [rsi], eax
    ret


; uint32_t sum_constants()
global _sum_constants
_sum_constants:
    mov eax, 10000
    ret


; uint8_t lookup_table(int index)
; rdi = index
global _lookup_table
_lookup_table:
    cmp edi, 10
    ja .out_of_range
    mov eax, 1
    imul eax, edi
    jmp .done
.out_of_range:
    xor eax, eax
.done:
    ret


; void load_words(uint16_t *dest)
; rdi = dest
global _load_words
_load_words:
    mov word [rdi], 100
    mov word [rdi + 2], 200
    ret


; void load_qwords(uint64_t *dest)
; rdi = dest
global _load_qwords
_load_qwords:
    mov qword [rdi], 10000
    ret
