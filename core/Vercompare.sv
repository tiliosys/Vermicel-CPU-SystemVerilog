//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

// Vermicel comparator.
//
// This module determines whether a conditional branch instruction is taken.
// Other instructions are considered not taken.
module Vercompare
    import Verdata_pkg::*,
           Veropcodes_pkg::*;
(
    input  instruction_t instr, // The decoded instruction fields.
    input  word_t        a,     // The first operand.
    input  word_t        b,     // The second operand.
    output bit           taken  // Is instr a conditional branch and is it taken?
);

    always_comb begin
        if (!instr.is_branch) begin
            taken = 0;
        end
        else begin
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
    end
endmodule

