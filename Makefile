# Final executable name
TARGET = transpiler

# Directories for Inputs
EXAMPLES_DIR = tests/examples
OURS_DIR = tests/our_tests

# Directories for Outputs
OUT_EXAMPLES = out/examples
OUT_OURS = out/our_tests

# Source and generated file paths
FLEX_SRC = src/lexical/lexical.l
BISON_SRC = src/syntax/syntax.y
FLEX_OUT = lex.yy.c
BISON_OUT = syntax.tab.c
BISON_HDR = syntax.tab.h

# C Compiler configurations for the Transpiler
CC = gcc
# Adicionado -Wno-unused-function para ignorar os avisos chatos do Flex
CFLAGS = -Wall -Wno-unused-function -I. 

# Main target (default action when executing 'make')
all: setup $(TARGET)

# Ensures output directories exist before compiling
setup:
	@powershell -Command "New-Item -ItemType Directory -Force -Path $(OUT_EXAMPLES), $(OUT_OURS) | Out-Null"

# Links generated C objects to create the final executable
$(TARGET): $(BISON_OUT) $(FLEX_OUT)
	@echo [Build] Compiling the transpiler...
	@$(CC) $(CFLAGS) $(BISON_OUT) $(FLEX_OUT) -o $(TARGET)

# Compiles the syntax specification using Bison
$(BISON_OUT) $(BISON_HDR): $(BISON_SRC)
	@echo [Bison] Generating syntax parser...
	@win_bison -d $(BISON_SRC)

# Compiles the lexical specification using Flex
$(FLEX_OUT): $(FLEX_SRC) $(BISON_HDR)
	@echo [Flex] Generating lexical scanner...
	@win_flex $(FLEX_SRC)

# Clean rule adapted to Windows
clean:
	@echo [Clean] Removing generated files...
	@powershell -Command "Remove-Item -Force $(TARGET).exe, $(FLEX_OUT), $(BISON_OUT), $(BISON_HDR), output.c, out/single_test* -ErrorAction SilentlyContinue; Remove-Item -Force $(OUT_EXAMPLES)/*.c, $(OUT_EXAMPLES)/*.exe, $(OUT_OURS)/*.c, $(OUT_OURS)/*.exe -ErrorAction SilentlyContinue"

# ==========================================
# MACROS DE TRANSPILAÇÃO (GERA OS .c)
# ==========================================

test-examples: all
	@powershell -Command "Write-Host ''; Write-Host '=== [TRANSPILANDO: EXEMPLOS DO PDF] ===' -ForegroundColor Cyan; \
	$$files = Get-ChildItem -Path $(EXAMPLES_DIR) -Filter *.obsact; \
	foreach ($$f in $$files) { Write-Host ('[Transpilando] ' + $$f.Name); Get-Content $$f.FullName | ./$(TARGET); if (Test-Path output.c) { Move-Item -Path output.c -Destination ('$(OUT_EXAMPLES)/' + $$f.BaseName + '.c') -Force } }"

test-ours: all
	@powershell -Command "Write-Host ''; Write-Host '=== [TRANSPILANDO: NOSSOS TESTES] ===' -ForegroundColor Yellow; \
	$$files = Get-ChildItem -Path $(OURS_DIR) -Filter *.obsact; \
	foreach ($$f in $$files) { Write-Host ('[Transpilando] ' + $$f.Name); Get-Content $$f.FullName | ./$(TARGET); if (Test-Path output.c) { Move-Item -Path output.c -Destination ('$(OUT_OURS)/' + $$f.BaseName + '.c') -Force } }"

tests: tests-examples tests-ours

# ==========================================
# MACROS DE EXECUÇÃO (COMPILA OS .c E RODA)
# ==========================================

# Nota: Usando a flag '-w' para compilar os .c gerados, ocultando warnings de variáveis não utilizadas do GCC
run-examples:
	@powershell -Command "Write-Host ''; Write-Host '=== [EXECUTANDO: EXEMPLOS DO PDF] ===' -ForegroundColor Cyan; \
	$$files = Get-ChildItem -Path $(OUT_EXAMPLES) -Filter *.c; \
	foreach ($$f in $$files) { Write-Host ('--- [Running] ' + $$f.Name + ' ---'); $(CC) -w -I. $$f.FullName -o ('$(OUT_EXAMPLES)/' + $$f.BaseName + '.exe'); if ($$?) { & ('./$(OUT_EXAMPLES)/' + $$f.BaseName + '.exe') } else { Write-Host 'Falha ao compilar ' $$f.Name } }"

run-ours:
	@powershell -Command "Write-Host ''; Write-Host '=== [EXECUTANDO: NOSSOS TESTES] ===' -ForegroundColor Yellow; \
	$$files = Get-ChildItem -Path $(OUT_OURS) -Filter *.c; \
	foreach ($$f in $$files) { Write-Host ('--- [Running] ' + $$f.Name + ' ---'); $(CC) -w -I. $$f.FullName -o ('$(OUT_OURS)/' + $$f.BaseName + '.exe'); if ($$?) { & ('./$(OUT_OURS)/' + $$f.BaseName + '.exe') } else { Write-Host 'Falha ao compilar ' $$f.Name } }"

run-tests: run-examples run-ours

# ==========================================
# MACRO PARA TESTAR UM ÚNICO ARQUIVO RÁPIDO
# ==========================================
test-single: all
	@powershell -Command "if ('$(FILE)' -eq '') { Write-Host 'ERRO: Informe o arquivo! Ex: mingw32-make test-single FILE=tests/our_tests/meu_teste.obsact' -ForegroundColor Red } \
	else { Write-Host ''; Write-Host ('[Transpilando] $(FILE)') -ForegroundColor Green; Get-Content $(FILE) | ./$(TARGET); \
	if (Test-Path output.c) { Move-Item -Path output.c -Destination 'out/single_test.c' -Force; \
	Write-Host ('[Compilando C e Executando...]') -ForegroundColor Green; $(CC) -w -I. out/single_test.c -o out/single_test.exe; if ($$?) { & './out/single_test.exe' } } }"

# ==========================================
# MACRO PARA COMPILAR E RODAR UM .c INDIVIDUAL
# ==========================================
run-single:
	@powershell -Command "if ('$(FILE)' -eq '') { Write-Host 'ERRO: Informe o arquivo C! Ex: mingw32-make run-single FILE=out/our_tests/meu_teste.c' -ForegroundColor Red } \
	else { Write-Host ''; Write-Host ('--- [Running] $(FILE) ---') -ForegroundColor Green; \
	$$exe = '$(FILE)'.Replace('.c', '.exe'); \
	$(CC) -w -I. $(FILE) -o $$exe; \
	if ($$?) { & $$exe } else { Write-Host 'Falha ao compilar $(FILE)' -ForegroundColor Red } }"
