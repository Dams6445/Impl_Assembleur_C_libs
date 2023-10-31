section .data
buf resb 1024 ; reserve 1024 bytes of memory for the input buffer

global my_read
section .text

my_read:
    push rbp
    mov rbp, rsp
    mov rdi, 0    ; read from standard input (file descriptor 0)
    mov rsi, buf  ; load the address of the input buffer
    mov rdx, 1024 ; read up to 1024 bytes
    mov eax, 0    ; set the system call number to 0 (read)
    syscall       ; call the read system call
    mov rdi, [rbp + 16] ; load the file descriptor argument
    mov [rdi], rax      ; store the number of bytes read in the file descriptor
    xor eax, eax        ; set the return value to 0
    pop rbp
    ret