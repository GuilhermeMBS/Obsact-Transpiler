# Final executable name
TARGET = transpiler

# Source and test file paths
FLEX_SRC = src/lexical/lexical.l
BISON_SRC = src/syntax/syntax.y
TEST_FILE = tests/test.obsact

# Automatically generated C files (kept at root for easier compilation)
FLEX_OUT = lex.yy.c
BISON_OUT = syntax.tab.c
BISON_HDR = syntax.tab.h

# C Compiler configurations
CC = gcc
CFLAGS = -Wall

# Main target (default action when executing 'make')
all: $(TARGET)

# Links generated C objects to create the final executable
$(TARGET): $(BISON_OUT) $(FLEX_OUT)
	$(CC) $(CFLAGS) $(BISON_OUT) $(FLEX_OUT) -o $(TARGET)

# Compiles the syntax specification using Bison
$(BISON_OUT) $(BISON_HDR): $(BISON_SRC)
	win_bison -d $(BISON_SRC)

# Compiles the lexical specification using Flex
$(FLEX_OUT): $(FLEX_SRC) $(BISON_HDR)
	win_flex $(FLEX_SRC)

# Clean rule adapted to Windows using PowerShell to prevent CreateProcess errors
clean:
	powershell -Command "Remove-Item -Force $(TARGET).exe, $(FLEX_OUT), $(BISON_OUT), $(BISON_HDR) -ErrorAction SilentlyContinue"

# Test execution shortcut using PowerShell and the updated tests path
test: all
	powershell -Command "Get-Content $(TEST_FILE) | ./$(TARGET)"
