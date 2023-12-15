//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vereset (
    input  bit clk,
    input  bit reset_i,
    output bit reset_o
);

    bit[1:0] reset_reg;

    always_ff @(posedge clk, posedge reset_i) begin
        if (reset_i) begin
            reset_reg <= 2'b11;
        end
        else begin
            reset_reg <= {reset_reg[0], 1'b0};
        end
    end

    assign reset_o = reset_reg[1];
endmodule
