# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.14-s082_1 on Sat Mar 21 14:19:33 IST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design counter

create_clock -name "clk" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_load -pin_load 0.15 [get_ports {q[3]}]
set_load -pin_load 0.15 [get_ports {q[2]}]
set_load -pin_load 0.15 [get_ports {q[1]}]
set_load -pin_load 0.15 [get_ports {q[0]}]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports rst]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {q[3]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {q[2]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {q[1]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {q[0]}]
set_input_transition 0.8 [get_ports clk]
set_input_transition 0.8 [get_ports rst]
set_wire_load_mode "enclosed"
