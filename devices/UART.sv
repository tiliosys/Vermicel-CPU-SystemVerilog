
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module UART (
    Bus.s  bus,
    input  bit rx,
    output bit tx
);

    import Types_pkg::*;
    import UART_pkg::*;

    local_address_t local_address;
    control_reg_t   control_reg;
    word_t          control_reg_as_word;
    word_t          division_reg;
    byte_t          tx_data_reg;
    word_t          tx_data_reg_as_word;
    byte_t          rx_data_reg;
    word_t          rx_data_reg_as_word;
    
    typedef enum {
        IDLE, BUSY, DONE
    } state_t;

    localparam BITS_PER_FRAME = 10; // Start + 8 bits + Stop
    localparam BIT_INDEX_MAX = BITS_PER_FRAME - 1;

    typedef bit[$clog2(BITS_PER_FRAME)-1:0] bit_index_t;

    state_t     tx_state_reg;
    word_t      tx_count_reg;
    bit_index_t tx_index_reg;
    byte_t      tx_buffer_reg;

    state_t     rx_state_reg;
    word_t      rx_count_reg;
    bit_index_t rx_index_reg;
    byte_t      rx_buffer_reg;

    assign local_address = local_address_t'(bus.address[2+:LOCAL_ADDRESS_WIDTH]);

    assign control_reg_as_word = word_t'(control_reg);
    assign tx_data_reg_as_word = word_t'(tx_data_reg);
    assign rx_data_reg_as_word = word_t'(rx_data_reg);

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            control_reg <= 0;
        end
        else if (bus.write_enabled() && local_address == CONTROL_ADDRESS) begin
            control_reg <= control_reg_t'(bus.write_into(control_reg_as_word));
        end
        else begin
            control_reg.tx_enable <= 0;
            if (tx_state_reg == DONE) begin
                control_reg.tx_event_flag <= 1;
            end 
            if (rx_state_reg == DONE) begin
                control_reg.rx_event_flag <= 1;
            end 
        end
    end

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            division_reg <= 0;
        end
        else if (bus.write_enabled() && local_address == DIVISION_ADDRESS) begin
            division_reg <= bus.write_into(division_reg);
        end 
    end

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            tx_data_reg <= 0;
        end
        else if (bus.write_enabled() && local_address == TX_DATA_ADDRESS) begin
            tx_data_reg <= byte_t'(bus.write_into(tx_data_reg_as_word));
        end 
    end

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            tx_state_reg <= IDLE;
            tx           <= 1;
        end
        else begin
            case (tx_state_reg)
                IDLE: begin
                    if (control_reg.tx_enable) begin
                        tx_state_reg  <= BUSY;
                        tx_count_reg  <= division_reg;
                        tx_index_reg  <= BIT_INDEX_MAX;
                        tx_buffer_reg <= tx_data_reg;
                        tx            <= 0;
                    end
                end
                BUSY: begin
                    if (tx_count_reg != 0) begin
                        tx_count_reg <= tx_count_reg - 1;
                    end
                    else if (tx_index_reg != 0) begin
                        tx_count_reg       <= division_reg;
                        tx                 <= tx_index_reg == 1 || tx_buffer_reg[0];
                        tx_buffer_reg[6:0] <= tx_buffer_reg[7:1];
                        tx_index_reg       <= tx_index_reg - 1;
                    end
                    else begin
                        tx_state_reg <= DONE;
                    end
                end
                DONE: begin
                    tx_state_reg <= IDLE;
                end
            endcase
        end
    end

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            rx_state_reg <= IDLE;
        end
        else begin
            case (rx_state_reg)
                IDLE: begin
                    if (!rx) begin
                        rx_state_reg <= BUSY;
                        rx_count_reg <= division_reg;
                        rx_index_reg <= BIT_INDEX_MAX;
                    end
                end
                BUSY: begin
                    if (rx_index_reg != 0) begin
                        if (rx_count_reg == division_reg / 2) begin
                            rx_buffer_reg <= {rx, rx_buffer_reg[7:1]};
                        end
                        if (rx_count_reg != 0) begin
                            rx_count_reg <= rx_count_reg - 1;
                        end
                        else begin
                            rx_count_reg <= division_reg;
                            rx_index_reg <= rx_index_reg - 1;
                        end
                    end
                    else if (rx) begin
                        rx_data_reg  <= rx_buffer_reg;
                        rx_state_reg <= DONE;
                    end
                end
                DONE: begin
                    rx_state_reg <= IDLE;
                end
            endcase
        end
    end

    always_comb begin
        case (local_address)
            CONTROL_ADDRESS  : bus.rdata = control_reg_as_word;
            DIVISION_ADDRESS : bus.rdata = division_reg;
            TX_DATA_ADDRESS  : bus.rdata = tx_data_reg_as_word;
            default          : bus.rdata = rx_data_reg_as_word;
        endcase
    end

    assign bus.ready = bus.valid;
    assign bus.irq   = control_reg.tx_irq_enable && control_reg.tx_event_flag ||
                       control_reg.rx_irq_enable && control_reg.rx_event_flag;
endmodule

