global my_read   ; Rend la fonction my_read accessible depuis d'autres fichiers
extern __errno_location ; Déclare la fonction externe __errno_location

section .text

my_read:
    ; Appel système read
    xor rax, rax   
    syscall         

    ; Gestion des erreurs
    test rax, rax   ; Compare la valeur de retour (nombre d'octets lus) avec 0
    jge no_error   ; Si >= 0, saute à l'étiquette 'no_error'

    ; En cas d'erreur
    neg rax        ; Met la valeur de retour dans rax à son opposé
    mov rdi, rax   ; Met la valeur de retour dans rdi pour l'appel à __errno_location
    call __errno_location ; Appelle __errno_location pour obtenir l'adresse de errno
    mov [rax], rdi ; Écrit la valeur de errno à l'adresse retournée par __errno_location
    push -1
    pop rax
    ret            ; Retourne

no_error:
    ; En cas de succès
    ret            ; Retourne
