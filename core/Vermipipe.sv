//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vermipipe (
    Vermibus.read_only_request ibus,
    Vermibus.read_write_request dbus
);

    import Vermitypes_pkg::*;
    import Vermicodes_pkg::*;
    import Vermicel_pkg::*;

endmodule
