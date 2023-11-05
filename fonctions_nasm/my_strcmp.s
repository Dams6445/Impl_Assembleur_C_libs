section .text
    global my_strcmp

my_strcmp:

    ; rdi: adresse de la première chaîne (str1)
    ; rsi: adresse de la seconde chaîne (str2)
    xor rax, rax

    .loop:
        ; Charger le caractère courant de str1 dans al
        mov r8b, [rdi]
        ; Charger le caractère courant de str2 dans bl
        mov r9b, [rsi]

        ; Comparer les caractères
        cmp r8b, r9b
        ; Si les caractères sont superieur, sortir de la boucle
        ja .superieur
        ; Si les caractères sont inférieur, sortir de la boucle
        jb .inferieur


        ; Si on a atteint la fin des chaînes (caractère nul), sortir de la boucle
        test r8b, r8b
        jz .equal

        ; Passer au caractère suivant
        inc rdi
        inc rsi

        ; Continuer la boucle
        jmp .loop

    .equal:
        ; Mettre 0 dans rax (valeur de retour)
        xor rax, rax
        ; Retourner
        ret
    
    .superieur:
        ; Mettre 1 dans rax (valeur de retour)
        ; mov rax, 1
        push 1
        pop rax
        ; Retourner
        ret
    
    .inferieur:
        ; Mettre -1 dans rax (valeur de retour)
        ; mov rax, -1
        push -1
        pop rax
        ; Retourner
        ret
