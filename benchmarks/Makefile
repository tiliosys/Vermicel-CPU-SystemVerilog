
VERMICEL=..

include $(VERMICEL)/sources.mk

TOP = Vermiperf

SRC = $(addprefix $(VERMICEL)/,$(RTL))
SRC += $(TOP).sv

BENCHMARKS ?= $(basename $(wildcard *.c))
BENCHMARKS_BIN = $(addprefix obj_dir/,$(BENCHMARKS))
BENCHMARKS_MEM = $(addsuffix .mem,$(BENCHMARKS))

LOOKAHEAD ?= 0

.PRECIOUS: $(BENCHMARKS_MEM)

all: $(BENCHMARKS_BIN)
	for f in $(BENCHMARKS_BIN); do $$f; done | tee benchmarks.log

# FIXME: 'make clean' is needed before executing with different LOOKAHEAD
obj_dir/%: $(SRC) %.mem
	verilator -sv --binary --timing --trace -Wno-lint --top-module $(TOP) -GRAM_INIT_FILENAME='"$*.mem"' -GUSE_LOOKAHEAD=$(LOOKAHEAD) -o $* $(SRC)

C_FLAGS_USER=-O2
LD_SCRIPT = $(TOP).ld

include ../scripts/rules.mk

clean:
	rm -rf obj_dir *.mem *.log
