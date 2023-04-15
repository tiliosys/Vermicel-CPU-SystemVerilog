
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import types_pkg::*;
import opcodes_pkg::*;

module decoder_tb;

    word_t        dec_data;
    instruction_t dec_instr;

    decoder dec (
        .data(dec_data),
        .instr(dec_instr)
    );

    typedef bit[4:0] field_ignore_t;
    localparam field_ignore_t ignore_rd     = 'b10000;
    localparam field_ignore_t ignore_rs1    = 'b01000;
    localparam field_ignore_t ignore_rs2    = 'b00100;
    localparam field_ignore_t ignore_imm    = 'b00010;
    localparam field_ignore_t ignore_funct3 = 'b00001;

    task check(string label, word_t data, instruction_t instr, field_ignore_t ignore);
        dec_data = data;

        #1;

        if (|(ignore & ignore_rd)) begin
            instr.rd = dec_instr.rd;
        end
        if (|(ignore & ignore_rs1)) begin
            instr.rs1 = dec_instr.rs1;
        end
        if (|(ignore & ignore_rs2)) begin
            instr.rs2 = dec_instr.rs2;
        end
        if (|(ignore & ignore_imm)) begin
            instr.imm = dec_instr.imm;
        end
        if (|(ignore & ignore_funct3)) begin
            instr.funct3 = dec_instr.funct3;
        end

        if (dec_instr == instr) begin
            $display("[PASS] %s", label);
        end
        else begin
            $display("[FAIL] %s : result=%08h expected=%08h", label, dec_instr, instr);
        end
    endtask

    initial begin
        $display("[TEST] decoder_tb");
        //                                                           rd  rs1 rs2 imm         funct3          alu_fn    use_pc use_imm has_rd is_load is_store is_jump is_branch is_mret
        // Test rd, rs1, rs2 for R-type instruction.
        check("ADD x0,  x0,  x0",       asm_add(0,  0,  0),        '{0,  0,  0,  0,          funct3_add_sub, alu_add,  0,     0,      0,     0,      0,       0,      0,        0}, ignore_imm);
        check("ADD x5,  x10, x15",      asm_add(5,  10, 15),       '{5,  10, 15, 0,          funct3_add_sub, alu_add,  0,     0,      1,     0,      0,       0,      0,        0}, ignore_imm);
        check("ADD x31, x31, x31",      asm_add(31, 31, 31),       '{31, 31, 31, 0,          funct3_add_sub, alu_add,  0,     0,      1,     0,      0,       0,      0,        0}, ignore_imm);
        // Test imm for I-type instruction (12 bits)
        check("ADDI x5, x10, 0",        asm_addi(5, 10, 0),        '{5,  10, 0,  0,          funct3_add_sub, alu_add,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rs2);
        check("ADDI x5, x10, 0x07ff",   asm_addi(5, 10, 'h07ff),   '{5,  10, 0,  32'h07ff,   funct3_add_sub, alu_add,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rs2);
        check("ADDI x5, x10, 0x0800",   asm_addi(5, 10, 'h0800),   '{5,  10, 0,  -32'h0800,  funct3_add_sub, alu_add,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rs2);
        check("ADDI x5, x10, 0x0fff",   asm_addi(5, 10, 'h0fff),   '{5,  10, 0,  -32'h0001,  funct3_add_sub, alu_add,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rs2);
        // Test imm for S-type instruction (12 bits)
        check("SW x5, x10, 0",          asm_sw(5, 10, 0),          '{0,  10, 5,  0,          funct3_lw_sw,   alu_add,  0,     1,      0,     0,      1,       0,      0,        0}, ignore_rd);
        check("SW x5, x10, 0x07ff",     asm_sw(5, 10, 'h07ff),     '{0,  10, 5,  32'h07ff,   funct3_lw_sw,   alu_add,  0,     1,      0,     0,      1,       0,      0,        0}, ignore_rd);
        check("SW x5, x10, 0x0800",     asm_sw(5, 10, 'h0800),     '{0,  10, 5,  -32'h0800,  funct3_lw_sw,   alu_add,  0,     1,      0,     0,      1,       0,      0,        0}, ignore_rd);
        check("SW x5, x10, 0x0fff",     asm_sw(5, 10, 'h0fff),     '{0,  10, 5,  -32'h0001,  funct3_lw_sw,   alu_add,  0,     1,      0,     0,      1,       0,      0,        0}, ignore_rd);
        // Test imm for B-type instruction (13 bits, always even)
        check("BEQ x5, x10, 0",         asm_beq(5, 10, 0),         '{0,  5,  10, 0,          funct3_beq,     alu_add,  1,     1,      0,     0,      0,       0,      1,        0}, ignore_rd);
        check("BEQ x5, x10, 0x0fff",    asm_beq(5, 10, 'h0fff),    '{0,  5,  10, 32'h0ffe,   funct3_beq,     alu_add,  1,     1,      0,     0,      0,       0,      1,        0}, ignore_rd);
        check("BEQ x5, x10, 0x1000",    asm_beq(5, 10, 'h1000),    '{0,  5,  10, -32'h1000,  funct3_beq,     alu_add,  1,     1,      0,     0,      0,       0,      1,        0}, ignore_rd);
        check("BEQ x5, x10, 0x1fff",    asm_beq(5, 10, 'h1fff),    '{0,  5,  10, -32'h0002,  funct3_beq,     alu_add,  1,     1,      0,     0,      0,       0,      1,        0}, ignore_rd);
        // Test imm for U-type instruction (32 bits, always a multiple of 'h1000)
        check("LUI x5, 0x0000",         asm_lui(5, 'h0000),        '{5,  0,  0,  0,          0,              alu_nop,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rs1|ignore_rs2|ignore_funct3);
        check("LUI x5, 0x0fff",         asm_lui(5, 'h0fff),        '{5,  0,  0,  0,          0,              alu_nop,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rs1|ignore_rs2|ignore_funct3);
        check("LUI x5, 0x1fff",         asm_lui(5, 'h1fff),        '{5,  0,  0,  32'h1000,   0,              alu_nop,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rs1|ignore_rs2|ignore_funct3);
        check("LUI x5, 0xffff",         asm_lui(5, 'hffff),        '{5,  0,  0,  32'hf000,   0,              alu_nop,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rs1|ignore_rs2|ignore_funct3);
        check("LUI x5, -1",             asm_lui(5, -1),            '{5,  0,  0,  -32'h1000,  0,              alu_nop,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rs1|ignore_rs2|ignore_funct3);
        // Test imm for J-type instruction (21 bits, even)
        check("JAL x5, x0",             asm_jal(5, 0),             '{5,  0,  0,         0,   0,              alu_add,  1,     1,      1,     0,      0,       1,      0,        0}, ignore_rs1|ignore_rs2|ignore_funct3);
        check("JAL x5, 0xfffff",        asm_jal(5, 'hfffff),       '{5,  0,  0, 32'hffffe,   0,              alu_add,  1,     1,      1,     0,      0,       1,      0,        0}, ignore_rs1|ignore_rs2|ignore_funct3);
        check("JAL x5, 0x100000",       asm_jal(5, 'h100000),      '{5,  0,  0, -32'h100000, 0,              alu_add,  1,     1,      1,     0,      0,       1,      0,        0}, ignore_rs1|ignore_rs2|ignore_funct3);
        check("JAL x5, 0x1fffff",       asm_jal(5, 'h1fffff),      '{5,  0,  0, -32'h000002, 0,              alu_add,  1,     1,      1,     0,      0,       1,      0,        0}, ignore_rs1|ignore_rs2|ignore_funct3);
        // Test functions for all instruction types.
        check("LUI x0, 0x1234",         asm_lui(0, 'h1234),        '{0,  0,  0, 0,           0,              alu_nop,  0,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm|ignore_funct3);
        check("LUI x31, 0x1234",        asm_lui(31, 'h1234),       '{0,  0,  0, 0,           0,              alu_nop,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm|ignore_funct3);
        check("AUIPC x0, 0x1234",       asm_auipc(0, 'h1234),      '{0,  0,  0, 0,           0,              alu_add,  1,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm|ignore_funct3);
        check("AUIPC x31, 0x1234",      asm_auipc(31, 'h1234),     '{0,  0,  0, 0,           0,              alu_add,  1,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm|ignore_funct3);
        check("JAL x0, 0x1234",         asm_jal(0, 'h1234),        '{0,  0,  0, 0,           0,              alu_add,  1,     1,      0,     0,      0,       1,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm|ignore_funct3);
        check("JAL x31, 0x1234",        asm_jal(31, 'h1234),       '{0,  0,  0, 0,           0,              alu_add,  1,     1,      1,     0,      0,       1,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm|ignore_funct3);
        check("JALR x0, x15, 0x1234",   asm_jalr(0, 15, 'h1234),   '{0,  0,  0, 0,           funct3_jalr,    alu_add,  0,     1,      0,     0,      0,       1,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("JALR x31, x15, 0x1234",  asm_jalr(31, 15, 'h1234),  '{0,  0,  0, 0,           funct3_jalr,    alu_add,  0,     1,      1,     0,      0,       1,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("BEQ x5, x10, 0x1234",    asm_beq(5, 10, 'h1234),    '{0,  0,  0, 0,           funct3_beq,     alu_add,  1,     1,      0,     0,      0,       0,      1,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("BNE x5, x10, 0x1234",    asm_bne(5, 10, 'h1234),    '{0,  0,  0, 0,           funct3_bne,     alu_add,  1,     1,      0,     0,      0,       0,      1,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("BLT x5, x10, 0x1234",    asm_blt(5, 10, 'h1234),    '{0,  0,  0, 0,           funct3_blt,     alu_add,  1,     1,      0,     0,      0,       0,      1,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("BGE x5, x10, 0x1234",    asm_bge(5, 10, 'h1234),    '{0,  0,  0, 0,           funct3_bge,     alu_add,  1,     1,      0,     0,      0,       0,      1,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("BLTU x5, x10, 0x1234",   asm_bltu(5, 10, 'h1234),   '{0,  0,  0, 0,           funct3_bltu,    alu_add,  1,     1,      0,     0,      0,       0,      1,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("BGEU x5, x10, 0x1234",   asm_bgeu(5, 10, 'h1234),   '{0,  0,  0, 0,           funct3_bgeu,    alu_add,  1,     1,      0,     0,      0,       0,      1,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("LB x0, x15, 0x1234",     asm_lb(0, 15, 'h1234),     '{0,  0,  0, 0,           funct3_lb_sb,   alu_add,  0,     1,      0,     1,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("LB x31, x15, 0x1234",    asm_lb(31, 15, 'h1234),    '{0,  0,  0, 0,           funct3_lb_sb,   alu_add,  0,     1,      1,     1,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("LH x0, x15, 0x1234",     asm_lh(0, 15, 'h1234),     '{0,  0,  0, 0,           funct3_lh_sh,   alu_add,  0,     1,      0,     1,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("LH x31, x15, 0x1234",    asm_lh(31, 15, 'h1234),    '{0,  0,  0, 0,           funct3_lh_sh,   alu_add,  0,     1,      1,     1,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("LW x0, x15, 0x1234",     asm_lw(0, 15, 'h1234),     '{0,  0,  0, 0,           funct3_lw_sw,   alu_add,  0,     1,      0,     1,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("LW x31, x15, 0x1234",    asm_lw(31, 15, 'h1234),    '{0,  0,  0, 0,           funct3_lw_sw,   alu_add,  0,     1,      1,     1,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("LBU x0, x15, 0x1234",    asm_lbu(0, 15, 'h1234),    '{0,  0,  0, 0,           funct3_lbu,     alu_add,  0,     1,      0,     1,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("LBU x31, x15, 0x1234",   asm_lbu(31, 15, 'h1234),   '{0,  0,  0, 0,           funct3_lbu,     alu_add,  0,     1,      1,     1,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("LHU x0, x15, 0x1234",    asm_lhu(0, 15, 'h1234),    '{0,  0,  0, 0,           funct3_lhu,     alu_add,  0,     1,      0,     1,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("LHU x31, x15, 0x1234",   asm_lhu(31, 15, 'h1234),   '{0,  0,  0, 0,           funct3_lhu,     alu_add,  0,     1,      1,     1,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SB x5, x15, 0x1234",     asm_sb(5, 15, 'h1234),     '{0,  0,  0, 0,           funct3_lb_sb,   alu_add,  0,     1,      0,     0,      1,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SH x5, x15, 0x1234",     asm_sh(5, 15, 'h1234),     '{0,  0,  0, 0,           funct3_lh_sh,   alu_add,  0,     1,      0,     0,      1,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SW x5, x15, 0x1234",     asm_sw(5, 15, 'h1234),     '{0,  0,  0, 0,           funct3_lw_sw,   alu_add,  0,     1,      0,     0,      1,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("ADDI x0, x10, 0x1234",   asm_addi(0, 10, 'h1234),   '{0,  0,  0, 0,           funct3_add_sub, alu_add,  0,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("ADDI x31, x10, 0x1234",  asm_addi(31, 10, 'h1234),  '{0,  0,  0, 0,           funct3_add_sub, alu_add,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLLI x0, x10, 0x1234",   asm_slli(0, 10, 'h1234),   '{0,  0,  0, 0,           funct3_sll,     alu_sll,  0,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLLI x31, x10, 0x1234",  asm_slli(31, 10, 'h1234),  '{0,  0,  0, 0,           funct3_sll,     alu_sll,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLTI x0, x10, 0x1234",   asm_slti(0, 10, 'h1234),   '{0,  0,  0, 0,           funct3_slt,     alu_slt,  0,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLTI x31, x10, 0x1234",  asm_slti(31, 10, 'h1234),  '{0,  0,  0, 0,           funct3_slt,     alu_slt,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLTIU x0, x10, 0x1234",  asm_sltiu(0, 10, 'h1234),  '{0,  0,  0, 0,           funct3_sltu,    alu_sltu, 0,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLTIU x31, x10, 0x1234", asm_sltiu(31, 10, 'h1234), '{0,  0,  0, 0,           funct3_sltu,    alu_sltu, 0,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("XORI x0, x10, 0x1234",   asm_xori(0, 10, 'h1234),   '{0,  0,  0, 0,           funct3_xor,     alu_xor,  0,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("XORI x31, x10, 0x1234",  asm_xori(31, 10, 'h1234),  '{0,  0,  0, 0,           funct3_xor,     alu_xor,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SRLI x0, x10, 0x1234",   asm_srli(0, 10, 'h1234),   '{0,  0,  0, 0,           funct3_srl_sra, alu_srl,  0,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SRLI x31, x10, 0x1234",  asm_srli(31, 10, 'h1234),  '{0,  0,  0, 0,           funct3_srl_sra, alu_srl,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SRAI x0, x10, 0x1234",   asm_srai(0, 10, 'h1234),   '{0,  0,  0, 0,           funct3_srl_sra, alu_sra,  0,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SRAI x31, x10, 0x1234",  asm_srai(31, 10, 'h1234),  '{0,  0,  0, 0,           funct3_srl_sra, alu_sra,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("ORI x0, x10, 0x1234",    asm_ori(0, 10, 'h1234),    '{0,  0,  0, 0,           funct3_or,      alu_or,   0,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("ORI x31, x10, 0x1234",   asm_ori(31, 10, 'h1234),   '{0,  0,  0, 0,           funct3_or,      alu_or,   0,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("ANDI x0, x10, 0x1234",   asm_andi(0, 10, 'h1234),   '{0,  0,  0, 0,           funct3_and,     alu_and,  0,     1,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("ANDI x31, x10, 0x1234",  asm_andi(31, 10, 'h1234),  '{0,  0,  0, 0,           funct3_and,     alu_and,  0,     1,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("ADD x0, x5, x10",        asm_add(0, 5, 10),         '{0,  0,  0, 0,           funct3_add_sub, alu_add,  0,     0,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("ADD x31, x5, x10",       asm_add(31, 5, 10),        '{0,  0,  0, 0,           funct3_add_sub, alu_add,  0,     0,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SUB x0, x5, 10",         asm_sub(0, 5, 10),         '{0,  0,  0, 0,           funct3_add_sub, alu_sub,  0,     0,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SUB x31, x5, 10",        asm_sub(31, 5, 10),        '{0,  0,  0, 0,           funct3_add_sub, alu_sub,  0,     0,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLL x0, x5, 10",         asm_sll(0, 5, 10),         '{0,  0,  0, 0,           funct3_sll,     alu_sll,  0,     0,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLL x31, x5, 10",        asm_sll(31, 5, 10),        '{0,  0,  0, 0,           funct3_sll,     alu_sll,  0,     0,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLT x0, x5, 10",         asm_slt(0, 5, 10),         '{0,  0,  0, 0,           funct3_slt,     alu_slt,  0,     0,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLT x31, x5, 10",        asm_slt(31, 5, 10),        '{0,  0,  0, 0,           funct3_slt,     alu_slt,  0,     0,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLTU x0, x5, 10",        asm_sltu(0, 5, 10),        '{0,  0,  0, 0,           funct3_sltu,    alu_sltu, 0,     0,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SLTU x31, x5, 10",       asm_sltu(31, 5, 10),       '{0,  0,  0, 0,           funct3_sltu,    alu_sltu, 0,     0,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("XOR x0, x5, 10",         asm_xor(0, 5, 10),         '{0,  0,  0, 0,           funct3_xor,     alu_xor,  0,     0,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("XOR x31, x5, 10",        asm_xor(31, 5, 10),        '{0,  0,  0, 0,           funct3_xor,     alu_xor,  0,     0,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SRL x0, x5, 10",         asm_srl(0, 5, 10),         '{0,  0,  0, 0,           funct3_srl_sra, alu_srl,  0,     0,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SRL x31, x5, 10",        asm_srl(31, 5, 10),        '{0,  0,  0, 0,           funct3_srl_sra, alu_srl,  0,     0,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SRA x0, x5, 10",         asm_sra(0, 5, 10),         '{0,  0,  0, 0,           funct3_srl_sra, alu_sra,  0,     0,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("SRA x31, x5, 10",        asm_sra(31, 5, 10),        '{0,  0,  0, 0,           funct3_srl_sra, alu_sra,  0,     0,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("OR x0, x5, 10",          asm_or(0, 5, 10),          '{0,  0,  0, 0,           funct3_or,      alu_or,   0,     0,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("OR x31, x5, 10",         asm_or(31, 5, 10),         '{0,  0,  0, 0,           funct3_or,      alu_or,   0,     0,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("AND x0, x5, 10",         asm_and(0, 5, 10),         '{0,  0,  0, 0,           funct3_and,     alu_and,  0,     0,      0,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        check("AND x31, x5, 10",        asm_and(31, 5, 10),        '{0,  0,  0, 0,           funct3_and,     alu_and,  0,     0,      1,     0,      0,       0,      0,        0}, ignore_rd|ignore_rs1|ignore_rs2|ignore_imm);
        //                                                           rd  rs1 rs2 imm         funct3          alu_fn    use_pc use_imm has_rd is_load is_store is_jump is_branch is_mret
        $display("[DONE] decoder_tb");
    end
endmodule
