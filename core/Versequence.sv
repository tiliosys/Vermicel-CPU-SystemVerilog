//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Versequence (
    Verbus.read_write_request bus
);

    import Verdata_pkg::*;
    import Veropcodes_pkg::*;
    import Vermicel_pkg::*;

    typedef enum {FETCH, DECODE, EXECUTE, LOAD, STORE, WRITEBACK} state_t;

    state_t       state_reg;    // The state of the sequencer
    bit           fetch_en;     // Are we fetching an instruction?
    bit           decode_en;    // Are we decoding an instruction?
    bit           execute_en;   // Are we executing an instruction?
    bit           load_en;      // Are we loading data from memory?
    bit           store_en;     // Are we storing data to memory?
    bit           writeback_en; // Are we writing results to a register?
    instruction_t instr;        // The decoded instruction.
    instruction_t instr_reg;    // Decoded instruction register.
    word_t        rdata_reg;    // Read data bus register.
    word_t        xs1;          // Source register value for operand 1.
    word_t        xs1_reg;      // Source register value for operand 1, registered.
    word_t        xs2;          // Source register value for operand 2.
    word_t        xs2_reg;      // Source register value for operand 2, registered.
    word_t        xd;           // Destination register value.
    word_t        pc_next;      // Next program counter, according to branch unit.
    word_t        pc_reg;       // Program counter register.
    word_t        pc_incr;      // Address of next instruction in sequence.
    word_t        pc_incr_reg;  // Address of next instruction in sequence, registered.
    word_t        alu_a_reg;    // ALU operand A, registered.
    word_t        alu_b_reg;    // ALU operand B, registered.
    word_t        alu_r;        // ALU result.
    word_t        alu_r_reg;    // ALU result, registered
    word_t        load_data;    // Data from load operation, re-aligned.

    /* ------------------------------------------------------------------------- *
     * Sequencer
     * ------------------------------------------------------------------------- */

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            state_reg <= FETCH;
        end
        else begin
            case (state_reg)
                FETCH     : if (bus.ready)          state_reg <= DECODE;
                DECODE    :                         state_reg <= EXECUTE;
                EXECUTE   : if (instr_reg.is_load)  state_reg <= LOAD;
                       else if (instr_reg.is_store) state_reg <= STORE;
                       else if (instr_reg.has_rd)   state_reg <= WRITEBACK;
                       else                         state_reg <= FETCH;
                LOAD      : if (bus.ready)          state_reg <= WRITEBACK;
                STORE     : if (bus.ready)          state_reg <= FETCH;
                default   :                         state_reg <= FETCH;
            endcase
        end
    end

    assign fetch_en     = state_reg == FETCH;
    assign decode_en    = state_reg == DECODE;
    assign execute_en   = state_reg == EXECUTE;
    assign load_en      = state_reg == LOAD;
    assign store_en     = state_reg == STORE;
    assign writeback_en = state_reg == WRITEBACK;

    /* ------------------------------------------------------------------------- *
     *  Instruction decoding:
     *  decode, read registers, select ALU operands.
     * ------------------------------------------------------------------------- */

    Verdecode dec (
        .data(rdata_reg),
        .instr(instr)
    );

    Vergister #(
        .SIZE(REGISTER_UNIT_SIZE)
    ) regs (
        .clk(bus.clk),
        .reset(bus.reset),
        .src_instr(instr),
        .xs1(xs1),
        .xs2(xs2),
        .enable(writeback_en),
        .dest_instr(instr_reg),
        .xd(xd)
    );

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            instr_reg <= INSTR_NOP;
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

    /* ------------------------------------------------------------------------- *
     * Instruction execution:
     * compute ALU and comparator results, compute branch address,
     * update program counter.
     * ------------------------------------------------------------------------- */

    Verithmetic alu (
        .instr(instr_reg),
        .a(alu_a_reg),
        .b(alu_b_reg),
        .r(alu_r)
    );

    assign pc_incr = pc_reg + 4;

    Vergoto #(
        .IRQ_ADDRESS(IRQ_ADDRESS),
        .TRAP_ADDRESS(TRAP_ADDRESS)
    ) branch (
        .clk(bus.clk),
        .reset(bus.reset),
        .enable(execute_en),
        .irq(bus.irq),
        .instr(instr_reg),
        .xs1(xs1_reg),
        .xs2(xs2_reg),
        .address(alu_r),
        .pc_incr(pc_incr),
        .pc_next(pc_next)
    );

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
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

    /* ------------------------------------------------------------------------- *
     * Memory access:
     * align data to/from memory, drive control outputs.
     * ------------------------------------------------------------------------- */

    assign bus.valid   = fetch_en || load_en || store_en;
    assign bus.address = fetch_en ? pc_reg : alu_r_reg;

    always_ff @(posedge bus.clk) begin
        if (bus.reset) begin
            rdata_reg <= WORD_NOP;
        end
        else if (bus.valid && bus.ready) begin
            rdata_reg <= bus.rdata;
        end
    end

    Veralign ld_st (
        .instr(instr_reg),
        .address(alu_r_reg),
        .store_enable(store_en),
        .store_data(xs2_reg),
        .load_data(load_data),
        .rdata(rdata_reg),
        .wstrobe(bus.wstrobe),
        .wdata(bus.wdata)
    );

    /* ------------------------------------------------------------------------- *
     * Write back
     * ------------------------------------------------------------------------- */

    assign xd = instr_reg.is_load ? load_data
              : instr_reg.is_jump ? pc_incr_reg
              :                     alu_r_reg;
endmodule


