
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

package Opcodes_pkg;

    import Types_pkg::*;

    // Base opcodes.
    typedef bit[6:0] base_opcode_t;
    localparam base_opcode_t OPCODE_LOAD   = 'b0000011;
    localparam base_opcode_t OPCODE_OP_IMM = 'b0010011;
    localparam base_opcode_t OPCODE_AUIPC  = 'b0010111;
    localparam base_opcode_t OPCODE_STORE  = 'b0100011;
    localparam base_opcode_t OPCODE_OP     = 'b0110011;
    localparam base_opcode_t OPCODE_LUI    = 'b0110111;
    localparam base_opcode_t OPCODE_BRANCH = 'b1100011;
    localparam base_opcode_t OPCODE_JALR   = 'b1100111;
    localparam base_opcode_t OPCODE_JAL    = 'b1101111;
    localparam base_opcode_t OPCODE_SYSTEM = 'b1110011;

    // funct3 opcodes.
    typedef bit[2:0] funct3_t;
    localparam funct3_t FUNCT3_JALR    = 'b000;
    localparam funct3_t FUNCT3_BEQ     = 'b000;
    localparam funct3_t FUNCT3_BNE     = 'b001;
    localparam funct3_t FUNCT3_BLT     = 'b100;
    localparam funct3_t FUNCT3_BGE     = 'b101;
    localparam funct3_t FUNCT3_BLTU    = 'b110;
    localparam funct3_t FUNCT3_BGEU    = 'b111;
    localparam funct3_t FUNCT3_LB_SB   = 'b000;
    localparam funct3_t FUNCT3_LH_SH   = 'b001;
    localparam funct3_t FUNCT3_LW_SW   = 'b010;
    localparam funct3_t FUNCT3_LBU     = 'b100;
    localparam funct3_t FUNCT3_LHU     = 'b101;
    localparam funct3_t FUNCT3_ADD_SUB = 'b000;
    localparam funct3_t FUNCT3_SLT     = 'b010;
    localparam funct3_t FUNCT3_SLTU    = 'b011;
    localparam funct3_t FUNCT3_XOR     = 'b100;
    localparam funct3_t FUNCT3_OR      = 'b110;
    localparam funct3_t FUNCT3_AND     = 'b111;
    localparam funct3_t FUNCT3_SLL     = 'b001;
    localparam funct3_t FUNCT3_SRL_SRA = 'b101;
    localparam funct3_t FUNCT3_DEFAULT = 'b000;

    // funct7 opcodes.
    typedef bit[6:0] funct7_t;
    localparam funct7_t FUNCT7_DEFAULT = 'b0000000;
    localparam funct7_t FUNCT7_SUB_SRA = 'b0100000;

    // Immediate_encoded opcodes.
    localparam signed_word_t IMM_MRET   = 'b001100000010;
    localparam signed_word_t IMM_ECALL  = 'b000000000000;
    localparam signed_word_t IMM_EBREAK = 'b000000000001;

    // Post-decoding instruction representation.
    typedef bit[4:0] register_index_t;

    typedef enum {
        ALU_NOP, ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU,
        ALU_AND, ALU_OR, ALU_XOR, ALU_SLL, ALU_SRL, ALU_SRA
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
        bit              is_trap;
    } instruction_t;

    localparam instruction_t INSTR_NOP = '{
        rd        : 0,
        rs1       : 0,
        rs2       : 0,
        imm       : 0,
        funct3    : FUNCT3_ADD_SUB,
        alu_fn    : ALU_NOP,
        use_pc    : 0,
        use_imm   : 0,
        has_rd    : 0,
        is_load   : 0,
        is_store  : 0,
        is_jump   : 0,
        is_branch : 0,
        is_mret   : 0,
        is_trap   : 0
    };

    function static word_t encode(
            base_opcode_t opcode, funct3_t funct3,
            register_index_t rd, register_index_t rs1, register_index_t rs2,
            word_t imm, funct7_t funct7
    );
        if (opcode == OPCODE_OP_IMM && (funct3 == FUNCT3_SLL || funct3 == FUNCT3_SRL_SRA)) begin
            imm = signed_word_t'({funct7, imm[4:0]});
        end
        case (opcode)
            //                      31        | 30       | 24 | 20     | 19 | 14    | 11               | 6    0
            OPCODE_OP     : return {funct7               , rs2         , rs1, funct3, rd               , opcode}; // R
            OPCODE_STORE  : return {imm[11:5]            , rs2         , rs1, funct3, imm[4:0]         , opcode}; // S
            OPCODE_BRANCH : return {imm[12]   , imm[10:5], rs2         , rs1, funct3, imm[4:1], imm[11], opcode}; // B
            OPCODE_LUI,
            OPCODE_AUIPC  : return {imm[31:12]                                      , rd               , opcode}; // U
            OPCODE_JAL    : return {imm[20]   , imm[10:1]     , imm[11], imm[19:12] , rd               , opcode}; // J
            default       : return {imm[11:0]                          , rs1, funct3, rd               , opcode}; // I
        endcase
    endfunction

    function static word_t asm_lui(register_index_t rd, word_t imm);
         return encode(OPCODE_LUI, FUNCT3_DEFAULT, rd, 0, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_auipc(register_index_t rd, word_t imm);
         return encode(OPCODE_AUIPC, FUNCT3_DEFAULT, rd, 0, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_jal(register_index_t rd, word_t offset);
         return encode(OPCODE_JAL, FUNCT3_DEFAULT, rd, 0, 0, offset, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_jalr(register_index_t rd, register_index_t rs1, word_t offset);
         return encode(OPCODE_JALR, FUNCT3_JALR, rd, rs1, 0, offset, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_beq(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(OPCODE_BRANCH, FUNCT3_BEQ, 0, rs1, rs2, offset, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_bne(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(OPCODE_BRANCH, FUNCT3_BNE, 0, rs1, rs2, offset, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_blt(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(OPCODE_BRANCH, FUNCT3_BLT, 0, rs1, rs2, offset, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_bge(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(OPCODE_BRANCH, FUNCT3_BGE, 0, rs1, rs2, offset, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_bltu(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(OPCODE_BRANCH, FUNCT3_BLTU, 0, rs1, rs2, offset, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_bgeu(register_index_t rs1, register_index_t rs2, word_t offset);
         return encode(OPCODE_BRANCH, FUNCT3_BGEU, 0, rs1, rs2, offset, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_lb(register_index_t rd,  register_index_t rs1, word_t imm);
         return encode(OPCODE_LOAD, FUNCT3_LB_SB, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_lh(register_index_t rd,  register_index_t rs1, word_t imm);
         return encode(OPCODE_LOAD, FUNCT3_LH_SH, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_lw(register_index_t rd,  register_index_t rs1, word_t imm);
         return encode(OPCODE_LOAD, FUNCT3_LW_SW, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_lbu(register_index_t rd,  register_index_t rs1, word_t imm);
         return encode(OPCODE_LOAD, FUNCT3_LBU, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_lhu(register_index_t rd,  register_index_t rs1, word_t imm);
         return encode(OPCODE_LOAD, FUNCT3_LHU, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_sb(register_index_t rs2, register_index_t rs1, word_t imm);
         return encode(OPCODE_STORE, FUNCT3_LB_SB, 0, rs1, rs2, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_sh(register_index_t rs2, register_index_t rs1, word_t imm);
         return encode(OPCODE_STORE, FUNCT3_LH_SH, 0, rs1, rs2, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_sw(register_index_t rs2, register_index_t rs1, word_t imm);
         return encode(OPCODE_STORE, FUNCT3_LW_SW, 0, rs1, rs2, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_addi(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(OPCODE_OP_IMM, FUNCT3_ADD_SUB, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_slli(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(OPCODE_OP_IMM, FUNCT3_SLL, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_slti(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(OPCODE_OP_IMM, FUNCT3_SLT, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_sltiu(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(OPCODE_OP_IMM, FUNCT3_SLTU, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_xori(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(OPCODE_OP_IMM, FUNCT3_XOR, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_srli(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(OPCODE_OP_IMM, FUNCT3_SRL_SRA, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_srai(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(OPCODE_OP_IMM, FUNCT3_SRL_SRA, rd, rs1, 0, imm, FUNCT7_SUB_SRA);
    endfunction

    function static word_t asm_ori(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(OPCODE_OP_IMM, FUNCT3_OR, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_andi(register_index_t rd, register_index_t rs1, word_t imm);
         return encode(OPCODE_OP_IMM, FUNCT3_AND, rd, rs1, 0, imm, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_add(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(OPCODE_OP, FUNCT3_ADD_SUB, rd, rs1, rs2, 0, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_sub(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(OPCODE_OP, FUNCT3_ADD_SUB, rd, rs1, rs2, 0, FUNCT7_SUB_SRA);
    endfunction

    function static word_t asm_sll(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(OPCODE_OP, FUNCT3_SLL, rd, rs1, rs2, 0, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_slt(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(OPCODE_OP, FUNCT3_SLT, rd, rs1, rs2, 0, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_sltu(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(OPCODE_OP, FUNCT3_SLTU, rd, rs1, rs2, 0, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_xor(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(OPCODE_OP, FUNCT3_XOR, rd, rs1, rs2, 0, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_srl(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(OPCODE_OP, FUNCT3_SRL_SRA, rd, rs1, rs2, 0, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_sra(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(OPCODE_OP, FUNCT3_SRL_SRA, rd, rs1, rs2, 0, FUNCT7_SUB_SRA);
    endfunction

    function static word_t asm_or(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(OPCODE_OP, FUNCT3_OR, rd, rs1, rs2, 0, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_and(register_index_t rd, register_index_t rs1, register_index_t rs2);
         return encode(OPCODE_OP, FUNCT3_AND, rd, rs1, rs2, 0, FUNCT7_DEFAULT);
    endfunction

    function static word_t asm_mret();
         return encode(OPCODE_SYSTEM, FUNCT3_DEFAULT, 0, 0, 0, IMM_MRET, FUNCT7_DEFAULT);
    endfunction
endpackage
