//
// SPDX-License-Identifier: CERN-OHL-W-2.0
// SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
//

`default_nettype none

module Vergoto
    import Verdata_pkg::*,
           Veropcodes_pkg::*;
#(
    parameter word_t IRQ_ADDRESS,
    parameter word_t TRAP_ADDRESS
)
(
    input  bit           clk,
    input  bit           reset,
    input  bit           enable,
    input  bit           irq,
    input  instruction_t instr,
    input  word_t        xs1,
    input  word_t        xs2,
    input  word_t        address,
    input  word_t        pc_incr,
    output word_t        pc_next,
    output bit           will_jump
);

    bit    taken;                // Is the branch taken?
    word_t pc_target;            // Target program counter in normal execution flow.
    bit    except_state_reg;     // Are we processing an IRQ?
    bit    accept_irq;           // Are we switching to IRQ mode?
    word_t mepc_reg;         // Saved program counter when switching to IRQ mode.

    Vercompare cmp (
        .instr(instr),
        .a(xs1),
        .b(xs2),
        .taken(taken)
    ); 

    assign pc_target = instr.is_mret          ? mepc_reg                  
                     : instr.is_jump || taken ? {address[31:2], 2'b0}
                     :                          pc_incr;

    always_ff @(posedge clk) begin
        if (reset) begin
            except_state_reg <= 0;
        end
        else if (enable) begin
            if (instr.is_mret) begin
                except_state_reg <= 0;
            end
            else if (irq) begin
                except_state_reg <= 1;
            end
        end
    end

    assign accept_irq = irq && !except_state_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            mepc_reg <= 0;
        end
        else if (enable && (accept_irq || instr.is_trap)) begin
            mepc_reg <= pc_target;
        end
    end

    assign pc_next = accept_irq    ? IRQ_ADDRESS
                   : instr.is_trap ? TRAP_ADDRESS
                   :                 pc_target;

    // We could detect a jump using this simple comparison
    // but it creates longer combinational paths and can lead
    // to timing violations.
    //
    // assign will_jump = pc_next != pc_incr;

    assign will_jump = instr.is_mret || instr.is_jump || taken
                    || accept_irq || instr.is_trap;
endmodule
