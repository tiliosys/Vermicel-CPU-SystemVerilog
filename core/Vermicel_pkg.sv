//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

// Common constants for the Vermicel core functional units.
package Vermicel_pkg;

    import Verdata_pkg::*;

    localparam word_t       IRQ_ADDRESS    = 4;  // The address of the IRQ vector.
    localparam word_t       TRAP_ADDRESS   = 8;  // The address of the trap vector.
    localparam int unsigned REGISTER_COUNT = 32; // The number of general-purpose registers.

endpackage
