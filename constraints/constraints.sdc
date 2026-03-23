# ================================
#        Timing Constraints 
# ================================

# Clock Definition
# Clock period = 10 ns
create_clock -name clk -period 10 [get_ports clk]

# Input transition
set_input_transition 0.8 [all_inputs]

# Input delay
set_input_delay -max 2 -clock clk [all_inputs]

# Output delay
set_output_delay -max 2 -clock clk [all_outputs]

# Output load
set_load 0.15 [all_outputs]

# Optional constraints (recommended)
set_max_transition 1.0 [all_designs]
set_max_fanout 20 [all_designs]
