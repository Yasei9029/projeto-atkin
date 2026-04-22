#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void atkin(int limit, int* count) {
    if (limit < 2) {
        *count = 0;
        return;
    }


    unsigned char* sieve = (unsigned char*)calloc(limit + 1, sizeof(unsigned char));
    if (!sieve) {
        printf("Erro de memoria!\n");
        exit(1);
    }

    int x, y, n;

    for (x = 1; x * x <= limit; x++) {
        for (y = 1; y * y <= limit; y++) {

            n = 4 * x * x + y * y;
            if (n <= limit && (n % 12 == 1 || n % 12 == 5))
                sieve[n] ^= 1;

            n = 3 * x * x + y * y;
            if (n <= limit && n % 12 == 7)
                sieve[n] ^= 1;

            n = 3 * x * x - y * y;
            if (x > y && n <= limit && n % 12 == 11)
                sieve[n] ^= 1;
        }
    }

    for (n = 5; n * n <= limit; n++) {
        if (sieve[n]) {
            for (int k = n * n; k <= limit; k += n * n)
                sieve[k] = 0;
        }
    }

    // contar primos (sem armazenar todos)
    int total = 0;

    if (limit >= 2) total++;
    if (limit >= 3) total++;

    for (n = 5; n <= limit; n++) {
        if (sieve[n])
            total++;
    }

    *count = total;

    free(sieve);
}

int main() {
    int n;
    int count = 0;

    printf("Selecione o limite: ");
    scanf("%d", &n);

    clock_t start = clock();

    atkin(n, &count);

    clock_t end = clock();

    double tempo = (double)(end - start) / CLOCKS_PER_SEC;

    printf("Quantidade de primos ate %d: %d\n", n, count);
    printf("Tempo: %f segundos\n", tempo);

    return 0;
}