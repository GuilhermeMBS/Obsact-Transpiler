%{
#include <stdio.h>
#include "sintatico.tab.h" // Cabeçalho gerado automaticamente pelo Bison
%}

%%

"dispositivo:"          { return DISPOSITIVO; }
"{"                     { return ABRE_CHAVE; }
"}"                     { return FECHA_CHAVE; }
[a-zA-Z]+               { return NAMEDEVICE; }
[ \t\n]+                { /* Ignora espaços em branco e quebras de linha */ }
.                       { printf("Erro léxico: caractere inválido '%s'\n", yytext); }

%%

int yywrap() {
    return 1;
}
