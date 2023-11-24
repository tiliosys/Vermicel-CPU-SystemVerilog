//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

// Vermicel arithmetic and logic unit.
//
// This module computes:
// - the results of arithmetic and logic instructions,
// - the target addresses in jump/branch instructions,
// - the addresses in memory access instructions.
module Verithmetic
    import Verdata_pkg::*,
           Veropcodes_pkg::*;
(
    input  instruction_t instr, // The decoded instruction fields.
    input  word_t        a,     // The first operand.
    input  word_t        b,     // The second operand.
    output word_t        r      // The result.
);

    bit[4:0] sh = b[4:0]; // Shift amount for SLL, SRL, SRA instructions.

    always_comb begin
        case (instr.alu_fn)
            ALU_ADD  : r = a + b;
            ALU_SUB  : r = a - b;
            ALU_SLT  : r = word_t'(signed'(a) < signed'(b));
            ALU_SLTU : r = word_t'(a < b);
            ALU_XOR  : r = a ^ b;
            ALU_OR   : r = a | b;
            ALU_AND  : r = a & b;
            ALU_SLL  : r = a << sh;
            ALU_SRL  : r = a >> sh;
            ALU_SRA  : r = signed'(a) >>> sh;
            default  : r = b;
        endcase
    end
endmodule

