//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Versync #(
    parameter integer unsigned WIDTH = 1
)
(
    input  bit clk,
    input  bit[WIDTH-1:0] data_i,
    output bit[WIDTH-1:0] data_o
);

    (* ASYNC_REG = "TRUE" *)
    bit[WIDTH-1:0] data_r0, data_r1;

    always_ff @(posedge clk) begin
        data_r0 <= data_i;
        data_r1 <= data_r0;
    end

    assign data_o = data_r1;
endmodule
