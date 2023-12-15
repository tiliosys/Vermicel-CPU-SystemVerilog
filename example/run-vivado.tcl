#
# SPDX-License-Identifier: CERN-OHL-W-2.0
# SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
#

set this_dir [file dirname [file normalize [info script]]]
set src_dir  "$this_dir/.."

set board_name   [lindex $argv 0]
set project_name "Verdemo-$board_name"
set project_dir  "$this_dir/vivado/$project_name"

set src "
    $src_dir/common/Verdata_pkg.sv
    $src_dir/common/Verbus.sv
    $src_dir/core/Veropcodes_pkg.sv
    $src_dir/core/Verithmetic.sv
    $src_dir/core/Vergoto.sv
    $src_dir/core/Vercompare.sv
    $src_dir/core/Verdecode.sv
    $src_dir/core/Veralign.sv
    $src_dir/core/Vergister.sv
    $src_dir/core/Vermicel_pkg.sv
    $src_dir/core/Versequence.sv
    $src_dir/core/Verpipeline.sv
    $src_dir/core/Vermicel.sv
    $src_dir/devices/Vereset.sv
    $src_dir/devices/Versync.sv
    $src_dir/devices/Vermemory.sv
    $src_dir/devices/Vertimer_pkg.sv
    $src_dir/devices/Vertimer.sv
    $src_dir/devices/Verserial_pkg.sv
    $src_dir/devices/Verserial.sv
    $this_dir/Verdemo.mem
    $this_dir/Verdemo.sv
"

set reset_level [dict get {
    Basys3 1
    ArtyA7 0
} $board_name]

set generics "
    RAM_SIZE_WORDS=32768
    RAM_INIT_FILENAME=Verdemo.mem
    USE_LOOKAHEAD=1
    PIPELINE=1
    RESET_LEVEL=$reset_level
"

set constraints "$this_dir/Verdemo-$board_name.xdc"

set part_name [dict get {
    Basys3 xc7a35tcpg236-1
    ArtyA7 xc7a100tcsg324-1
} $board_name]

# Set to true to reduce the synthesis and implementation time.
# This can affect the timing closure, especially if PIPELINE=1.
set runtime_optimize false

source "$src_dir/scripts/vivado.inc.tcl"

