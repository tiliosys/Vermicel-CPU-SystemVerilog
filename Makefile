
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

RTL=$(addprefix rtl/,\
	virgule_pkg.sv \
	opcodes_pkg.sv \
	bus.sv \
	decoder.sv \
	arith_logic_unit.sv \
)

TESTS=$(addprefix obj_dir/,\
	decoder_tb \
	arith_logic_unit_tb \
)

run: $(TESTS)
	for f in $(TESTS); do $$f; done

obj_dir/%: $(RTL) tests/%.sv
	verilator -sv --binary --timing --top-module $* -o $* $^

clean:
	rm -rf obj_dir
