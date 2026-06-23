# Final executable name
TARGET = transpiler

# Directories
TEST_DIR = tests/examples
OUT_DIR = out
OUT_TESTS_DIR = out/out_tests

# Source and generated file paths
FLEX_SRC = src/lexical/lexical.l
BISON_SRC = src/syntax/syntax.y
FLEX_OUT = lex.yy.c
BISON_OUT = syntax.tab.c
BISON_HDR = syntax.tab.h

# C Compiler configurations
CC = gcc
CFLAGS = -Wall

# Main target (default action when executing 'make')
all: setup $(TARGET)

# Ensures output directories exist before compiling
setup:
	powershell -Command "New-Item -ItemType Directory -Force -Path $(OUT_TESTS_DIR) | Out-Null"

# Links generated C objects to create the final executable
$(TARGET): $(BISON_OUT) $(FLEX_OUT)
	$(CC) $(CFLAGS) $(BISON_OUT) $(FLEX_OUT) -o $(TARGET)

# Compiles the syntax specification using Bison
$(BISON_OUT) $(BISON_HDR): $(BISON_SRC)
	win_bison -d $(BISON_SRC)

# Compiles the lexical specification using Flex
$(FLEX_OUT): $(FLEX_SRC) $(BISON_HDR)
	win_flex $(FLEX_SRC)

# Clean rule adapted to Windows
clean:
	powershell -Command "Remove-Item -Force $(TARGET).exe, $(FLEX_OUT), $(BISON_OUT), $(BISON_HDR), output.c -ErrorAction SilentlyContinue; Remove-Item -Recurse -Force $(OUT_DIR) -ErrorAction SilentlyContinue"

# Transpiles all .obsact tests in the examples folder and moves them to out_tests
tests: all
	powershell -Command '$$files = Get-ChildItem -Path $(TEST_DIR) -Filter *.obsact; foreach ($$f in $$files) { Write-Host ("[Transpilando] " + $$f.Name); Get-Content $$f.FullName | ./$(TARGET); Move-Item -Path output.c -Destination ("$(OUT_TESTS_DIR)/" + $$f.BaseName + ".c") -Force }'

# Compiles and executes all the generated .c files in the out_tests folder
run-tests:
	powershell -Command '$$files = Get-ChildItem -Path $(OUT_TESTS_DIR) -Filter *.c; foreach ($$f in $$files) { Write-Host ("`n--- [Executando] " + $$f.Name + " ---"); $(CC) $(CFLAGS) $$f.FullName -o ("$(OUT_TESTS_DIR)/" + $$f.BaseName + ".exe"); if ($$?) { & ("./$(OUT_TESTS_DIR)/" + $$f.BaseName + ".exe") } else { Write-Host "Falha ao compilar " $$f.Name } }'
