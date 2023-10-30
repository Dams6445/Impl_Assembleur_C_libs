section .data
msg db "Hello, world!", 0

section .text
global puts

puts:
    push rbp
    mov rbp, rsp
    mov rsi, msg ; load the address of the string to print
    call printf   ; call the C standard library function printf
    xor eax, eax  ; set the return value to 0
    pop rbp
    ret