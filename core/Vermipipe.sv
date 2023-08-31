//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vermipipe (
    Vermibus.read_only_request ibus,
    Vermibus.read_write_request dbus
);

    import Vermitypes_pkg::*;
    import Vermicodes_pkg::*;
    import Vermicel_pkg::*;

    bit           tick;
    bit           stall;

    bit           ibus_done;
    bit           dbus_done;

    // Fetch stage.
    word_t        fetch_rdata_reg;
    bit           fetch_pending_reg;
    word_t        fetch_pc_reg;
    word_t        fetch_pc_next;

    // Fetch -> Decode registers.
    word_t        decode_rdata_reg;
    word_t        decode_pc_reg;

    // Decode stage.
    instruction_t decode_instr;
    word_t        decode_xs1;
    word_t        decode_xs2;
    word_t        decode_xs1_fwd;
    word_t        decode_xs2_fwd;
    word_t        decode_alu_a;
    word_t        decode_alu_b;

    // Decode -> Execute registers.
    word_t        execute_pc_incr_reg;
    instruction_t execute_instr_reg;
    word_t        execute_alu_a_reg;
    word_t        execute_alu_b_reg;
    word_t        execute_xs1_reg;
    word_t        execute_xs2_reg;

    // Execute stage.
    word_t        execute_alu_r;
    bit           execute_will_jump;
    word_t        execute_pc_next;
    word_t        execute_xd;

    // Execute -> Memory registers.
    instruction_t memory_instr_reg;
    word_t        memory_xs2_reg;
    word_t        memory_alu_r_reg;
    word_t        memory_xd_partial_reg;

    // Memory stage.
    word_t        memory_rdata_reg;
    word_t        memory_rdata;
    bit           memory_pending_reg;
    word_t        memory_load_data;
    word_t        memory_xd;

    // Memory -> Write-back registers.
    instruction_t writeback_instr_reg;
    word_t        writeback_xd_reg;

    // Write-back stage.
    bit           writeback_en;

    /* ------------------------------------------------------------------------- *
     * Pipeline control.
     * ------------------------------------------------------------------------- */

    // The pipeline is updated at each clock edge when tick is set:
    //   * when a new instruction is available, and no data memory access is in progress,
    //   * as soon as a data memory access is complete, if a new instruction is available.
    assign tick = (!ibus.valid || ibus.ready) && (!dbus.valid || dbus.ready);

    // If the instruction in the Decode stage has a data dependency with a load instruction
    // currently in the Execute stage, we will stall the pipeline for one cycle.
    assign stall = execute_instr_reg.has_rd
                && execute_instr_reg.is_load
                && (execute_instr_reg.rd == decode_instr.rs1
                 || execute_instr_reg.rd == decode_instr.rs2);

    /* ------------------------------------------------------------------------- *
     * Fetch stage.
     * ------------------------------------------------------------------------- */

    assign ibus_done = ibus.valid && ibus.ready;

    // Keep a copy of ibus.rdata if a fetch operation completes before the tick.
    always_ff @(posedge ibus.clk) begin
        if (ibus.reset || tick) begin
            fetch_pending_reg <= 0;
        end
        else if (ibus_done) begin
            fetch_pending_reg <= 1;
            fetch_rdata_reg   <= ibus.rdata;
        end
    end

    assign fetch_pc_next  = execute_will_jump ? execute_pc_next
                          : stall             ? fetch_pc_reg
                          :                     fetch_pc_reg + 4;

    always_ff @(posedge ibus.clk) begin
        if (ibus.reset) begin
            fetch_pc_reg <= 0;
        end
        else if (tick) begin
            fetch_pc_reg <= fetch_pc_next;
        end
    end

    assign ibus.valid     = !stall && !fetch_pending_reg;
    assign ibus.address   = fetch_pc_reg;
    assign ibus.lookahead = fetch_pc_next;

    // Fetch -> Decode registers.
    always_ff @(posedge ibus.clk) begin
        if (ibus.reset) begin
            decode_pc_reg    <= 0;
            decode_rdata_reg <= WORD_NOP;
        end
        else if (tick) begin
            if (execute_will_jump) begin
                decode_rdata_reg <= WORD_NOP;
            end
            else if (!stall) begin
                decode_pc_reg    <= fetch_pc_reg;
                decode_rdata_reg <= ibus_done ? ibus.rdata : fetch_rdata_reg;
            end
        end
    end

    /* ------------------------------------------------------------------------- *
     * Decode stage.
     * ------------------------------------------------------------------------- */

    Verdicode dec (
        .data(decode_rdata_reg),
        .instr(decode_instr)
    );

    Vergister #(
        .SIZE(REGISTER_UNIT_SIZE)
    ) regs (
        .clk(ibus.clk),
        .reset(ibus.reset),
        .src_instr(decode_instr),
        .xs1(decode_xs1),
        .xs2(decode_xs2),
        .enable(writeback_en),
        .dest_instr(writeback_instr_reg),
        .xd(writeback_xd_reg)
    );

    // A data dependency is detected when the destination register of a previous
    // instruction that is still in the pipeline is a source register of the
    // instruction in the Decode stage.

    assign decode_xs1_fwd = execute_instr_reg.has_rd   && execute_instr_reg.rd   == decode_instr.rs1 && !execute_instr_reg.is_load ? execute_xd
                          : memory_instr_reg.has_rd    && memory_instr_reg.rd    == decode_instr.rs1                               ? memory_xd
                          : writeback_instr_reg.has_rd && writeback_instr_reg.rd == decode_instr.rs1                               ? writeback_xd_reg
                          :                                                                                                          decode_xs1;

    assign decode_xs2_fwd = execute_instr_reg.has_rd   && execute_instr_reg.rd   == decode_instr.rs2 && !execute_instr_reg.is_load ? execute_xd
                          : memory_instr_reg.has_rd    && memory_instr_reg.rd    == decode_instr.rs2                               ? memory_xd
                          : writeback_instr_reg.has_rd && writeback_instr_reg.rd == decode_instr.rs2                               ? writeback_xd_reg
                          :                                                                                                          decode_xs2;

    assign decode_alu_a = decode_instr.use_pc  ? decode_pc_reg    : decode_xs1_fwd;
    assign decode_alu_b = decode_instr.use_imm ? decode_instr.imm : decode_xs2_fwd;

    // Decode -> Execute registers.
    always_ff @(posedge ibus.clk) begin
        if (ibus.reset) begin
            execute_instr_reg   <= INSTR_NOP;
        end
        else if (tick) begin
            execute_instr_reg   <= execute_will_jump || stall ? INSTR_NOP : decode_instr;
            execute_pc_incr_reg <= decode_pc_reg + 4;
            execute_alu_a_reg   <= decode_alu_a;
            execute_alu_b_reg   <= decode_alu_b;
            execute_xs1_reg     <= decode_xs1_fwd;
            execute_xs2_reg     <= decode_xs2_fwd;
        end
    end

    /* ------------------------------------------------------------------------- *
     * Execute stage.
     * ------------------------------------------------------------------------- */

    Verithmetic alu (
        .instr(execute_instr_reg),
        .a(execute_alu_a_reg),
        .b(execute_alu_b_reg),
        .r(execute_alu_r)
    );

    Vermibranch #(
        .IRQ_ADDRESS(IRQ_ADDRESS),
        .TRAP_ADDRESS(TRAP_ADDRESS)
    ) branch (
        .clk(ibus.clk),
        .reset(ibus.reset),
        .enable(tick),
        .irq(dbus.irq),
        .instr(execute_instr_reg),
        .xs1(execute_xs1_reg),
        .xs2(execute_xs2_reg),
        .address(execute_alu_r),
        .pc_incr(execute_pc_incr_reg),
        .pc_next(execute_pc_next),
        .will_jump(execute_will_jump)
    );

    assign execute_xd = execute_instr_reg.is_jump ? execute_pc_incr_reg : execute_alu_r;

    // Execute -> Memory registers.
    always_ff @(posedge ibus.clk) begin
        if (ibus.reset) begin
            memory_instr_reg <= INSTR_NOP;
        end
        else if (tick) begin
            memory_instr_reg      <= execute_instr_reg;
            memory_xs2_reg        <= execute_xs2_reg;
            memory_alu_r_reg      <= execute_alu_r;
            memory_xd_partial_reg <= execute_xd;
        end
    end

    /* ------------------------------------------------------------------------- *
     * Memory stage.
     * ------------------------------------------------------------------------- */

    assign dbus_done = dbus.valid && dbus.ready;

    // Keep a copy of dbus.rdata if a load operation completes before the tick.
    always_ff @(posedge dbus.clk) begin
        if (dbus.reset || tick) begin
            memory_pending_reg <= 0;
        end
        else if (dbus_done) begin
            memory_pending_reg <= 1;
            memory_rdata_reg   <= dbus.rdata;
        end
    end

    assign memory_rdata = dbus_done ? dbus.rdata : memory_rdata_reg;

    Verdata ld_st (
        .instr(memory_instr_reg),
        .address(memory_alu_r_reg),
        .store_enable(memory_instr_reg.is_store),
        .store_data(memory_xs2_reg),
        .load_data(memory_load_data),
        .rdata(memory_rdata),
        .wstrobe(dbus.wstrobe),
        .wdata(dbus.wdata)
    );

    assign dbus.valid   = (memory_instr_reg.is_load || memory_instr_reg.is_store) && !memory_pending_reg;
    assign dbus.address = memory_alu_r_reg;

    assign memory_xd = memory_instr_reg.is_load ? memory_load_data : memory_xd_partial_reg;

    // Memory -> Write-back registers.
    always_ff @(posedge ibus.clk) begin
        if (ibus.reset) begin
            writeback_instr_reg <= INSTR_NOP;
        end
        else if (tick) begin
            writeback_instr_reg <= memory_instr_reg;
            writeback_xd_reg    <= memory_xd;
        end
    end

    /* ------------------------------------------------------------------------- *
     * Write-back stage.
     * ------------------------------------------------------------------------- */

    assign writeback_en = writeback_instr_reg.has_rd && tick;
endmodule
