
VERMICEL=..

include $(VERMICEL)/sources.mk

SRC = $(addprefix $(VERMICEL)/,$(RTL))
TOP = Verminacci

all: obj_dir/$(TOP)
	$^

obj_dir/%: $(SRC) %.sv
	verilator -sv --binary --timing --trace -Wno-lint --top-module $* -o $* $^

obj_dir/$(TOP): | $(TOP).mem

LD_SCRIPT = $(TOP).ld

include ../scripts/rules.mk

