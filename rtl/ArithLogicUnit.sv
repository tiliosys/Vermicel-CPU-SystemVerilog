
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

module ArithLogicUnit
    import Types_pkg::*,
           Opcodes_pkg::*;
(
    input  instruction_t instr,
    input  word_t        a,
    input  word_t        b,
    output word_t        r
);

    bit[5:0] sh; // Shift amount for SLL, SRL, SRA instructions.

    assign sh = b[5:0];

    always_comb begin
        case (instr.alu_fn)
            alu_nop  : r = b;
            alu_add  : r = a + b;
            alu_sub  : r = a - b;
            alu_slt  : r = word_t'(signed'(a) < signed'(b));
            alu_sltu : r = word_t'(a < b);
            alu_xor  : r = a ^ b;
            alu_or   : r = a | b;
            alu_and  : r = a & b;
            alu_sll  : r = a << sh;
            alu_srl  : r = a >> sh;
            alu_sra  : r = signed'(a) >>> sh;
        endcase
    end
endmodule

