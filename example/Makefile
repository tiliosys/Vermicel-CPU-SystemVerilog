#
# SPDX-License-Identifier: CERN-OHL-W-2.0
# SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
#

VERMICEL = ..

TOP = Vermichello

include $(VERMICEL)/sources.mk

SRC = \
	$(addprefix $(VERMICEL)/,$(RTL)) \
    $(TOP).mem \
    $(TOP).sv

BOARDS ?= \
	Basys3 \
	ArtyA7

BITSTREAMS = $(addsuffix .bit,$(addprefix vivado/$(TOP)-,$(BOARDS)))

all: $(BITSTREAMS)

.PRECIOUS: $(TOP).mem

vivado/$(TOP)-%.bit: $(SRC) $(TOP)-%.xdc
	vivado -mode batch -source run-vivado.tcl -tclargs $*
	cp vivado/$(TOP)-$*/$(TOP)-$*.runs/impl_1/$(TOP).bit $@

C_FLAGS_USER=-Os
LD_SCRIPT=$(TOP).ld

include $(VERMICEL)/scripts/rules.mk

clean::
	rm -rf vivado $(TOP).mem
