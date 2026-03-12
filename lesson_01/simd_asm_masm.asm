; simd_asm.asm
; SIMD向量汇编函数示例 - 对应Lesson 1中的add_values函数
; 使用MASM语法 (ML64) - SSE2指令集
; 编译: ml64 simd_asm.asm /c /Fo:simd_asm.obj

.CODE

; void add_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; rcx = src, rdx = src2, r8 = count
add_values_sse2 PROC
    ; 保存rbx寄存器
    push rbx
    
    ; 将count转换为16字节块的数量
    mov rax, r8
    shr rax, 4      ; count / 16
    test rax, rax
    jz remainder   ; 如果没有完整的16字节块，处理剩余部分
    
simd_loop:
    ; 加载16字节从src和src2
    movdqu xmm0, [rcx]      ; xmm0 = 16字节从src
    movdqu xmm1, [rdx]      ; xmm1 = 16字节从src2
    
    ; 打包字节加法 (paddb = packed add bytes)
    paddb xmm0, xmm1        ; xmm0[i] = xmm0[i] + xmm1[i]
    
    ; 存储结果回src
    movdqu [rcx], xmm0
    
    ; 更新指针
    add rcx, 16
    add rdx, 16
    
    dec rax
    jnz simd_loop

remainder:
    ; 处理剩余的字节（少于16字节的情况）
    mov rax, r8
    and rax, 15      ; count % 16
    test rax, rax
    jz done
    
remainder_loop:
    movzx ebx, byte ptr [rdx]
    add bl, byte ptr [rcx]
    mov [rcx], bl
    
    inc rcx
    inc rdx
    
    dec rax
    jnz remainder_loop

done:
    pop rbx
    ret
add_values_sse2 ENDP


; void add_values_sse2_simple(uint8_t *src, const uint8_t *src2)
; 简单版本，处理固定的16字节
; rcx = src, rdx = src2
add_values_sse2_simple PROC
    movdqu xmm0, [rcx]      ; 加载16字节从src
    movdqu xmm1, [rdx]      ; 加载16字节从src2
    paddb xmm0, xmm1        ; 16字节并行加法
    movdqu [rcx], xmm0      ; 存储结果
    
    ret
add_values_sse2_simple ENDP


; void subtract_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; 演示psubb（打包字节减法）
subtract_values_sse2 PROC
    push rbx
    
    mov rax, r8
    shr rax, 4
    test rax, rax
    jz remainder_sub
    
sub_loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    psubb xmm0, xmm1        ; 打包字节减法
    movdqu [rcx], xmm0
    
    add rcx, 16
    add rdx, 16
    
    dec rax
    jnz sub_loop

remainder_sub:
    mov rax, r8
    and rax, 15
    test rax, rax
    jz done_sub
    
remainder_loop_sub:
    movzx ebx, byte ptr [rdx]
    sub bl, byte ptr [rcx]
    mov [rcx], bl
    
    inc rcx
    inc rdx
    
    dec rax
    jnz remainder_loop_sub

done_sub:
    pop rbx
    ret
subtract_values_sse2 ENDP


; void max_values_sse2(uint8_t *src, const uint8_t *src2, int count)
; 演示pmaxub（打包无符号字节最大值）
max_values_sse2 PROC
    push rbx
    
    mov rax, r8
    shr rax, 4
    test rax, rax
    jz remainder_max
    
max_loop:
    movdqu xmm0, [rcx]
    movdqu xmm1, [rdx]
    pmaxub xmm0, xmm1        ; 打包无符号字节最大值
    movdqu [rcx], xmm0
    
    add rcx, 16
    add rdx, 16
    
    dec rax
    jnz max_loop

remainder_max:
    mov rax, r8
    and rax, 15
    test rax, rax
    jz done_max
    
remainder_loop_max:
    movzx ebx, byte ptr [rdx]
    cmp bl, byte ptr [rcx]
    ja update_max
    jmp skip_max
    
update_max:
    mov [rcx], bl
    
skip_max:
    inc rcx
    inc rdx
    
    dec rax
    jnz remainder_loop_max

done_max:
    pop rbx
    ret
max_values_sse2 ENDP


; void average_values_sse2(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, int count)
; 演示pavgub（打包无符号字节平均值）
; rcx = dst, rdx = src1, r8 = src2, [rsp+40] = count
average_values_sse2 PROC
    push rbx
    mov r11, r8              ; 保存src2
    mov r8, [rsp+40]         ; 获取count参数
    
    mov rax, r8
    shr rax, 4
    test rax, rax
    jz remainder_avg
    
avg_loop:
    movdqu xmm0, [rdx]       ; src1
    movdqu xmm1, [r11]       ; src2
    pavgb xmm0, xmm1         ; 打包无符号字节平均值（带舍入）
    movdqu [rcx], xmm0       ; dst
    
    add rcx, 16
    add rdx, 16
    add r11, 16
    
    dec rax
    jnz avg_loop

remainder_avg:
    mov rax, r8
    and rax, 15
    test rax, rax
    jz done_avg
    
remainder_loop_avg:
    movzx ebx, byte ptr [rdx]
    add ebx, [r11]
    shr ebx, 1               ; (a + b) / 2
    mov [rcx], bl
    
    inc rcx
    inc rdx
    inc r11
    
    dec rax
    jnz remainder_loop_avg

done_avg:
    pop rbx
    ret
average_values_sse2 ENDP


; void saturating_add_sse2(uint8_t *dst, const uint8_t *src1, const uint8_t *src2, int count)
; 演示饱和加法 (paddusb = packed add unsigned saturated bytes)
; rcx = dst, rdx = src1, r8 = src2, [rsp+40] = count
saturating_add_sse2 PROC
    push rbx
    mov r11, r8              ; 保存src2
    mov r8, [rsp+40]         ; 获取count参数
    
    mov rax, r8
    shr rax, 4
    test rax, rax
    jz remainder_sat
    
sat_loop:
    movdqu xmm0, [rdx]
    movdqu xmm1, [r11]
    paddusb xmm0, xmm1       ; 饱和无符号字节加法
    movdqu [rcx], xmm0
    
    add rcx, 16
    add rdx, 16
    add r11, 16
    
    dec rax
    jnz sat_loop

remainder_sat:
    mov rax, r8
    and rax, 15
    test rax, rax
    jz done_sat
    
remainder_loop_sat:
    movzx ebx, byte ptr [rdx]
    add bl, byte ptr [r11]
    jnc no_saturate
    mov bl, 255              ; 饱和到255
    
no_saturate:
    mov [rcx], bl
    
    inc rcx
    inc rdx
    inc r11
    
    dec rax
    jnz remainder_loop_sat

done_sat:
    pop rbx
    ret
saturating_add_sse2 ENDP

END
