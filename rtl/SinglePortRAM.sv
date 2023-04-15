
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module SinglePortRAM #(
    parameter int unsigned SIZE,
    parameter string INIT_FILENAME
)
(
    Bus.s bus
);

    import Types_pkg::*;

    word_t data_reg[0:SIZE-1];
    bit[29:0] word_address;
    bit ready_reg;

    initial begin
        $readmemh(INIT_FILENAME, data_reg);
    end

    assign word_address = bus.address[31:2];

    always_ff @(posedge bus.clk) begin
        if (bus.valid) begin
            bus.rdata <= data_reg[word_address];
            for (int i = 0; i < 4; i ++) begin
                if (bus.wstrobe[i]) begin
                    data_reg[word_address][i*8+:8] <= bus.wdata[i*8+:8];
                end
            end
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

endmodule
