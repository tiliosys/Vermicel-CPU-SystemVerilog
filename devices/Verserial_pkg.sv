//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

package Verserial_pkg;

    typedef enum {
        CONTROL_ADDRESS,  // Control register         (RW)
        STATUS_ADDRESS,   // Status register          (RW)
        DIVISION_ADDRESS, // Frequency divisor config (RW)
        DATA_ADDRESS,     // TX/RX data               (WO/RO)
        LOCAL_ADDRESS_NUM // The number of supported local addresses
    } local_address_t;

    localparam LOCAL_ADDRESS_WIDTH = $clog2(LOCAL_ADDRESS_NUM);

    typedef struct packed {
        bit tx_irq_enable; // Enable end-of-transmission IRQ (RW)
        bit rx_irq_enable; // Enable end-of-reception IRQ    (RW)
    } control_reg_t;

    typedef struct packed {
        bit tx_event_flag; // End of transmission indicator  (RW, autoset)
        bit rx_event_flag; // End of reception indicator     (RW, autoset)
    } status_reg_t;
endpackage

