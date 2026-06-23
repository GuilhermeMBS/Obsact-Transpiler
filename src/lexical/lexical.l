%{
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#include "syntax.tab.h"
%}

%option yylineno

%%

    /* Symbols */
"{"                     { return TOKEN_OPEN_BRACE; }
"}"                     { return TOKEN_CLOSE_BRACE; }
"("                     { return TOKEN_OPEN_PARENTHESIS; }
")"                     { return TOKEN_CLOSE_PARENTHESIS; }
"="                     { return TOKEN_EQUAL; }
"."                     { return TOKEN_PERIOD; }
":"                     { return TOKEN_TWO_POINTS; }
","                     { return TOKEN_COMMA; }
"&&"                    { return TOKEN_AND; }

    /* Keywords */
"dispositivo"           { return TOKEN_DEVICE_KW; }
"set"                   { return TOKEN_SET_KW; }
"se"                    { return TOKEN_IF_KW; }
"senao"                 { return TOKEN_ELSE_KW; }
"entao"                 { return TOKEN_THEN_KW; }
"para todos"            { return TOKEN_FOR_ALL_KW; }
"enviar alerta"         { return TOKEN_SEND_ALERT_KW; }
"ligar"                 { return TOKEN_TURN_ON_KW; }
"desligar"              { return TOKEN_TURN_OFF_KW; }
"verificar"             { return TOKEN_CHECK_KW; }

    /* Logic Operators (oplogic) */
">"                     { yylval.str_val = strdup(yytext); return TOKEN_OPLOGIC; }
"<"                     { yylval.str_val = strdup(yytext); return TOKEN_OPLOGIC; }
">="                    { yylval.str_val = strdup(yytext); return TOKEN_OPLOGIC; }
"<="                    { yylval.str_val = strdup(yytext); return TOKEN_OPLOGIC; }
"=="                    { yylval.str_val = strdup(yytext); return TOKEN_OPLOGIC; }
"!="                    { yylval.str_val = strdup(yytext); return TOKEN_OPLOGIC; }

    /* Boolean Values */
[Tt][Rr][Uu][Ee]        { 
                            yylval.bool_val = true;
                            return TOKEN_BOOL;
                        }

[Ff][Aa][Ll][Ss][Ee]    { 
                            yylval.bool_val = false;
                            return TOKEN_BOOL;
                        }

    /* Regex Rules for Identifiers, Numbers, and Strings */
\"([^"\\]|\\.)*\"       { 
                            yylval.str_val = strdup(yytext);
                            return TOKEN_MSG;
                        }

[a-zA-Z][a-zA-Z0-9]* { 
                            yylval.str_val = strdup(yytext);
                            return TOKEN_IDENTIFIER; 
                        }

[0-9]+                  { 
                            yylval.int_val = atoi(yytext);
                            return TOKEN_NUM;
                        }

[ \t\r\n]+              { /* Ignores spaces, tabs and newlines */ }

.                       { printf("Lexical Error on line %d: Unknown character '%s'\n", yylineno, yytext); }

%%

int yywrap() {
    return 1;
}
