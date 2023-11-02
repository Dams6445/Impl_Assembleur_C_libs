global my_toupper
section .text
my_toupper:
    ; Convertir la valeur d'entrée en unsigned char
    ; (c'est-à-dire, prendre les 8 bits de poids faible de RDI)
    movzx rdi, dil
    
    ; Vérifier si le caractère est une lettre minuscule (entre 'a' et 'z')
    cmp dil, 'a'
    jl .not_lowercase
    cmp dil, 'z'
    jg .not_lowercase

    ; Convertir la lettre minuscule en majuscule
    sub dil, 0x20

.not_lowercase:
    ; Retourner le résultat comme un int (RAX)
    mov eax, edi
    ret
