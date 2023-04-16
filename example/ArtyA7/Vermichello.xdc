
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Clock (100 MHz)
set_property PACKAGE_PIN E3      [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# Reset is connected to button BTN0
set_property PACKAGE_PIN D9       [get_ports reset]
set_property IOSTANDARD LVCMOS33  [get_ports reset]

# UART
set_property PACKAGE_PIN A9      [get_ports uart_rx]
set_property PACKAGE_PIN D10     [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_*]

