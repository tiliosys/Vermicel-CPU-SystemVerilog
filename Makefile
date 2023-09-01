#
# SPDX-License-Identifier: CERN-OHL-W-2.0
# SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
#

include sources.mk

SRC = $(RTL) example/Verdemo.sv
TOP = Verdemo

lint: $(SRC)
	verilator -sv --lint-only --timing -Wall --top-module $(TOP) scripts/lint.vlt $^

clean:
	rm -rf example/.Xil example/vivado.* example/vivado_*

clean_all: clean
	make -C tests clean
	make -C example clean
	make -C benchmarks clean
