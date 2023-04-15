
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module Comparator
    import Types_pkg::*,
           Opcodes_pkg::*;
(
    input  instruction_t instr,
    input  word_t        a,
    input  word_t        b,
    output bit           taken
);

    always_comb begin
        case (instr.funct3)
            FUNCT3_BEQ  : taken = a == b;
            FUNCT3_BNE  : taken = a != b;
            FUNCT3_BLT  : taken = signed'(a) <  signed'(b);
            FUNCT3_BGE  : taken = signed'(a) >= signed'(b);
            FUNCT3_BLTU : taken = a <  b;
            FUNCT3_BGEU : taken = a >= b;
            default     : taken = 0;
        endcase
    end
endmodule

