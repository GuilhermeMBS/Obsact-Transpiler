#include "src/includes/obsact_func.h"
#include "src/includes/aux_func.h"
#include <stdio.h>

int ligar(const char* namedevice) {
    printf("%s ligado!\n", namedevice);
    _update_device(namedevice, 1);
    return 1;
}

int desligar(const char* namedevice) {
    printf("%s desligado!\n", namedevice);
    _update_device(namedevice, 0);
    return 0;
}

int verificar(const char* namedevice) {
    int state = _get_device_state(namedevice);
    
    // Conditional output formatted exactly as required by the SRS
    if (state == 1) {
        printf("%s est ligado.\n", namedevice);
        return 1;
    } else {
        printf("%s est desligado.\n", namedevice);
        return 0;
    }
}

void alerta_sem_var(const char* namedevice, const char* msg) {
    printf("%s recebeu o alerta:\n", namedevice);
    printf("%s\n", msg);
}

void alerta_com_var(const char* namedevice, const char* msg, int var) {
    printf("%s recebeu o alerta:\n", namedevice);
    printf("%s %d\n", msg, var);
}
