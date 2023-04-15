
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
set root_dir    "$this_dir/../.."
set rtl_dir     "$root_dir/rtl"
set asm_dir     "$root_dir/asm"
set scripts_dir "$root_dir/scripts"

set project_name "SimpleSoC_Hello"

set src "
    $rtl_dir/common/Types_pkg.sv
    $rtl_dir/common/Bus.sv
    $rtl_dir/cpu/Opcodes_pkg.sv
    $rtl_dir/cpu/ArithLogicUnit.sv
    $rtl_dir/cpu/BranchUnit.sv
    $rtl_dir/cpu/Comparator.sv
    $rtl_dir/cpu/Decoder.sv
    $rtl_dir/cpu/LoadStoreUnit.sv
    $rtl_dir/cpu/RegisterUnit.sv
    $rtl_dir/cpu/Virgule_pkg.sv
    $rtl_dir/cpu/Virgule.sv
    $rtl_dir/devices/SinglePortRAM.sv
    $rtl_dir/devices/Timer_pkg.sv
    $rtl_dir/devices/Timer.sv
    $rtl_dir/devices/UART_pkg.sv
    $rtl_dir/devices/UART.sv
    $asm_dir/Hello/Hello.mem
    $rtl_dir/simple-soc/SimpleSoC.sv
"

set constraints "
    $rtl_dir/simple-soc/SimpleSoC-Basys3.xdc
"

set generics "
    RAM_SIZE_WORDS=32768
    RAM_INIT_FILENAME=Hello.mem
"

set part_name "xc7a35tcpg236-1"

set runtime_optimize true

source "$scripts_dir/vivado-project.tcl"
