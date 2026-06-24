#include <stdio.h>
#include <stdbool.h>
#include "src/includes/obsact_func.h"

int main() {
    // Registering standalone device
    const char* PortaPrincipal = "PortaPrincipal";

    // Registering standalone device
    const char* PortaFundos = "PortaFundos";

    // Registering standalone device
    const char* Janela = "Janela";

    alerta_sem_var(PortaPrincipal, "Travar todas as entradas");
    alerta_sem_var(PortaFundos, "Travar todas as entradas");
    alerta_sem_var(Janela, "Travar todas as entradas");

    // Transpilation finished successfully.
    return 0;
}
