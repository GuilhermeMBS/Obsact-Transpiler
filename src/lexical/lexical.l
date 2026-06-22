%{
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#include "syntax.tab.h"
%}


%%


"{"                     { return TOKEN_OPEN_BRACE; }
"}"                     { return TOKEN_CLOSE_BRACE; }
"("                     { return TOKEN_OPEN_PARENTHESIS; }
")"                     { return TOKEN_CLOSE_PARENTHESIS; }
"="                     { return TOKEN_EQUAL; }
"."                     { return TOKEN_PERIOD; }
":"                     { return TOKEN_TWO_POINTS; }
","                     { return TOKEN_COMMA; }
"&&"                    { return TOKEN_AND; }

"num"                   { return TOKEN_NUM_KW; }
"bool"                  { return TOKEN_BOOL_KW; }
"msg"                   { return TOKEN_MSG_KW; }

"dispositivo"          { return TOKEN_DEVICE_KW; }
"set"                  { return TOKEN_SET_KW; }
"namedevice"           { return TOKEN_NAME_DEVICE_KW; }
"observation"          { return TOKEN_OBSERVATION_KW; }
"oplogic"              { return TOKEN_OPLOGIC_KW; }

"se"                   { return TOKEN_IF_KW; }
"senao"                { return TOKEN_ELSE_KW; }
"entao"                { return TOKEN_THEN_KW; }

"enviar"                { return TOKEN_SEND_KW; }
"alerta"                { return TOKEN_ALERT_KW; }
"verificar"             { return TOKEN_CHECK_KW; }


[a-zA-Z]+               { 
                            // Passa o texto capturado (nome do dispositivo ou sensor) para o Bison
                            yylval.str_val = strdup(yytext); 
                            return TOKEN_IDENTIFIER; 
                        }

[0-9]+                  { 
                            // Converte o texto capturado em número inteiro e passa para o Bison
                            yylval.int_val = atoi(yytext); 
                            return TOKEN_NUM; 
                        }

[ \t\n]+                { /* Ignora espaços em branco e quebras de linha */ }
.                       { printf("Lexical Error: Unknown character '%s'\n", yytext); }


%%


int yywrap() {
    return 1;
}
