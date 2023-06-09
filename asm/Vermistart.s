/*
 * SPDX-License-Identifier: CERN-OHL-W-2.0
 * SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
 */

    .section vectors, "x"

    .global __reset
__reset:
    tail start

__irq:
    tail irq_handler

__trap:
    tail trap_handler

    /* This variable contains the address where to branch after returning from main().
       The default behavior is to branch to the label 'finalize'. */
    .global __finalizer
__finalizer:
    .word finalize

    .text

    .align 4

    .weak irq_handler
irq_handler:
    mret

    .weak trap_handler
trap_handler:
    j .

start:
    /* Initialize the global pointer and the stack pointer. */
    .option push
    .option norelax
    la gp, __global_pointer
    .option pop
    la sp, __stack_pointer

    /* Clear the BSS section. */
    la t0, __bss_start
    la t1, __bss_end
    bgeu t0, t1, memclr_done
memclr:
    sw zero, (t0)
    addi t0, t0, 4
    bltu t0, t1, memclr

memclr_done:
    /* Execute the main program. */
    call main

    /* Branch to a custom termination program.
       The default behavior is to loop on the label 'finalize'. */
    lw t0, __finalizer
finalize:
    jr t0
