
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import types_pkg::*;
import opcodes_pkg::*;

module branch_unit #(
    parameter word_t irq_address
) (
    input  bit           clk,
    input  bit           reset,
    input  bit           enable,
    input  bit           irq,
    input  instruction_t instr,
    input  word_t        xs1,
    input  word_t        xs2,
    input  word_t        address,
    input  word_t        pc_next,
    output word_t        pc
);

    bit cmp_taken;

    comparator cmp_inst (
        .instr(instr),
        .a(xs1),
        .b(xs2),
        .taken(cmp_taken)
    ); 

    word_t mepc;

    word_t pc_target =
        instr.is_mret                                   ? mepc                  :
        instr.is_jump || (instr.is_branch && cmp_taken) ? {address[31:2], 2'b0} :
                                                          pc_next;

    bit irq_state;

    always @(posedge clk) begin
        if (reset) begin
            irq_state <= 0;
        end
        else if (enable) begin
            if (instr.is_mret) begin
                irq_state <= 0;
            end
            else if (irq) begin
                irq_state <= 1;
            end
        end
    end

    bit accept_irq = irq && !irq_state;

    always @(posedge clk) begin
        if (reset) begin
            mepc <= 0;
        end
        else if (enable && accept_irq) begin
            mepc <= pc_target;
        end
    end

    assign pc = accept_irq ? irq_address : pc_target;
endmodule
