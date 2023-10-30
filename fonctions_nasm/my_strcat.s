section .text
global strcat

strcat:
    push rbp
    mov rbp, rsp
    mov rsi, [rbp + 16] ; load the destination string
    mov rdi, [rbp + 24] ; load the source string
    mov rcx, 0          ; initialize the counter to 0
    cld                 ; clear the direction flag
    repne scasb         ; find the end of the destination string
    dec rdi             ; back up to the null terminator
    mov rdx, rdi        ; save the address of the null terminator
    mov rsi, [rbp + 24] ; load the source string again
    rep movsb           ; copy the source string to the destination string
    mov byte [rdx], 0   ; add a null terminator to the end of the concatenated string
    pop rbp
    ret