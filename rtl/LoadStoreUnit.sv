
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

    bit[2:0] size;

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

    bit[1:0] align = address[1:0];

    genvar i;
    generate
        for (i = 0; i < 4; i ++) begin
            assign wstrobe[i] = store_enable && i >= align && i < align + size;
        end
    endgenerate

    word_t aligned_rdata = rdata >> (align * 8);

    always_comb begin
        case (instr.funct3)
            funct3_lb_sb : load_data = word_t'(signed'(aligned_rdata[7:0]));
            funct3_lbu   : load_data = word_t'(aligned_rdata[7:0]);
            funct3_lh_sh : load_data = word_t'(signed'(aligned_rdata[15:0]));
            funct3_lhu   : load_data = word_t'(aligned_rdata[15:0]);
            default      : load_data = aligned_rdata;
        endcase
    end
endmodule


