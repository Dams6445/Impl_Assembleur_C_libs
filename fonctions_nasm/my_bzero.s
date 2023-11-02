global my_bzero
section .text
my_bzero:
    ; rdi: pointeur vers la zone mémoire à remplir
    ; rsi: nombre d'octets à écrire

    ; Vérifier si le nombre d'octets à écrire est zéro
    test rsi, rsi
    jz .end

    ; Remplir la mémoire avec des zéros
    xor rax, rax          ; Mettre 0 dans rax
.loop:
    mov [rdi], al         ; Écrire la valeur de rax (0) à l'adresse pointée par rdi
    inc rdi               ; Passer à l'adresse mémoire suivante
    dec rsi               ; Décrémenter le compteur
    jnz .loop             ; Continuer la boucle si rsi n'est pas zéro

.end:
    ret
