
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import types_pkg::*;
import opcodes_pkg::*;
import virgule_pkg::*;

module virgule (
    input bit clk,
    input bit reset,
    bus_if.m  bus
);

    //
    // Sequencer
    //

    typedef enum {fetch, decode, execute, load, store, writeback} state_t;

    state_t state_reg;
    instruction_t instr; // From decoding stage

    always_ff @(posedge clk) begin
        if (reset) begin
            state_reg <= fetch;
        end
        else begin
            case (state_reg)
                fetch     : if (bus.ready)      state_reg <= decode;
                decode    :                     state_reg <= execute;
                execute   : if (instr.is_load)  state_reg <= load;
                       else if (instr.is_store) state_reg <= store;
                       else if (instr.has_rd)   state_reg <= writeback;
                       else                     state_reg <= fetch;
                load      : if (bus.ready)      state_reg <= writeback;
                store     : if (bus.ready)      state_reg <= fetch;
                default   :                     state_reg <= fetch;
            endcase
        end
    end

    bit fetch_en     = state_reg == fetch;
    bit decode_en    = state_reg == decode;
    bit execute_en   = state_reg == execute;
    bit load_en      = state_reg == load;
    bit store_en     = state_reg == store;
    bit writeback_en = state_reg == writeback;

    // 
    //  Instruction decoding:
    //  decode, read registers, select ALU operands.
    // 

    word_t rdata_reg; // From memory access stage

    decoder dec (
        .data(rdata_reg),
        .instr(instr)
    );

    instruction_t instr_reg;
    word_t        xd; // From writeback stage
    word_t        xs1;
    word_t        xs2;

    register_unit #(
        .size(register_unit_size)
    ) regs (
        .clk(clk),
        .reset(reset),
        .enable(writeback_en),
        .src_instr(instr),
        .dest_instr(instr_reg),
        .xd(xd),
        .xs1(xs1),
        .xs2(xs2)
    );

    word_t pc_reg; // From execution stage
    word_t xs1_reg;
    word_t xs2_reg;
    word_t alu_a_reg;
    word_t alu_b_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            instr_reg <= instr_nop;
            xs1_reg   <= 0;
            xs2_reg   <= 0;
            alu_a_reg <= 0;
            alu_b_reg <= 0;
        end
        else if (decode_en) begin
            instr_reg <= instr;
            xs1_reg   <= xs1;
            xs2_reg   <= xs2;
            alu_a_reg <= instr.use_pc  ? pc_reg    : xs1;
            alu_b_reg <= instr.use_imm ? instr.imm : xs2;
        end
    end

    //
    // Instruction execution:
    // compute ALU and comparator results, compute branch address,
    // update program counter.
    //

    word_t alu_r;

    arith_logic_unit alu (
        .instr(instr_reg),
        .a(alu_a_reg),
        .b(alu_b_reg),
        .r(alu_r)
    );

    word_t pc_next;
    word_t pc_incr = pc_reg + 4;

    branch_unit #(
        .irq_address(irq_address)
    ) branch (
        .clk(clk),
        .reset(reset),
        .enable(execute_en),
        .irq(bus.irq),
        .instr(instr_reg),
        .xs1(xs1_reg),
        .xs2(xs2_reg),
        .address(alu_r),
        .pc_incr(pc_incr),
        .pc_next(pc_next)
    );

    word_t pc_incr_reg;
    word_t alu_r_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            alu_r_reg   <= 0;
            pc_reg      <= 0;
            pc_incr_reg <= 0;
        end
        else if (execute_en) begin
            alu_r_reg   <= alu_r;
            pc_reg      <= pc_next;
            pc_incr_reg <= pc_incr;
        end
    end

    //
    // Memory access:
    // align data to/from memory, drive control outputs.
    //

    always_ff @(posedge clk) begin
        if (reset) begin
            rdata_reg <= 0;
        end
        else if (bus.valid && bus.ready) begin
            rdata_reg <= bus.rdata;
        end
    end

    word_t load_data;

    load_store_unit ld_st (
        .instr(instr_reg),
        .address(alu_r_reg),
        .store_enable(store_en),
        .store_data(xs2_reg),
        .load_data(load_data),
        .rdata(rdata_reg),
        .wstrobe(bus.wstrobe),
        .wdata(bus.wdata)
    );

    assign bus.valid   = fetch_en || load_en || store_en;
    assign bus.address = fetch_en ? pc_reg : alu_r_reg;

    //
    // Write back
    //

    assign xd = instr_reg.is_load ? load_data :
                instr_reg.is_jump ? pc_incr_reg     :
                                    alu_r_reg;
endmodule


