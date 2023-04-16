
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set this_dir    [file dirname [file normalize [info script]]]
set root_dir    "$this_dir/.."
set project_dir "$this_dir/vivado"

set project_name "Vermichello"

source "$root_dir/scripts/vivado-bitstream.tcl"

