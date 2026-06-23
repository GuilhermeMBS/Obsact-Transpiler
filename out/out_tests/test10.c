#include <stdio.h>
#include <stdbool.h>
#include "src/includes/obsact_func.h"

int main() {
    // Registering device with sensor bound
    const char* Termometro = "Termometro";
    int temperatura = 0; // Implicit initialization to 0

    alerta3("Termometro", " Temperatura esta em ", temperatura);

    return 0;
}
