//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

// Vermicel load/store data alignment.
//
// This module realigns the values before a bus write operation or
// after a bus read operation depending on the access size, address
// and signedness.
module Veralign
    import Verdata_pkg::*,
           Veropcodes_pkg::*;
(
    input  instruction_t instr,        // The current instruction fields.
    input  word_t        address,      // The address where to read or write.
    input  bit           store_enable, // Are we executing a store instruction?
    input  word_t        store_data,   // The value to store.
    output word_t        load_data,    // The result of a load instruction.
    input  word_t        rdata,        // The current value of the read data bus.
    output wstrobe_t     wstrobe,      // The byte selection in the write data bus.
    output word_t        wdata         // The value to assign to the write data bus.
);

    bit[1:0]    byte_index      = address[1:0]; // Byte address alignment (0 to 3).
    bit         half_word_index = address[1];   // Half-word address alignment (0 to 1).
    byte_t      rdata_byte;                     // rdata, re-aligned for byte access.
    half_word_t rdata_half_word;                // rdata, re-aligned for half-word access.

    // Depending on the access size, replicate the least-significant byte,
    // half-word or word of store_data to fill wdata.
    // Assign wstrobe according to the access size and address alignment.
    always_comb begin
        wstrobe = 0;
        case (instr.funct3)
            FUNCT3_LB_SB, FUNCT3_LBU : begin
                wdata               = {4{store_data[7:0]}};
                wstrobe[byte_index] = store_enable;
            end
            FUNCT3_LH_SH, FUNCT3_LHU : begin
                wdata                         = {2{store_data[15:0]}};
                wstrobe[2*half_word_index+:2] = {2{store_enable}};
            end
            FUNCT3_LW_SW: begin
                wdata   = store_data;
                wstrobe = {4{store_enable}};
            end
            default : begin
                wdata = store_data;
            end
        endcase
    end

    // Assuming a byte or half-word access, select the slice of rdata
    // that corresponds to the current address alignment.
    assign rdata_byte      = rdata[byte_index*8+:8];
    assign rdata_half_word = rdata[half_word_index*16+:16];

    // Resize the slice from rdata that corresponds to the current
    // access size and address alignment, applying sign extension
    // for signed byte and half-word accesses.
    always_comb begin
        case (instr.funct3)
            FUNCT3_LB_SB : load_data = word_t'(signed'(rdata_byte));
            FUNCT3_LBU   : load_data = word_t'(rdata_byte);
            FUNCT3_LH_SH : load_data = word_t'(signed'(rdata_half_word));
            FUNCT3_LHU   : load_data = word_t'(rdata_half_word);
            default      : load_data = rdata;
        endcase
    end
endmodule


