//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

// Vermicel general-purpose registers.
//
// This module implements a register file with two read ports
// and one write port.
module Vergister
    import Verdata_pkg::*,
           Veropcodes_pkg::*,
           Vermicel_pkg::*;
(
    input  bit           clk,         // The clock signal.
    input  bit           reset,       // The active-high reset signal.
    input  bit           enable,      // Enables writing to a register.
    input  instruction_t src_instr,   // The instruction that specifies which registers to read.
    input  instruction_t dest_instr,  // The instruction that specifies which register to write.
    input  word_t        xd,          // The value to write to the destination register.
    output word_t        xs1,         // The value read from the first source register.
    output word_t        xs2          // The value read from the second source register.
);

    word_t x_reg[0:REGISTER_COUNT-1]; // The current register values.

    // Write to the destination register.
    always_ff @(posedge clk) begin
        if (reset) begin
            x_reg <= '{REGISTER_COUNT{0}};
        end
        else if (enable && dest_instr.has_rd) begin
            x_reg[dest_instr.rd] <= xd;
        end
    end

    // Read from the two source registers.
    assign xs1 = x_reg[src_instr.rs1];
    assign xs2 = x_reg[src_instr.rs2];
endmodule
