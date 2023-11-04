global my_strcat
section .text
my_strcat:
    ; Les arguments sont passés via les registres rdi (dest) et rsi (src)
    ; Sauvegarde des registres
    push rdi

    ; Trouver le caractère nul de la chaîne dest
    ; rdi pointe vers dest
find_end_of_dest:
    mov al, byte [rdi]    ; Charger le caractère actuel dans al
    test al, al           ; Tester si al est nul
    jz copy_src           ; Si c'est le cas, passer à la copie de src
    inc rdi               ; Sinon, passer au caractère suivant dans dest
    jmp find_end_of_dest

    ; Copier la chaîne src à la fin de dest
copy_src:
    mov al, byte [rsi]    ; Charger le caractère actuel de src dans al
    mov byte [rdi], al    ; Copier al à la position actuelle de dest
    test al, al           ; Tester si al est nul
    jz finish             ; Si c'est le cas, terminer
    inc rdi               ; Passer au caractère suivant dans dest
    inc rsi               ; Passer au caractère suivant dans src
    jmp copy_src

finish:
    ; Restaurer les registres et retourner
    pop rax
    ret
