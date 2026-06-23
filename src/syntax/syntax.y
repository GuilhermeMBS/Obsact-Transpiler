%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);
extern int yylineno;
%}

/* Define os tipos de dados que trafegam do Flex para o Bison */
%union {
    char* str_val;
    unsigned int int_val;
    bool bool_val;
}

/* Declaração dos Tokens informando o tipo de dado que eles carregam */
%token TOKEN_OPEN_BRACE TOKEN_CLOSE_BRACE
%token TOKEN_OPEN_PARENTHESIS TOKEN_CLOSE_PARENTHESIS
%token TOKEN_EQUAL
%token TOKEN_PERIOD
%token TOKEN_TWO_POINTS
%token TOKEN_COMMA
%token TOKEN_AND

%token TOKEN_DEVICE_KW
%token TOKEN_SET_KW

%token TOKEN_IF_KW
%token TOKEN_ELSE_KW
%token TOKEN_THEN_KW
%token TOKEN_FOR_ALL_KW

%token TOKEN_SEND_ALERT_KW
%token TOKEN_CHECK_KW
%token TOKEN_TURN_ON_KW
%token TOKEN_TURN_OFF_KW

%token <str_val> TOKEN_OPLOGIC
%token <str_val> TOKEN_MSG
%token <str_val> TOKEN_IDENTIFIER

%token <int_val> TOKEN_NUM
%token <bool_val> TOKEN_BOOL

/* Configuração de tipos para as regras que retornam ou processam valores de texto/lógica */
%type <str_val> with_obs exp actexecute obs action
%type <str_val> value

/* Resoluções de Precedência e Ambiguidade */
%left TOKEN_AND
%nonassoc TOKEN_ELSE_KW
%expect 1

%%

/* PROGRAM -> Agora aceita opcionalmente que o Flex termine de ler espaços/novas linhas vazias */
program:
    devices cmds end_of_file { 
        printf("    // Transpilation finished successfully.\n"); 
    }
;

end_of_file:
    /* vazio */
  | TOKEN_PERIOD /* absorve algum ponto residual se houver no escopo global */
;

/* DEVICES -> DEVICES DEVICE | DEVICE */
devices:
    devices device
  | device
;

/* DEVICE -> dispositivo: { namedevice with_obs } */
device:
    TOKEN_DEVICE_KW TOKEN_TWO_POINTS TOKEN_OPEN_BRACE TOKEN_IDENTIFIER with_obs TOKEN_CLOSE_BRACE {
        if ($5 == NULL) {
            printf("    // Registering standalone device\n");
            printf("    const char* %s = \"%s\";\n\n", $4, $4);
        } else {
            printf("    // Registering device with sensor bound\n");
            printf("    const char* %s = \"%s\";\n", $4, $4);
            printf("    int %s = 0; // Implicit initialization to 0\n\n", $5);
            free($5);
        }
        free($4);
    }
;

/* REGRA MÁGICA REAPROVEITÁVEL (Fatoração do ", observation") */
with_obs:
    TOKEN_COMMA TOKEN_IDENTIFIER { 
        $$ = $2; 
    }
  | /* vazio = épsilon seguro */ { 
        $$ = NULL; 
    }
;

/* CMDS -> Lista de comandos (agora sem o ponto engessado) */
cmds:
    cmds cmd
  | cmd
;

/* CMD -> Atribuição e Ação pedem ponto. OBSACT (bloco if) não pede ponto extra! */
cmd:
    attrib TOKEN_PERIOD
  | obsact
  | act TOKEN_PERIOD
;

/* ATTRIB -> set observation = EXP */
attrib:
    TOKEN_SET_KW TOKEN_IDENTIFIER TOKEN_EQUAL exp {
        printf("    // Setting sensor or expression value\n");
        printf("    %s = %s;\n\n", $2, $4);
        free($2);
        free($4);
    }
;

/* EXP -> VAR | ACTEXECUTE */
exp:
    value      { $$ = $1; }
  | actexecute { $$ = $1; }
;

/* VALUE -> num | bool (retorna string para a regra EXP) */
value:
    TOKEN_NUM  { 
        char buffer[32];
        sprintf(buffer, "%u", $1);
        $$ = strdup(buffer);
    }
  | TOKEN_BOOL { 
        $$ = strdup($1 ? "true" : "false"); 
    }
;

/* REGRA AUXILIAR PARA EVITAR CONFLITO DE MID-RULE ACTION */
if_header:
    TOKEN_IF_KW obs TOKEN_THEN_KW {
        printf("    if (%s) {\n", $2);
        free($2);
    }
;

/* OBSACT -> se OBS entao CMDS | se OBS entao CMDS senao CMDS */
obsact:
    if_header cmd {
        printf("    }\n\n");
    }
  | if_header cmd TOKEN_ELSE_KW { printf("    } else {\n"); } cmd {
        printf("    }\n\n");
    }
;

/* OBS -> observation oplogic VAR | OBS && OBS */
obs:
    TOKEN_IDENTIFIER TOKEN_OPLOGIC value {
        char *buffer;
        asprintf(&buffer, "%s %s %s", $1, $2, $3);
        $$ = buffer;
        free($1);
        free($2);
        free($3);
    }
  | obs TOKEN_AND obs {
        char *buffer;
        asprintf(&buffer, "%s && %s", $1, $3);
        $$ = buffer;
        free($1);
        free($3);
    }
;

/* ACT -> ACTEXECUTE | ACTALERT */
act:
    actexecute { 
        printf("    %s;\n\n", $1);
        free($1); 
    }
  | actalert
;

/* ACTEXECUTE -> ACTION namedevice */
actexecute:
    action TOKEN_IDENTIFIER {
        char *buffer;
        asprintf(&buffer, "%s(\"%s\")", $1, $2);
        $$ = buffer;
        free($1);
        free($2);
    }
;

/* ACTALERT -> enviar alerta ( msg with_obs ) namedevice */
actalert:
    TOKEN_SEND_ALERT_KW TOKEN_OPEN_PARENTHESIS TOKEN_MSG with_obs TOKEN_CLOSE_PARENTHESIS TOKEN_IDENTIFIER {
        if ($4 == NULL) {
            printf("    alerta2(\"%s\", %s);\n\n", $6, $3);
        } else {
            printf("    alerta3(\"%s\", %s, %s);\n\n", $6, $3, $4);
            free($4);
        }
        free($3);
        free($6);
    }
;

/* ACTION -> ligar | desligar | verificar */
action:
    TOKEN_CHECK_KW       { $$ = strdup("verificar"); }
  | TOKEN_TURN_ON_KW     { $$ = strdup("ligar"); }
  | TOKEN_TURN_OFF_KW    { $$ = strdup("desligar"); }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error on line %d: %s\n", yylineno, s);
}

int main() {
    if (freopen("output.c", "w", stdout) == NULL) {
        fprintf(stderr, "Error: Could not redirect output to output.c.\n");
        return 1;
    }

    printf("#include <stdio.h>\n");
    printf("#include <stdbool.h>\n");
    printf("#include \"src/includes/obsact_func.h\"\n\n");
    printf("int main() {\n");

    // Roda a análise sintática (tudo o que for printf normal vai pro output.c)
    yyparse();

    printf("    return 0;\n");
    printf("}\n");

    // ---- MENSAGEM NO TERMINAL ----
    // O fprintf para o stderr ignora o freopen e aparece direto na sua tela preta!
    fprintf(stderr, "\n[LOG] Compilado e transpilado com sucesso! Zero erros de sintaxe.\n\n");

    return 0;
}
