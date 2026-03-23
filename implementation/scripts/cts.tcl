# ==========================================
# CTS SCRIPT (SAFE + MINIMAL)
# ==========================================

# Reset any previous CTS configs
reset_ccopt_config

# (Optional) Use only slow corner cells
# Uncomment ONLY if needed later
# set_ccopt_property buffer_cells [get_lib_cells slow/BUFX*]
# set_ccopt_property inverter_cells [get_lib_cells slow/INVX*]

# Run CTS (auto mode)
ccopt_design

# Reports
report_ccopt_clock_trees -file clk_trees.rpt
report_ccopt_skew_groups -file skew_groups.rpt

# Save design
saveDesign DBS/cts.enc

# ==========================================
# END OF FILE
# ==========================================