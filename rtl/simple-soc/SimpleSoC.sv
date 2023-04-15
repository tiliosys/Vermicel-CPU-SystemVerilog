
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module SimpleSoC #(
    parameter RAM_SIZE_WORDS,
    parameter RAM_INIT_FILENAME
)
(
    input  bit clk,
    input  bit reset,

    output bit uart_tx,
    input  bit uart_rx
);

    localparam RAM_ADDRESS   = 8'h00;
    localparam TIMER_ADDRESS = 8'h80;
    localparam UART_ADDRESS  = 8'h81;

    Bus cpu_bus   (clk, reset);
    Bus ram_bus   (clk, reset);
    Bus timer_bus (clk, reset);
    Bus uart_bus  (clk, reset);

    bit[7:0] dev_address;

    //
    // CPU instance
    //

    Vermicel cpu (cpu_bus.m);

    //
    // Device control
    //

    assign dev_address = cpu_bus.address[24+:8];

    assign cpu_bus.irq = timer_bus.irq;

    always_comb begin
        case (dev_address)
            RAM_ADDRESS: begin
                cpu_bus.rdata = ram_bus.rdata;
                cpu_bus.ready = ram_bus.ready;
            end
            TIMER_ADDRESS: begin
                cpu_bus.rdata = timer_bus.rdata;
                cpu_bus.ready = timer_bus.ready;
            end
            UART_ADDRESS: begin
                cpu_bus.rdata = uart_bus.rdata;
                cpu_bus.ready = uart_bus.ready;
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
    // Timer instance
    //

    Timer timer (timer_bus.s);

    assign timer_bus.valid   = cpu_bus.valid && dev_address == TIMER_ADDRESS;
    assign timer_bus.address = cpu_bus.address;
    assign timer_bus.wstrobe = cpu_bus.wstrobe;
    assign timer_bus.wdata   = cpu_bus.wdata;

    //
    // UART instance
    //

    UART uart (
        .bus(uart_bus.s),
        .rx(uart_rx),
        .tx(uart_tx)
    );

    assign uart_bus.valid   = cpu_bus.valid && dev_address == UART_ADDRESS;
    assign uart_bus.address = cpu_bus.address;
    assign uart_bus.wstrobe = cpu_bus.wstrobe;
    assign uart_bus.wdata   = cpu_bus.wdata;

endmodule



