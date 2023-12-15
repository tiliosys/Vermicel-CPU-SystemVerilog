//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Verdemo #(
    parameter RAM_SIZE_WORDS    = 32768,
    parameter RAM_INIT_FILENAME = "ram-init.mem",
    parameter bit USE_LOOKAHEAD = 0,
    parameter bit PIPELINE      = 0,
    parameter bit RESET_LEVEL   = 1
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

    //
    // Reset generator and input synchronizers.
    //

    bit int_reset;

    generate
        if (RESET_LEVEL) begin : gen_reset
            Vereset reset_gen (clk, reset, int_reset);
        end
        else begin : gen_reset_n
            Vereset reset_gen (clk, !reset, int_reset);
        end
    endgenerate

    bit uart_rx_sync;
    Versync sync (clk, uart_rx, uart_rx_sync);

    //
    // Bus interfaces.
    //

    Verbus cpu_ibus  (clk, int_reset);
    Verbus cpu_dbus  (clk, int_reset);
    Verbus ram_dbus  (clk, int_reset);
    Verbus timer_bus (clk, int_reset);
    Verbus uart_bus  (clk, int_reset);

    bit[7:0] dev_address = cpu_dbus.address[24+:8];

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
    // Timer instance
    //

    Vertimer timer (timer_bus.read_write_response);

    assign timer_bus.valid   = cpu_dbus.valid && dev_address == TIMER_ADDRESS;
    assign timer_bus.address = cpu_dbus.address;
    assign timer_bus.wstrobe = cpu_dbus.wstrobe;
    assign timer_bus.wdata   = cpu_dbus.wdata;

    //
    // UART instance
    //

    Verserial uart (
        .bus(uart_bus.read_write_response),
        .rx(uart_rx_sync),
        .tx(uart_tx)
    );

    assign uart_bus.valid   = cpu_dbus.valid && dev_address == UART_ADDRESS;
    assign uart_bus.address = cpu_dbus.address;
    assign uart_bus.wstrobe = cpu_dbus.wstrobe;
    assign uart_bus.wdata   = cpu_dbus.wdata;

endmodule



