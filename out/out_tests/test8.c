#include <stdio.h>
#include <stdbool.h>
#include "src/includes/obsact_func.h"

int main() {
    // Registering standalone device
    const char* ventilador = "ventilador";

    desligar("ventilador");

    return 0;
}
