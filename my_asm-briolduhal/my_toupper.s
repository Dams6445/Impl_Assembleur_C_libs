global my_toupper
section .text
my_toupper:
    ; Sauvegarder le registre EDI
    mov eax, edi
    
    ; Vérifier si la lettre est minuscule
    sub al, 'a'
    cmp al, 'z' - 'a'
    ja .not_lowercase
    
    ; Convertir la lettre minuscule en majuscule
    add al, 'A'
    ret

.not_lowercase:
    ; Retourner le résultat comme un int (RAX)
    add al, 'a'
    ret
