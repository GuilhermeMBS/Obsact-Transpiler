%{
#include <stdio.h>
#include <stdbool.h>
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

%token <str_val> TOKEN_OPLOGIC
%token <str_val> TOKEN_MSG
%token <str_val> TOKEN_IDENTIFIER

%token <int_val> TOKEN_NUM
%token <int_val> TOKEN_BOOL

%type <int_val> value

%%

/* PROGRAM -> DEVICES CMDS */
program:
    devices cmds { 
        printf("    // Transpilation finished successfully.\n"); 
    }
;

/* DEVICES -> DEVICES DEVICE | DEVICE (Recursão à esquerda) */
devices:
    devices device
  | device
;

/* DEVICE -> dispositivo: {namedevice} | dispositivo: {namedevice, observation} */
device:
    TOKEN_DEVICE_KW TOKEN_TWO_POINTS TOKEN_OPEN_BRACE TOKEN_IDENTIFIER TOKEN_CLOSE_BRACE {
        printf("    // Registering standalone device\n");
        printf("    const char* %s = \"%s\";\n\n", $4, $4);
        free($4);
    }
  | TOKEN_DEVICE_KW TOKEN_TWO_POINTS TOKEN_OPEN_BRACE TOKEN_IDENTIFIER TOKEN_COMMA TOKEN_IDENTIFIER TOKEN_CLOSE_BRACE {
        printf("    // Registering device with sensor bound\n");
        printf("    const char* %s = \"%s\";\n", $4, $4);
        printf("    int %s = 0; // Implicit initialization to 0\n\n", $6);
        free($4);
        free($6);
    }
;

/* CMDS -> CMDS CMD. | CMD. (Recursão à esquerda) */
cmds:
    cmds cmd TOKEN_PERIOD
  | cmd TOKEN_PERIOD
;

/* CMD -> ATTRIB | OBSACT | ACT */
cmd:
    attrib
  | obsact
  | act
;

/* ATTRIB -> set observation = value */
attrib:
    TOKEN_SET_KW TOKEN_IDENTIFIER TOKEN_EQUAL value {
        printf("    // Setting sensor value\n");
        printf("    %s = %d;\n\n", $2, $4);
        free($2);
    }
;

/* VALUE -> num | bool */
value:
    TOKEN_NUM  { $$ = $1; }
  | TOKEN_BOOL { $$ = $1; }
;

/* OBSACT -> se OBS entao CMDS */
obsact:
    TOKEN_IF_KW obs TOKEN_THEN_KW cmds {
        // Placeholder for conditional block execution
    }
;

/* OBS -> observation oplogic VAR */
obs:
    TOKEN_IDENTIFIER TOKEN_OPLOGIC TOKEN_NUM {
        free($1);
        free($2);
    }
;

/* ACT -> enviar alerta ... */
act:
    TOKEN_SEND_ALERT_KW TOKEN_OPEN_PARENTHESIS TOKEN_MSG TOKEN_COMMA TOKEN_IDENTIFIER TOKEN_CLOSE_PARENTHESIS TOKEN_IDENTIFIER {
        printf("    // Sending alert tracking parameter\n");
        printf("    alerta_com_variavel(%s, %s, %s);\n\n", $7, $3, $5);
        free($3);
        free($5);
        free($7);
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main() {
    // freopen automatically closes stdout and redirects it to "output.c"
    // "w" opens the file for writing (and creates it if it doesn't exist)
    if (freopen("output.c", "w", stdout) == NULL) {
        fprintf(stderr, "Error: Could not redirect output to output.c.\n");
        return 1;
    }

    // Now every standard printf inside your Bison rules writes into output.c
    printf("#include <stdio.h>\n");
    printf("// Include your runtime platform functions here\n\n");
    printf("int main() {\n");

    // Executes the syntactic analysis
    yyparse();

    // Closes the main function block inside the generated file
    printf("    return 0;\n");
    printf("}\n");

    // Under Windows, freopen safely cleanup at exit, so we just return
    return 0;
}
