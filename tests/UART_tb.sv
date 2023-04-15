
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

    Bus uart_bus (clk, reset);

    UART uart (
        .bus(uart_bus),
        .rx(uart_rx),
        .tx(uart_tx)
    );

    always #1 clk = ~clk;

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
        automatic bit frame_detected = 0;
        automatic bit stop = 0;
        automatic bit timing_failed = 0;
        automatic bit data_failed = 0;
        automatic bit flag_failed = 0;

        fork
            begin : initiator
                automatic control_reg_t ctrl  = '{
                    tx_irq_enable : irq_enable,
                    tx_enable     : 1,
                    default       : 0
                };

                // Write and check the baud rate configuration register.
                bus_write(DIVISION_ADDRESS, DIVISION, 4'b1111);
                if (uart.division_reg != DIVISION) begin
                    $display("[FAIL] %s: division_reg write failed (value %08h, expected %08h)", label, uart.division_reg, DIVISION);
                    stop = 1;
                    disable initiator;
                end

                // Write and check the TX data register.
                bus_write(TX_DATA_ADDRESS, data, 4'b0001);
                if (uart.tx_data_reg != data) begin
                    $display("[FAIL] %s: tx_data_reg write failed (value %02h, expected %02h)", label, uart.tx_data_reg, data);
                    stop = 1;
                    disable initiator;
                end

                // Write and check the control register, start transmitting.
                bus_write(CONTROL_ADDRESS, ctrl, 4'b0001);
                ctrl.tx_enable = 0;
                if (uart.control_reg != ctrl) begin
                    $display("[FAIL] %s: control_reg clear failed (value %02h, expected %02h)", label, uart.control_reg, ctrl);
                    stop = 1;
                    disable initiator;
                end

                // Stop the other threads after the timeout has elapsed.
                #(TIMEOUT);
                stop = 1;

                // Check correct frame termination, flags and IRQ.
                ctrl.tx_event_flag = 1;

                if (!frame_detected) begin
                    $display("[FAIL] %s: timeout", label);
                end
                else if (uart.control_reg != ctrl) begin
                    $display("[FAIL] %s: control_reg invalid after TX (value %02h, expected %02h)", label, uart.control_reg, ctrl);
                end
                else if (irq_enable && !uart_bus.irq) begin
                    $display("[FAIL] %s: IRQ was not asserted", label);
                end
                else if (timing_failed) begin
                    $display("[FAIL] %s: data timing errors", label);
                end
                else if (data_failed) begin
                    $display("[FAIL] %s: data bit errors", label);
                end
                else if (flag_failed) begin
                    $display("[FAIL] %s: event flag timing error", label);
                end
                else begin
                    $display("[PASS] %s", label);
                end
            end
            begin : timing_checker
                automatic time t0, t1;
                // Wait for start bit
                @(negedge uart_tx, stop);
                if (!stop) begin
                    t0 = $time;
                    // Next transitions should happen after multiples of DIVISION cycles.
                    forever begin
                        @(uart_tx, stop);
                        if (stop) break;
                        t1 = $time;
                        if ((t1 - t0) % BIT_TIME != 0) begin
                            $display("[WARN] %s: wrong time between TX transitions (%0d)", label, (t1 - t0) / 2);
                            timing_failed = 1;
                        end
                        t0 = t1;
                    end
                end
            end
            begin : data_checker
                // Wait for start bit
                @(negedge uart_tx, stop);
                if (stop) disable data_checker;

                frame_detected = 1;
                // Wait until half of the first data bit has been output.
                #(BIT_TIME * 3 / 2);
                for (int n = 0; n < 9; n ++) begin
                    automatic bit expected = n < 8 ? data[n] : 1;
                    if (uart_tx != expected) begin
                        $display("[WARN] %s: wrong value for bit %0d at time %0d (%b)", label, n, $time, uart_tx);
                        data_failed = 1;
                    end
                    #(BIT_TIME);
                end
            end
            begin : flag_timing_checker
                automatic time t0, t1;
                // Wait for start bit
                @(negedge uart_tx, stop);
                if (stop) disable flag_timing_checker;

                t0 = $time;
                if (uart.control_reg.tx_event_flag) begin
                    t1 = t0;
                end
                else begin
                    @(posedge uart.control_reg.tx_event_flag, stop);
                    if (stop) disable flag_timing_checker;
                    t1 = $time;
                end

                if (t1 - t0 < 10 * BIT_TIME) begin
                    $display("[WARN] %s: TX event flag asserted too early", label);
                    flag_failed = 1;
                end
            end
        join
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



