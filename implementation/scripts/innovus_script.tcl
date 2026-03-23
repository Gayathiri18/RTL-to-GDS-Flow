################################################

       # INNOVUS IMPLEMENTATION SCRIPT #

################################################

################ CLEAN PREVIOUS DATA ################

# Remove old database (safe clean start)
if {[file exists ../DBS]} {
    puts "🧹 Cleaning old ../DBS directory..."
    exec rm -rf ../DBS/*
}

# Create required directories
exec mkdir -p ../checkDesign ../Floorplan_Report ../Placement_Report ../PreCTS_Report ../PostRouting_Report ../final_reports ../DBS

# Load global configuration (libraries, netlistm LEF, MMMC)
source add_Default.globals

# Initialize design database
init_design

###################### SANITY CHECKS ##########################
# Perform design checks to ensure correct setup before implementation
checkDesign -all > ../checkDesign/checkDesign_all.rpt
checkDesign -netlist > ../checkDesign/checkDesign_netlist.rpt
checkDesign -physicalLibrary > ../checkDesign/checkDesign_physicalLibrary.rpt
checkDesign -timingLibrary > ../checkDesign/checkDesign_timingLibrary.rpt

###################### FLOORPLAN ##############################
# Set technology node (90nm)
setDesignMode -process 90
# Enable On-Chip Variation (OCV) and Common Path Pessimism Removal (CPPR)
setAnalysisMode -analysisType onChipVariation -cppr both
# Set RC extraction mode (post-route model with medium effort)
setExtractRCMode -engine postRoute -effortLevel medium

# Define core area, aspect ratio, and margins
floorPlan -site gsclib090site -r 0.8 0.45 5 5 5 5

checkFPlan > ../Floorplan_Report/fpnCheck.rpt
saveDesign ../DBS/floorplan.enc

###################### POWER PLANNING #########################
# Connect global power and ground nets to all cells
globalNetConnect VDD -type pgpin -pin VDD -all
globalNetConnect VSS -type pgpin -pin VSS -all

# Create power rings around core for stable supply
addRing -nets {VDD VSS} -type core_rings -follow core -layer {top Metal9 bottom Metal9 left Metal8 right Metal8} -width 2 -spacing 1 -offset 2

# Create vertical power stripes (Metal8)
addStripe -nets {VDD VSS} -layer Metal8 -direction vertical -width 1 -spacing 1 -set_to_set_distance 10

# Create horizontal power stripes (Metal9)
addStripe -nets {VDD VSS} -layer Metal9 -direction horizontal -width 1 -spacing 1 -set_to_set_distance 10

# Route power connections between rings, stripes, and cells
sroute -nets {VDD VSS}

###################### PLACEMENT ##############################
# Place standard cells in the defined core area
placeDesign

# Optimize design before CTS for timing and congestion
optDesign -preCTS

# Perform timing analysis after placement
timeDesign -preCTS

report_timing > ../Placement_Report/timing_place.rpt
report_power > ../Placement_Report/power_place.rpt

saveDesign ../DBS/placement.enc

###################### CTS ####################################
# Clock Tree Synthesis (currently skipped for small design)
#source cts.tcl

# Post-CTS optimization and timing (if enabled)
#timeDesign -postCTS
#optDesign -postCTS

#saveDesign ../DBS/cts.enc

###################### ROUTING ################################
# Perform global + detailed routing of all nets
routeDesign

# Optimize routing for timing and congestion
optDesign -postRoute
# Perform post-route timing analysis
timeDesign -postRoute

report_timing > ../PostRouting_Report/timing_route.rpt
report_power > ../PostRouting_Report/power_route.rpt

###################### VERIFICATION ###########################
verifyConnectivity > ../PostRouting_Report/connectivity.rpt
verifyGeometry > ../PostRouting_Report/geometry.rpt
verify_drc > ../PostRouting_Report/drc.rpt

###################### EXTRACTION #############################
# Extract parasitic resistance and capacitance
extractRC

# Generate SPEF file for post-layout timing analysis
rcOut -spef ../outputs/counter.spef -rc_corner RC_CORNER

###################### FINAL OUTPUT ###########################
# Generate final timing, power, and area reports
report_timing > ../final_reports/final_timing.rpt
report_power > ../final_reports/final_power.rpt
report_area > ../final_reports/final_area.rpt

# Export final GDSII layout (fabrication-ready)
streamOut ../outputs/counter.gds

# Save final gate-level netlist after PnR
saveNetlist ../outputs/counter_final.v

# Open GUI window (optional visualization)
win

##############################################################
