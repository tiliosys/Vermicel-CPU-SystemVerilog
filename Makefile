
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

RTL = \
	common/Types_pkg \
	common/Bus \
	core/Opcodes_pkg \
	core/Decoder \
	core/ArithLogicUnit \
	core/Comparator \
	core/RegisterUnit \
	core/BranchUnit \
	core/LoadStoreUnit \
	core/Vermicel_pkg \
	core/Vermicel \
	devices/SinglePortRAM \
	devices/Timer_pkg \
	devices/Timer \
	devices/UART_pkg \
	devices/UART \
	example/VermicelDemo

TOP = VermicelDemo

TESTS ?= \
	Decoder_tb \
	ArithLogicUnit_tb \
	Comparator_tb \
	RegisterUnit_tb \
	Vermicel_tb \
	rv32ui_tb \
	UART_tb

RTL_SRC   = $(addsuffix .sv,$(RTL))
TESTS_SRC = $(addprefix tests/,$(addsuffix .sv,$(TESTS)))
TESTS_BIN = $(addprefix obj_dir/,$(TESTS))

run-tests: tests/rv32ui/tests.mem $(TESTS_BIN)
	for f in $(TESTS_BIN); do $$f; done | tee tests.log
	@echo "--"
	@echo "Total PASS: " $$(egrep "PASS|OK"    tests.log | wc -l)
	@echo "Total FAIL: " $$(egrep "FAIL|ERROR" tests.log | wc -l)
	@echo "--"

tests/rv32ui/tests.mem:
	$(MAKE) -C $(@D) $(@F)

obj_dir/%: $(RTL_SRC) tests/%.sv
	verilator -sv --binary --timing --trace -Wno-lint --top-module $* -o $* $^

lint: $(RTL_SRC)
	verilator -sv --lint-only --timing -Wall --top-module $(TOP) lint.vlt $^

clean:
	rm -rf obj_dir tests.log *.vcd vivado* .Xil
	$(MAKE) -C tests/rv32ui clean

