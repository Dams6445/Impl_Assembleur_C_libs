section .text
global strcmp

strcmp:
    push rbp
    mov rbp, rsp
    mov rsi, [rbp + 16] ; pointer to first string
    mov rdi, [rbp + 24] ; pointer to second string
    xor eax, eax        ; set return value to 0
    cmp rsi, rdi        ; compare the pointers
    je .end             ; if they are equal, return 0
.loop:
    movzx eax, byte [rsi] ; load a byte from the first string
    movzx edx, byte [rdi] ; load a byte from the second string
    cmp al, dl            ; compare the bytes
    jne .done             ; if they are not equal, return the difference
    cmp al, 0             ; if the byte is null, return 0
    je .end
    inc rsi               ; move to the next byte in the first string
    inc rdi               ; move to the next byte in the second string
    jmp .loop             ; repeat
.done:
    sub eax, edx          ; return the difference between the bytes
.end:
    pop rbp
    ret