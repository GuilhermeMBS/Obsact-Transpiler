#include <stdio.h>
#include <stdbool.h>
#include "src/includes/obsact_func.h"

int main() {
    // Registering device with sensor bound
    const char* Termometro = "Termometro";
    int temperatura = 0; // Implicit initialization to 0

    // Registering device with sensor bound
    const char* ventilador = "ventilador";
    int potencia = 0; // Implicit initialization to 0

    // Setting sensor or expression value
    temperatura = 40;

    if (temperatura > 30) {
Lexical Error on line 6: Unknown character '_'
    return 0;
}
