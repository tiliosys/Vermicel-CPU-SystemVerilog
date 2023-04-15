
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module rv32ui_tb;

    localparam RAM_ADDRESS       = 8'h00;
    localparam RAM_SIZE_WORDS    = 65536;
    localparam RAM_INIT_FILENAME = "tests/rv32ui/tests.mem";
    localparam OUT_ADDRESS       = 8'h10;

    bit clk, reset;
    Bus cpu_bus (clk, reset);
    Bus ram_bus (clk, reset);
    Bus out_bus (clk, reset);
    bit[7:0] dev_address;

    always #10 clk = ~clk;

    //
    // CPU instance
    //

    Vermicel cpu (cpu_bus.m);

    //
    // Device control
    //

    assign dev_address = cpu_bus.address[24+:8];

    assign cpu_bus.irq = 0;

    always_comb begin
        case (dev_address)
            RAM_ADDRESS: begin
                cpu_bus.rdata = ram_bus.rdata;
                cpu_bus.ready = ram_bus.ready;
            end
            OUT_ADDRESS: begin
                cpu_bus.rdata = out_bus.rdata;
                cpu_bus.ready = out_bus.ready;
            end
            default: begin
                cpu_bus.rdata = 0;
                cpu_bus.ready = cpu_bus.valid;
            end
        endcase
    end

    //
    // RAM instance
    //

    SinglePortRAM #(
        .SIZE_WORDS(RAM_SIZE_WORDS),
        .INIT_FILENAME(RAM_INIT_FILENAME)
    ) ram (ram_bus.s);

    assign ram_bus.valid   = cpu_bus.valid && dev_address == RAM_ADDRESS;
    assign ram_bus.address = cpu_bus.address;
    assign ram_bus.wstrobe = cpu_bus.wstrobe;
    assign ram_bus.wdata   = cpu_bus.wdata;

    //
    // Text output
    //

    assign out_bus.valid   = cpu_bus.valid && dev_address == OUT_ADDRESS;
    assign out_bus.address = cpu_bus.address;
    assign out_bus.wstrobe = cpu_bus.wstrobe;
    assign out_bus.wdata   = cpu_bus.wdata;
    assign out_bus.rdata   = 0;
    assign out_bus.ready   = cpu_bus.valid;

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


