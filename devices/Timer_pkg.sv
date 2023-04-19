
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

package Timer_pkg;

    typedef enum {
        CONTROL_ADDRESS,  // Control/status register (RW)
        STATUS_ADDRESS,   // Control/status register (RW)
        REFILL_ADDRESS,   // Refill value            (RW)
        COUNT_ADDRESS,    // Current count           (RO)
        LOCAL_ADDRESS_NUM // The number of supported local addresses
    } local_address_t;

    localparam LOCAL_ADDRESS_WIDTH = $clog2(LOCAL_ADDRESS_NUM);

    typedef struct packed {
        bit irq_enable;   // Enable IRQs              (RW)
        bit cyclic_mode;  // Enable cyclic mode       (RW)
        bit count_enable; // Enable counting          (RW, autoclear)
    } control_reg_t;

    typedef struct packed {
        bit event_flag;   // Timer rollover indicator (RW, autoset)
    } status_reg_t;

endpackage
