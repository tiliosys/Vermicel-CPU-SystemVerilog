
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
    bit tx_ref, tx_data_error, tx_flag_error, tx_irq_error, tx_done;
    bit rx_enable, rx_data_error, rx_flag_error, rx_irq_error, rx_done;
    byte_t rx_data;

    Bus uart_bus (clk, reset);

    UART uart (
        .bus(uart_bus),
        .rx(uart_rx),
        .tx(uart_tx)
    );

    always #1 clk = ~clk;

    //
    // Reference TX frame generator and checker.
    //

    initial tx_ref = 1;

    always @(posedge uart.control_reg.tx_enable)
    begin
        automatic byte_t data = uart.tx_data_reg;

        tx_data_error = 0;
        tx_flag_error = 0;
        tx_irq_error  = 0;
        tx_done       = 0;

        @(posedge clk)

        for (int n = 0; n < 10; n ++) begin
            case (n)
                0       : tx_ref = 0; // Start
                9       : tx_ref = 1; // Stop
                default : tx_ref = data[n-1];
            endcase
            repeat(DIVISION + 1) begin
                @(posedge clk)
                if (uart_tx != tx_ref) begin
                    tx_data_error = 1;
                end
                if (uart.control_reg.tx_event_flag) begin
                    tx_flag_error = 1;
                end
                if (uart_bus.irq) begin
                    tx_irq_error = 1;
                end
            end
        end

        @(posedge clk)

        if (uart_tx != tx_ref) begin
            tx_data_error = 1;
        end

        @(posedge clk)

        if (!uart.control_reg.tx_event_flag) begin
            tx_flag_error = 1;
        end

        if (uart_bus.irq != uart.control_reg.tx_irq_enable) begin
            tx_irq_error = 1;
        end

        tx_done = 1;
    end

    //
    // Reference RX frame generator and checker.
    //

    initial uart_rx = 1;

    always @(posedge rx_enable)
    begin
        rx_flag_error = 0;
        rx_irq_error  = 0;
        rx_done       = 0;

        for (int n = 0; n < 10; n ++) begin
            case (n)
                0       : uart_rx = 0; // Start
                9       : uart_rx = 1; // Stop
                default : uart_rx = rx_data[n-1];
            endcase
            repeat(DIVISION + 1) begin
                @(posedge clk)
                if (uart.control_reg.rx_event_flag && n < 9) begin
                    rx_flag_error = 1;
                end
                if (uart_bus.irq && n < 9) begin
                    rx_irq_error = 1;
                end
            end
        end

        @(posedge clk)

        rx_data_error = uart.rx_data_reg != rx_data;

        if (!uart.control_reg.rx_event_flag) begin
            rx_flag_error = 1;
        end

        if (uart_bus.irq != uart.control_reg.rx_irq_enable) begin
            rx_irq_error = 1;
        end

        rx_done = 1;
    end

    task bus_write(word_t address, word_t data, wstrobe_t wstrobe);
        @(posedge clk)
        uart_bus.address = address * 4;
        uart_bus.wdata   = data;
        uart_bus.wstrobe = wstrobe;
        uart_bus.valid   = 1;
        do @(posedge clk); while (!uart_bus.ready);
        uart_bus.valid = 0;
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
        if (uart.control_reg != ctrl) begin
            $display("[FAIL] %s: control_reg write failed (value %02h, expected %02h)", label, uart.control_reg, data);
            return;
        end

        @(posedge clk);

        ctrl.tx_enable = 0;
        if (uart.control_reg != ctrl) begin
            $display("[FAIL] %s: control_reg autoclear failed (value %02h, expected %02h)", label, uart.control_reg, ctrl);
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

        if (tx_irq_error) begin
            $display("[FAIL] %s: IRQ error (check waveforms)", label);
            return;
        end

        $display("[PASS] %s", label);
    endtask

    task test_rx(string label, byte_t data, bit irq_enable);
        automatic control_reg_t ctrl  = '{
            rx_irq_enable : irq_enable,
            default       : 0
        };

        bus_write(CONTROL_ADDRESS, ctrl, 4'b0001);
        if (uart.control_reg != ctrl) begin
            $display("[FAIL] %s: control_reg write failed (value %02h, expected %02h)", label, uart.control_reg, data);
            return;
        end

        rx_data = data;

        @(posedge clk) rx_enable = 1;

        @(posedge rx_done) rx_enable = 0;

        if (rx_data_error) begin
            $display("[FAIL] %s: data bit errors (check waveforms)", label);
            return;
        end

        if (tx_flag_error) begin
            $display("[FAIL] %s: event flag error (check waveforms)", label);
            return;
        end

        if (tx_irq_error) begin
            $display("[FAIL] %s: IRQ error (check waveforms)", label);
            return;
        end

        $display("[PASS] %s", label);
        if (rx_flag_error) begin
            $display("[FAIL] %s: event flag error (check waveforms)", label);
            return;
        end

        if (rx_irq_error) begin
            $display("[FAIL] %s: IRQ error (check waveforms)", label);
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

        test_tx("TX     (DATA1)", DATA1, 0);
        test_tx("TX     (DATA2)", DATA2, 0);
        test_tx("TX+IRQ (DATA1)", DATA1, 1);
        test_tx("TX+IRQ (DATA2)", DATA2, 1);

        test_rx("RX     (DATA1)", DATA1, 0);
        test_rx("RX     (DATA2)", DATA2, 0);
        test_rx("RX+IRQ (DATA1)", DATA1, 1);
        test_rx("RX+IRQ (DATA2)", DATA2, 1);

        $display("[DONE] UART_tb");
        $finish;
    end
endmodule



