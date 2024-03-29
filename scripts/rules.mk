#
# SPDX-License-Identifier: CERN-OHL-W-2.0
# SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
#

# Variables:
#   C_DEPS: C source files to link with the main program
#	C_FLAGS_USER: additional options for the compiler or the assembler
#	LD_FLAGS_USER: additional options for the linker
#   LD_SCRIPT: the linker script to use

SCRIPTS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
ASM_DIR     := $(SCRIPTS_DIR)/../asm
C_DIR       := $(SCRIPTS_DIR)/../c

PLATFORM := riscv64-unknown-elf
CC       := $(PLATFORM)-gcc
OBJCOPY  := $(PLATFORM)-objcopy

C_FLAGS    = -march=rv32i -mabi=ilp32 -ffreestanding -I$(C_DIR) -I$(C_DIR)/LibC $(C_FLAGS_USER)
LD_FLAGS   = -nostdlib -T $(LD_SCRIPT) $(LD_FLAGS_USER)

OBJ_STARTUP := $(ASM_DIR)/Verboot.o
OBJ_DEPS     = $(C_DEPS:.c=.o) $(ASM_DEPS:.S=.o)

%.elf: %.o $(OBJ_DEPS) $(OBJ_STARTUP) $(LD_SCRIPT)
	$(CC) $(C_FLAGS) $(LD_FLAGS) -o $@ $(OBJ_STARTUP) $(OBJ_DEPS) $<

%.o: %.c
	$(CC) $(C_FLAGS) -c -o $@ $<

%.o: %.s
	$(CC) $(C_FLAGS) -c -o $@ $<

%.o: %.S
	$(CC) $(C_FLAGS) -c -o $@ $<

%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@

%.mem: %.hex
	$(OBJCOPY) --reverse-bytes=4 -O verilog --verilog-data-width=4 $< $@

clean::
	rm -f $(OBJ_STARTUP) *.o *.hex *.mem *.elf
