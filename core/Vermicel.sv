//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vermicel (
    Vermibus.read_only_request  ibus,
    Vermibus.read_write_request dbus
);

    assign ibus.valid     = 0;
    assign ibus.address   = 0;
    assign ibus.lookahead = 0;

    Vermisnail core (
        .bus(dbus)
    );

endmodule


