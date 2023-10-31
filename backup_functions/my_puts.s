section .data
msg db "Hello, world!", 0

global my_puts
section .text

my_puts:
    ; write system call number
    mov eax, 1
    ; file descriptor (stdout)
    mov ebx, 1
    ; address of string to output
    mov ecx, msg
    ; length of string to output
    mov edx, 13
    ; make the system call
    int 0x80

    ; exit system call number
    mov eax, 60
    ; exit code
    xor edi, edi
    ; make the system call
    syscall