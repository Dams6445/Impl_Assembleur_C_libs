global my_read
section .text
my_read:
    ; Numéro de l'appel système pour 'read' sous Linux x86-64
    mov rax, 0

    ; Appel système
    syscall

    ; Vérifier si une erreur s'est produite (valeur de retour dans rax)
    cmp rax, -4096  ; Les erreurs sont signalées par des valeurs négatives
    jge .success    ; Si rax >= -4096, alors pas d'erreur

    ; Si c'est une erreur, -rax est le code d'erreur
    neg rax         ; Convertir rax en valeur positive
    mov rdi, rax    ; Mettre le code d'erreur dans rdi
    call set_errno  ; Appeler set_errno

    ; Mettre le code d'erreur en valeur négative dans rax pour le retourner
    neg rax

.success:
    ret

section .data
errno resq 1      ; Réserver de l'espace pour errno

section .text
set_errno:
    ; Mettre le code d'erreur (rdi) dans errno
    mov [errno], rdi
    ret
