//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

interface Vermibus (
    input bit clk,
    input bit reset
);

    import Vermitypes_pkg::*;

    bit       valid;
    bit       ready;
    word_t    lookahead;
    word_t    address;
    wstrobe_t wstrobe;
    word_t    wdata;
    word_t    rdata;
    bit       irq;

    function bit write_enabled();
        return valid && wstrobe != 0;
    endfunction

    function bit read_enabled();
        return valid && wstrobe == 0;
    endfunction

    function word_t write_into(word_t data);
        for (int i = 0; i < 4; i ++) begin
            if (wstrobe[i]) begin
                data[i*8+:8] = wdata[i*8+:8];
            end
        end
        return data;
    endfunction

    function word_t clear_into(word_t data);
        for (int i = 0; i < 4; i ++) begin
            if (wstrobe[i]) begin
                data[i*8+:8] &= ~wdata[i*8+:8];
            end
        end
        return data;
    endfunction

    modport read_only_request (
        input  clk, reset,
        output valid, address, lookahead,
        input  ready, rdata
    );

    modport read_only_response (
        input  clk, reset,
        input  valid, address, lookahead,
        output ready, rdata
    );

    modport read_write_request (
        input  clk, reset,
        output valid, address, wstrobe, wdata,
        input  ready, rdata, irq
    );

    modport read_write_response (
        input  clk, reset,
        input  valid, address, wstrobe, wdata,
        output ready, rdata, irq,
        import read_enabled, write_enabled, write_into, clear_into
    );

endinterface
