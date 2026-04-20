FC = gfortran
FFLAGS = -O3 -fopenmp -Jobj
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

# Lista os objetos na ordem correta: primeiro os módulos, depois o main
OBJS = $(OBJ_DIR)/mod_crivo.o $(OBJ_DIR)/main.o

TARGET = $(BIN_DIR)/crivo_atkin

all: $(TARGET)

$(TARGET): $(OBJS)
	$(FC) $(FFLAGS) -o $@ $^

# Regra geral para transformar .f90 em .o
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.f90
	$(FC) $(FFLAGS) -c $< -o $@

# EXPLÍCITO: O main.o depende do mod_crivo.o estar pronto
$(OBJ_DIR)/main.o: $(SRC_DIR)/main.f90 $(OBJ_DIR)/mod_crivo.o

clean:
	if exist obj\*.o del /q obj\*.o
	if exist obj\*.mod del /q obj\*.mod
	if exist bin\*.exe del /q bin\*.exe