# ================================
#      Genus Synthesis Script 
# ================================

# Set search paths
set_db init_lib_search_path {$Installation_directory/FOUNDRY/digital/90nm/dig/lib}
set_db init_hdl_search_path {../../rtl}

# Define design
set DESIGN counter

# Read library
set_db library {slow.lib}

# Read input RTL
read_hdl counter.v

# Elaborate design
elaborate $DESIGN

# Check design
check_design -unresolved

# Read constraints
read_sdc ../../sdc/constraints.sdc

# Link design (IMPORTANT) - Connects design with library
link

# Set synthesis effort
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

# Run synthesis stages
syn_generic
syn_map
syn_opt

# Timing check (IMPORTANT ADDITION)
check_timing

# Create output directory if not exists
file mkdir ../output

# Write outputs
write_hdl > ../output/${DESIGN}_netlist.v
write_sdc > ../output/${DESIGN}_out.sdc

# Reports
report_power  > ../output/${DESIGN}_power.rpt
report_area   > ../output/${DESIGN}_area.rpt
report_gates  > ../output/${DESIGN}_gatecount.rpt

# Timing reports (improved)
report_timing -max_paths 10 > ../output/${DESIGN}_timing.rpt
report_timing -unconstrained > ../output/${DESIGN}_unconstrained.rpt

# QoR report
report_qor -levels_of_logic -power -exclude_constant_nets > ../output/${DESIGN}_qor.rpt

# Open GUI
gui_show
