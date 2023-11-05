global my_isalpha
section .text
my_isalpha:
    mov     rax, rdi
    or      al, 32    ; Convertit le caractère en minuscule
    sub     al, 'a'   ; Soustrait 'a' pour obtenir un nombre entre 0 et 25
    cmp     al, 'z' - 'a'    ; Vérifie si le caractère est entre 'a' et 'z'
    setna   al      ; Si le caractère est plus grand que 'z', al = 1
    ret
