
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module ArithLogicUnit_tb;

    import Types_pkg::*;
    import Opcodes_pkg::*;

    instruction_t instr;
    word_t        alu_a, alu_b, alu_r;

    ArithLogicUnit alu (
        .instr(instr),
        .a(alu_a),
        .b(alu_b),
        .r(alu_r)
    );

    task check(string label, alu_fn_t fn, word_t a, word_t b, word_t r);
        instr        = INSTR_NOP;
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
        $display("[TEST] ArithLogicUnit_tb");
        check("NOP",  ALU_NOP,         10,     20,         20);
        check("ADD",  ALU_ADD,         10,     20,         30);
        check("ADD",  ALU_ADD,        -10,    -20,        -30);
        check("SUB",  ALU_SUB,         10,     20,        -10);
        check("SUB",  ALU_SUB,        -10,    -20,         10);
        check("SLT",  ALU_SLT,         10,     20,          1);
        check("SLT",  ALU_SLT,        -10,     20,          1);
        check("SLT",  ALU_SLT,         10,    -20,          0);
        check("SLT",  ALU_SLT,         10,     10,          0);
        check("SLT",  ALU_SLT,        -10,    -10,          0);
        check("SLT",  ALU_SLT,        -10,    -20,          0);
        check("SLTU", ALU_SLTU,        10,     20,          1);
        check("SLTU", ALU_SLTU,       -10,     20,          0);
        check("SLTU", ALU_SLTU,        10,    -20,          1);
        check("SLTU", ALU_SLTU,        10,     10,          0);
        check("SLTU", ALU_SLTU,       -10,    -10,          0);
        check("SLTU", ALU_SLTU,       -10,    -20,          0);
        check("XOR",  ALU_XOR,     'b0011, 'b0101,     'b0110);
        check("OR",   ALU_OR,      'b0011, 'b0101,     'b0111);
        check("AND",  ALU_AND,     'b0011, 'b0101,     'b0001);
        check("SLL",  ALU_SLL,    'h12345,     12, 'h12345000);
        check("SRA",  ALU_SRA,    'h12345,     12,       'h12);
        check("SRA",  ALU_SRA, 'hF0005432,     12, 'hFFFF0005);
        check("SRL",  ALU_SRL,    'h12345,     12,       'h12);
        check("SRL",  ALU_SRL, 'hF0005432,     12, 'h000F0005);
        $display("[DONE] ArithLogicUnit_tb");
    end
endmodule

