#
# SPDX-License-Identifier: CERN-OHL-W-2.0
# SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
#

VERMICEL=..

include $(VERMICEL)/sources.mk

SRC = $(addprefix $(VERMICEL)/,$(RTL))

TESTS ?= $(basename $(wildcard *_tb.sv))
TESTS_BIN = $(addprefix obj_dir/,$(TESTS))

DEPS = rv32ui/tests.mem

all: $(TESTS_BIN)
	for f in $(TESTS_BIN); do $$f; done | tee tests.log
	@echo "--"
	@echo "Total PASS: " $$(egrep "PASS|OK"    tests.log | wc -l)
	@echo "Total FAIL: " $$(egrep "FAIL|ERROR" tests.log | wc -l)
	@echo "--"

obj_dir/%: $(SRC) %.sv
	verilator -sv --binary --timing --trace -Wno-lint --top-module $* -o $* $^

obj_dir/Vermicel_tb: | rv32ui/tests.mem

rv32ui/tests.mem:
	$(MAKE) -C rv32ui $(notdir $@)

include ../scripts/rules.mk

clean:
	rm -rf obj_dir
	$(MAKE) -C rv32ui clean

