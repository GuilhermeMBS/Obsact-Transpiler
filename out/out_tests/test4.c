#include <stdio.h>
#include <stdbool.h>
#include "src/includes/obsact_func.h"

int main() {
    // Registering device with sensor bound
    const char* celular = "celular";
    int movimento = 0; // Implicit initialization to 0

    // Registering device with sensor bound
    const char* higrometro = "higrometro";
    int umidade = 0; // Implicit initialization to 0

    // Registering device with sensor bound
    const char* lampada = "lampada";
    int potencia = 0; // Implicit initialization to 0

    // Registering standalone device
    const char* Monitor = "Monitor";

    // Setting sensor or expression value
    potencia = 100;

    if (umidade < 40) {
    return 0;
}
