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

# Load global setup
source add_Default.globals

# Initialize design
init_design

###################### SANITY CHECKS ##########################
checkDesign -all > ../checkDesign/checkDesign_all.rpt
checkDesign -netlist > ../checkDesign/checkDesign_netlist.rpt
checkDesign -physicalLibrary > ../checkDesign/checkDesign_physicalLibrary.rpt
checkDesign -timingLibrary > ../checkDesign/checkDesign_timingLibrary.rpt

###################### FLOORPLAN ##############################
setDesignMode -process 90
setAnalysisMode -analysisType onChipVariation -cppr both
setExtractRCMode -engine postRoute -effortLevel medium

floorPlan -site gsclib090site -r 0.8 0.45 5 5 5 5

checkFPlan > ../Floorplan_Report/fpnCheck.rpt
saveDesign ../DBS/floorplan.enc

###################### POWER PLANNING #########################
globalNetConnect VDD -type pgpin -pin VDD -all
globalNetConnect VSS -type pgpin -pin VSS -all

addRing -nets {VDD VSS} -type core_rings -follow core \
-layer {top Metal9 bottom Metal9 left Metal8 right Metal8} -width 2 -spacing 1 -offset 2

addStripe -nets {VDD VSS} -layer Metal8 -direction vertical -width 1 -spacing 1 -set_to_set_distance 10
addStripe -nets {VDD VSS} -layer Metal9 -direction horizontal -width 1 -spacing 1 -set_to_set_distance 10

sroute -nets {VDD VSS}

###################### PLACEMENT ##############################
placeDesign
optDesign -preCTS
timeDesign -preCTS

report_timing > ../Placement_Report/timing_place.rpt
report_power > ../Placement_Report/power_place.rpt

saveDesign ../DBS/placement.enc

###################### CTS ####################################
#source cts.tcl

#timeDesign -postCTS
#optDesign -postCTS

#saveDesign ../DBS/cts.enc

###################### ROUTING ################################
routeDesign

optDesign -postRoute
timeDesign -postRoute

report_timing > ../PostRouting_Report/timing_route.rpt
report_power > ../PostRouting_Report/power_route.rpt

###################### VERIFICATION ###########################
verifyConnectivity > ../PostRouting_Report/connectivity.rpt
verifyGeometry > ../PostRouting_Report/geometry.rpt
verify_drc > ../PostRouting_Report/drc.rpt

###################### EXTRACTION #############################
extractRC
rcOut -spef ../outputs/counter.spef -rc_corner RC_CORNER

###################### FINAL OUTPUT ###########################
report_timing > ../final_reports/final_timing.rpt
report_power > ../final_reports/final_power.rpt
report_area > ../final_reports/final_area.rpt

streamOut ../outputs/counter.gds

saveNetlist ../outputs/counter_final.v

win

##############################################################