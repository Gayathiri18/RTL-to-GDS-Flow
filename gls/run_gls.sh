#!/bin/bash

echo "🔄 Cleaning previous simulation data..."
rm -rf xrun.*

echo "🚀 Running Gate-Level Simulation (GLS)..."

# RTL Verification
xrun -gui -access +rwc \
/home/super/circuits/virtuoso_test/rtl2gds/rtl/counter.v  /home/super/circuits/virtuoso_test/rtl2gds/rtl/counter_tb.v 

# After Synthesis Run 
#xrun -gui -access +rwc \
# /home/super/circuits/virtuoso_test/rtl2gds/synthesis/output/counter_netlist.v counter_tb.v \
# -v /home/install/FOUNDRY/digital/90nm/dig/vlog/slow.v



#slow.v - Verilog model file of standard cells, Behavioral definitions of all gates used in the synthesized netlist

if [ $? -ne 0 ]; then
    echo "❌ GLS failed. Check errors above."
    exit 1
fi

echo "✅ GLS completed successfully!"
