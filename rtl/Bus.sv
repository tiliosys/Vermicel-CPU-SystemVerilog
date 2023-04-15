
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

interface Bus;

    import Types_pkg::*;

    bit       valid;
    bit       ready;
    word_t    address;
    wstrobe_t wstrobe;
    word_t    wdata;
    word_t    rdata;
    bit       irq;

    modport m (
        output valid, address, wstrobe, wdata,
        input  ready, rdata, irq
    );

    modport s (
        input  valid, address, wstrobe, wdata,
        output ready, rdata, irq
    );

endinterface
