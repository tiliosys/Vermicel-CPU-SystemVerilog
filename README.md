
Vermicel is a simple RISC processor core that implements most of the RISC-V base instruction set (RV32I).

I have developed this core as an exercice to practice SystemVerilog (I am much more experienced in VHDL)
and as a platform for my personal embedded computing experiments.

Vermicel is in a very early stage of development, and it is unlikely to ever become production-ready.
Full compliance to the RISC-V specification is not guaranteed either.
So, if you are looking for a RISC-V core to use in your product, there are a lot of other implementations available.

Vermicel is distributed under the terms of the Mozilla Public License 2.0.

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
`example`    | Vermichello, a "Hello World" SoC built around Vermicel
`scripts`    | Various scripts for linting, simulation, synthesis, software compilation
`tests`      | The test suite

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
