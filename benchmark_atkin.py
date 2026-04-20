import time
import math

def executar_atkin_python(limite):
    print(f"--- Iniciando Crivo de Atkin (Python) ---")
    print(f"Limite: {limite}")
    
    # Em Python, uma lista de booleanos consome muito mais RAM que em Fortran
    eh_primo = [False] * (limite + 1)
    
    t1 = time.time()

    # 1. Equações Quadráticas
    raiz = int(math.sqrt(limite))
    for x in range(1, raiz + 1):
        for y in range(1, raiz + 1):
            
            # n = 4x² + y²
            n = 4*x**2 + y**2
            if n <= limite and (n % 12 == 1 or n % 12 == 5):
                eh_primo[n] = not eh_primo[n]
            
            # n = 3x² + y²
            n = 3*x**2 + y**2
            if n <= limite and (n % 12 == 7):
                eh_primo[n] = not eh_primo[n]
            
            # n = 3x² - y²
            n = 3*x**2 - y**2
            if x > y and n <= limite and (n % 12 == 11):
                eh_primo[n] = not eh_primo[n]

    # 2. Eliminar múltiplos de quadrados
    for s in range(5, raiz + 1):
        if eh_primo[s]:
            quadrado = s**2
            for i in range(quadrado, limite + 1, quadrado):
                eh_primo[i] = False

    # 3. Primos base
    if limite >= 2: eh_primo[2] = True
    if limite >= 3: eh_primo[3] = True

    t2 = time.time()
    
    # Contagem final
    contagem = sum(1 for p in eh_primo if p)
    
    print(f"Cálculo concluído!")
    print(f"Tempo total: {t2 - t1:.4f} segundos")
    print(f"Primos encontrados: {contagem}")

if __name__ == "__main__":
    try:
        limite_input = int(input("Digite o limite para o benchmark (ex: 1000000): "))
        executar_atkin_python(limite_input)
    except ValueError:
        print("Por favor, digite um número inteiro válido.")