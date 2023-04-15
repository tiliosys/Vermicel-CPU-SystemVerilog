
import opcodes_pkg::*;

module decoder_tb;

    decoder decoder_inst (
        .data(decoder_data),
        .instr(decoder_instr)
    );

    function static void check(string label, instruction_t instr);
        assert (decoder_instr == instr) begin
            $info(label);
        end
        else begin
            $error(label);
        end
    endfunction

    initial begin
        decoder_data = add(0, 0, 0); #1;
        check("ADD x0, x0, x0", '{0, 0, 0, 0, funct3_add_sub, alu_add, 0, 0, 0, 0, 0, 0, 0, 0});
    end
endmodule
