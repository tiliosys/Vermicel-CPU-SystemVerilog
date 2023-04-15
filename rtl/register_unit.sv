
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import virgule_pkg::*;
import opcodes_pkg::*;

module register_unit #(
    parameter int unsigned size
) (
    input  bit           clk,
    input  instruction_t src_instr, 
    input  instruction_t dest_instr, 
    input  bit           reset, 
    input  bit           enable, 
    input  word_t        xd, 
    output word_t        xs1, 
    output word_t        xs2
);

    word_t x[0:size-1];

    always_ff @(posedge clk) begin
        if (reset) begin
            x <= '{size{0}};
        end
        else if (enable && dest_instr.has_rd) begin
            x[dest_instr.rd] <= xd;
        end
    end

    assign xs1 = x[src_instr.rs1];
    assign xs2 = x[src_instr.rs2];
endmodule
