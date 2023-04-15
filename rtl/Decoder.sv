
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

module Decoder
    import Types_pkg::*,
           Opcodes_pkg::*;
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
            opcode_op                : imm = 0;
            opcode_store             : imm = signed_word_t'(signed'({funct7, rd}));
            opcode_branch            : imm = signed_word_t'(signed'({data[31], data[7], data[30:25], data[11:8], 1'b0}));
            opcode_lui, opcode_auipc : imm = signed_word_t'(signed'({funct7, rs2, rs1, funct3, 12'b0}));
            opcode_jal               : imm = signed_word_t'(signed'({data[31], rs1, funct3, data[20], data[30:21], 1'b0}));
            default                  : imm = signed_word_t'(signed'({funct7, rs2}));
        endcase
    end

    always_comb begin
        case (opcode)
            opcode_lui               : alu_fn = alu_nop;
            opcode_op, opcode_op_imm : begin
                case (funct3)
                    funct3_slt       : alu_fn = alu_slt;
                    funct3_sltu      : alu_fn = alu_sltu;
                    funct3_and       : alu_fn = alu_and;
                    funct3_or        : alu_fn = alu_or;
                    funct3_xor       : alu_fn = alu_xor;
                    funct3_sll       : alu_fn = alu_sll;
                    funct3_srl_sra   : alu_fn = (funct7 == funct7_sub_sra)
                                                    ? alu_sra
                                                    : alu_srl;
                    funct3_add_sub   : alu_fn = (opcode == opcode_op && funct7 == funct7_sub_sra)
                                                    ? alu_sub
                                                    : alu_add;
                    default          : alu_fn = alu_add;
                endcase
            end
            default                  : alu_fn = alu_add;
        endcase
    end

    assign instr = '{
        rd        : rd,
        rs1       : rs1,
        rs2       : rs2,
        imm       : imm,
        funct3    : funct3,
        alu_fn    : alu_fn,
        use_pc    : opcode == opcode_auipc || opcode == opcode_jal || opcode == opcode_branch,
        use_imm   : opcode != opcode_op,
        is_load   : opcode == opcode_load,
        is_store  : opcode == opcode_store,
        is_mret   : opcode == opcode_system && funct3 == funct3_mret && imm == imm_mret,
        is_jump   : opcode == opcode_jal || opcode == opcode_jalr,
        is_branch : opcode == opcode_branch,
        has_rd    : !(opcode == opcode_branch || opcode == opcode_store || rd == 0)
    };
endmodule