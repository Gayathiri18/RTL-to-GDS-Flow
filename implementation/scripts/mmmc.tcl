# ==========================================
# MMMC FILE (90nm - CLEAN VERSION)
# ==========================================

# -------- Library Set --------
create_library_set -name max_timing -timing {$Installation_Directory/digital/90nm/dig/lib/slow.lib}
create_library_set -name min_timing -timing {$Installation_Directory/digital/90nm/dig/lib/fast.lib}

# -------- RC Corner --------
create_rc_corner -name RC_CORNER \
    -qx_tech_file {$Installation_Directory/digital/90nm/dig/qrc/gpdk090_9l.tch} \
    -preRoute_res 1.0 \
    -preRoute_cap 1.0 \
    -postRoute_res 1.0 \
    -postRoute_cap 1.0

# -------- Delay Corners --------
create_delay_corner -name max_delay -library_set max_timing -rc_corner RC_CORNER
create_delay_corner -name min_delay -library_set min_timing -rc_corner RC_CORNER

# -------- Constraint Mode --------
create_constraint_mode -name constr -sdc_files [list $Working_Directory/rtl2gds/synthesis/output/counter_out.sdc]

# -------- Analysis View --------
#create_analysis_view -name analysis_view -constraint_mode constr -delay_corner RC_CORNER

create_analysis_view -name setup_view -constraint_mode constr -delay_corner max_delay
create_analysis_view -name hold_view -constraint_mode constr -delay_corner min_delay

# -------- Set Active Views --------
set_analysis_view -setup {setup_view} -hold {hold_view}

# ==========================================
# END OF FILE
# ==========================================
