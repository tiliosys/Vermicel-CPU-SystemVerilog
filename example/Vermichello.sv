
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module Vermichello #(
    parameter RAM_SIZE_WORDS    = 32768,
    parameter RAM_INIT_FILENAME = "ram-init.mem"
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

    Vermibus cpu_ibus  (clk, reset);
    Vermibus cpu_dbus  (clk, reset);
    Vermibus ram_dbus  (clk, reset);
    Vermibus timer_bus (clk, reset);
    Vermibus uart_bus  (clk, reset);

    bit[7:0] dev_address;

    //
    // CPU instance
    //

    Vermicel cpu (
        .ibus(cpu_ibus.read_only_request),
        .dbus(cpu_dbus.read_write_request)
    );

    //
    // Device control
    //

    assign dev_address = cpu_dbus.address[24+:8];

    assign cpu_dbus.irq = timer_bus.irq;

    always_comb begin
        case (dev_address)
            RAM_ADDRESS: begin
                cpu_dbus.rdata = ram_dbus.rdata;
                cpu_dbus.ready = ram_dbus.ready;
            end
            TIMER_ADDRESS: begin
                cpu_dbus.rdata = timer_bus.rdata;
                cpu_dbus.ready = timer_bus.ready;
            end
            UART_ADDRESS: begin
                cpu_dbus.rdata = uart_bus.rdata;
                cpu_dbus.ready = uart_bus.ready;
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
        .INIT_FILENAME(RAM_INIT_FILENAME)
    ) ram (
        .ibus(cpu_ibus.read_only_response),
        .dbus(ram_dbus.read_write_response)
    );

    assign ram_dbus.valid   = cpu_dbus.valid && dev_address == RAM_ADDRESS;
    assign ram_dbus.address = cpu_dbus.address;
    assign ram_dbus.wstrobe = cpu_dbus.wstrobe;
    assign ram_dbus.wdata   = cpu_dbus.wdata;

    //
    // Timer instance
    //

    Vermitime timer (timer_bus.read_write_response);

    assign timer_bus.valid   = cpu_dbus.valid && dev_address == TIMER_ADDRESS;
    assign timer_bus.address = cpu_dbus.address;
    assign timer_bus.wstrobe = cpu_dbus.wstrobe;
    assign timer_bus.wdata   = cpu_dbus.wdata;

    //
    // UART instance
    //

    Vermicom uart (
        .bus(uart_bus.read_write_response),
        .rx(uart_rx),
        .tx(uart_tx)
    );

    assign uart_bus.valid   = cpu_dbus.valid && dev_address == UART_ADDRESS;
    assign uart_bus.address = cpu_dbus.address;
    assign uart_bus.wstrobe = cpu_dbus.wstrobe;
    assign uart_bus.wdata   = cpu_dbus.wdata;

endmodule



