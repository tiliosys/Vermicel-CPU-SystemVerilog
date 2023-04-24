
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module Vermimory #(
    parameter int unsigned SIZE_WORDS,
    parameter INIT_FILENAME // Implicit string type, not supported by Xilinx Vivado 2019.1
) (Vermibus.read_write_response bus);

    import Vermitypes_pkg::*;

    localparam LOCAL_ADDRESS_WIDTH = $clog2(SIZE_WORDS);

    word_t                       data_reg[0:SIZE_WORDS-1];
    bit[LOCAL_ADDRESS_WIDTH-1:0] local_address;
    word_t                       rdata;
    bit                          ready_reg;

    initial begin
        $readmemh(INIT_FILENAME, data_reg);
    end

    assign local_address = bus.address[2+:LOCAL_ADDRESS_WIDTH];
    assign rdata         = data_reg[local_address];

    always_ff @(posedge bus.clk) begin
        if (bus.valid) begin
            bus.rdata <= rdata;
            data_reg[local_address] <= bus.write_into(rdata);
        end
    end

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            ready_reg <= 0;
        end
        else if (bus.valid && bus.wstrobe == 0) begin
            ready_reg <= !ready_reg;
        end
    end

    assign bus.ready = bus.wstrobe == 0 ? ready_reg : bus.valid;
    assign bus.irq   = 0;

endmodule
