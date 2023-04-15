
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module UART_tb;

    import Types_pkg::*;
    import UART_pkg::*;

    localparam DIVISION = 867;
    localparam DATA1    = 8'b01010011;
    localparam DATA2    = 8'b11001010;

    localparam BIT_TIME = (DIVISION + 1) * 2;
    localparam TIMEOUT  = BIT_TIME * 10 + 2;

    bit clk, reset, uart_rx, uart_tx;
    bit ref_rx, ref_tx;
    bit tx_data_error, tx_flag_error, tx_done;

    Bus uart_bus (clk, reset);

    UART uart (
        .bus(uart_bus),
        .rx(uart_rx),
        .tx(uart_tx)
    );

    always #1 clk = ~clk;

    // Reference TX frame generator and checker.
    initial begin
        byte_t data;

        ref_tx = 1;

        forever begin
            @(posedge uart.control_reg.tx_enable)

            data = uart.tx_data_reg;
            tx_data_error = 0;
            tx_flag_error = 0;
            tx_done = 0;

            @(posedge clk)

            for (int n = 0; n < 10; n ++) begin
                case (n)
                    0       : ref_tx = 0; // Start
                    9       : ref_tx = 1; // Stop
                    default : ref_tx = data[n-1];
                endcase
                repeat(DIVISION + 1) begin
                    @(posedge clk)
                    if (uart_tx != ref_tx) begin
                        tx_data_error = 1;
                    end
                    if (uart.control_reg.tx_event_flag) begin
                        tx_flag_error = 1;
                    end
                end
            end

            @(posedge clk)

            if (uart_tx != ref_tx) begin
                tx_data_error = 1;
            end

            @(posedge clk)

            if (!uart.control_reg.tx_event_flag) begin
                tx_flag_error = 1;
            end

            tx_done = 1;
        end
    end

    task bus_write(word_t address, word_t data, wstrobe_t wstrobe);
        uart_bus.address = address * 4;
        uart_bus.wdata   = data;
        uart_bus.wstrobe = wstrobe;
        uart_bus.valid   = 1;
        do begin
            @(posedge clk);
        end while (!uart_bus.ready);
        uart_bus.valid   = 0;
        @(posedge clk);
    endtask

    task test_tx(string label, byte_t data, bit irq_enable);
        automatic control_reg_t ctrl  = '{
            tx_irq_enable : irq_enable,
            tx_enable     : 1,
            default       : 0
        };

        // Write and check the baud rate configuration register.
        bus_write(DIVISION_ADDRESS, DIVISION, 4'b1111);
        if (uart.division_reg != DIVISION) begin
            $display("[FAIL] %s: division_reg write failed (value %08h, expected %08h)", label, uart.division_reg, DIVISION);
            return;
        end

        // Write and check the TX data register.
        bus_write(TX_DATA_ADDRESS, data, 4'b0001);
        if (uart.tx_data_reg != data) begin
            $display("[FAIL] %s: tx_data_reg write failed (value %02h, expected %02h)", label, uart.tx_data_reg, data);
            return;
        end

        // Write and check the control register, start transmitting.
        bus_write(CONTROL_ADDRESS, ctrl, 4'b0001);
        ctrl.tx_enable = 0;
        if (uart.control_reg != ctrl) begin
            $display("[FAIL] %s: control_reg clear failed (value %02h, expected %02h)", label, uart.control_reg, ctrl);
            return;
        end

        @(posedge tx_done)

        if (tx_data_error) begin
            $display("[FAIL] %s: data bit errors (check waveforms)", label);
            return;
        end

        if (tx_flag_error) begin
            $display("[FAIL] %s: event flag error (check waveforms)", label);
            return;
        end

        $display("[PASS] %s", label);
    endtask

    initial begin
        $dumpfile("UART_tb.vcd");
        $dumpvars(0, UART_tb);

        $display("[TEST] UART_tb");

        reset = 1;
        @(negedge clk);
        reset = 0;
        @(posedge clk);

        if (uart_tx) begin
            $display("[PASS] reset");
        end
        else begin
            $display("[FAIL] reset: TX is not 1");
        end

        test_tx("tx(DATA1)",     DATA1, 0);
        test_tx("tx+irq(DATA1)", DATA1, 1);
        test_tx("tx(DATA2)",     DATA2, 0);
        test_tx("tx+irq(DATA2)", DATA2, 1);

        $display("[DONE] UART_tb");
        $finish;
    end
endmodule



