
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set this_dir [file dirname [file normalize [info script]]]
set src_dir  "$this_dir/.."

set board_name   [lindex $argv 0]
set project_name "Vermichello-$board_name"
set project_dir  "$this_dir/vivado/$project_name"

set src "
    $src_dir/common/Vermitypes_pkg.sv
    $src_dir/common/Vermibus.sv
    $src_dir/core/Vermicodes_pkg.sv
    $src_dir/core/Verithmetic.sv
    $src_dir/core/Vermibranch.sv
    $src_dir/core/Vermipare.sv
    $src_dir/core/Verdicoder.sv
    $src_dir/core/Vermilosto.sv
    $src_dir/core/Vergister.sv
    $src_dir/core/Vermicel_pkg.sv
    $src_dir/core/Vermicel.sv
    $src_dir/devices/Vermimory.sv
    $src_dir/devices/Vermitime_pkg.sv
    $src_dir/devices/Vermitime.sv
    $src_dir/devices/Vermicom_pkg.sv
    $src_dir/devices/Vermicom.sv
    $this_dir/Vermichello.mem
    $this_dir/Vermichello.sv
"

set generics "
    RAM_SIZE_WORDS=32768
    RAM_INIT_FILENAME=Vermichello.mem
"

set constraints "$this_dir/Vermichello-$board_name.xdc"

set part_name [dict get {
    Basys3 xc7a35tcpg236-1
    ArtyA7 xc7a100tcsg324-1
} $board_name]

set runtime_optimize true

source "$src_dir/scripts/vivado.inc.tcl"

