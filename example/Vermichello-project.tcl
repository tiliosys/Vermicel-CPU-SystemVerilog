
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Run from the Vivado graphical user interface:
#   Tools menu / Run Tcl Script / <project_name>.tcl
#
# or from the command line:
#   vivado -mode batch -source <project_name>.tcl
#
# This will create a folder vivado with a Vivado project <project_name>.xpr.

set this_dir    [file dirname [file normalize [info script]]]
set root_dir    "$this_dir/.."
set project_dir "$this_dir/vivado"

set project_name "Vermichello"

set src "
    $root_dir/common/Types_pkg.sv
    $root_dir/common/Bus.sv
    $root_dir/core/Opcodes_pkg.sv
    $root_dir/core/ArithLogicUnit.sv
    $root_dir/core/BranchUnit.sv
    $root_dir/core/Comparator.sv
    $root_dir/core/Decoder.sv
    $root_dir/core/LoadStoreUnit.sv
    $root_dir/core/RegisterUnit.sv
    $root_dir/core/Vermicel_pkg.sv
    $root_dir/core/Vermicel.sv
    $root_dir/devices/SinglePortRAM.sv
    $root_dir/devices/Timer_pkg.sv
    $root_dir/devices/Timer.sv
    $root_dir/devices/UART_pkg.sv
    $root_dir/devices/UART.sv
    $this_dir/Vermichello.mem
    $this_dir/Vermichello.sv
"

set constraints "
    $this_dir/Vermichello-Basys3.xdc
"

set generics "
    RAM_SIZE_WORDS=32768
    RAM_INIT_FILENAME=Vermichello.mem
"

set part_name "xc7a35tcpg236-1"

set runtime_optimize true

source "$root_dir/scripts/vivado-project.tcl"
