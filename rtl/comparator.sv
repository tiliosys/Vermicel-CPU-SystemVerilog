
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import types_pkg::*;
import opcodes_pkg::*;

module comparator (
    input  instruction_t instr,
    input  word_t        a,
    input  word_t        b,
    output bit           taken
);

    always_comb begin
        case (instr.funct3)
            funct3_beq  : taken = a == b;
            funct3_bne  : taken = a != b;
            funct3_blt  : taken = signed'(a) <  signed'(b);
            funct3_bge  : taken = signed'(a) >= signed'(b);
            funct3_bltu : taken = a <  b;
            funct3_bgeu : taken = a >= b;
            default     : taken = 0;
        endcase
    end
endmodule

