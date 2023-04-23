
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

`default_nettype none

module Vermibranch
    import Vermitypes_pkg::*,
           Vermicodes_pkg::*;
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
    output word_t        pc_next
);

    bit    taken;            // Is the branch taken?
    word_t pc_target;        // Target program counter in normal execution flow.
    bit    except_state_reg; // Are we processing an IRQ?
    bit    accept_irq;       // Are we switching to IRQ mode?
    word_t mepc_reg;         // Saved program counter when switching to IRQ mode.

    Vermipare cmp (
        .instr(instr),
        .a(xs1),
        .b(xs2),
        .taken(taken)
    ); 

    assign pc_target =
        instr.is_mret                               ? mepc_reg                  :
        instr.is_jump || (instr.is_branch && taken) ? {address[31:2], 2'b0} :
                                                      pc_incr;

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

    assign pc_next =
        accept_irq    ? IRQ_ADDRESS  :
        instr.is_trap ? TRAP_ADDRESS :
                        pc_target;
endmodule
