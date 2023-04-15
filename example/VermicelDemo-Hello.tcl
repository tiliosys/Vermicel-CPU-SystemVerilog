
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Run from the Vivado graphical user interface:
#   Tools menu / Run Tcl Script / <project_name>.tcl
#
# or from the command line:
#   vivado -mode batch -source <project_name>.tcl
#
# This will create a folder build/<project_name>
# with a Vivado project <project_name>.xpr.

set this_dir    [file dirname [file normalize [info script]]]
set root_dir    "$this_dir/.."

set project_name "VermicelDemo_Hello"

set src "
    $root_dir/common/Types_pkg.sv
    $root_dir/common/Bus.sv
    $root_dir/cpu/Opcodes_pkg.sv
    $root_dir/cpu/ArithLogicUnit.sv
    $root_dir/cpu/BranchUnit.sv
    $root_dir/cpu/Comparator.sv
    $root_dir/cpu/Decoder.sv
    $root_dir/cpu/LoadStoreUnit.sv
    $root_dir/cpu/RegisterUnit.sv
    $root_dir/cpu/Vermicel_pkg.sv
    $root_dir/cpu/Vermicel.sv
    $root_dir/devices/SinglePortRAM.sv
    $root_dir/devices/Timer_pkg.sv
    $root_dir/devices/Timer.sv
    $root_dir/devices/UART_pkg.sv
    $root_dir/devices/UART.sv
    $root_dir/asm/Hello/Hello.mem
    $root_dir/simple-soc/VermicelDemo.sv
"

set constraints "
    $root_dir/simple-soc/VermicelDemo-Basys3.xdc
"

set generics "
    RAM_SIZE_WORDS=128
    RAM_INIT_FILENAME=Hello.mem
"

set part_name "xc7a35tcpg236-1"

set runtime_optimize true

source "$root_dir/scripts/vivado-project.tcl"
