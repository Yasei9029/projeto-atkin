import math
import time

def executar_atkin_puro(limite):
    print(f"--- Iniciando Crivo de Atkin (Python Puro) ---")
    # Cuidado: 1 bilhão aqui vai consumir muita RAM (~8GB+) e horas de CPU
    eh_primo = [False] * (limite + 1)
    
    t1 = time.perf_counter()
    raiz_limite = int(math.sqrt(limite))

    for x in range(1, raiz_limite + 1):
        x2 = x * x
        for y in range(1, raiz_limite + 1):
            y2 = y * y
            
            n = 4 * x2 + y2
            if n <= limite and (n % 12 == 1 or n % 12 == 5):
                eh_primo[n] = not eh_primo[n]

            n = 3 * x2 + y2
            if n <= limite and n % 12 == 7:
                eh_primo[n] = not eh_primo[n]

            n = 3 * x2 - y2
            if x > y and n <= limite and n % 12 == 11:
                eh_primo[n] = not eh_primo[n]

    for s in range(5, raiz_limite + 1):
        if eh_primo[s]:
            s2 = s * s
            for n in range(s2, limite + 1, s2):
                eh_primo[n] = False

    if limite >= 2: eh_primo[2] = True
    if limite >= 3: eh_primo[3] = True
    
    t2 = time.perf_counter()
    print(f"Tempo total: {t2 - t1:.4f} segundos")
    print(f"Primos encontrados: {sum(eh_primo)}")

if __name__ == "__main__":
    limite = int(input("Digite o limite para o benchmark (ex: 1000000): "))
    executar_atkin_puro(limite)
