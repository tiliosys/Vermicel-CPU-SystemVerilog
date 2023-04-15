
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Variables:
#   C_DEPS: C source files to link with the main program
#	C_FLAGS_USER: additional options for the compiler or the assembler
#	LD_FLAGS_USER: additional options for the linker

MEM_SIZE = 262144

SCRIPTS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
ASM_DIR     := $(SCRIPTS_DIR)/../asm
C_DIR       := $(SCRIPTS_DIR)/../c

PLATFORM := riscv64-unknown-elf
CC       := $(PLATFORM)-gcc
OBJCOPY  := $(PLATFORM)-objcopy

LD_SCRIPT := $(SCRIPTS_DIR)/Vermicel.ld
C_FLAGS    = -march=rv32i -mabi=ilp32 -ffreestanding -I$(C_DIR) -I$(C_DIR)/LibC $(C_FLAGS_USER)
LD_FLAGS   = -nostdlib -T $(LD_SCRIPT) $(LD_FLAGS_USER)

OBJ_STARTUP := $(ASM_DIR)/Startup.o
OBJ_DEPS     = $(C_DEPS:.c=.o) $(ASM_DEPS:.S=.o)

%.elf: %.o $(OBJ_DEPS) $(OBJ_STARTUP) $(LD_SCRIPT)
	$(CC) $(C_FLAGS) $(LD_FLAGS) -o $@ $(OBJ_STARTUP) $(OBJ_DEPS) $<

%.o: %.c
	$(CC) $(C_FLAGS) -c -o $@ $<

%.o: %.S
	$(CC) $(C_FLAGS) -c -o $@ $<

%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@

%.mem: %.hex
	$(OBJCOPY) --reverse-bytes=4 -O verilog --verilog-data-width=4 $< $@

clean:
	rm -f *.o *.hex *.mem *.elf
