
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module ArithLogicUnit
    import Types_pkg::*,
           Opcodes_pkg::*;
(
    input  instruction_t instr,
    input  word_t        a,
    input  word_t        b,
    output word_t        r
);

    bit[4:0] sh; // Shift amount for SLL, SRL, SRA instructions.

    assign sh = b[4:0];

    always_comb begin
        case (instr.alu_fn)
            ALU_NOP  : r = b;
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
        endcase
    end
endmodule

