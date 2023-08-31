#
# SPDX-License-Identifier: CERN-OHL-W-2.0
# SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
#

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
    $src_dir/core/Verdicode.sv
    $src_dir/core/Verdata.sv
    $src_dir/core/Vergister.sv
    $src_dir/core/Vermicel_pkg.sv
    $src_dir/core/Versiquential.sv
    $src_dir/core/Vermipipe.sv
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
    USE_LOOKAHEAD=1
    PIPELINE=1
"

set constraints "$this_dir/Vermichello-$board_name.xdc"

set part_name [dict get {
    Basys3 xc7a35tcpg236-1
    ArtyA7 xc7a100tcsg324-1
} $board_name]

# Set to true to reduce the synthesis and implementation time.
# This can affect the timing closure, especially if PIPELINE=1.
set runtime_optimize false

source "$src_dir/scripts/vivado.inc.tcl"

