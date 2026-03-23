#!/bin/bash

echo "🔄 Cleaning previous synthesis data..."
rm -rf genus.log* genus.cmd* INCA_libs .genus* fv .cadence

echo "📁 Creating output directory..."
mkdir -p output

echo "🚀 Starting Synthesis using Cadence Genus..."

genus -files genus_script.tcl

if [ $? -ne 0 ]; then
    echo "❌ Synthesis failed. Check logs."
    exit 1
fi

echo "✅ Synthesis completed successfully!"

echo "📊 Generated Files:"
ls -lh output/

echo "📈 Opening key reports..."

echo "---- AREA REPORT ----"
head -20 output/*_area.rpt

echo "---- TIMING REPORT ----"
head -20 output/*_timing.rpt
