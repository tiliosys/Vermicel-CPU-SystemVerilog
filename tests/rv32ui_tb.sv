//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module rv32ui_tb;

    localparam RAM_ADDRESS       = 8'h00;
    localparam RAM_SIZE_WORDS    = 65536;
    localparam RAM_INIT_FILENAME = "rv32ui/tests.mem";
    localparam OUT_ADDRESS       = 8'h10;
    localparam USE_LOOKAHEAD     = 1;
    localparam PIPELINE          = 0;

    bit clk, reset;
    Vermibus cpu_ibus (clk, reset);
    Vermibus cpu_dbus (clk, reset);
    Vermibus ram_dbus (clk, reset);
    Vermibus out_bus  (clk, reset);
    bit[7:0] dev_address;

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

    assign dev_address = cpu_dbus.address[24+:8];

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
            default: begin
                cpu_dbus.rdata = 0;
                cpu_dbus.ready = 1;
            end
        endcase
    end

    //
    // RAM instance
    //

    Vermimory #(
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
        if (out_bus.valid && out_bus.wstrobe[0]) begin
            $write("%s", out_bus.wdata[7:0]);
        end
    end

    //
    // Simulation control
    //

    initial begin
        $display("[TEST] rv32ui_tb");

        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        #60us

        $display("[DONE] rv32ui_tb");
        $finish;
    end
endmodule


