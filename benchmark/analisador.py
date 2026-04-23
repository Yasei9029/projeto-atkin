import subprocess
import os
import re

# Entra na pasta do benchmark
os.chdir(os.path.dirname(os.path.abspath(__file__)))

def coletar_tempos(comando, nome, limite, termo_chave):
    print(f"\n[ANALISANDO {nome}...]")
    tempos = []
    
    # Garante as 8 threads para o Fortran
    env = os.environ.copy()
    env["OMP_NUM_THREADS"] = "8"

    for i in range(1, 11):
        print(f"  Rodada {i}/10...", end="\r")
        
        # Executa EXATAMENTE como o seu .bat faz
        p = subprocess.Popen(comando, stdin=subprocess.PIPE, stdout=subprocess.PIPE, 
                             stderr=subprocess.PIPE, text=True, shell=True, env=env)
        stdout, _ = p.communicate(input=f"{limite}\n")
        
        # Procura o número na linha que contém o termo chave (Tempo ou CPU)
        for linha in stdout.splitlines():
            if termo_chave in linha:
                # Regex para pegar o número (funciona com ponto ou vírgula)
                busca = re.findall(r"[-+]?\d*\.\d+|\d+", linha.replace(",", "."))
                if busca:
                    tempos.append(float(busca[0]))
                    break
    
    if len(tempos) >= 3:
        tempos.sort()
        # Remove o menor e o maior
        filtrados = tempos[1:-1]
        media = sum(filtrados) / len(filtrados)
        print(f"  Média Final (sem extremos): {media:.4f} segundos")
    else:
        print(f"  Erro: Não foi possível capturar os tempos. Saída: {stdout[:50]}")

L = "1000000000"

# Comandos identicos aos do seu .bat
coletar_tempos(".\\fortran_bench.exe", "FORTRAN", L, "Tempo")
coletar_tempos(".\\c_bench.exe", "LINGUAGEM C", L, "Tempo")
coletar_tempos("java benchmark_java", "JAVA", L, "CPU")
coletar_tempos("python benchmark_python.py", "PYTHON", L, "CPU")

print("\n>>> Benchmark Finalizado! <<<")