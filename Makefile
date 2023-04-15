
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
	Virgule \
	SinglePortRAM

TESTS?=\
	Decoder_tb \
	ArithLogicUnit_tb \
	Comparator_tb \
	RegisterUnit_tb \
	Virgule_tb \
	rv32ui_tb

RTL_SRC=$(addprefix rtl/,$(addsuffix .sv,$(RTL)))
TESTS_SRC=$(addprefix tests/,$(addsuffix .sv,$(TESTS)))
TESTS_BIN=$(addprefix obj_dir/,$(TESTS))

run: tests/rv32ui/tests.txt $(TESTS_BIN)
	for f in $^; do $$f; done | tee tests.log
	@echo "--"
	@echo "Total PASS: " $$(grep PASS tests.log | wc -l)
	@echo "Total FAIL: " $$(grep FAIL tests.log | wc -l)
	@echo "--"

tests/rv32ui/tests.txt:
	$(MAKE) -C $(@D) $(@F)

obj_dir/%: $(RTL_SRC) tests/%.sv
	verilator -sv --binary --timing -Wno-lint --top-module $* -o $* $^

lint: $(RTL_SRC)
	verilator -sv --lint-only --timing -Wall --top-module $(lastword $(RTL)) lint.vlt $^

clean:
	rm -rf obj_dir
	rm -f tests.log
	$(MAKE) -C tests/rv32ui clean

