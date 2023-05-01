//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vermipare
    import Vermitypes_pkg::*,
           Vermicodes_pkg::*;
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

