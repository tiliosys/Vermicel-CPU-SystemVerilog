
import opcodes_pkg::*;

module decoder_tb;

    word_t decoder_data;
    instruction_t decoder_instr;

    decoder decoder_inst (
        .data(decoder_data),
        .instr(decoder_instr)
    );

    task check(string label, word_t data, instruction_t instr);
        decoder_data = data;
        #1;
        if (decoder_instr == instr) begin
            $display("[PASS] ", label);
        end
        else begin
            $display("[FAIL] ", label);
        end
    endtask

    initial begin
        $display("[TEST] decoder_tb");
        check("ADD x0, x0, x0", asm_add(0, 0, 0), '{0, 0, 0, 0, funct3_add_sub, alu_add, 0, 0, 0, 0, 0, 0, 0, 0});
        $display("[DONE] decoder_tb");
    end
endmodule
