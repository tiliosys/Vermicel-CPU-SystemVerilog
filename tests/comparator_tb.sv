
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import types_pkg::*;
import opcodes_pkg::*;

module comparator_tb;

    instruction_t cmp_instr;
    word_t        cmp_a, cmp_b;
    bit           cmp_taken;

    comparator cmp_inst (
        .instr(cmp_instr),
        .a(cmp_a),
        .b(cmp_b),
        .taken(cmp_taken)
    );

    task check(string label, funct3_t funct3, word_t a, word_t b, bit taken);
        cmp_instr        = instr_nop;
        cmp_instr.funct3 = funct3;
        cmp_a            = a;
        cmp_b            = b;

        #1;

        if (cmp_taken == taken) begin
            $display("[PASS] %s %8x, %8x", label, a, b);
        end
        else begin
            $display("[FAIL] %s %8x, %8x : result=%08h expected=%08h", label, a, b, cmp_taken, taken);
        end
    endtask

    initial begin
        $display("[TEST] comparator_tb");
        check("BEQ",  funct3_beq,   10,  20, 0);
        check("BEQ",  funct3_beq,   10,  10, 1);
        check("BEQ",  funct3_beq,  -10, -20, 0);
        check("BEQ",  funct3_beq,  -10, -10, 1);
        check("BNE",  funct3_bne,   10,  20, 1);
        check("BNE",  funct3_bne,   10,  10, 0);
        check("BNE",  funct3_bne,  -10, -20, 1);
        check("BNE",  funct3_bne,  -10, -10, 0);
        check("BLT",  funct3_blt,   10,  20, 1);
        check("BLT",  funct3_blt,  -10,  20, 1);
        check("BLT",  funct3_blt,   10, -20, 0);
        check("BLT",  funct3_blt,   10,  10, 0);
        check("BLT",  funct3_blt,  -10, -10, 0);
        check("BLT",  funct3_blt,  -10, -20, 0);
        check("BGE",  funct3_bge,   10,  20, 0);
        check("BGE",  funct3_bge,  -10,  20, 0);
        check("BGE",  funct3_bge,   10, -20, 1);
        check("BGE",  funct3_bge,   10,  10, 1);
        check("BGE",  funct3_bge,  -10, -10, 1);
        check("BGE",  funct3_bge,  -10, -20, 1);
        check("BLTU", funct3_bltu,  10,  20, 1);
        check("BLTU", funct3_bltu, -10,  20, 0);
        check("BLTU", funct3_bltu,  10, -20, 1);
        check("BLTU", funct3_bltu,  10,  10, 0);
        check("BLTU", funct3_bltu, -10, -10, 0);
        check("BLTU", funct3_bltu, -10, -20, 0);
        check("BGEU", funct3_bgeu,  10,  20, 0);
        check("BGEU", funct3_bgeu, -10,  20, 1);
        check("BGEU", funct3_bgeu,  10, -20, 0);
        check("BGEU", funct3_bgeu,  10,  10, 1);
        check("BGEU", funct3_bgeu, -10, -10, 1);
        check("BGEU", funct3_bgeu, -10, -20, 1);
        $display("[DONE] comparator_tb");
    end
endmodule

