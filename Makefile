
RTL=$(addprefix rtl/,\
	virgule_pkg.sv \
	opcodes_pkg.sv \
	bus.sv \
	decoder.sv \
)

TESTS=$(addprefix obj_dir/,\
	decoder_tb \
)

run: $(TESTS)
	for f in $(TESTS); do $$f; done

obj_dir/%: $(RTL) tests/%.sv
	verilator --binary --timing -o $* $^

clean:
	rm -rf obj_dir
