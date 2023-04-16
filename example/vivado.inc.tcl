
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set this_dir [file dirname [file normalize [info script]]]
set src_dir  "$this_dir/.."

set project_name "Vermichello-$board_name"
set project_dir  "$this_dir/vivado/$project_name"

set src "
    $src_dir/common/Types_pkg.sv
    $src_dir/common/Bus.sv
    $src_dir/core/Opcodes_pkg.sv
    $src_dir/core/ArithLogicUnit.sv
    $src_dir/core/BranchUnit.sv
    $src_dir/core/Comparator.sv
    $src_dir/core/Decoder.sv
    $src_dir/core/LoadStoreUnit.sv
    $src_dir/core/RegisterUnit.sv
    $src_dir/core/Vermicel_pkg.sv
    $src_dir/core/Vermicel.sv
    $src_dir/devices/SinglePortRAM.sv
    $src_dir/devices/Timer_pkg.sv
    $src_dir/devices/Timer.sv
    $src_dir/devices/UART_pkg.sv
    $src_dir/devices/UART.sv
    $this_dir/Vermichello.mem
    $this_dir/Vermichello.sv
"

set generics "
    RAM_SIZE_WORDS=32768
    RAM_INIT_FILENAME=Vermichello.mem
"

set constraints "$this_dir/$board_name/Vermichello.xdc"

set runtime_optimize true

source "$src_dir/scripts/vivado.inc.tcl"

