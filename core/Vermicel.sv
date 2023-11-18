//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vermicel #(
    parameter bit PIPELINE = 1
) (
    Verbus.read_only_request  ibus,
    Verbus.read_write_request dbus
);

    generate
        if (PIPELINE) begin : gen_pipeline
            Verpipeline core (
                .ibus(ibus),
                .dbus(dbus)
            );
        end
        else begin : gen_sequence
            assign ibus.valid     = 0;
            assign ibus.address   = 0;
            assign ibus.lookahead = 0;

            Versequence core (
                .bus(dbus)
            );
        end
    endgenerate

endmodule


