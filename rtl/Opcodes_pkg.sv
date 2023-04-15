
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

package Opcodes_pkg;

    import Types_pkg::*;

    // Base opcodes.
    typedef bit[6:0] base_opcode_t;
    const base_opcode_t opcode_load   = 'b0000011;
    const base_opcode_t opcode_op_imm = 'b0010011;
    const base_opcode_t opcode_auipc  = 'b0010111;
    const base_opcode_t opcode_store  = 'b0100011;
    const base_opcode_t opcode_op     = 'b0110011;
    const base_opcode_t opcode_lui    = 'b0110111;
    const base_opcode_t opcode_branch = 'b1100011;
    const base_opcode_t opcode_jalr   = 'b1100111;
    const base_opcode_t opcode_jal    = 'b1101111;
    const base_opcode_t opcode_system = 'b1110011;

    // funct3 opcodes.
    typedef bit[2:0] funct3_t;
    const funct3_t funct3_jalr    = 'b000;
    const funct3_t funct3_beq     = 'b000;
    const funct3_t funct3_bne     = 'b001;
    const funct3_t funct3_blt     = 'b100;
    const funct3_t funct3_bge     = 'b101;
    const funct3_t funct3_bltu    = 'b110;
    const funct3_t funct3_bgeu    = 'b111;
    const funct3_t funct3_lb_sb   = 'b000;
    const funct3_t funct3_lh_sh   = 'b001;
    const funct3_t funct3_lw_sw   = 'b010;
    const funct3_t funct3_lbu     = 'b100;
    const funct3_t funct3_lhu     = 'b101;
    const funct3_t funct3_add_sub = 'b000;
    const funct3_t funct3_slt     = 'b010;
    const funct3_t funct3_sltu    = 'b011;
    const funct3_t funct3_xor     = 'b100;
    const funct3_t funct3_or      = 'b110;
    const funct3_t funct3_and     = 'b111;
    const funct3_t funct3_sll     = 'b001;
    const funct3_t funct3_srl_sra = 'b101;
    const funct3_t funct3_mret    = 'b000;
    const funct3_t funct3_none    = 'b000;

    // funct7 opcodes.
    typedef bit[6:0] funct7_t;
    const funct7_t funct7_default = 'b0000000;
    const funct7_t funct7_sub_sra = 'b0100000;

    // Immediate_encoded opcodes.
    const signed_word_t imm_mret = 'b001100000010;

    // Post-decoding instruction representation.
    typedef bit[4:0] register_index_t;

    typedef enum {
        alu_nop, alu_add, alu_sub, alu_slt, alu_sltu,
        alu_and, alu_or, alu_xor, alu_sll, alu_srl, alu_sra
    } alu_fn_t;

    typedef struct packed { // [Verilator 5.005] supports only packed structs
        register_index_t rd;
        register_index_t rs1;
        register_index_t rs2;
        signed_word_t    imm;
        funct3_t         funct3;
        alu_fn_t         alu_fn;
        bit              use_pc;
        bit              use_imm;
        bit              has_rd;
        bit              is_load;
        bit              is_store;
        bit              is_jump;
        bit              is_branch;
        bit              is_mret;
    } instruction_t;

    const instruction_t instr_nop = '{
        rd        : 0,
        rs1       : 0,
        rs2       : 0,
        imm       : 0,
        funct3    : funct3_add_sub,
        alu_fn    : alu_nop,
        use_pc    : 0,
        use_imm   : 0,
        has_rd    : 0,
        is_load   : 0,
        is_store  : 0,
        is_jump   : 0,
        is_branch : 0,
        is_mret   : 0
    };

    function static word_t encode(
            base_opcode_t opcode, funct3_t funct3,
            register_index_t rd, register_index_t rs1, register_index_t rs2,
            word_t imm, funct7_t funct7
    );
        if (opcode == opcode_op_imm && (funct3 == funct3_sll || funct3 == funct3_srl_sra)) begin
            imm = signed_word_t'({funct7, imm[4:0]});
        end
        case (opcode)
            //                      31        | 30       | 24 | 20     | 19 | 14    | 11               | 6    0
            opcode_op     : return {funct7               , rs2         , rs1, funct3, rd               , opcode}; // R
            opcode_store  : return {imm[11:5]            , rs2         , rs1, funct3, imm[4:0]         , opcode}; // S
            opcode_branch : return {imm[12]   , imm[10:5], rs2         , rs1, funct3, imm[4:1], imm[11], opcode}; // B
            opcode_lui,
            opcode_auipc  : return {imm[31:12]                                      , rd               , opcode}; // U
            opcode_jal    : return {imm[20]   , imm[10:1]     , imm[11], imm[19:12] , rd               , opcode}; // J
            default       : return {imm[11:0]                          , rs1, funct3, rd               , opcode}; // I
        endcase
    endfunction

    function static word_t asm_lui(register_index_t rd, word_t imm);
         return encode(opcode_lui, funct3_none, rd, 0, 0, imm, funct7_default);
    endfunction

    function static word_t asm_auipc(register_index_t rd, word_t imm);
         return encode(opcode_auipc, funct3_none, rd, 0, 0, imm, funct7_default);
    endfunction

    function static word_t asm_jal(register_index_t rd, word_t offset);
         return encode(opcode_jal, funct3_none, rd, 0, 0, offset, funct7_default);
    endfunction

    function static word_t asm_jalr(register_index_t rd, register_index_t rs1, word_t offset);
         return encode(opcode_jalr, funct3_jalr, rd, rs1, 0, offset, funct7_default);
    endfunction

    function static word_t asm_beq(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(opcode_branch, funct3_beq, 0, rs1, rs2, offset, funct7_default);
    endfunction

    function static word_t asm_bne(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(opcode_branch, funct3_bne, 0, rs1, rs2, offset, funct7_default);
    endfunction

    function static word_t asm_blt(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(opcode_branch, funct3_blt, 0, rs1, rs2, offset, funct7_default);
    endfunction

    function static word_t asm_bge(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(opcode_branch, funct3_bge, 0, rs1, rs2, offset, funct7_default);
    endfunction

    function static word_t asm_bltu(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(opcode_branch, funct3_bltu, 0, rs1, rs2, offset, funct7_default);
    endfunction

    function static word_t asm_bgeu(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(opcode_branch, funct3_bgeu, 0, rs1, rs2, offset, funct7_default);
    endfunction

    function static word_t asm_lb(register_index_t rd,  register_index_t rs1, word_t imm);
         return encode(opcode_load, funct3_lb_sb, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_lh(register_index_t rd,  register_index_t rs1, word_t imm);
         return encode(opcode_load, funct3_lh_sh, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_lw(register_index_t rd,  register_index_t rs1, word_t imm);
         return encode(opcode_load, funct3_lw_sw, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_lbu(register_index_t rd,  register_index_t rs1, word_t imm);
         return encode(opcode_load, funct3_lbu, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_lhu(register_index_t rd,  register_index_t rs1, word_t imm);
         return encode(opcode_load, funct3_lhu, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_sb(register_index_t rs2, register_index_t rs1, word_t imm);
         return encode(opcode_store, funct3_lb_sb, 0, rs1, rs2, imm, funct7_default);
    endfunction

    function static word_t asm_sh(register_index_t rs2, register_index_t rs1, word_t imm);
         return encode(opcode_store, funct3_lh_sh, 0, rs1, rs2, imm, funct7_default);
    endfunction

    function static word_t asm_sw(register_index_t rs2, register_index_t rs1, word_t imm);
         return encode(opcode_store, funct3_lw_sw, 0, rs1, rs2, imm, funct7_default);
    endfunction

    function static word_t asm_addi(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(opcode_op_imm, funct3_add_sub, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_slli(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(opcode_op_imm, funct3_sll, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_slti(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(opcode_op_imm, funct3_slt, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_sltiu(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(opcode_op_imm, funct3_sltu, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_xori(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(opcode_op_imm, funct3_xor, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_srli(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(opcode_op_imm, funct3_srl_sra, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_srai(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(opcode_op_imm, funct3_srl_sra, rd, rs1, 0, imm, funct7_sub_sra);
    endfunction

    function static word_t asm_ori(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(opcode_op_imm, funct3_or, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_andi(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(opcode_op_imm, funct3_and, rd, rs1, 0, imm, funct7_default);
    endfunction

    function static word_t asm_add(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(opcode_op, funct3_add_sub, rd, rs1, rs2, 0, funct7_default);
    endfunction

    function static word_t asm_sub(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(opcode_op, funct3_add_sub, rd, rs1, rs2, 0, funct7_sub_sra);
    endfunction

    function static word_t asm_sll(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(opcode_op, funct3_sll, rd, rs1, rs2, 0, funct7_default);
    endfunction

    function static word_t asm_slt(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(opcode_op, funct3_slt, rd, rs1, rs2, 0, funct7_default);
    endfunction

    function static word_t asm_sltu(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(opcode_op, funct3_sltu, rd, rs1, rs2, 0, funct7_default);
    endfunction

    function static word_t asm_xor(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(opcode_op, funct3_xor, rd, rs1, rs2, 0, funct7_default);
    endfunction

    function static word_t asm_srl(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(opcode_op, funct3_srl_sra, rd, rs1, rs2, 0, funct7_default);
    endfunction

    function static word_t asm_sra(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(opcode_op, funct3_srl_sra, rd, rs1, rs2, 0, funct7_sub_sra);
    endfunction

    function static word_t asm_or(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(opcode_op, funct3_or, rd, rs1, rs2, 0, funct7_default);
    endfunction

    function static word_t asm_and(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(opcode_op, funct3_and, rd, rs1, rs2, 0, funct7_default);
    endfunction

    function static word_t asm_mret();
         return encode(opcode_system, funct3_mret, 0, 0, 0, imm_mret, funct7_default);
    endfunction
endpackage
