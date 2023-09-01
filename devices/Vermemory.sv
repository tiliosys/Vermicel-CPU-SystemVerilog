//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vermemory #(
    parameter int unsigned SIZE_WORDS,
    parameter INIT_FILENAME, // Implicit string type, not supported by Xilinx Vivado 2019.1
    parameter bit USE_LOOKAHEAD
) (
    Verbus.read_only_response  ibus,
    Verbus.read_write_response dbus
);

    import Verdata_pkg::*;

    localparam LOCAL_ADDRESS_WIDTH = $clog2(SIZE_WORDS);
    typedef bit[LOCAL_ADDRESS_WIDTH-1:0] local_address_t;

    word_t data_reg[0:SIZE_WORDS-1];

    initial begin
        $readmemh(INIT_FILENAME, data_reg);
    end

    //
    // Instruction bus.
    //

    local_address_t ibus_local_address;
    local_address_t ibus_local_address_sel;
    local_address_t ibus_local_address_reg;
    word_t          ibus_rdata;

    assign ibus_local_address     = ibus.address[2+:LOCAL_ADDRESS_WIDTH];
    assign ibus_local_address_sel = USE_LOOKAHEAD && ibus.ready ? ibus.lookahead[2+:LOCAL_ADDRESS_WIDTH] : ibus_local_address;
    assign ibus_rdata             = data_reg[ibus_local_address_sel];

    always_ff @(posedge ibus.clk) begin
        if (ibus.valid) begin
            ibus.rdata <= ibus_rdata;
        end
    end

    always_ff @(posedge ibus.clk) begin
        if (ibus.reset) begin
            ibus_local_address_reg <= {LOCAL_ADDRESS_WIDTH{1'b1}};
        end
        else if (ibus.valid) begin
            ibus_local_address_reg <= ibus_local_address_sel;
        end
    end

    assign ibus.ready = !ibus.valid || ibus_local_address == ibus_local_address_reg;

    //
    // Data bus.
    //

    local_address_t dbus_local_address;
    local_address_t dbus_local_address_reg;
    word_t          dbus_rdata;
    bit             dbus_write_reg;

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
            dbus_local_address_reg <= {LOCAL_ADDRESS_WIDTH{1'b1}};
            dbus_write_reg         <= 0;
        end
        else if (dbus.valid) begin
            dbus_local_address_reg <= dbus_local_address;
            dbus_write_reg         <= dbus.write_enabled();
        end
    end

    assign dbus.ready = !dbus.valid || dbus.write_enabled() || (dbus_local_address == dbus_local_address_reg && !dbus_write_reg);
    assign dbus.irq   = 0;

endmodule
