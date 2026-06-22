# Nome do executável final
TARGET = transpilador

# Arquivos fonte do Flex e Bison
FLEX_SRC = lexico.l
BISON_SRC = sintatico.y

# Arquivos C gerados automaticamente
FLEX_OUT = lex.yy.c
BISON_OUT = sintatico.tab.c
BISON_HDR = sintatico.tab.h

# Compilador C
CC = gcc
CFLAGS = -Wall

# Alvo principal (o que acontece quando você digita apenas 'make')
all: $(TARGET)

$(TARGET): $(BISON_OUT) $(FLEX_OUT)
	$(CC) $(CFLAGS) $(BISON_OUT) $(FLEX_OUT) -o $(TARGET)

$(BISON_OUT) $(BISON_HDR): $(BISON_SRC)
	win_bison -d $(BISON_SRC)

$(FLEX_OUT): $(FLEX_SRC) $(BISON_HDR)
	win_flex $(FLEX_SRC)

# Alvo para limpar os arquivos gerados e recomeçar do zero
clean:
	del /f $(TARGET).exe $(FLEX_OUT) $(BISON_OUT) $(BISON_HDR)

# Alvo para rodar o teste rapidamente
test: all
	./$(TARGET) < teste.obsact
