global my_puts  ; Rend la fonction my_puts accessible depuis d'autres fichiers
section .text

my_puts:
    mov r8, rdi    ; Sauvegarde l'adresse de la chaîne de caractères (passée en rdi) dans r8
    xor r9, r9     ; Initialise r9 à 0, qui sera utilisé pour compter le nombre de caractères

count:
    inc r9         ; Incrémente le compteur de caractères
    inc rdi        ; Passe au caractère suivant dans la chaîne
    cmp BYTE [rdi], 0x0  ; Compare le caractère actuel avec 0 (fin de chaîne)
    je end         ; Si c'est la fin de la chaîne, saute à l'étiquette 'end'
    jmp count      ; Sinon, continue à compter

end:
    mov rax, 0x1   ; Met 1 dans rax, indiquant l'appel système write
    mov rdi, 0x1   ; Met 1 dans rdi, indiquant le descripteur de fichier STDOUT
    mov rsi, r8    ; Met l'adresse de la chaîne dans rsi
    mov rdx, r9    ; Met la longueur de la chaîne dans rdx
    syscall        ; Appelle le système pour écrire la chaîne sur STDOUT
    cmp rax, 0x0   ; Compare la valeur de retour (nombre de caractères écrits) avec 0
    jge no_error   ; Si >= 0, saute à l'étiquette 'no_error'
    mov rax, -1    ; Sinon, met -1 dans rax pour indiquer une erreur
    ret            ; Retourne

no_error:
    mov rax, 1     ; Met 1 dans rax pour indiquer un succès
    ret            ; Retourne
