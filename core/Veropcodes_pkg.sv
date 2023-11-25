//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

package Veropcodes_pkg;

    import Verdata_pkg::*;

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

    // The standard NOP instruction word (ADDI x0, x0, 0)
    localparam word_t WORD_NOP = {17'b0, FUNCT3_ADD_SUB, 5'b0, OPCODE_OP_IMM};

    /* ---------------------------------------------------------------------- *
     * Post-decoding instruction representation.
     * ---------------------------------------------------------------------- */

    // Register index field.
    typedef bit[4:0] register_index_t;

    // The available arithmetic and logic operations.
    typedef enum {
        ALU_NOP, ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU,
        ALU_AND, ALU_OR, ALU_XOR, ALU_SLL, ALU_SRL, ALU_SRA
    } alu_fn_t;

    // Decoded instruction fields.
    typedef struct packed { // [Verilator 5.005] supports only packed structs
        register_index_t rd;        // The destination register index.
        register_index_t rs1;       // The first source register index.
        register_index_t rs2;       // The second source register index.
        signed_word_t    imm;       // The immediate operand.
        funct3_t         funct3;    // The funct3 opcode.
        alu_fn_t         alu_fn;    // The arithmetic or logic operation to execute.
        bit              use_pc;    // Does this instruction read the program counter?
        bit              use_imm;   // Does this instruction have an immediate operand?
        bit              has_rd;    // Does this instruction write to a general-purpose register?
        bit              is_load;   // Is this instruction a load?
        bit              is_store;  // Is this instruction a store?
        bit              is_jump;   // Is this instruction a jump?
        bit              is_branch; // Is this instruction a conditional branch?
        bit              is_mret;   // Is this instruction an exception return?
        bit              is_trap;   // Is this instruction a trap?
    } instruction_t;

    // The standard NOP instruction fields (ADDI x0, x0, 0).
    localparam instruction_t INSTR_NOP = '{
        funct3  : FUNCT3_ADD_SUB,
        alu_fn  : ALU_ADD,
        use_imm : 1,
        default : 0
    };

endpackage
