
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

VERMICEL=..

include $(VERMICEL)/sources.mk

SRC = \
	$(addprefix $(VERMICEL)/,$(RTL)) \
    Vermichello.mem \
    Vermichello.sv

all: vivado/Vermichello.bit

.PRECIOUS: vivado/Vermichello.xpr Vermichello.mem

vivado/%.xpr: $(SRC) %-project.tcl
	mkdir -p vivado
	vivado -mode batch -source $*-project.tcl
	
vivado/%.bit: vivado/%.xpr %-bitstream.tcl
	vivado -mode batch -source $*-bitstream.tcl
	cp vivado/$*.runs/impl_1/$*.bit $@

LD_SCRIPT=Vermichello.ld

include $(VERMICEL)/scripts/rules.mk

