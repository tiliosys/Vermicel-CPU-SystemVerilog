//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vermicel_tb;

    import Vermitypes_pkg::*;
    import Vermicodes_pkg::*;

    bit clk, reset;

    Vermibus tb_bus (clk, reset);

    Vermicel #(
        .PIPELINE(0)
    ) cpu (
        .ibus(tb_bus.read_only_request),
        .dbus(tb_bus.read_write_request)
    );

    typedef bit[2:0] field_ignore_t;
    localparam field_ignore_t ignore_none    = 'b000;
    localparam field_ignore_t ignore_address = 'b100;
    localparam field_ignore_t ignore_wstrobe = 'b010;
    localparam field_ignore_t ignore_wdata   = 'b001;

    task check(string label, word_t rdata, bit ready, bit irq, bit valid, word_t address, wstrobe_t wstrobe, word_t wdata, field_ignore_t ignore);
        tb_bus.rdata = rdata;
        tb_bus.ready = ready;
        tb_bus.irq   = irq;

        if (|(ignore & ignore_address)) begin
            address = tb_bus.address;
        end
        if (|(ignore & ignore_wstrobe)) begin
            wstrobe = tb_bus.wstrobe;
        end
        if (|(ignore & ignore_wdata)) begin
            wdata = tb_bus.wdata;
        end

        if (tb_bus.valid == valid && tb_bus.address == address && tb_bus.wstrobe == wstrobe && tb_bus.wdata == wdata) begin
            $display("[PASS] %s", label);
        end
        else begin
            $display("[FAIL] %s: valid=%b, expected=%b ; address=%08x, expected=%08x, wstrobe=%04b, expected=%04b ; wdata=%08x, expected=%08x",
                label,
                tb_bus.valid, valid,
                tb_bus.address, address,
                tb_bus.wstrobe, wstrobe,
                tb_bus.wdata, wdata);
        end
        @(posedge clk);
    endtask

    task check_reg(string label, register_index_t n, word_t actual, word_t expected);
        if (actual == expected) begin
            $display("[PASS] %s", label);
        end
        else begin
            $display("[FAIL] %s: x%0d=%08h, expected=%08h", label, n, actual, expected);
        end
    endtask

    always #1 clk = ~clk;

    initial begin
        $display("[TEST] Vermicel_tb");

        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        //                          rdata           ready irq valid address    wstrobe  wdata             state
        check("INIT (F)",           0,                  0, 0, 1, 32'h00000000, 4'b0000, 32'hxxxxxxxx, ignore_wdata);
        check("LUI x4, 0xA000 (F)", asm_lui(4, 'hA000), 1, 0, 1, 32'h00000000, 4'b0000, 32'hxxxxxxxx, ignore_wdata);
        check("LUI x4, 0xA000 (D)", 0,                  0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata);
        check("LUI x4, 0xA000 (E)", 0,                  0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata);
        check("LUI x4, 0xA000 (R)", 0,                  0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata);

        check_reg("LUI x4, 0xA000", 4, cpu.s.core.regs.x_reg[4], 32'h0000A000);

        check("ADDI x5, x0, 0x96 (F)", asm_addi(5, 0, 'h96), 1, 0, 1, 32'h00000004, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("ADDI x5, x0, 0x96 (D)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("ADDI x5, x0, 0x96 (E)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("ADDI x5, x0, 0x96 (R)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // R

        check_reg("ADDI x5, x0, 0x96", 5, cpu.s.core.regs.x_reg[5], 32'h00000096);

        check("SW x5, 0x100(x4) (F)", asm_sw(5, 4, 'h100), 1, 0, 1, 32'h00000008, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("SW x5, 0x100(x4) (D)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("SW x5, 0x100(x4) (E)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("SW x5, 0x100(x4) (S)", 0,                   0, 0, 1, 32'h0000A100, 4'b1111, 32'h00000096, ignore_none); // S
        check("SW x5, 0x100(x4) (s)", 0,                   1, 0, 1, 32'h0000A100, 4'b1111, 32'h00000096, ignore_none); // S

        check("SH x5, 0x100(x4) (F)", asm_sh(5, 4, 'h100), 1, 0, 1, 32'h0000000C, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("SH x5, 0x100(x4) (D)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("SH x5, 0x100(x4) (E)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("SH x5, 0x100(x4) (S)", 0,                   1, 0, 1, 32'h0000A100, 4'b0011, 32'h00960096, ignore_none); // S

        check("SH x5, 0x102(x4) (F)", asm_sh(5, 4, 'h102), 1, 0, 1, 32'h00000010, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("SH x5, 0x102(x4) (D)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("SH x5, 0x102(x4) (E)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("SH x5, 0x102(x4) (S)", 0,                   1, 0, 1, 32'h0000A102, 4'b1100, 32'h00960096, ignore_none); // S

        check("SB x5, 0x100(x4) (F)", asm_sb(5, 4, 'h100), 1, 0, 1, 32'h00000014, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("SB x5, 0x100(x4) (D)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("SB x5, 0x100(x4) (E)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("SB x5, 0x100(x4) (S)", 0,                   1, 0, 1, 32'h0000A100, 4'b0001, 32'h96969696, ignore_none); // S

        check("SB x5, 0x101(x4) (F)", asm_sb(5, 4, 'h101), 1, 0, 1, 32'h00000018, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("SB x5, 0x101(x4) (D)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("SB x5, 0x101(x4) (E)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("SB x5, 0x101(x4) (S)", 0,                   1, 0, 1, 32'h0000A101, 4'b0010, 32'h96969696, ignore_none); // S

        check("SB x5, 0x102(x4) (F)", asm_sb(5, 4, 'h102), 1, 0, 1, 32'h0000001C, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("SB x5, 0x102(x4) (D)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("SB x5, 0x102(x4) (E)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("SB x5, 0x102(x4) (S)", 0,                   1, 0, 1, 32'h0000A102, 4'b0100, 32'h96969696, ignore_none); // S

        check("SB x5, 0x103(x4) (F)", asm_sb(5, 4, 'h103), 1, 0, 1, 32'h00000020, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("SB x5, 0x103(x4) (D)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("SB x5, 0x103(x4) (E)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("SB x5, 0x103(x4) (S)", 0,                   1, 0, 1, 32'h0000A103, 4'b1000, 32'h96969696, ignore_none); // S

        check("LW x6, 0x100(x4) (F)", asm_lw(6, 4, 'h100), 1, 0, 1, 32'h00000024, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("LW x6, 0x100(x4) (D)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("LW x6, 0x100(x4) (E)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("LW x6, 0x100(x4) (L)", 0,                   0, 0, 1, 32'h0000A100, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // L
        check("LW x6, 0x100(x4) (l)", 32'h8C15F3E4,        1, 0, 1, 32'h0000A100, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // L
        check("LW x6, 0x100(x4) (R)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // R

        check_reg("LW x6, 0x100(x4)", 6, cpu.s.core.regs.x_reg[6], 32'h8C15F3E4);

        check("LH x7, 0x100(x4) (F)", asm_lh(7, 4, 'h100), 1, 0, 1, 32'h00000028, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("LH x7, 0x100(x4) (D)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("LH x7, 0x100(x4) (E)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("LH x7, 0x100(x4) (L)", 32'h8C15F3E4,        1, 0, 1, 32'h0000A100, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // L
        check("LH x7, 0x100(x4) (R)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // R

        check_reg("LH x7, 0x100(x4)", 7, cpu.s.core.regs.x_reg[7], 32'hFFFFF3E4);

        check("LH x8, 0x102(x4) (F)", asm_lh(8, 4, 'h102), 1, 0, 1, 32'h0000002c, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("LH x8, 0x102(x4) (D)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("LH x8, 0x102(x4) (E)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("LH x8, 0x102(x4) (L)", 32'h8C15F3E4,        1, 0, 1, 32'h0000A102, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // L
        check("LH x8, 0x102(x4) (R)", 0,                   0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // R

        check_reg("LH x8, 0x102(x4)", 8, cpu.s.core.regs.x_reg[8], 32'hFFFF8C15);

        check("LHU x9, 0x100(x4) (F)", asm_lhu(9, 4, 'h100), 1, 0, 1, 32'h00000030, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("LHU x9, 0x100(x4) (D)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("LHU x9, 0x100(x4) (E)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("LHU x9, 0x100(x4) (L)", 32'h8C15F3E4,         1, 0, 1, 32'h0000A100, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // L
        check("LHU x9, 0x100(x4) (R)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // R

        check_reg("LHU x9, 0x100(x4)", 9, cpu.s.core.regs.x_reg[9], 32'h0000F3E4);

        check("LHU x10, 0x102(x4) (F)", asm_lhu(10, 4, 'h102), 1, 0, 1, 32'h00000034, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("LHU x10, 0x102(x4) (D)", 0,                     0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("LHU x10, 0x102(x4) (E)", 0,                     0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("LHU x10, 0x102(x4) (L)", 32'h8C15F3E4,          1, 0, 1, 32'h0000A102, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // L
        check("LHU x10, 0x102(x4) (R)", 0,                     0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // R

        check_reg("LHU x10, 0x102(x4)", 10, cpu.s.core.regs.x_reg[10], 32'h00008C15);

        check("LB x11, 0x100(x4) (F)", asm_lb(11, 4, 'h100), 1, 0, 1, 32'h00000038, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("LB x11, 0x100(x4) (D)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("LB x11, 0x100(x4) (E)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("LB x11, 0x100(x4) (L)", 32'h8C15F3E4,         1, 0, 1, 32'h0000A100, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // L
        check("LB x11, 0x100(x4) (R)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // R

        check_reg("LB x11, 0x100(x4)", 11, cpu.s.core.regs.x_reg[11], 32'hFFFFFFE4);

        check("LB x12, 0x101(x4) (F)", asm_lb(12, 4, 'h101), 1, 0, 1, 32'h0000003c, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("LB x12, 0x101(x4) (D)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("LB x12, 0x101(x4) (E)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("LB x12, 0x101(x4) (L)", 32'h8C15F3E4,         1, 0, 1, 32'h0000A101, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // L
        check("LB x12, 0x101(x4) (R)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // R

        check_reg("LB x12, 0x101(x4)", 12, cpu.s.core.regs.x_reg[12], 32'hFFFFFFF3);

        check("LB x13, 0x102(x4) (F)", asm_lb(13, 4, 'h102), 1, 0, 1, 32'h00000040, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("LB x13, 0x102(x4) (D)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("LB x13, 0x102(x4) (E)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("LB x13, 0x102(x4) (L)", 32'h8C15F3E4,         1, 0, 1, 32'h0000A102, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // L
        check("LB x13, 0x102(x4) (R)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // R

        check_reg("LB x13, 0x102(x4)", 13, cpu.s.core.regs.x_reg[13], 32'h00000015);

        check("LB x14, 0x103(x4) (F)", asm_lb(14, 4, 'h103), 1, 0, 1, 32'h00000044, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // F
        check("LB x14, 0x103(x4) (D)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // D
        check("LB x14, 0x103(x4) (E)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // E
        check("LB x14, 0x103(x4) (L)", 32'h8C15F3E4,         1, 0, 1, 32'h0000A103, 4'b0000, 32'hxxxxxxxx, ignore_wdata); // L
        check("LB x14, 0x103(x4) (R)", 0,                    0, 0, 0, 32'hxxxxxxxx, 4'bxxxx, 32'hxxxxxxxx, ignore_address|ignore_wstrobe|ignore_wdata); // R

        check_reg("LB x14, 0x103(x4)", 14, cpu.s.core.regs.x_reg[14], 32'hFFFFFF8C);

        $display("[DONE] Vermicel_tb");
        $finish;
    end
endmodule
