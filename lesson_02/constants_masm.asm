; constants.asm
; 常量定义示例 - 对应Lesson 2
; 使用MASM语法

.DATA

; ============================================================
; 字节常量
; ============================================================
constants_1 DB 1, 2, 3, 4

; ============================================================
; 字常量 (dw = declare word, 16位)
; ============================================================
constants_word DW 100, 200, 300, 400

; ============================================================
; 双字常量 (dd = declare doubleword, 32位)
; ============================================================
constants_dword DD 1000, 2000, 3000, 4000

; ============================================================
; 四字常量 (dq = declare quadword, 64位)
; ============================================================
constants_qword DQ 10000, 20000, 30000, 40000

; ============================================================
; 使用DUP重复数据
; ============================================================
constants_2 DW 4, 3, 2, 1, 4, 3, 2, 1

zeros DB 16 DUP(0)

; ============================================================
; 对齐数据
; ============================================================
ALIGN 16
aligned_data DB 1, 2, 3, 4, 5, 6, 7, 8

.CODE

; ============================================================
; 演示如何使用常量
; void load_constants(uint8_t *dest)
; rcx = dest指针
load_constants PROC
    movzx eax, BYTE PTR constants_1
    mov [rcx], al
    
    movzx eax, BYTE PTR constants_1 + 1
    mov [rcx + 1], al
    
    movzx eax, BYTE PTR constants_1 + 2
    mov [rcx + 2], al
    
    movzx eax, BYTE PTR constants_1 + 3
    mov [rcx + 3], al
    
    ret
load_constants ENDP


; ============================================================
; 查找表
; uint8_t lookup_table(int index)
; rcx = index
lookup_table PROC
    mov rax, 0
    mov al, BYTE PTR constants_1[rcx]
    ret
lookup_table ENDP


; ============================================================
; 加载字常量
; void load_words(uint16_t *dest)
; rcx = dest指针
load_words PROC
    movzx eax, WORD PTR constants_word
    mov [rcx], ax
    
    movzx eax, WORD PTR constants_word + 2
    mov [rcx + 2], ax
    
    movzx eax, WORD PTR constants_word + 4
    mov [rcx + 4], ax
    
    movzx eax, WORD PTR constants_word + 6
    mov [rcx + 6], ax
    
    ret
load_words ENDP


; ============================================================
; 加载四字常量
; void load_qwords(uint64_t *dest)
; rcx = dest指针
load_qwords PROC
    mov rax, QWORD PTR constants_qword
    mov [rcx], rax
    
    mov rax, QWORD PTR constants_qword + 8
    mov [rcx + 8], rax
    
    mov rax, QWORD PTR constants_qword + 16
    mov [rcx + 16], rax
    
    mov rax, QWORD PTR constants_qword + 24
    mov [rcx + 24], rax
    
    ret
load_qwords ENDP

END
