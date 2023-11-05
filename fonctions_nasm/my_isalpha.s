global my_isalpha
section .text
my_isalpha:
    ; Vérifie si le caractère est une lettre majuscule (A-Z)
    cmp rdi, 'A'
    jl  .not_alpha
    cmp rdi, 'Z'
    jle .is_alpha

    ; Vérifie si le caractère est une lettre minuscule (a-z)
    cmp rdi, 'a'
    jl  .not_alpha
    cmp rdi, 'z'
    jle .is_alpha

.not_alpha:
    ; Si ce n'est pas une lettre, retourne 0
    ; mov rax, 0
    push 0
    pop rax
    ret

.is_alpha:
    ; Si c'est une lettre, retourne une valeur non nulle (ici 1)
    push 1
    pop rax
    ; mov rax, 1
    ret
