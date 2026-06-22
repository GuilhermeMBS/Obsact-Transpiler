%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);
%}

/* Define os tipos de dados que trafegam do Flex para o Bison */
%union {
    char* str_val;
    int int_val;
}

/* Declaração dos Tokens informando o tipo de dado que eles carregam */
%token TOKEN_DEVICE_KW TOKEN_SET_KW TOKEN_OPEN_BRACE TOKEN_CLOSE_BRACE TOKEN_EQUAL TOKEN_PERIOD
%token <str_val> TOKEN_IDENTIFIER
%token <int_val> TOKEN_NUM

%%

/* PROGRAM -> DEVICES CMDS */
program:
    devices cmds { 
        printf("// Transpilation finished successfully.\n"); 
    }
;

/* DEVICES -> DEVICE DEVICES | DEVICE */
devices:
    device
  | device devices
;

/* DEVICE -> dispositivo: {namedevice} */
device:
    TOKEN_DEVICE_KW TOKEN_OPEN_BRACE TOKEN_IDENTIFIER TOKEN_CLOSE_BRACE {
        // Geração de código C: criando uma variável para representar o estado do dispositivo
        printf("// Registering device\n");
        printf("int %s_status = 0;\n\n", $3);
        free($3); // Libera a memória alocada pelo strdup no Flex
    }
;

/* CMDS -> CMD. CMDS | CMD. (Simplificado para o seu ponto de partida) */
cmds:
    cmd TOKEN_PERIOD
  | cmd TOKEN_PERIOD cmds
;

/* CMD -> ATTRIB */
cmd:
    attrib
;

/* ATTRIB -> set observation = VAR */
attrib:
    TOKEN_SET_KW TOKEN_IDENTIFIER TOKEN_EQUAL TOKEN_NUM {
        // Geração de código C: traduzindo a atribuição do ObsAct para uma linha C válida
        printf("// Setting sensor value\n");
        printf("int %s = %d;\n\n", $2, $4);
        free($2);
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main() {
    // Escreve o cabeçalho padrão do arquivo C que será gerado antes de começar o parsing
    printf("#include <stdio.h>\n");
    printf("// Include your runtime platform functions here\n\n");
    printf("int main() {\n");

    yyparse();

    // Fecha a função main do arquivo gerado
    printf("    return 0;\n");
    printf("}\n");
    return 0;
}
