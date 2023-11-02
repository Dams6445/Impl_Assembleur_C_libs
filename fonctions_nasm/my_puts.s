global my_puts
section .data
newline db 0xA         ; Newline character

section .text
my_puts:
    ; Input: rdi points to the null-terminated string
    ; Output: String written to stdout, rax contains number of bytes written

    ; Save registers that will be modified
    push rdi
    push rdx

    ; Find the length of the string (excluding null terminator)
    xor rdx, rdx      ; rdx = 0 (counter for length)
    xor rcx, rcx      ; Clear rcx
    mov cl, byte [rdi] ; Load first character of the string
    find_length:
        cmp cl, 0      ; Check for null terminator
        je  end_find_length
        inc rdx        ; Increment length counter
        inc rdi        ; Move to next character
        mov cl, byte [rdi] ; Load next character
        jmp find_length
    end_find_length:

    ; rdx now contains the length of the string

    ; Perform write syscall to write string to stdout
    pop rdi           ; Restore original rdi (pointer to string)
    mov rax, 1        ; syscall: write
    mov rdi, 1        ; file descriptor: stdout
    syscall

    ; Write newline character to stdout
    mov rax, 1        ; syscall: write
    mov rdi, 1        ; file descriptor: stdout
    lea rsi, [newline] ; pointer to newline character
    mov rdx, 1        ; length: 1 byte
    syscall

    ; Restore registers and return
    pop rdx
    ret
