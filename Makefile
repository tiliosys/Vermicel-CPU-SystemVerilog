
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

RTL=\
	types_pkg \
	opcodes_pkg \
	bus \
	decoder \
	arith_logic_unit \
	comparator \
	register_unit \
	branch_unit \
	virgule_pkg

TESTS=\
	decoder_tb \
	arith_logic_unit_tb \
	comparator_tb \
	register_unit_tb \

RTL_SRC=$(addprefix rtl/,$(addsuffix .sv,$(RTL)))
TESTS_SRC=$(addprefix tests/,$(addsuffix .sv,$(TESTS)))
TESTS_BIN=$(addprefix obj_dir/,$(TESTS))

run: $(TESTS_BIN)
	for f in $^; do $$f; done

obj_dir/%: $(RTL_SRC) tests/%.sv
	verilator -sv --binary --timing -Wno-lint --top-module $* -o $* $^

lint: $(RTL_SRC)
	verilator -sv --lint-only --timing -Wall $^

clean:
	rm -rf obj_dir
