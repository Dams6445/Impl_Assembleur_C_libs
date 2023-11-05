global my_read   ; Rend la fonction my_read accessible depuis d'autres fichiers
extern __errno_location ; Déclare la fonction externe __errno_location

section .text

my_read:
    ; Sauvegarde des arguments
    ; mov r8, rdi    ; Sauvegarde le descripteur de fichier (passé en rdi) dans r8
    ; mov r9, rsi    ; Sauvegarde l'adresse du buffer (passé en rsi) dans r9
    ; mov r10, rdx   ; Sauvegarde la taille du buffer (passée en rdx) dans r10

    ; Appel système read
    xor rax, rax   ; Met 0 dans rax, indiquant l'appel système read
    ; mov rdi, r8    ; Met le descripteur de fichier dans rdi
    ; mov rsi, r9    ; Met l'adresse du buffer dans rsi
    ; mov rdx, r10   ; Met la taille du buffer dans rdx
    syscall        ; Appelle le système pour lire les données dans le buffer

    ; Gestion des erreurs
    test rax, rax   ; Compare la valeur de retour (nombre d'octets lus) avec 0
    jge no_error   ; Si >= 0, saute à l'étiquette 'no_error'

    ; En cas d'erreur
    neg rax        ; Met la valeur de retour dans rax à son opposé
    mov rdi, rax   ; Met la valeur de retour dans rdi pour l'appel à __errno_location
    call __errno_location ; Appelle __errno_location pour obtenir l'adresse de errno
    mov [rax], rdi ; Écrit la valeur de errno à l'adresse retournée par __errno_location
    ; mov rax, -1    ; Met -1 dans rax pour indiquer une erreur
    push -1
    pop rax
    ret            ; Retourne

no_error:
    ; En cas de succès
    ret            ; Retourne
