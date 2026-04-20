# Crivo de Atkin em Fortran: Computação Científica de Alto Desempenho

Este projeto consiste na implementação e otimização do algoritmo **Crivo de Atkin** utilizando a linguagem **Fortran (padrão 90/2008)**. O objetivo é identificar números primos em escalas massivas, aproveitando a eficiência de memória e o paralelismo nativo do Fortran.

## 🚀 Diferenciais do Projeto
- **Performance Massiva:** Capaz de processar 1 bilhão de números em menos de 5 segundos.
- **Paralelização (OpenMP):** Utiliza múltiplos núcleos da CPU para acelerar cálculos quadráticos complexos.
- **Eficiência de Memória:** Implementação com `logical(kind=1)` para permitir grandes intervalos de busca mesmo em hardware doméstico.
- **Salvamento Inteligente:** Gera relatórios detalhados (`resumo_primos.txt`) com auditoria dos últimos primos encontrados.

## 🛠️ Pré-requisitos
Para compilar e rodar o projeto, você precisará de:
- Compilador **gfortran** (GCC) com suporte a OpenMP.
- Ferramenta **Make** (ou `mingw32-make` no Windows).

## ⚙️ Como Compilar e Rodar

### ⚙️ Guia Rápido de Instalação e Execução

## 1. Clone o repositório e acesse a pasta
git clone https://github.com/Yasei9029/projeto-atkin.git
cd projeto-atkin

## 2. Crie a estrutura de pastas necessária
mkdir bin, obj, data

## 3. Compile o código usando o Makefile
mingw32-make

## 4. Execute o programa
.\bin\crivo_atkin.exe

```bash
