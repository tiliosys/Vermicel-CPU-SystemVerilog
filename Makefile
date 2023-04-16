
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

include sources.mk

SRC = $(RTL) example/Vermichello.sv
TOP = Vermichello

lint: $(SRC)
	verilator -sv --lint-only --timing -Wall --top-module $(TOP) scripts/lint.vlt $^

clean:
	rm -rf example/.Xil example/vivado.* example/vivado_*
