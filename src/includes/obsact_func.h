#ifndef OBSACT_FUNC_H
#define OBSACT_FUNC_H

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

// --- Runtime Device State Manager ---
// Guarda o estado de até 50 dispositivos simultaneamente na memórtia
#define MAX_DEVICES 50
static const char* _device_names[MAX_DEVICES];
static int _device_states[MAX_DEVICES];
static int _device_count = 0;

// Função interna invisível para o usuário que busca ou cadastra o dispositivo
static inline int _get_device_index(const char* namedevice) {
    // Procura se o dispositivo já existe
    for (int i = 0; i < _device_count; i++) {
        if (strcmp(_device_names[i], namedevice) == 0) {
            return i;
        }
    }
    // Se não existe, cadastra ele na primeira posição livre
    if (_device_count < MAX_DEVICES) {
        _device_names[_device_count] = namedevice;
        _device_states[_device_count] = 0; // Inicializa sempre desligado
        return _device_count++;
    }
    return -1; // Proteção contra overflow
}

// --- Funções de suporte do PDF do laboratório ---

static inline int ligar(const char* namedevice) {
    printf("%s ligado!\n", namedevice);
    int idx = _get_device_index(namedevice);
    if (idx >= 0) _device_states[idx] = 1; // Atualiza SÓ o dispositivo chamado
    return 1;
}

static inline int desligar(const char* namedevice) {
    printf("%s desligado!\n", namedevice);
    int idx = _get_device_index(namedevice);
    if (idx >= 0) _device_states[idx] = 0; // Atualiza SÓ o dispositivo chamado
    return 0;
}

static inline int verificar(const char* namedevice) {
    int idx = _get_device_index(namedevice);
    int state = (idx >= 0) ? _device_states[idx] : 0; // Pega o estado real dele
    
    // O print condicional exatamente como pede o PDF
    if (state == 1) {
        printf("%s est ligado.\n", namedevice);
        return 1;
    } else {
        printf("%s est desligado.\n", namedevice);
        return 0;
    }
}

static inline void alerta_sem_var(const char* namedevice, const char* msg) {
    printf("%s recebeu o alerta:\n", namedevice);
    printf("%s\n", msg);
}

static inline void alerta_com_var(const char* namedevice, const char* msg, int var) {
    printf("%s recebeu o alerta:\n", namedevice);
    printf("%s %d\n", msg, var);
}

#endif // OBSACT_FUNC_H
