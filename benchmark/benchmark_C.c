#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

void atkin(long long limit, long long* count) {
    if (limit < 2) {
        *count = 0;
        return;
    }

    unsigned char* sieve = (unsigned char*)calloc(limit + 1, sizeof(unsigned char));
    if (!sieve) {
        printf("Erro de memoria!\n");
        exit(1);
    }

    long long x, y, n;

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
            long long step = n * n;
            for (long long k = step; k <= limit; k += step)
                sieve[k] = 0;
        }
    }

    long long total = 0;
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
    long long n;
    long long count = 0;

    printf(">>> CALCULADORA DE PRIMOS (ATKIN) <<<\n");
    printf("Digite o valor limite:\n");
    if (scanf("%lld", &n) != 1) return 1;

    printf("--- Iniciando Crivo de Atkin ---\n");
    printf("Limite: %lld\n", n);

    clock_t start = clock();
    atkin(n, &count);
    clock_t end = clock();

    double tempo = (double)(end - start) / CLOCKS_PER_SEC;

    printf("Tempo total de CPU: %f segundos\n", tempo);
    printf("Primos encontrados: %lld\n", count);

    printf("\nPressione ENTER para sair...\n");
    getchar(); 
    getchar(); 

    return 0;
}