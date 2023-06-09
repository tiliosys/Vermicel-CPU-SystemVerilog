#
# SPDX-License-Identifier: CERN-OHL-W-2.0
# SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
#

# Close project if already open.
if {![catch current_project]} {
    close_project
}

# Create a new Vivado project.
create_project $project_name $project_dir -part $part_name -force

# Add source files and update the compile order.
add_files -fileset sources_1 $src
add_files -fileset constrs_1 $constraints
update_compile_order -fileset sources_1

if {[info exists generics]} {
    set_property generic $generics [current_fileset]
}

# Set the synthesis and implementation strategies to get shorter runs
# with no physical optimizations.
if {![info exists runtime_optimize]} {
    set runtime_optimize false
}

if {$runtime_optimize} {
    set_property strategy Flow_RuntimeOptimized [get_runs synth_1]
    set_property strategy Flow_RuntimeOptimized [get_runs impl_1]
}

unset runtime_optimize

# Lower severity for message "[Common 17-55] 'set_property' expects at least one object."
set_msg_config -id {Common 17-55} -new_severity {WARNING}

launch_runs impl_1 -to_step write_bitstream -jobs 10
wait_on_run impl_1

