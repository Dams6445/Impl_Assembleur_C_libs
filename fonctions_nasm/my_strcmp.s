section .text
    global my_strcmp

my_strcmp:
    ; rdi: adresse de la première chaîne (str1)
    ; rsi: adresse de la seconde chaîne (str2)

    .loop:
        ; Charger le caractère courant de str1 dans al
        mov al, byte [rdi]
        ; Charger le caractère courant de str2 dans bl
        mov bl, byte [rsi]

        ; Comparer les caractères
        cmp al, bl
        ; Si les caractères sont différents, sortir de la boucle
        jne .different

        ; Si on a atteint la fin des chaînes (caractère nul), sortir de la boucle
        test al, al
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

    .different:
        ; Retourner la différence entre les caractères (al - bl)
        sub rax, rsi
        ret
