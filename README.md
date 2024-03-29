
Vermicel is a simple RISC processor core that implements most of the RISC-V base instruction set (RV32I).

I have developed this core as an exercice to practice SystemVerilog (I am much more experienced in VHDL)
and as a platform for my personal embedded computing experiments.

Vermicel is in a very early stage of development, and it is unlikely to ever become production-ready.
Full compliance to the RISC-V specification is not guaranteed either.
So, if you are looking for a RISC-V core to use in your product, there are a lot of other implementations available.

License
-------

This project is licensed under the terms of the CERN Open Hardware Licence Version 2 - Weakly Reciprocal (CERN-OHL-W).
For details please see the [LICENSE](./LICENSE) file or https://ohwr.org/project/cernohl/wikis/Documents/CERN-OHL-version-2

The test suite in folder `tests/rv32ui` comes from [the riscv-tests project](https://github.com/riscv-software-src/riscv-tests),
with modifications from [the picorv32 project](https://github.com/YosysHQ/picorv32).
The license of this test suite can be found in [tests/rv32ui/LICENSE](./tests/rv32ui/LICENSE).

Content of this repository
--------------------------

The source tree contains the following elements:

Folder       | Content
-------------|--------
`asm`        | Base assembly code (startup module)
`benchmarks` | Performance measurement programs.
`common`     | Common SystemVerilog code (data types, bus interface)
`core`       | Vermicel, the CPU core itself
`devices`    | A minimal set of peripherals to create simple systems (RAM, timer, UART)
`example`    | Verdemo, a "Hello World" SoC built around Vermicel
`scripts`    | Various scripts for linting, simulation, synthesis, software compilation
`tests`      | The test suite

Meet the Vermicel family
------------------------

### Core members

[Vermicel](./core/Vermicel.sv), has two possible implementations that can be chosen
using its `PIPELINE` parameter:

* [Versequence](./core/Versequence.sv) (`PIPELINE=0`): a sequential architecture that uses a state machine.
* [Verpipeline](./core/Verpipeline.sv) (`PIPELINE=1`): a 5-stage pipeline architecture.

Both implementations are composed of the same modules:

* [Verdecode](./core/Verdecode.sv): the instruction decoder.
* [Verithmetic](./core/Verithmetic.sv): the Arithemetic and Logic Unit (ALU).
* [Vercompare](./core/Vercompare.sv): the comparator, a close collaborator of [Vergoto](./core/Vergoto.sv).
* [Vergoto](./core/Vergoto.sv): the branch calculation unit.
* [Vergister](./core/Vergister.sv): the general-purpose register bank.
* [Veralign](./core/Veralign.sv): responsible for formatting the values on the data bus.

They are assisted by:

* [Verbus](./common/Verbus.sv): the bus interface.
* [Verdata_pkg](./common/Verdata_pkg.sv): a package with common data types.
* [Veropcodes_pkg](./core/Veropcodes_pkg.sv): a package with the main RISC-V opcodes.
* [Vermicel_pkg](./core/Vermicel_pkg.sv): a package with constant declarations.

### Peripherals

Vermicel comes with a minimal set of devices:

* [Vermemory](./devices/Vermemory.sv): a dual-port SRAM block.
* [Verserial](./devices/Verserial.sv): a serial communication controller (UART).
* [Vertimer](./devices/Vertimer.sv): a timer.

### Examples and benchmarks

* [Verdemo](./example): a synthesizable "Hello world" SoC.
* [Verbench](./benchmarks/Verbench.sv): a simulation environment to measure execution time with various programs:
  * [Verbonacci](./benchmarks/Verbonacci.c): computes the Fibonacci series.
  * [Vercopy](./benchmarks/Vercopy.c): performs string copy operations.

Development software and hardware
---------------------------------

Vermicel has been developed, tested and synthesized using these tools:

* Simulator: Verilator 5.009
* Synthesis: Xilinx Vivado 2019.1
* Software compilation: RISC-V GNU toolchain with GCC 12.2.0, binutils 2.40
* Build automation: GNU make 4.3

The example system supports the following FPGA boards:

* Digilent Basys 3
* Digilent Arty A7

Simulation
----------

Run all tests:

```
make -C tests
```

Run one or more specific tests:

```
TESTS="Vermicel_tb rv32ui_tb" make -C tests
```

Clean the tests folder:

```
make -C tests clean

```

Benchmarks
----------

Run all benchmarks:

```
make -C benchmarks
```

Run one or more specific benchmarks:

```
BENCHMARKS="Verminacci" make -C benchmarks
```

Clean the benchmarks folder:

```
make -C benchmarks clean

```

Synthesis
---------

This command will generate bitstreams for all target boards:

```
make -C example
```

Generate a bitstream for one or more specific boards:

```
BOARDS=Basys3 make -C example
```
