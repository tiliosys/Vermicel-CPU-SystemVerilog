
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

package UART_pkg;

    typedef enum {
        CONTROL_ADDRESS,  // Control/status register  (RW)
        DIVISION_ADDRESS, // Frequency divisor config (RW)
        DATA_ADDRESS,     // RX/TX data               (RO/WO)
        LOCAL_ADDRESS_NUM // The number of supported local addresses
    } local_address_t;

    localparam LOCAL_ADDRESS_WIDTH = $clog2(LOCAL_ADDRESS_NUM);

    typedef struct packed {
        bit tx_event_flag; // End of transmission indicator  (RW, autoset)
        bit rx_event_flag; // End of reception indicator     (RW, autoset)
        bit tx_irq_enable; // Enable end-of-transmission IRQ (RW)
        bit rx_irq_enable; // Enable end-of-reception IRQ    (RW)
        bit tx_enable;     // Transmission start command     (RW, autoclear)
    } control_reg_t;

endpackage

