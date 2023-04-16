
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set this_dir [file dirname [file normalize [info script]]]

set project_name "Vermichello-Basys3"
set project_dir "$this_dir/../vivado/$project_name"

set part_name "xc7a35tcpg236-1"

set constraints "
    $this_dir/Vermichello.xdc
"

source $this_dir/../vivado.inc.tcl


