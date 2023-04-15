
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module LoadStoreUnit 
    import Types_pkg::*,
           Opcodes_pkg::*;
(
    input  instruction_t instr,
    input  word_t        address,
    input  bit           store_enable,
    input  word_t        store_data,
    output word_t        load_data,
    input  word_t        rdata,
    output wstrobe_t     wstrobe,
    output word_t        wdata
);

    bit[1:0]  align_byte; // Byte address alignment (0 to 3)
    bit       align_half; // Half-word address alignment (0 to 1)
    bit[7:0]  rdata_byte; // rdata, re-aligned for byte access.
    bit[15:0] rdata_half; // rdata, re-aligned for half-word access.

    always_comb begin
        wstrobe = 0;
        case (instr.funct3)
            FUNCT3_LB_SB, FUNCT3_LBU : begin
                wdata               = {4{store_data[7:0]}};
                wstrobe[align_byte] = store_enable;
            end
            FUNCT3_LH_SH, FUNCT3_LHU : begin
                wdata                  = {2{store_data[15:0]}};
                wstrobe[align_byte+:2] = {2{store_enable}};
            end
            FUNCT3_LW_SW: begin
                wdata   = store_data;
                wstrobe = {4{store_enable}};
            end
            default : begin
                wdata   = store_data;
            end
        endcase
    end

    assign align_byte = address[1:0];
    assign align_half = address[1];

    assign rdata_byte = rdata[align_byte*8+:8];
    assign rdata_half = rdata[align_half*16+:16];

    always_comb begin
        case (instr.funct3)
            FUNCT3_LB_SB : load_data = word_t'(signed'(rdata_byte));
            FUNCT3_LBU   : load_data = word_t'(rdata_byte);
            FUNCT3_LH_SH : load_data = word_t'(signed'(rdata_half));
            FUNCT3_LHU   : load_data = word_t'(rdata_half);
            default      : load_data = rdata;
        endcase
    end
endmodule


