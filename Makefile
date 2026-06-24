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

# Generates and runs tests for example test cases
test-examples: all
	@powershell -Command "Write-Host ''; Write-Host '=== [TRANSPILANDO: EXEMPLOS DO PDF] ===' -ForegroundColor Cyan; \
	$$files = Get-ChildItem -Path $(EXAMPLES_DIR) -Filter *.obsact; \
	foreach ($$f in $$files) { Write-Host ('[Transpilando] ' + $$f.Name); Get-Content $$f.FullName | ./$(TARGET); if (Test-Path output.c) { Move-Item -Path output.c -Destination ('$(OUT_EXAMPLES)/' + $$f.BaseName + '.c') -Force } }"

# Generates and runs tests for custom test cases
test-ours: all
	@powershell -Command "Write-Host ''; Write-Host '=== [TRANSPILANDO: NOSSOS TESTES] ===' -ForegroundColor Yellow; \
	$$files = Get-ChildItem -Path $(OURS_DIR) -Filter *.obsact; \
	foreach ($$f in $$files) { Write-Host ('[Transpilando] ' + $$f.Name); Get-Content $$f.FullName | ./$(TARGET); if (Test-Path output.c) { Move-Item -Path output.c -Destination ('$(OUT_OURS)/' + $$f.BaseName + '.c') -Force } }"

# Aggregates both example and custom test cases into a single target
tests: tests-examples tests-ours

# Variables to hold the new runtime dependencies
RUNTIME_SRCS = src/functions/obsact_func.c src/functions/aux_func.c

# Runs the compiled C files from example test cases
run-examples:
	@powershell -Command "Write-Host ''; Write-Host '=== [EXECUTANDO: EXEMPLOS DO PDF] ===' -ForegroundColor Cyan; \
	$$files = Get-ChildItem -Path $(OUT_EXAMPLES) -Filter *.c; \
	foreach ($$f in $$files) { Write-Host ('--- [Running] ' + $$f.Name + ' ---'); $(CC) -w -I. $$f.FullName $(RUNTIME_SRCS) -o ('$(OUT_EXAMPLES)/' + $$f.BaseName + '.exe'); if ($$?) { & ('./$(OUT_EXAMPLES)/' + $$f.BaseName + '.exe') } else { Write-Host 'Falha ao compilar ' $$f.Name } }"

# Runs the compiled C files from custom test cases
run-ours:
	@powershell -Command "Write-Host ''; Write-Host '=== [EXECUTANDO: NOSSOS TESTES] ===' -ForegroundColor Yellow; \
	$$files = Get-ChildItem -Path $(OUT_OURS) -Filter *.c; \
	foreach ($$f in $$files) { Write-Host ('--- [Running] ' + $$f.Name + ' ---'); $(CC) -w -I. $$f.FullName $(RUNTIME_SRCS) -o ('$(OUT_OURS)/' + $$f.BaseName + '.exe'); if ($$?) { & ('./$(OUT_OURS)/' + $$f.BaseName + '.exe') } else { Write-Host 'Falha ao compilar ' $$f.Name } }"

# Aggregates both example and custom test runs into a single target
run-tests: run-examples run-ours

# Generates and runs a single test case specified by the FILE variable
test-single: all
	@powershell -Command "if ('$(FILE)' -eq '') { Write-Host 'ERRO: Informe o arquivo! Ex: mingw32-make test-single FILE=tests/our_tests/meu_teste.obsact' -ForegroundColor Red } \
	else { Write-Host ''; Write-Host ('[Transpilando] $(FILE)') -ForegroundColor Green; Get-Content $(FILE) | ./$(TARGET); \
	if (Test-Path output.c) { Move-Item -Path output.c -Destination 'out/single_test.c' -Force; \
	Write-Host ('[Compilando C e Executando...]') -ForegroundColor Green; $(CC) -w -I. out/single_test.c $(RUNTIME_SRCS) -o out/single_test.exe; if ($$?) { & './out/single_test.exe' } } }"

# Runs a single C file specified by the FILE variable
run-single:
	@powershell -Command "if ('$(FILE)' -eq '') { Write-Host 'ERRO: Informe o arquivo C! Ex: mingw32-make run-single FILE=out/our_tests/meu_teste.c' -ForegroundColor Red } \
	else { Write-Host ''; Write-Host ('--- [Running] $(FILE) ---') -ForegroundColor Green; \
	$$exe = '$(FILE)'.Replace('.c', '.exe'); \
	$(CC) -w -I. $(FILE) $(RUNTIME_SRCS) -o $$exe; \
	if ($$?) { & $$exe } else { Write-Host 'Falha ao compilar $(FILE)' -ForegroundColor Red } }"
