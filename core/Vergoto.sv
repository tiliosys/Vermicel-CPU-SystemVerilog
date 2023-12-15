//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

// Vermicel branch unit.
//
// The main role of this module is to determine the next value of the program
// counter. This value depends of the following elements:
// - Whether the current instruction affects the program counter (jump, branch, mret or trap).
// - The detection of an interrupt request.
//
// This module manages the exception state of the processor, including the
// saved program counter register (MEPC).
// It does not contain the program counter register itself.
module Vergoto
    import Verdata_pkg::*,
           Veropcodes_pkg::*,
           Vermicel_pkg::*;
(
    input  bit           clk,      // The clock signal.
    input  bit           reset,    // The active-high reset signal.
    input  bit           enable,   // Enables updating the state of this module.
    input  bit           irq,      // The interrupt request signal.
    input  instruction_t instr,    // The current decoded instruction fields.
    input  word_t        xs1,      // The value of the first source register of the current instruction.
    input  word_t        xs2,      // The value of the second source register of the current instruction.
    input  word_t        address,  // The address where to jump, if applicable.
    input  word_t        pc_incr,  // The instruction address after the current program counter.
    output word_t        pc_next,  // The new value of the program counter.
    output bit           will_jump // Indicates that the program counter will jump to a new location (different from pc_incr)
);

    bit    taken;                  // Is the current instruction a taken conditional branch?
    word_t pc_target;              // The next program counter as a result of executing the current instruction (i.e. excluding exceptions).
    bit    except_state_reg;       // Are we currently handling an exception?
    bit    accept_irq;             // Are we switching to the exception state due to an IRQ?
    word_t mepc_reg;               // The aaved program counter when switching to the exception state.

    Vercompare cmp (
        .instr(instr),
        .a(xs1),
        .b(xs2),
        .taken(taken)
    ); 

    assign pc_target = instr.is_mret          ? mepc_reg                  
                     : instr.is_jump || taken ? {address[31:2], 2'b0}
                     :                          pc_incr;

    // Enter the exception state when detecting an IRQ or executing a trap instruction.
    // Exit the exception state when executing the MRET instruction.
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            except_state_reg <= 0;
        end
        else if (enable) begin
            if (instr.is_mret) begin
                except_state_reg <= 0;
            end
            else if (irq || instr.is_trap) begin
                except_state_reg <= 1;
            end
        end
    end

    assign accept_irq = irq && !except_state_reg;

    // Save the next program counter when switching to the exception state.
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            mepc_reg <= 0;
        end
        else if (enable && (accept_irq || instr.is_trap)) begin
            mepc_reg <= pc_target;
        end
    end

    // Compute the actual next program counter, taking exceptions into account.
    assign pc_next = accept_irq    ? IRQ_ADDRESS
                   : instr.is_trap ? TRAP_ADDRESS
                   :                 pc_target;

    // We could detect a jump using this simple comparison
    // but it creates longer combinational paths and can lead
    // to timing violations.
    //
    // assign will_jump = pc_next != pc_incr;

    // This is a simpler solution, but not equivalent.
    // For instance, this ignores the situations where
    // is_jump is true and pc_next == pc_incr.
    assign will_jump = instr.is_mret || instr.is_jump || taken
                    || accept_irq || instr.is_trap;
endmodule
