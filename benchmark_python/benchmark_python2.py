import math
import time
import multiprocessing
from multiprocessing import shared_memory
 
def marcar_candidatos(x_inicio, x_fim, limite, raiz_limite, shm_name):
    """Função executada em paralelo pelos núcleos."""
 
    # OTIMIZAÇÃO 2: Conecta diretamente à memória RAM alocada pelo processo principal.
    # O .buf retorna um memoryview nativo (format 'B'), livre de erros.
    shm = shared_memory.SharedMemory(name=shm_name)
    mem_view = shm.buf 
 
    for x in range(x_inicio, x_fim):
        # OTIMIZAÇÃO 1: Pre-calcular valores baseados em 'x' fora do loop de 'y'
        x2 = x * x
        x2_4 = 4 * x2
        x2_3 = 3 * x2
 
        for y in range(1, raiz_limite + 1):
            y2 = y * y
 
            n = x2_4 + y2
            if n <= limite:
                # OTIMIZAÇÃO 3: Calcular o módulo uma vez só
                mod12 = n % 12
                if mod12 == 1 or mod12 == 5:
                    mem_view[n] ^= 1
 
            n = x2_3 + y2
            if n <= limite and n % 12 == 7:
                mem_view[n] ^= 1
 
            n = x2_3 - y2
            if x > y and n <= limite and n % 12 == 11:
                mem_view[n] ^= 1
 
    # Fecha a conexão do worker com a memória
    shm.close()
 
def executar_atkin_paralelo_otimizado(limite, num_cores=4):
    print(f"--- Iniciando Crivo de Atkin (Python Multiprocessing Otimizado - {num_cores} Cores) ---")
    print(f"Limite: {limite}")
 
    # Cria o bloco de RAM compartilhada. Ele já nasce preenchido com zeros (False).
    tamanho_bytes = limite + 1
    shm = shared_memory.SharedMemory(create=True, size=tamanho_bytes)
    mem_view = shm.buf
 
    t1 = time.perf_counter()
    raiz_limite = int(math.sqrt(limite))
 
    # --- FASE 1: PARALELIZADA ---
    processos = []
    tamanho_chunk = math.ceil(raiz_limite / num_cores)
 
    for i in range(num_cores):
        x_inicio = i * tamanho_chunk + 1
        x_fim = min((i + 1) * tamanho_chunk + 1, raiz_limite + 1)
 
        p = multiprocessing.Process(
            target=marcar_candidatos, 
            args=(x_inicio, x_fim, limite, raiz_limite, shm.name) # Passamos apenas o nome do bloco RAM
        )
        processos.append(p)
        p.start()
 
    for p in processos:
        p.join()
 
    # --- FASE 2: SERIAL ---
    for s in range(5, raiz_limite + 1):
        if mem_view[s]:
            s2 = s * s
            for n in range(s2, limite + 1, s2):
                mem_view[n] = 0
 
    # --- FASE 3: Primos base ---
    if limite >= 2: mem_view[2] = 1
    if limite >= 3: mem_view[3] = 1
 
    t2 = time.perf_counter()
    tempo_total = t2 - t1
 
    # O Sistema Operacional pode alocar a memória arredondando para blocos maiores (ex: múltiplos de 4096 bytes).
    # Por isso, fatiamos mem_view[:limite + 1] para somar estritamente o intervalo que calculamos.
    total_primos = sum(mem_view[:limite + 1])
 
    print(f"Calculo concluido!")
    print(f"Tempo total (Wall-clock): {tempo_total:.4f} segundos")
    print(f"Primos encontrados: {total_primos}")
 
    # Limpeza obrigatória para devolver a RAM ao Sistema Operacional
    shm.close()
    shm.unlink()
 
if __name__ == "__main__":
    limite_input = int(input("Digite o limite para o benchmark (ex: 1000000): "))
    executar_atkin_paralelo_otimizado(limite_input, num_cores=4)