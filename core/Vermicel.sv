//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vermicel #(
    parameter bit PIPELINE = 1
) (
    Vermibus.read_only_request  ibus,
    Vermibus.read_write_request dbus
);

    generate
        if (PIPELINE) begin : p
            Vermipipe core (
                .ibus(ibus),
                .dbus(dbus)
            );
        end
        else begin :  s
            assign ibus.valid     = 0;
            assign ibus.address   = 0;
            assign ibus.lookahead = 0;

            Versiquential core (
                .bus(dbus)
            );
        end
    endgenerate

endmodule


