global my_bzero
section .text
my_bzero:
    mov byte [rdi], 0   ; Écrire 0 à l'adresse pointée par rdi
    inc rdi             ; Passer à l'adresse mémoire suivante
    dec rsi             ; Décrémenter le compteur
    jnz my_bzero        ; Continuer la boucle si rsi n'est pas zéro
    ret                 ; Retourner au programme appelant
