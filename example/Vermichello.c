
#include <stdint.h>

#define BYTE_REG(address) *(volatile uint8_t*)(address)
#define WORD_REG(address) *(volatile uint32_t*)(address)

// General memory map.
#define RAM_ADDRESS                0x00000000
#define TIMER_ADDRESS              0x80000000
#define UART_ADDRESS               0x81000000

// Timer register map.
#define TIMER_CONTROL_REG          BYTE_REG(TIMER_ADDRESS + 0x00)
#define TIMER_STATUS_REG           BYTE_REG(TIMER_ADDRESS + 0x04)
#define TIMER_REFILL_REG           WORD_REG(TIMER_ADDRESS + 0x08)
#define TIMER_COUNT_REG            WORD_REG(TIMER_ADDRESS + 0x0C)

// Timer control register field masks.
#define TIMER_CONTROL_COUNT_ENABLE 0x01
#define TIMER_CONTROL_CYCLIC_MODE  0x02
#define TIMER_CONTROL_IRQ_ENABLE   0x04

// Timer status register field masks.
#define TIMER_STATUS_EVENT_FLAG    0x01

// UART register map.
#define UART_CONTROL_REG           BYTE_REG(UART_ADDRESS + 0x00)
#define UART_STATUS_REG            BYTE_REG(UART_ADDRESS + 0x04)
#define UART_DIVISION_REG          WORD_REG(UART_ADDRESS + 0x08)
#define UART_DATA_REG              BYTE_REG(UART_ADDRESS + 0x0C)

// UART control register field masks.
#define UART_CONTROL_RX_IRQ_ENABLE 0x01
#define UART_CONTROL_TX_IRQ_ENABLE 0x02

// UART status register field masks.
#define UART_STATUS_RX_EVENT_FLAG  0x01
#define UART_STATUS_TX_EVENT_FLAG  0x02

// UART Baud rate configuration value (115200 bits/sec).
#define UART_DIVISION_VALUE        867

// A nice greeting message to display.
const char *const greeter = "Hello! What's your name?\n> ";

// ----------------------------------------------------------------------------
// UART 
// ----------------------------------------------------------------------------

void UART_set_division(uint32_t division) {
  UART_DIVISION_REG = division;
}

void UART_putc(uint8_t chr) {
  UART_DATA_REG = chr;
  while (!(UART_STATUS_REG & UART_STATUS_TX_EVENT_FLAG));
  UART_STATUS_REG = UART_STATUS_TX_EVENT_FLAG;
}

uint8_t UART_getc(void) {
  while (!(UART_STATUS_REG & UART_STATUS_RX_EVENT_FLAG));
  UART_STATUS_REG = UART_STATUS_RX_EVENT_FLAG;
  return UART_DATA_REG;
}

void UART_puts(const char *str) {
  while (*str) {
    UART_putc(*str);
    str ++;
  }
}

// ----------------------------------------------------------------------------
// Main program 
// ----------------------------------------------------------------------------

int main(void) {
  UART_set_division(UART_DIVISION_VALUE);
  UART_puts(greeter);
  return 0;
}
