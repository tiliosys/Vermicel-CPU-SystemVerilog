//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

volatile uint32_t *const out  = (uint32_t*)0x10000000;
volatile uint32_t *const tick = (uint32_t*)0x20000000;

void copy(uint8_t *dest, const uint8_t *src, size_t len) {
    while (len > 0) {
        *dest = *src;
        src ++;
        dest ++;
        len --;
    }
}

bool equal(const uint8_t *dest, const uint8_t *src, size_t len) {
    while (len > 0) {
        if (*dest != *src) {
            return false;
        }
        src ++;
        dest ++;
        len --;
    }
    return true;
}

const uint8_t str[] = "This string needs to be copied to another location";
uint8_t buffer[sizeof(str)] = {0};

int main(void) {
    *tick = 1;
    copy(buffer, str, sizeof(str));
    *out = equal(buffer, str, sizeof(str));
    *tick = 0;
}

