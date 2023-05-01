//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Verdicode
    import Vermitypes_pkg::*,
           Vermicodes_pkg::*;
(
    input  word_t        data,
    output instruction_t instr
);

    funct7_t         funct7; // Funct7 field of the instruction word.
    register_index_t rs2;    // Source register index for operand 2.
    register_index_t rs1;    // Source register index for operand 1.
    funct3_t         funct3; // Funct3 field of the instruction word.
    register_index_t rd;     // Destination register index.
    base_opcode_t    opcode; // Base opcode of the instruction.
    signed_word_t    imm;    // Decoded immediate value.
    alu_fn_t         alu_fn; // Decoded ALU operation.

    assign funct7 = data[31:25];
    assign rs2    = data[24:20];
    assign rs1    = data[19:15];
    assign funct3 = data[14:12];
    assign rd     = data[11: 7];
    assign opcode = data[ 6: 0];

    always_comb begin
        case (opcode)
            OPCODE_OP                : imm = 0;
            OPCODE_STORE             : imm = signed_word_t'(signed'({funct7, rd}));
            OPCODE_BRANCH            : imm = signed_word_t'(signed'({data[31], data[7], data[30:25], data[11:8], 1'b0}));
            OPCODE_LUI, OPCODE_AUIPC : imm = signed_word_t'(signed'({funct7, rs2, rs1, funct3, 12'b0}));
            OPCODE_JAL               : imm = signed_word_t'(signed'({data[31], rs1, funct3, data[20], data[30:21], 1'b0}));
            default                  : imm = signed_word_t'(signed'({funct7, rs2}));
        endcase
    end

    always_comb begin
        case (opcode)
            OPCODE_LUI               : alu_fn = ALU_NOP;
            OPCODE_OP, OPCODE_OP_IMM : begin
                case (funct3)
                    FUNCT3_SLT       : alu_fn = ALU_SLT;
                    FUNCT3_SLTU      : alu_fn = ALU_SLTU;
                    FUNCT3_AND       : alu_fn = ALU_AND;
                    FUNCT3_OR        : alu_fn = ALU_OR;
                    FUNCT3_XOR       : alu_fn = ALU_XOR;
                    FUNCT3_SLL       : alu_fn = ALU_SLL;
                    FUNCT3_SRL_SRA   : alu_fn = (funct7 == FUNCT7_SUB_SRA)
                                                    ? ALU_SRA
                                                    : ALU_SRL;
                    FUNCT3_ADD_SUB   : alu_fn = (opcode == OPCODE_OP && funct7 == FUNCT7_SUB_SRA)
                                                    ? ALU_SUB
                                                    : ALU_ADD;
                    default          : alu_fn = ALU_ADD;
                endcase
            end
            default                  : alu_fn = ALU_ADD;
        endcase
    end

    assign instr = '{
        rd        : rd,
        rs1       : rs1,
        rs2       : rs2,
        imm       : imm,
        funct3    : funct3,
        alu_fn    : alu_fn,
        use_pc    : opcode == OPCODE_AUIPC || opcode == OPCODE_JAL || opcode == OPCODE_BRANCH,
        use_imm   : opcode != OPCODE_OP,
        has_rd    : !(opcode == OPCODE_BRANCH || opcode == OPCODE_STORE || rd == 0),
        is_load   : opcode == OPCODE_LOAD,
        is_store  : opcode == OPCODE_STORE,
        is_jump   : opcode == OPCODE_JAL || opcode == OPCODE_JALR,
        is_branch : opcode == OPCODE_BRANCH,
        is_mret   : opcode == OPCODE_SYSTEM && funct3 == FUNCT3_DEFAULT && imm == IMM_MRET,
        is_trap   : opcode == OPCODE_SYSTEM && funct3 == FUNCT3_DEFAULT && (imm == IMM_ECALL || imm == IMM_EBREAK)
    };
endmodule
