#
# SPDX-License-Identifier: CERN-OHL-W-2.0
# SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
#

VERMICEL = ..

include $(VERMICEL)/sources.mk

SRC = \
	$(addprefix $(VERMICEL)/,$(RTL)) \
	Verencode_pkg.sv

TESTS ?= $(basename $(wildcard *_tb.sv))
TESTS_BIN = $(addprefix obj_dir/,$(TESTS))

DEPS = rv32ui/tests.mem

all: $(TESTS_BIN)
	for f in $(TESTS_BIN); do $$f; done | tee tests.log
	@echo "--"
	@echo "Total PASS: " $$(grep -E "PASS|OK"    tests.log | wc -l)
	@echo "Total FAIL: " $$(grep -E "FAIL|ERROR" tests.log | wc -l)
	@echo "--"

obj_dir/%: $(SRC) %.sv
	verilator -sv --binary --timing --trace -Wno-lint --top-module $* -o $* $^

obj_dir/rv32ui_tb: | rv32ui/tests.mem

rv32ui/tests.mem:
	$(MAKE) -C rv32ui $(notdir $@)

include $(VERMICEL)/scripts/rules.mk

clean::
	rm -rf obj_dir *.log *.vcd
	$(MAKE) -C rv32ui clean

