
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

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

vivado/$(TOP)-%.bit: $(SRC) %/$(TOP).xdc
	vivado -mode batch -source $*/run-vivado.tcl
	cp vivado/$(TOP)-$*/$(TOP)-$*.runs/impl_1/$(TOP).bit $@

LD_SCRIPT=$(TOP).ld

include $(VERMICEL)/scripts/rules.mk

