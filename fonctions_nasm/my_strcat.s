global my_strcat
section .text
my_strcat:
    push rdi                ;sauvegarde de rdi dans la stack

find_end_of_dest:
    mov al, byte [rdi]      ;on met dans al le caractère contenu dans rdi
    test al, al             ;on teste si al est nul           
    jz copy_src             ;si nul on saute à copy_src
    inc rdi                 ;sinon on incrémente rdi
    jmp find_end_of_dest    ;on enchaine avec le caractère suivant

copy_src:
    mov al, byte [rsi]      ;on met dans al le caractère contenu dans rsi 
    mov byte [rdi], al      ;on met dans rdi le caractère contenu dans al
    test al, al             ;on teste si al est nul     
    jz finish               ;si nul on saute à finish
    inc rdi                 ;sinon on incrémente rdi
    inc rsi                 ;on incrémente rsi
    jmp copy_src            ;on enchaine avec le caractère suivant  

finish:
    pop rax                 ;on récupère rdi dans rax
    ret                     
