
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module Timer (Bus.s bus);

    import Types_pkg::*;
    import Timer_pkg::*;

    local_address_t local_address;
    control_reg_t   control_reg;
    word_t          control_reg_as_word;
    word_t          refill_reg;
    word_t          count_reg;

    assign local_address = local_address_t'(bus.address[2+:LOCAL_ADDRESS_WIDTH]);

    assign control_reg_as_word = word_t'(control_reg);

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            control_reg <= 0;
        end
        else if (bus.write_enabled() && local_address == CONTROL_ADDRESS) begin
            control_reg <= control_reg_t'(bus.write_into(control_reg_as_word));
        end
        else if (control_reg.count_enable && count_reg == 0) begin
            control_reg.event_flag <= 1;
            if (!control_reg.cyclic_mode) begin
                control_reg.count_enable <= 0;
            end
        end
    end

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            refill_reg <= 0;
            count_reg  <= 0;
        end
        else if (bus.write_enabled() && local_address == REFILL_ADDRESS) begin
            refill_reg <= bus.write_into(refill_reg);
            count_reg  <= bus.write_into(count_reg);
        end 
        else if (control_reg.count_enable && count_reg != 0) begin
            count_reg <= count_reg - 1;
        end
        else begin
            count_reg <= refill_reg;
        end
    end

    always_comb begin
        case (local_address)
            CONTROL_ADDRESS: bus.rdata = control_reg_as_word;
            REFILL_ADDRESS:  bus.rdata = refill_reg;
            default:         bus.rdata = count_reg;
        endcase
    end

    assign bus.ready = bus.valid;
    assign bus.irq   = control_reg.event_flag && control_reg.irq_enable;

endmodule
