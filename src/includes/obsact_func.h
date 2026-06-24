/**
 * @file obsact_func.h
 * @brief Standard support functions for the ObsAct language runtime.
 *
 * This header provides the public API required by the laboratory specifications.
 * These functions are injected into the transpiled C code to handle hardware 
 * control commands, state verification, and alert broadcasting.
 */

#ifndef OBSACT_FUNC_H
#define OBSACT_FUNC_H

/**
 * @brief Turns on a specific device and updates its internal state.
 *
 * @param namedevice The string identifier of the device to be turned on.
 * @return int Always returns 1, indicating a successful ON state.
 */
int ligar(const char* namedevice);

/**
 * @brief Turns off a specific device and updates its internal state.
 *
 * @param namedevice The string identifier of the device to be turned off.
 * @return int Always returns 0, indicating a successful OFF state.
 */
int desligar(const char* namedevice);

/**
 * @brief Verifies and prints the current status of a specific device.
 *
 * Queries the internal state manager to determine if the device is currently
 * active or inactive, and prints the corresponding status formatted to standard output.
 *
 * @param namedevice The string identifier of the device to be verified.
 * @return int 1 if the device is currently ON, 0 if it is OFF.
 */
int verificar(const char* namedevice);

/**
 * @brief Sends a broadcast or direct alert message to a specific device.
 *
 * @param namedevice The string identifier of the target device receiving the alert.
 * @param msg The alert message string to be printed.
 */
void alerta_sem_var(const char* namedevice, const char* msg);

/**
 * @brief Sends an alert message to a specific device, appending a variable's value.
 *
 * @param namedevice The string identifier of the target device receiving the alert.
 * @param msg The alert message string to be printed.
 * @param var The integer value of the sensor or variable to be appended to the message.
 */
void alerta_com_var(const char* namedevice, const char* msg, int var);

#endif // OBSACT_FUNC_H
