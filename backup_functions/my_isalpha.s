global my_isalpha
section .text

my_isalpha:
    push rbp
    mov rbp, rsp
    movzx eax, byte [rbp + 16] ; load the character to check
    cmp al, 'A'                ; compare with 'A'
    jb .not_alpha              ; if less than 'A', not alpha
    cmp al, 'Z'                ; compare with 'Z'
    jbe .is_alpha              ; if between 'A' and 'Z', is alpha
    cmp al, 'a'                ; compare with 'a'
    jb .not_alpha              ; if less than 'a', not alpha
    cmp al, 'z'                ; compare with 'z'
    ja .not_alpha              ; if greater than 'z', not alpha
.is_alpha:
    mov eax, 1                 ; set return value to 1 (true)
    jmp .end
.not_alpha:
    xor eax, eax               ; set return value to 0 (false)
.end:
    pop rbp
    ret