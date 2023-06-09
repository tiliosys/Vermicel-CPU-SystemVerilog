//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

#include <stdint.h>

volatile uint32_t *const out  = (uint32_t*)0x10000000;
volatile uint32_t *const tick = (uint32_t*)0x20000000;

uint32_t fibonacci(uint32_t n) {
    uint32_t a = 0;
    uint32_t b = 1;
    for (uint32_t i = 0; i < n; i ++) {
        uint32_t s = a + b;
        a = b;
        b = s;
    }
    return a;
}

#define N 30

int main(void) {
    *tick = 1;
    for (uint32_t n = 0; n < N; n ++) {
        *out = fibonacci(n);
    }
    *tick = 0;
}
