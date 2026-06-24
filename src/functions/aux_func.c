#include "src/includes/aux_func.h"
#include <string.h>

#define MAX_DEVICES 50

// Internal memory state (static makes them strictly private to this .c file)
static const char* _device_names[MAX_DEVICES];
static int _device_states[MAX_DEVICES];
static int _device_count = 0;

int _get_device_index(const char* namedevice) {
    // Search for an existing device
    for (int i = 0; i < _device_count; i++) {
        if (strcmp(_device_names[i], namedevice) == 0) {
            return i;
        }
    }
    // Register a new device if space permits
    if (_device_count < MAX_DEVICES) {
        _device_names[_device_count] = namedevice;
        _device_states[_device_count] = 0; // Always initialized as OFF (0)
        return _device_count++;
    }
    return -1; // Overflow protection
}

void _update_device(const char* namedevice, int state) {
    int idx = _get_device_index(namedevice);
    if (idx >= 0) {
        _device_states[idx] = state;
    }
}

int _get_device_state(const char* namedevice) {
    int idx = _get_device_index(namedevice);
    return (idx >= 0) ? _device_states[idx] : 0;
}
