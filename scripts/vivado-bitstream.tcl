
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

open_project $project_dir/$project_name.xpr

update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs 10
wait_on_run impl_1

