
    .set RAM_ADDRESS,   0x00000000
    .set TIMER_ADDRESS, 0x80000000
    .set UART_ADDRESS,  0x81000000

    .set TIMER_CONTROL_REG, 0x00
    .set TIMER_REFILL_REG,  0x04
    .set TIMER_COUNT_REG,   0x08

    .set TIMER_CONTROL_EVENT_FLAG,   0x01
    .set TIMER_CONTROL_IRQ_ENABLE,   0x02
    .set TIMER_CONTROL_CYCLIC_MODE,  0x04
    .set TIMER_CONTROL_COUNT_ENABLE, 0x08

    .set UART_CONTROL_REG,  0x00
    .set UART_DIVISION_REG, 0x01
    .set UART_TX_DATA_REG,  0x02
    .set UART_RX_DATA_REG,  0x03

    .set UART_CONTROL_TX_EVENT_FLAG, 0x01
    .set UART_CONTROL_RX_EVENT_FLAG, 0x02
    .set UART_CONTROL_TX_IRQ_ENABLE, 0x04
    .set UART_CONTROL_RX_IRQ_ENABLE, 0x08
    .set UART_CONTROL_TX_ENABLE,     0x10

    .set UART_DIVISION_VALUE, 867

    .data
    .align 4

str: .asciz ">Hello!"

    .text
    .align 4

    // a0: the frequency divider config value.
uart_set_division:
    li t0, UART_ADDRESS
    sw a0, UART_DIVISION_REG(t0)
    ret

    // a0: the ASCII code of the character to send.
uart_putc:
    li t0, UART_ADDRESS
    // Copy the character to the UART data register.
    sb a0, UART_TX_DATA_REG(t0)
    // Set the TX enable bit in the UART control register.
    lw t1, UART_CONTROL_REG(t0)
    ori t1, t1, UART_CONTROL_TX_ENABLE
    sw t1, UART_CONTROL_REG(t0)
uart_putc_loop:
    // Check the TX event flag in the UART control register.
    lw t1, UART_CONTROL_REG(t0)
    andi t2, t1, UART_CONTROL_TX_EVENT_FLAG
    beqz t2, uart_putc_loop
    // Clear the TX event flag in the UART control register.
    xori t1, t1, UART_CONTROL_TX_EVENT_FLAG
    sw t1, UART_CONTROL_REG(t0)
    ret

    // a0: the address of the string to send.
uart_puts:
    addi sp, sp, -4
    sw s0, (sp)
    mv s0, a0
uart_puts_loop:
    lb a0, (s0)
    beqz a0, uart_puts_end
    call uart_putc
    addi s0, s0, 1
    j uart_puts_loop
uart_puts_end:
    lw s0, (sp)
    addi sp, sp, 4
    ret
    
    .global main
main:
    li a0, UART_DIVISION_VALUE
    call uart_set_division

    la a0, str
    call uart_puts
    ret

