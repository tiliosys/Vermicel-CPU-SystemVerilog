
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

RTL = \
	common/Types_pkg \
	common/Bus \
	cpu/Opcodes_pkg \
	cpu/Decoder \
	cpu/ArithLogicUnit \
	cpu/Comparator \
	cpu/RegisterUnit \
	cpu/BranchUnit \
	cpu/LoadStoreUnit \
	cpu/Virgule_pkg \
	cpu/Virgule \
	devices/SinglePortRAM \
	devices/Timer_pkg \
	devices/Timer \
	simple-soc/SimpleSoC

TOP = SimpleSoC

TESTS ?= \
	Decoder_tb \
	ArithLogicUnit_tb \
	Comparator_tb \
	RegisterUnit_tb \
	Virgule_tb \
	rv32ui_tb

RTL_SRC   = $(addprefix rtl/,$(addsuffix .sv,$(RTL)))
TESTS_SRC = $(addprefix tests/,$(addsuffix .sv,$(TESTS)))
TESTS_BIN = $(addprefix obj_dir/,$(TESTS))

run-tests: tests/rv32ui/tests.mem $(TESTS_BIN)
	for f in $^; do $$f; done | tee tests.log
	@echo "--"
	@echo "Total PASS: " $$(egrep "PASS|OK"    tests.log | wc -l)
	@echo "Total FAIL: " $$(egrep "FAIL|ERROR" tests.log | wc -l)
	@echo "--"

tests/rv32ui/tests.mem:
	$(MAKE) -C $(@D) $(@F)

obj_dir/%: $(RTL_SRC) tests/%.sv
	verilator -sv --binary --timing -Wno-lint --top-module $* -o $* $^

lint: $(RTL_SRC)
	verilator -sv --lint-only --timing -Wall --top-module $(TOP) lint.vlt $^

clean:
	rm -rf obj_dir
	rm -f tests.log
	$(MAKE) -C tests/rv32ui clean

