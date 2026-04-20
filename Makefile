# Compilador
FC = gfortran
# Flags de otimização e OpenMP
FFLAGS = -O3 -fopenmp -Jobj

# Pastas
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

# Arquivos fonte
SRCS = $(wildcard $(SRC_DIR)/*.f90)
OBJS = $(patsubst $(SRC_DIR)/%.f90, $(OBJ_DIR)/%.o, $(SRCS))

# Nome do executável
TARGET = $(BIN_DIR)/crivo_atkin

# Regra principal
all: $(TARGET)

$(TARGET): $(OBJS)
	$(FC) $(FFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.f90
	$(FC) $(FFLAGS) -c $< -o $@

# Limpar arquivos de compilação
clean:
	rm -rf $(OBJ_DIR)/*.o $(OBJ_DIR)/*.mod $(TARGET)