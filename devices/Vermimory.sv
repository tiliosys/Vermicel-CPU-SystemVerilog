
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module Vermimory #(
    parameter int unsigned SIZE_WORDS,
    parameter INIT_FILENAME // Implicit string type, not supported by Xilinx Vivado 2019.1
) (
    Vermibus.read_only_response  ibus,
    Vermibus.read_write_response dbus
);

    import Vermitypes_pkg::*;

    localparam LOCAL_ADDRESS_WIDTH = $clog2(SIZE_WORDS);

    word_t data_reg[0:SIZE_WORDS-1];

    initial begin
        $readmemh(INIT_FILENAME, data_reg);
    end

    //
    // Instruction bus.
    //

    bit[LOCAL_ADDRESS_WIDTH-1:0] ibus_local_address;
    word_t                       ibus_rdata;
    bit                          ibus_ready_reg;

    assign ibus_local_address = ibus.address[2+:LOCAL_ADDRESS_WIDTH];
    assign ibus_rdata         = data_reg[ibus_local_address];

    always_ff @(posedge ibus.clk) begin
        if (ibus.valid) begin
            ibus.rdata <= ibus_rdata;
        end
    end

    always_ff @(posedge ibus.clk) begin
        if (ibus.reset) begin
            ibus_ready_reg <= 0;
        end
        else if (ibus.valid) begin
            ibus_ready_reg <= !ibus_ready_reg;
        end
    end

    assign ibus.ready = ibus_ready_reg;

    //
    // Data bus.
    //

    bit[LOCAL_ADDRESS_WIDTH-1:0] dbus_local_address;
    word_t                       dbus_rdata;
    bit                          dbus_ready_reg;

    assign dbus_local_address = dbus.address[2+:LOCAL_ADDRESS_WIDTH];
    assign dbus_rdata         = data_reg[dbus_local_address];

    always_ff @(posedge dbus.clk) begin
        if (dbus.valid) begin
            dbus.rdata <= dbus_rdata;
            data_reg[dbus_local_address] <= dbus.write_into(dbus_rdata);
        end
    end

    always_ff @(posedge dbus.clk) begin
        if (dbus.reset) begin
            dbus_ready_reg <= 0;
        end
        else if (dbus.valid && dbus.wstrobe == 0) begin
            dbus_ready_reg <= !dbus_ready_reg;
        end
    end

    assign dbus.ready = dbus.wstrobe == 0 ? dbus_ready_reg : dbus.valid;
    assign dbus.irq   = 0;

endmodule
