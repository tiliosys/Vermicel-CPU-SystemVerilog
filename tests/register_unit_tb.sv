
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import virgule_pkg::*;
import opcodes_pkg::*;

module register_unit_tb;

    localparam int reg_size = 32;

    bit           reg_clk, reg_reset, reg_enable;
    instruction_t reg_src_instr, reg_dest_instr;
    word_t        reg_xd, reg_xs1, reg_xs2;
    
    register_unit #(
        .size(reg_size)
    ) reg_inst (
        .clk(reg_clk),
        .src_instr(reg_src_instr),
        .dest_instr(reg_dest_instr),
        .reset(reg_reset),
        .enable(reg_enable),
        .xd(reg_xd),
        .xs1(reg_xs1),
        .xs2(reg_xs2)
    );

    function static word_t write_value(register_index_t n);
        return (n + 1) << 12;
    endfunction

    function static word_t read_value(register_index_t n);
        return (n == 0) ? 0 : write_value(n);
    endfunction

    task write(register_index_t rd);
        reg_src_instr         = instr_nop;
        reg_dest_instr        = instr_nop;
        reg_dest_instr.has_rd = rd > 0;
        reg_dest_instr.rd     = rd;
        reg_xd                = write_value(rd);
        reg_enable            = 1;
        @(posedge reg_clk);
    endtask

    task check_read(register_index_t rs1, register_index_t rs2);
        automatic word_t xs1 = read_value(rs1);
        automatic word_t xs2 = read_value(rs2);

        reg_src_instr         = instr_nop;
        reg_src_instr.rs1     = rs1;
        reg_src_instr.rs2     = rs2;
        reg_dest_instr        = instr_nop;
        reg_xd                = 0;
        reg_enable            = 0;

        #1;

        if (reg_xs1 == xs1 && reg_xs2 == xs2) begin
            $display("[PASS] Read %2d, %2d", rs1, rs2);
        end
        else begin
            $display("[FAIL] Read %2d, %2d : xs1=%08h expected=%08h, xs2=%08h expected=%08h", rs1, rs2, reg_xs1, xs1, reg_xs2, xs2);
        end
    endtask


    always #1 reg_clk = ~reg_clk;

    initial begin
        $display("[TEST] register_unit_tb");
        for (int n = 0; n < reg_size; n ++) begin
            write(n);
        end
        for (int n = 0; n < reg_size; n += 2) begin
            check_read(n, n + 1);
        end
        $display("[DONE] register_unit_tb");
        $finish;
    end
endmodule

