
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

RTL=\
	Types_pkg \
	Opcodes_pkg \
	Bus \
	Decoder \
	ArithLogicUnit \
	Comparator \
	RegisterUnit \
	BranchUnit \
	LoadStoreUnit \
	Virgule_pkg \
	Virgule

TESTS=\
	Decoder_tb \
	ArithLogicUnit_tb \
	Comparator_tb \
	RegisterUnit_tb \

RTL_SRC=$(addprefix rtl/,$(addsuffix .sv,$(RTL)))
TESTS_SRC=$(addprefix tests/,$(addsuffix .sv,$(TESTS)))
TESTS_BIN=$(addprefix obj_dir/,$(TESTS))

run: $(TESTS_BIN)
	for f in $^; do $$f; done

obj_dir/%: $(RTL_SRC) tests/%.sv
	verilator -sv --binary --timing -Wno-lint --top-module $* -o $* $^

lint: $(RTL_SRC)
	verilator -sv --lint-only --timing -Wall --top-module $(lastword $(RTL)) lint.vlt $^

clean:
	rm -rf obj_dir
