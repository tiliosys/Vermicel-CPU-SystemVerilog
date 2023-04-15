
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

module Virgule_tb;

    import Types_pkg::*;
    import Opcodes_pkg::*;

    bit cpu_clk, cpu_reset;
    Bus cpu_bus;

    Virgule cpu (
        .clk(cpu_clk),
        .reset(cpu_reset),
        .bus(cpu_bus.m)
    );

    initial begin
        $display("[TEST] Virgule_tb");
        $display("[DONE] Virgule_tb");
        $finish;
    end
endmodule
