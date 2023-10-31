global my_toupper
section .text

my_toupper:
    push rbp
    mov rbp, rsp
    movzx eax, byte [rbp + 16] ; load the character to convert
    cmp al, 'a'                ; compare with 'a'
    jb .end                    ; if less than 'a', return the original character
    cmp al, 'z'                ; compare with 'z'
    ja .end                    ; if greater than 'z', return the original character
    sub al, 32                 ; convert to uppercase by subtracting 32
.end:
    pop rbp
    ret