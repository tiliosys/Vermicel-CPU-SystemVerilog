
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import types_pkg::*;
import opcodes_pkg::*;

module arith_logic_unit_tb;

    instruction_t instr;
    word_t        alu_a, alu_b, alu_r;

    arith_logic_unit alu (
        .instr(instr),
        .a(alu_a),
        .b(alu_b),
        .r(alu_r)
    );

    task check(string label, alu_fn_t fn, word_t a, word_t b, word_t r);
        instr        = instr_nop;
        instr.alu_fn = fn;
        alu_a        = a;
        alu_b        = b;

        #1;

        if (alu_r == r) begin
            $display("[PASS] %s %8x, %8x", label, a, b);
        end
        else begin
            $display("[FAIL] %s %8x, %8x : result=%08h expected=%08h", label, a, b, alu_r, r);
        end
    endtask

    initial begin
        $display("[TEST] arith_logic_unit_tb");
        check("NOP",  alu_nop,         10,     20,         20);
        check("ADD",  alu_add,         10,     20,         30);
        check("ADD",  alu_add,        -10,    -20,        -30);
        check("SUB",  alu_sub,         10,     20,        -10);
        check("SUB",  alu_sub,        -10,    -20,         10);
        check("SLT",  alu_slt,         10,     20,          1);
        check("SLT",  alu_slt,        -10,     20,          1);
        check("SLT",  alu_slt,         10,    -20,          0);
        check("SLT",  alu_slt,         10,     10,          0);
        check("SLT",  alu_slt,        -10,    -10,          0);
        check("SLT",  alu_slt,        -10,    -20,          0);
        check("SLTU", alu_sltu,        10,     20,          1);
        check("SLTU", alu_sltu,       -10,     20,          0);
        check("SLTU", alu_sltu,        10,    -20,          1);
        check("SLTU", alu_sltu,        10,     10,          0);
        check("SLTU", alu_sltu,       -10,    -10,          0);
        check("SLTU", alu_sltu,       -10,    -20,          0);
        check("XOR",  alu_xor,     'b0011, 'b0101,     'b0110);
        check("OR",   alu_or,      'b0011, 'b0101,     'b0111);
        check("AND",  alu_and,     'b0011, 'b0101,     'b0001);
        check("SLL",  alu_sll,    'h12345,     12, 'h12345000);
        check("SRA",  alu_sra,    'h12345,     12,       'h12);
        check("SRA",  alu_sra, 'hF0005432,     12, 'hFFFF0005);
        check("SRL",  alu_srl,    'h12345,     12,       'h12);
        check("SRL",  alu_srl, 'hF0005432,     12, 'h000F0005);
        $display("[DONE] arith_logic_unit_tb");
    end
endmodule

