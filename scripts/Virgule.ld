
ENTRY(__reset)

MEM_SIZE   = 256K;
STACK_SIZE = 4K;
BOOT_SIZE  = 4K;

SECTIONS {
    . = 0x0;

    .text : {
        *(vectors)
        *(.text*)
        __text_end = .;
    }

    .sdata  : { *(.sdata*) }
    .data   : { *(.data*) }
    .rodata : { *(.rodata*) }

    __global_pointer = ALIGN(4);

    .bss ALIGN(4) : {
        __bss_start = .;
        *(.bss COMMON)
        __bss_end = ALIGN(4);
    }

    . = MEM_SIZE - STACK_SIZE - BOOT_SIZE;

    .boot ALIGN(4) : {
        __boot_start = .;
        . += BOOT_SIZE;
        __boot_end = ALIGN(4);
    }

    .stack ALIGN(4) : {
        __stack_start = .;
        . += STACK_SIZE;
        __stack_pointer = .;
    }
}
