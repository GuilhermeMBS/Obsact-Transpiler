#include <stdio.h>
#include <stdbool.h>
#include "src/includes/obsact_func.h"

int main() {
    // Registering device with sensor bound
    const char* Termometro = "Termometro";
    unsigned int temperatura = 0; // Implicit initialization to 0

    // Registering device with sensor bound
    const char* ventilador = "ventilador";
    unsigned int potencia = 0; // Implicit initialization to 0

    // Setting sensor or expression value
    temperatura = 40;

    // Setting sensor or expression value
    potencia = 90;

    if (temperatura > 30) {
    ligar(ventilador);

    }

    // Transpilation finished successfully.
    return 0;
}
