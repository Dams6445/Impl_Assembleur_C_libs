global my_puts
section .data
    newline db 0xA   ; Définit la chaîne de nouvelle ligne

section .text
    my_puts:
        mov r8, rdi    ; Sauvegarde l'adresse de la chaîne de caractères (passée en rdi) dans r8
        xor r9, r9     ; Initialise r9 à 0, qui sera utilisé pour compter le nombre de caractères
        cmp BYTE [r8], 0x0  ; Compare le premier caractère avec 0 (fin de chaîne)
        je write_newline ; Si c'est la fin de la chaîne, saute à 'write_newline'
        
    count:
        inc r9         ; Incrémente le compteur de caractères
        inc rdi        ; Passe au caractère suivant dans la chaîne
        cmp BYTE [rdi], 0x0  ; Compare le caractère actuel avec 0 (fin de chaîne)
        je end         ; Si c'est la fin de la chaîne, saute à 'end'
        jmp count      ; Sinon, continue à compter

    end:
        push 1
        pop rax        ; Met 1 dans rax, indiquant l'appel système write
        push 1
        pop rdi        ; Met 1 dans rdi, indiquant le descripteur de fichier STDOUT   
        mov rsi, r8    ; Met l'adresse de la chaîne dans rsi
        mov rdx, r9    ; Met la longueur de la chaîne dans rdx
        syscall        ; Appelle le système pour écrire la chaîne sur STDOUT
        cmp rax, 0x0   ; Compare la valeur de retour (nombre de caractères écrits) avec 0
        jge write_newline ; Si >= 0, saute à l'étiquette 'write_newline'   
        push -1
        pop rax        ; Sinon, met -1 dans rax pour indiquer une erreur
        ret            ; Retourne

    write_newline: 
        push 1
        pop rax        ; Met 1 dans rax, indiquant l'appel système write
        push 1
        pop rdi        ; Met 1 dans rdi, indiquant le descripteur de fichier STDOUT  
        lea rsi, [rel newline] ; Met l'adresse de la chaîne de nouvelle ligne dans rsi
        push 1
        pop rdx        ; Met la longueur de la chaîne de nouvelle ligne dans rdx
        syscall        ; Appelle le système pour écrire la nouvelle ligne sur STDOUT
        cmp rax, 0x0   ; Compare la valeur de retour (nombre de caractères écrits) avec 0
        jl error       ; Si >= 0, saute à l'étiquette 'error'  
        push 1         
        pop rax        ; Met 1 dans rax pour indiquer un succès
        ret            ; Retourne

    error:  
        push -1
        pop rax        ; Met -1 dans rax pour indiquer une erreur
        ret            ; Retourne
