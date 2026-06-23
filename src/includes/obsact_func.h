#ifndef OBSACT_FUNC_H
#define OBSACT_FUNC_H

#include <stdio.h>
#include <stdbool.h>

// Funcoes de suporte extraidas do PDF do laboratorio
static inline int ligar(const char* namedevice) {
    printf("%s ligado!\n", namedevice);
    return 1;
}

static inline int desligar(const char* namedevice) {
    printf("%s desligado!\n", namedevice);
    return 0;
}

static inline int verificar(const char* namedevice) {
    printf("%s est ligado.\n", namedevice);
    return 1;
}

static inline void alerta2(const char* namedevice, const char* msg) {
    printf("%s recebeu o alerta:\n", namedevice);
    printf("%s\n", msg);
}

static inline void alerta3(const char* namedevice, const char* msg, int var) {
    printf("%s recebeu o alerta:\n", namedevice);
    printf("%s %d\n", msg, var);
}

#endif // OBSACT_FUNC_H
