section .text
    global my_strcmp

my_strcmp:

    ; rdi: adresse de la seconde chaîne (str1)
    mov rdi, [rsp+16]
    mov rdi, [rdi]
    ; rsi: adresse de la seconde chaîne (str2)
    mov rsi, [rsp+24]
    mov rsi, [rsi]
    

    .loop:
        ; Charger le caractère courant de str1 dans al
        mov al, dil
        ; Charger le caractère courant de str2 dans bl
        mov bl, sil

        ; Comparer les caractères
        cmp al, bl
        ; Si les caractères sont différents, sortir de la boucle
        jne .different

        ; Si on a atteint la fin des chaînes (caractère nul), sortir de la boucle
        test al, al
        jz .equal

        ; trouver un moyen pour que l'incrementation fasse une suppression de la première lettre et pas un mofification de a en b
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
