
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

module RegisterUnit
    import Types_pkg::*,
           Opcodes_pkg::*;
#(
    parameter int unsigned SIZE
)
(
    input  bit           clk,
    input  bit           reset, 
    input  bit           enable, 
    input  instruction_t src_instr, 
    input  instruction_t dest_instr, 
    input  word_t        xd, 
    output word_t        xs1, 
    output word_t        xs2
);

    word_t x_reg[0:SIZE-1];

    always_ff @(posedge clk) begin
        if (reset) begin
            x_reg <= '{SIZE{0}};
        end
        else if (enable && dest_instr.has_rd) begin
            x_reg[dest_instr.rd] <= xd;
        end
    end

    assign xs1 = x_reg[src_instr.rs1];
    assign xs2 = x_reg[src_instr.rs2];
endmodule
