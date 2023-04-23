
#include <stdint.h>

volatile uint32_t *const out = (uint32_t*)0x10000000;

void print(uint32_t n) {
    *out = n;
}

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

#define N 1000

int main(void) {
    print(N);
    print(fibonacci(N));
}
