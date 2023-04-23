
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

interface Vermibus (
    input bit clk,
    input bit reset
);

    import Vermitypes_pkg::*;

    bit       valid;
    bit       ready;
    word_t    address;
    wstrobe_t wstrobe;
    word_t    wdata;
    word_t    rdata;
    bit       irq;

    function bit write_enabled();
        return valid && wstrobe != 0;
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

    modport m (
        input  clk, reset,
        output valid, address, wstrobe, wdata,
        input  ready, rdata, irq
    );

    modport s (
        input  clk, reset,
        input  valid, address, wstrobe, wdata,
        output ready, rdata, irq,
        import write_enabled, write_into, clear_into
    );

endinterface
