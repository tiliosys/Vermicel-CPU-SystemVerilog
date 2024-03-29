//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Verbench #(
    parameter RAM_INIT_FILENAME, // Implicit string type. Verilator fails to load file if type specified.
    parameter bit USE_LOOKAHEAD,
    parameter bit PIPELINE
);
    localparam RAM_ADDRESS       = 8'h00;
    localparam RAM_SIZE_WORDS    = 32768;
    localparam OUT_ADDRESS       = 8'h10;
    localparam TICK_ADDRESS      = 8'h20;

    bit clk, reset;

    Verbus cpu_ibus (clk, reset);
    Verbus cpu_dbus (clk, reset);
    Verbus ram_dbus (clk, reset);
    Verbus out_bus  (clk, reset);
    Verbus tick_bus (clk, reset);

    bit[7:0] dev_address = cpu_dbus.address[24+:8];

    always #1 clk = ~clk;

    //
    // CPU instance
    //

    Vermicel #(
        .PIPELINE(PIPELINE)
    ) cpu (
        .ibus(cpu_ibus.read_only_request),
        .dbus(cpu_dbus.read_write_request)
    );

    //
    // Device control
    //

    assign cpu_dbus.irq = 0;

    always_comb begin
        case (dev_address)
            RAM_ADDRESS: begin
                cpu_dbus.rdata = ram_dbus.rdata;
                cpu_dbus.ready = ram_dbus.ready;
            end
            OUT_ADDRESS: begin
                cpu_dbus.rdata = out_bus.rdata;
                cpu_dbus.ready = out_bus.ready;
            end
            TICK_ADDRESS: begin
                cpu_dbus.rdata = tick_bus.rdata;
                cpu_dbus.ready = tick_bus.ready;
            end
            default: begin
                cpu_dbus.rdata = 0;
                cpu_dbus.ready = 1;
            end
        endcase
    end

    //
    // RAM instance
    //

    Vermemory #(
        .SIZE_WORDS(RAM_SIZE_WORDS),
        .INIT_FILENAME(RAM_INIT_FILENAME),
        .USE_LOOKAHEAD(USE_LOOKAHEAD)
    ) ram (
        .ibus(cpu_ibus.read_only_response),
        .dbus(ram_dbus.read_write_response)
    );

    assign ram_dbus.valid   = cpu_dbus.valid && dev_address == RAM_ADDRESS;
    assign ram_dbus.address = cpu_dbus.address;
    assign ram_dbus.wstrobe = cpu_dbus.wstrobe;
    assign ram_dbus.wdata   = cpu_dbus.wdata;

    //
    // Text output
    //

    assign out_bus.valid   = cpu_dbus.valid && dev_address == OUT_ADDRESS;
    assign out_bus.address = cpu_dbus.address;
    assign out_bus.wstrobe = cpu_dbus.wstrobe;
    assign out_bus.wdata   = cpu_dbus.wdata;
    assign out_bus.rdata   = 0;
    assign out_bus.ready   = 1;

    always_ff @(posedge clk) begin
        if (out_bus.write_enabled()) begin
            $display("Output = %0d", out_bus.wdata);
        end
    end

    //
    // Time measurement command.
    //

    assign tick_bus.valid   = cpu_dbus.valid && dev_address == TICK_ADDRESS;
    assign tick_bus.address = cpu_dbus.address;
    assign tick_bus.wstrobe = cpu_dbus.wstrobe;
    assign tick_bus.wdata   = cpu_dbus.wdata;
    assign tick_bus.rdata   = 0;
    assign tick_bus.ready   = 1;

    int unsigned cycle_counter;

    initial begin
        $display("-- %s", RAM_INIT_FILENAME);
    end

    always_ff @(posedge clk) begin
        if (tick_bus.write_enabled()) begin
            if (tick_bus.wdata != 0) begin
                cycle_counter <= 0;
            end
            else begin
                $display("Execution time = %0d clock cycles", cycle_counter);
                $finish;
            end
        end
        else begin
            cycle_counter <= cycle_counter + 1;
        end
    end
endmodule


