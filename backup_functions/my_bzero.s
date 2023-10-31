global my_bzero
section .text

my_bzero:
    push rbp
    mov rbp, rsp
    mov rdi, [rbp + 16] ; load the address of the memory to zero
    mov rcx, [rbp + 24] ; load the number of bytes to zero
    xor eax, eax        ; set return value to 0
    rep stosb           ; zero the memory
    pop rbp
    ret