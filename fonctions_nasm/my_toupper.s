global my_toupper
section .text
my_toupper:
    ; Convertir la valeur d'entrée en unsigned char
    ; (c'est-à-dire, prendre les 8 bits de poids faible de RDI)
    mov eax, edi
    
    ; Vérifier si le caractère est une lettre minuscule (entre 'a' et 'z')
    sub al, 'a'
    cmp al, 'z' - 'a'
    ja .not_lowercase
    
    ; cmp dil, 'a'
    ; jl .not_lowercase
    ; cmp dil, 'z'
    ; jg .not_lowercase

    ; Convertir la lettre minuscule en majuscule
    add al, 'A'
    ret

.not_lowercase:
    ; Retourner le résultat comme un int (RAX)
    add al, 'a'
    ret
