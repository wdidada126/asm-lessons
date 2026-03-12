; constants.asm
; 常量定义示例 - 对应Lesson 2
; 编译: nasm -f win64 constants.asm -o constants.obj

section .data

; ============================================================
; 字节常量 (db = declare byte, 8位)
; 相当于: uint8_t constants_1[4] = {1, 2, 3, 4};
; ============================================================
constants_1: db 1, 2, 3, 4

; ============================================================
; 字常量 (dw = declare word, 16位)
; 相当于: uint16_t constants_word[4] = {100, 200, 300, 400};
; ============================================================
constants_word: dw 100, 200, 300, 400

; ============================================================
; 双字常量 (dd = declare doubleword, 32位)
; 相当于: uint32_t constants_dword[4] = {1000, 2000, 3000, 4000};
; ============================================================
constants_dword: dd 1000, 2000, 3000, 4000

; ============================================================
; 四字常量 (dq = declare quadword, 64位)
; 相当于: uint64_t constants_qword[4] = {10000, 20000, 30000, 40000};
; ============================================================
constants_qword: dq 10000, 20000, 30000, 40000

; ============================================================
; 使用times重复数据
; 相当于: uint16_t constants_2[8] = {4, 3, 2, 1, 4, 3, 2, 1};
; ============================================================
constants_2: times 2 dw 4, 3, 2, 1

; ============================================================
; 重复字节
; 相当于: uint8_t zeros[16] = {0};
; ============================================================
zeros: times 16 db 0

; ============================================================
; 重复字
; 相当于: uint16_t words[8] = {0xFFFF};
; ============================================================
words: times 8 dw 0xFFFF

; ============================================================
; 字符串常量
; 字符串以null结尾
; ============================================================
message: db 'Hello, Assembly!', 0

; ============================================================
; 填充和对齐
; align 16 确保数据从16字节边界开始
; ============================================================
align 16
aligned_data: db 1, 2, 3, 4, 5, 6, 7, 8

; ============================================================
; 浮点数常量
; ============================================================
float_pi: dd 3.14159265
double_pi: dq 3.14159265358979

section .text

; ============================================================
; 演示如何使用常量 - 从常量加载数据
; void load_constants(uint8_t *dest)
; rdi = dest指针
global load_constants
load_constants:
    ; 从字节常量加载
    movzx eax, byte [constants_1]
    mov [rdi], al
    
    movzx eax, byte [constants_1 + 1]
    mov [rdi + 1], al
    
    movzx eax, byte [constants_1 + 2]
    mov [rdi + 2], al
    
    movzx eax, byte [constants_1 + 3]
    mov [rdi + 3], al
    
    ret


; ============================================================
; 演示加载重复数据
; void fill_zeros(uint8_t *dest, int count)
; rdi = dest, rsi = count
global fill_zeros
fill_zeros:
    xor rcx, rcx
.loop:
    movzx eax, byte [zeros + rcx]
    mov [rdi + rcx], al
    inc rcx
    cmp rcx, rsi
    jl .loop
    ret


; ============================================================
; 演示从对齐数据加载
; void load_aligned(uint8_t *dest)
; rdi = dest指针
global load_aligned
load_aligned:
    movdqu xmm0, [aligned_data]
    movdqu [rdi], xmm0
    ret


; ============================================================
; 演示使用常量作为查找表
; uint8_t lookup_table(int index)
; rdi = index (0-3)
; 返回值在rax中
global lookup_table
lookup_table:
    ; 根据索引返回constants_1中的值
    mov rax, 0
    mov al, [constants_1 + rdi]
    ret


; ============================================================
; 演示从字常量加载
; void load_words(uint16_t *dest)
; rdi = dest指针
global load_words
load_words:
    movzx eax, word [constants_word]
    mov [rdi], ax
    
    movzx eax, word [constants_word + 2]
    mov [rdi + 2], ax
    
    movzx eax, word [constants_word + 4]
    mov [rdi + 4], ax
    
    movzx eax, word [constants_word + 6]
    mov [rdi + 6], ax
    
    ret


; ============================================================
; 演示从四字常量加载
; void load_qwords(uint64_t *dest)
; rdi = dest指针
global load_qwords
load_qwords:
    mov rax, [constants_qword]
    mov [rdi], rax
    
    mov rax, [constants_qword + 8]
    mov [rdi + 8], rax
    
    mov rax, [constants_qword + 16]
    mov [rdi + 16], rax
    
    mov rax, [constants_qword + 24]
    mov [rdi + 24], rax
    
    ret
