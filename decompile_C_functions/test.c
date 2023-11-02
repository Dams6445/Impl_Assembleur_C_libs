#include <stdio.h>
#include <ctype.h>

int main() {
    char c = 00;
    char result = toupper(c);
    printf("Original character: %c\n", c);
    printf("Converted character: %c\n", result);
    return 0;
}