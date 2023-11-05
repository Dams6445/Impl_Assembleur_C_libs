global my_read   ; Rend la fonction my_read accessible depuis d'autres fichiers
extern __errno_location ; Déclare la fonction externe __errno_location

section .text

my_read:
    xor rax, rax            ; RAZ de rax
    syscall                 ; Appel système 0 : read

    test rax, rax           ; Test si rax est null
    jge no_error            ; Si rax >= 0, pas d'erreur

    ;si erreur
    neg rax                 ; Sinon, on met rax à -1
    mov rdi, rax            ; On met rax dans rdi pour l'appel de __errno_location
    call __errno_location   ; Appel de __errno_location
    mov [rax], rdi          ; On met rdi dans l'adresse pointée par rax
    push -1                 
    pop rax                 ; On met -1 dans rax
    ret            

no_error:
    ret            
