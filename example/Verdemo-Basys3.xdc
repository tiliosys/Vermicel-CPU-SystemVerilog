#
# SPDX-License-Identifier: CERN-OHL-W-2.0
# SPDX-FileCopyrightText: 2023 Guillaume Savaton <guillaume.savaton@tiliosys.fr>
#

# Clock (100 MHz)
set_property PACKAGE_PIN W5      [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# Reset button (BTNC, active high)
set_property PACKAGE_PIN U18     [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# UART
set_property PACKAGE_PIN B18     [get_ports uart_rx]
set_property PACKAGE_PIN A18     [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_*]

