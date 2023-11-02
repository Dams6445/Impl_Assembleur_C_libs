global my_read
section .text
my_read:
    ; Sauvegarde des registres qui doivent être préservés
    push rbp
    push rdi
    push rsi
    push rdx

    ; Paramètres de l'appel système pour read():
    ; rax = syscall number
    ; rdi = file descriptor
    ; rsi = pointer to buffer
    ; rdx = count (number of bytes to read)
    mov rax, 0          ; syscall number for read()
    mov rdi, [rsp + 20] ; file descriptor (1st argument)
    mov rsi, [rsp + 28] ; pointer to buffer (2nd argument)
    mov rdx, [rsp + 36] ; count (3rd argument)

    ; Appel système
    syscall

    ; Restaure les registres
    pop rdx
    pop rsi
    pop rdi
    pop rbp

    ; Retour de la fonction
    ret
