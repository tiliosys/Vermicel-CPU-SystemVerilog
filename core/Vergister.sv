//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vergister
    import Vermitypes_pkg::*,
           Vermicodes_pkg::*;
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
