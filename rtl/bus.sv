
import virgule_pkg::*;

interface bus_if;

    bit valid;
    bit ready;
    word_t address;
    wstrobe_t wstrobe;
    word_t wdata;
    word_t rdata;
    bit irq;

    modport m (
        output valid, address, wstrobe, wdata,
        input ready, rdata, irq
    );

    modport s (
        input valid, address, wstrobe, wdata,
        output ready, rdata, irq
    );

endinterface
