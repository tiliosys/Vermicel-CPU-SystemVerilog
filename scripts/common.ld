/*
 * SPDX-License-Identifier: CERN-OHL-W-2.0
 * SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
 */

ENTRY(__reset)

SECTIONS {
    . = 0x0;

    .text : {
        *(vectors)
        *(.text*)
        __text_end = .;
    }

    .sdata  : {
        *(.sdata*)
        . = ALIGN(4);
    }

    .data   : {
        *(.data*) 
        . = ALIGN(4);
    }

    .rodata : {
        *(.rodata*) 
        . = ALIGN(4);
    }

    __global_pointer = ALIGN(4);

    .bss ALIGN(4) : {
        __bss_start = .;
        *(.bss COMMON)
        __bss_end = ALIGN(4);
    }

    . = MEM_SIZE - STACK_SIZE;

    .stack ALIGN(4) : {
        __stack_start = .;
        . += STACK_SIZE;
        __stack_pointer = .;
    }
}
