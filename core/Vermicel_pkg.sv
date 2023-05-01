//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

package Vermicel_pkg;

    import Vermitypes_pkg::*;

    localparam word_t       IRQ_ADDRESS        = 4;
    localparam word_t       TRAP_ADDRESS       = 8;
    localparam int unsigned REGISTER_UNIT_SIZE = 32;

endpackage
