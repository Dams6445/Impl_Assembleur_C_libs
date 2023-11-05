global my_puts
section .data
    newline db 0xA   ; Définit la chaîne de nouvelle ligne

section .text
    my_puts:
        mov r8, rdi    ; Sauvegarde l'adresse de la chaîne de caractères (passée en rdi) dans r8
        xor r9, r9     ; Initialise r9 à 0, qui sera utilisé pour compter le nombre de caractères
        cmp BYTE [r8], 0x0  ; Compare le premier caractère avec 0 (fin de chaîne)
        je write_newline ; Si c'est la fin de la chaîne, saute à l'étiquette 'write_newline'
        jmp count      ; Sinon, continue à compter
        
    count:
        inc r9         ; Incrémente le compteur de caractères
        inc rdi        ; Passe au caractère suivant dans la chaîne
        cmp BYTE [rdi], 0x0  ; Compare le caractère actuel avec 0 (fin de chaîne)
        je end         ; Si c'est la fin de la chaîne, saute à l'étiquette 'end'
        jmp count      ; Sinon, continue à compter

    end:
        ; mov rax, 0x1   ; Met 1 dans rax, indiquant l'appel système write
        push 1
        pop rax
        push 1
        pop rdi
        ; mov rdi, 0x1   ; Met 1 dans rdi, indiquant le descripteur de fichier STDOUT
        mov rsi, r8    ; Met l'adresse de la chaîne dans rsi
        mov rdx, r9    ; Met la longueur de la chaîne dans rdx
        syscall        ; Appelle le système pour écrire la chaîne sur STDOUT
        cmp rax, 0x0   ; Compare la valeur de retour (nombre de caractères écrits) avec 0
        jge write_newline ; Si >= 0, saute à l'étiquette 'write_newline'
        ;mov rax, -1    ; Sinon, met -1 dans rax pour indiquer une erreur
        push -1
        pop rax
        ret            ; Retourne

    write_newline:
        ;mov rax, 0x1   ; Met 1 dans rax, indiquant l'appel système write
        push 1
        pop rax
        push 1
        pop rdi
        ; mov rdi, 0x1   ; Met 1 dans rdi, indiquant le descripteur de fichier STDOUT
        lea rsi, [rel newline] ; Met l'adresse de la chaîne de nouvelle ligne dans rsi
        ; mov rdx, 1     ; Met la longueur de la chaîne de nouvelle ligne dans rdx
        push 1
        pop rdx
        syscall        ; Appelle le système pour écrire la nouvelle ligne sur STDOUT
        cmp rax, 0x0   ; Compare la valeur de retour (nombre de caractères écrits) avec 0
        jge error       ; Si >= 0, saute à l'étiquette 'error'
        ; mov rax, -1     ; Met 1 dans rax pour indiquer un succès
        push -1
        pop rax
        ret            ; Retourne

    error:
        ; mov rax, 1    ; Met -1 dans rax pour indiquer une erreur
        push 1
        pop rax
        ret            ; Retourne
