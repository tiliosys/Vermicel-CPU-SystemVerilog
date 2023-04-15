
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set_property PACKAGE_PIN W5      [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

set_property PACKAGE_PIN U18      [get_ports reset]
set_property IOSTANDARD LVCMOS33  [get_ports reset]

set_property PACKAGE_PIN B18     [get_ports uart_rx]
set_property PACKAGE_PIN A18     [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_*]

