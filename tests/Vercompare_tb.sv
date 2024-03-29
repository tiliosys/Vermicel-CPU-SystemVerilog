//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vercompare_tb;

    import Verdata_pkg::*;
    import Veropcodes_pkg::*;

    instruction_t cmp_instr;
    word_t        cmp_a, cmp_b;
    bit           cmp_taken;

    Vercompare cmp (
        .instr(cmp_instr),
        .a(cmp_a),
        .b(cmp_b),
        .taken(cmp_taken)
    );

    task check(string label, funct3_t funct3, word_t a, word_t b, bit taken);
        cmp_instr           = INSTR_NOP;
        cmp_instr.is_branch = 1;
        cmp_instr.funct3    = funct3;
        cmp_a               = a;
        cmp_b               = b;

        #1;

        if (cmp_taken == taken) begin
            $display("[PASS] %s %8x, %8x", label, a, b);
        end
        else begin
            $display("[FAIL] %s %8x, %8x : result=%08h expected=%08h", label, a, b, cmp_taken, taken);
        end
    endtask

    initial begin
        $display("[TEST] Vercompare_tb");
        check("BEQ",  FUNCT3_BEQ,   10,  20, 0);
        check("BEQ",  FUNCT3_BEQ,   10,  10, 1);
        check("BEQ",  FUNCT3_BEQ,  -10, -20, 0);
        check("BEQ",  FUNCT3_BEQ,  -10, -10, 1);
        check("BNE",  FUNCT3_BNE,   10,  20, 1);
        check("BNE",  FUNCT3_BNE,   10,  10, 0);
        check("BNE",  FUNCT3_BNE,  -10, -20, 1);
        check("BNE",  FUNCT3_BNE,  -10, -10, 0);
        check("BLT",  FUNCT3_BLT,   10,  20, 1);
        check("BLT",  FUNCT3_BLT,  -10,  20, 1);
        check("BLT",  FUNCT3_BLT,   10, -20, 0);
        check("BLT",  FUNCT3_BLT,   10,  10, 0);
        check("BLT",  FUNCT3_BLT,  -10, -10, 0);
        check("BLT",  FUNCT3_BLT,  -10, -20, 0);
        check("BGE",  FUNCT3_BGE,   10,  20, 0);
        check("BGE",  FUNCT3_BGE,  -10,  20, 0);
        check("BGE",  FUNCT3_BGE,   10, -20, 1);
        check("BGE",  FUNCT3_BGE,   10,  10, 1);
        check("BGE",  FUNCT3_BGE,  -10, -10, 1);
        check("BGE",  FUNCT3_BGE,  -10, -20, 1);
        check("BLTU", FUNCT3_BLTU,  10,  20, 1);
        check("BLTU", FUNCT3_BLTU, -10,  20, 0);
        check("BLTU", FUNCT3_BLTU,  10, -20, 1);
        check("BLTU", FUNCT3_BLTU,  10,  10, 0);
        check("BLTU", FUNCT3_BLTU, -10, -10, 0);
        check("BLTU", FUNCT3_BLTU, -10, -20, 0);
        check("BGEU", FUNCT3_BGEU,  10,  20, 0);
        check("BGEU", FUNCT3_BGEU, -10,  20, 1);
        check("BGEU", FUNCT3_BGEU,  10, -20, 0);
        check("BGEU", FUNCT3_BGEU,  10,  10, 1);
        check("BGEU", FUNCT3_BGEU, -10, -10, 1);
        check("BGEU", FUNCT3_BGEU, -10, -20, 1);
        $display("[DONE] Vercompare_tb");
    end
endmodule

