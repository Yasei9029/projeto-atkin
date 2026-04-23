import math
import time
import multiprocessing
from multiprocessing import shared_memory

def marcar_candidatos(x_inicio, x_fim, limite, raiz_limite, shm_name):
    shm = shared_memory.SharedMemory(name=shm_name)
    mem_view = shm.buf 

    for x in range(x_inicio, x_fim):
        x2 = x * x
        x2_4 = 4 * x2
        x2_3 = 3 * x2
 
        for y in range(1, raiz_limite + 1):
            y2 = y * y
 
            n = x2_4 + y2
            if n <= limite:
                mod12 = n % 12
                if mod12 == 1 or mod12 == 5:
                    mem_view[n] ^= 1
 
            n = x2_3 + y2
            if n <= limite and n % 12 == 7:
                mem_view[n] ^= 1
 
            n = x2_3 - y2
            if x > y and n <= limite and n % 12 == 11:
                mem_view[n] ^= 1
 
    shm.close()
 
def executar_atkin_paralelo_otimizado(limite, num_cores=4):
    print(f"--- Iniciando Crivo de Atkin ---")
    print(f"Limite: {limite}")
 
    tamanho_bytes = limite + 1
    shm = shared_memory.SharedMemory(create=True, size=tamanho_bytes)
    mem_view = shm.buf
 
    t1 = time.perf_counter()
    raiz_limite = int(math.sqrt(limite))
 
    processos = []
    tamanho_chunk = math.ceil(raiz_limite / num_cores)
 
    for i in range(num_cores):
        x_inicio = i * tamanho_chunk + 1
        x_fim = min((i + 1) * tamanho_chunk + 1, raiz_limite + 1)
 
        p = multiprocessing.Process(
            target=marcar_candidatos, 
            args=(x_inicio, x_fim, limite, raiz_limite, shm.name)
        )
        processos.append(p)
        p.start()
 
    for p in processos:
        p.join()
 
    for s in range(5, raiz_limite + 1):
        if mem_view[s]:
            s2 = s * s
            for n in range(s2, limite + 1, s2):
                mem_view[n] = 0
 
    if limite >= 2: mem_view[2] = 1
    if limite >= 3: mem_view[3] = 1
 
    t2 = time.perf_counter()
    tempo_total = t2 - t1
    total_primos = sum(mem_view[:limite + 1])
 
    print(f"Tempo total de CPU: {tempo_total:.4f} segundos")
    print(f"Primos encontrados: {total_primos}")
 
    shm.close()
    shm.unlink()
 
if __name__ == "__main__":
    print(">>> CALCULADORA DE PRIMOS (ATKIN) <<<")
    limite_input = int(input("Digite o valor limite:\n"))
    
    executar_atkin_paralelo_otimizado(limite_input, num_cores=multiprocessing.cpu_count())
    
    print("")
    input("Pressione ENTER para sair...")