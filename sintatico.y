%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);
%}

/* Definição dos tokens que o Flex vai nos enviar */
%token DISPOSITIVO ABRE_CHAVE FECHA_CHAVE NAMEDEVICE

%%

/* Regra inicial da nossa gramática simplificada */
programa:
    declaracao_dispositivo { printf("// Compilação concluída com sucesso!\n"); }
;

declaracao_dispositivo:
    DISPOSITIVO ABRE_CHAVE NAMEDEVICE FECHA_CHAVE {
        // Aqui acontece a Tradução / Geração de Código!
        // Quando o parser reconhece a regra, nós cuspimos o código equivalente
        printf("# Dispositivo detectado na linguagem ObsAct\n");
        printf("init_device_setup()\n\n");
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}

int main() {
    // Inicia o processo de parsing lendo da entrada padrão (stdin)
    yyparse();
    return 0;
}
