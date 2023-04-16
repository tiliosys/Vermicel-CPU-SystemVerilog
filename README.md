
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
