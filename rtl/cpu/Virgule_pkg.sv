
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

package Virgule_pkg;

    import Types_pkg::*;

    localparam word_t       IRQ_ADDRESS        = 4;
    localparam word_t       TRAP_ADDRESS       = 8;
    localparam int unsigned REGISTER_UNIT_SIZE = 32;

endpackage
