//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vergister_tb;

    import Verdata_pkg::*;
    import Veropcodes_pkg::*;

    localparam int REGS_SIZE = 32;

    bit           regs_clk, regs_reset, regs_enable;
    instruction_t regs_src_instr, regs_dest_instr;
    word_t        regs_xd, regs_xs1, regs_xs2;
    
    Vergister #(
        .SIZE(REGS_SIZE)
    ) regs (
        .clk(regs_clk),
        .reset(regs_reset),
        .enable(regs_enable),
        .src_instr(regs_src_instr),
        .dest_instr(regs_dest_instr),
        .xd(regs_xd),
        .xs1(regs_xs1),
        .xs2(regs_xs2)
    );

    function static word_t write_value(register_index_t n);
        return (n + 1) << 12;
    endfunction

    function static word_t read_value(register_index_t n);
        return (n == 0) ? 0 : write_value(n);
    endfunction

    task write(register_index_t rd);
        regs_src_instr         = INSTR_NOP;
        regs_dest_instr        = INSTR_NOP;
        regs_dest_instr.has_rd = rd > 0;
        regs_dest_instr.rd     = rd;
        regs_xd                = write_value(rd);
        regs_enable            = 1;
        @(posedge regs_clk);
    endtask

    task check_read(register_index_t rs1, register_index_t rs2);
        automatic word_t xs1 = read_value(rs1);
        automatic word_t xs2 = read_value(rs2);

        regs_src_instr         = INSTR_NOP;
        regs_src_instr.rs1     = rs1;
        regs_src_instr.rs2     = rs2;
        regs_dest_instr        = INSTR_NOP;
        regs_xd                = 0;
        regs_enable            = 0;

        #1;

        if (regs_xs1 == xs1 && regs_xs2 == xs2) begin
            $display("[PASS] Read %2d, %2d", rs1, rs2);
        end
        else begin
            $display("[FAIL] Read %2d, %2d : xs1=%08h expected=%08h, xs2=%08h expected=%08h", rs1, rs2, regs_xs1, xs1, regs_xs2, xs2);
        end
    endtask

    always #1 regs_clk = ~regs_clk;

    initial begin
        $display("[TEST] Vergister_tb");

        regs_enable = 0;
        regs_reset  = 1;
        @(posedge regs_clk);
        regs_reset  = 0;

        for (int n = 0; n < REGS_SIZE; n ++) begin
            write(n);
        end

        for (int n = 0; n < REGS_SIZE; n += 2) begin
            check_read(n, n + 1);
        end

        $display("[DONE] Vergister_tb");
        $finish;
    end
endmodule

