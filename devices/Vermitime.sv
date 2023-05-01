//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vermitime (Vermibus.read_write_response bus);

    import Vermitypes_pkg::*;
    import Vermitime_pkg::*;

    local_address_t local_address;
    control_reg_t   control_reg;
    word_t          control_reg_as_word;
    status_reg_t    status_reg;
    word_t          status_reg_as_word;
    word_t          refill_reg;
    word_t          count_reg;

    assign local_address = local_address_t'(bus.address[2+:LOCAL_ADDRESS_WIDTH]);

    assign control_reg_as_word = word_t'(control_reg);
    assign status_reg_as_word  = word_t'(status_reg);

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            control_reg <= 0;
        end
        else if (bus.write_enabled() && local_address == CONTROL_ADDRESS) begin
            control_reg <= control_reg_t'(bus.write_into(control_reg_as_word));
        end
        else if (control_reg.cyclic_mode && count_reg == 0) begin
            control_reg.count_enable <= 0;
        end
    end

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            status_reg <= 0;
        end
        else if (bus.write_enabled() && local_address == STATUS_ADDRESS) begin
            status_reg <= status_reg_t'(bus.clear_into(status_reg_as_word));
        end
        else if (control_reg.count_enable && count_reg == 0) begin
            status_reg.event_flag <= 1;
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
            CONTROL_ADDRESS : bus.rdata = control_reg_as_word;
            STATUS_ADDRESS  : bus.rdata = status_reg_as_word;
            REFILL_ADDRESS  : bus.rdata = refill_reg;
            default         : bus.rdata = count_reg;
        endcase
    end

    assign bus.ready = 1;
    assign bus.irq   = status_reg.event_flag && control_reg.irq_enable;

endmodule
