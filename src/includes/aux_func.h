/**
 * @file aux_func.h
 * @brief Internal runtime device state manager for the ObsAct transpiler.
 *
 * This header defines the internal memory management and state tracking
 * functions for devices. These functions are intended for internal use
 * by the transpiled code and should not be directly called by the user
 * within the ObsAct source logic.
 */

#ifndef AUX_FUNC_H
#define AUX_FUNC_H

/**
 * @brief Retrieves or registers a device, returning its internal memory index.
 *
 * Searches the internal state array for the specified device. If the device
 * does not exist and space permits, it registers the device and initializes
 * its state to 0 (OFF).
 *
 * @param namedevice The string identifier of the target device.
 * @return int The internal array index of the device, or -1 if the maximum capacity is reached.
 */
int _get_device_index(const char* namedevice);

/**
 * @brief Updates the internal state of a specific device.
 *
 * @param namedevice The string identifier of the target device.
 * @param state The new integer state to be assigned (e.g., 1 for ON, 0 for OFF).
 */
void _update_device(const char* namedevice, int state);

/**
 * @brief Retrieves the current internal state of a specific device.
 *
 * @param namedevice The string identifier of the target device.
 * @return int The current state of the device (1 for ON, 0 for OFF). Returns 0 if the device is not found.
 */
int _get_device_state(const char* namedevice);

#endif // AUX_FUNC_H
