
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

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

    bit[2:0]  size;       // Size of the data to load/store, in bytes (1, 2, 4)
    bit[1:0]  align;      // Address alignment (0 to 3)
    bit[15:0] rdata_half; // rdata, re-aligned for half-word access.
    bit[7:0]  rdata_byte; // rdata, re-aligned for byte access.

    always_comb begin
        case (instr.funct3)
            funct3_lb_sb, funct3_lbu : begin
                size  = 1;
                wdata = {4{store_data[7:0]}};
            end
            funct3_lh_sh, funct3_lhu : begin
                size  = 2;
                wdata = {2{store_data[15:0]}};
            end
            funct3_lw_sw: begin
                size  = 4;
                wdata = store_data;
            end
            default : begin
                size  = 0;
                wdata = store_data;
            end
        endcase
    end

    assign align = address[1:0];

    genvar i;
    generate
        for (i = 0; i < 4; i ++) begin
            assign wstrobe[i] = store_enable && i >= align && i < align + size;
        end
    endgenerate

    assign rdata_half = align == 2'b00 ? rdata[15:0] : rdata[31:16];

    always_comb begin
        case (align)
            3:       rdata_byte = rdata[31:24];
            2:       rdata_byte = rdata[23:16];
            1:       rdata_byte = rdata[15:8];
            default: rdata_byte = rdata[7:0];
        endcase
    end

    always_comb begin
        case (instr.funct3)
            funct3_lb_sb : load_data = word_t'(signed'(rdata_byte));
            funct3_lbu   : load_data = word_t'(rdata_byte);
            funct3_lh_sh : load_data = word_t'(signed'(rdata_half));
            funct3_lhu   : load_data = word_t'(rdata_half);
            default      : load_data = rdata;
        endcase
    end
endmodule


