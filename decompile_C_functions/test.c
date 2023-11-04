#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Déclaration de la fonction my_strcmp qui est définie dans un autre fichier
int my_strcmp(const char *s1, const char *s2);

int main() {
    // Exemples de chaînes à comparer
    const char *test_strs[][2] = {
        {"abc", "abc"},
        {"abc", "abcd"},
        {"abcd", "abc"},
        {"abc", "def"},
        {"def", "abc"},
    };

    // Test de la fonction my_strcmp
    for (int i = 0; i < sizeof(test_strs) / sizeof(test_strs[0]); i++) {
        const char *s1 = test_strs[i][0];
        const char *s2 = test_strs[i][1];

        int result = my_strcmp(s1, s2);

        printf("Comparing \"%s\" and \"%s\":\n", s1, s2);
        printf("  my_strcmp result: %d\n", result);
        printf("  Expected result: %d\n", strcmp(s1, s2));
        printf("\n");
    }

    return 0;
}
