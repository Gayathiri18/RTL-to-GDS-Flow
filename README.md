# RTL 2 GDS Simulation of 4-bit Counter Using Cadence Tools

## 1. RTL Simulation using Cadence Xcelium
### Overview
This project demonstrates the RTL simulation of a 4-bit synchronous counter using Verilog HDL and Cadence Xcelium (xrun). The behavioral modelling is used to model the Verilog code.
The goal is to verify the functional correctness of the counter design.

#### Working Directory
$Working_Directory/rtl2gds/rtl/

#### Design Description
The counter is a 4-bit synchronous up-counter with:
    Clock input (clk)
    Asynchronous reset (rst)
    4-bit output (q[3:0])

#### Functionality
    On reset → output becomes 0000
    On every rising clock edge → counter increments by 1
    After 1111 → wraps to 0000

#### Files Used
Inputs:
| File Name                  | Description                   |
| -----------------------    | ------------------            |
| counter.v                  | RTL design of 4-bit counter   |
| counter_tb.v               | Testbench for simulation      |

Outputs:
| File Form                  | Tool                     |
| -----------------------    | ------------------       |
| Waveforms                  | SimVision                |

#### Simulation Tool:
| File Form                  | Tool                     |
| -----------------------    | ------------------       |
| Verilog Simulation         | Cadence Xcelium (xrun)   |
| Waveforms                  | SimVision                |

#### Steps to Run Simulation
clean Previous Runs
rm -rf xrun.*

#### Command to run Simulation:
xrun -gui -access +rwc counter.v counter_tb.v

##-access +rwc - for signals visibility (read/write access/create/debug access)

#### Waveform Viewing Steps:
* Open SimVision GUI, Navigate to:
* counter_tb → uut
* Select signals: clk, rst, q[3:0]
* Right-click → Send to Waveform
* Click Run
* Press f for Zoom Fit


## 2. RTL Synthesis using Cadence Genus
### Overview:
Synthesis is the process of transforming a high-level Register Transfer Level (RTL) design into a **gate-level netlist** using a standard cell library. In this project, Cadence Genus is used to convert the Verilog description of the counter into an optimized hardware implementation.
During synthesis, the tool interprets the functional behavior of the RTL and maps it into a network of logic gates (such as AND, NAND, and inverters) and sequential elements (flip-flops). The process is guided by timing constraints provided through the SDC file, ensuring that the design meets the required performance specifications.
Synthesis involves three major stages:
 **Generic synthesis**: Converts RTL into an intermediate logic representation
 **Technology mapping**: Maps logic into standard cells from the library
 **Optimization**: Improves timing, area, and power based on constraints

The output of synthesis includes a **gate-level netlist**, along with reports for timing, area, and power. This netlist represents the actual hardware structure and is used for further stages such as gate-level simulation and physical design.
Overall, synthesis bridges the gap between abstract design and physical realization, making it a critical step in the ASIC design flow.

#### Design Flow:
Synthesis → Gate-Level Netlist

#### Working Directory:
$Working_Directory/rtl2gds/synthesis/

#### Files Used
Inputs:
| File Name                  | Description           |
| -----------------------    | ------------------    |
| `constraints.sdc`          | Timing constraints    |
| `genus_script.tcl`         | Synthesis script      |
| Standard cell library      | Library Information   |

Outputs:
| File Name                  | Description              |
| -----------------------    | ------------------       |
| counter_netlist.v          | Gate-level netlist       |
| counter_out.sdc            | Synthesized constraints  |
| Standard cell library      | Library Information      |

Reports:
Timing report
Area report
Power report
QoR report

#### Tools Used
Tool Used: Cadence Genus

#### Command to run
Launch synthesis: genus
Run script: source genus_script.tcl (Inside genus tool)

#### Key Synthesis Steps
Read RTL and library
Elaborate design
Apply constraints
Map to standard cells
Optimize for timing, area, and power

## ##3. Gate-Level Simulation (GLS)
### Overview
Gate-Level Simulation (GLS) is performed after synthesis to verify that the **synthesized gate-level netlist behaves identically to the RTL design**. Unlike RTL simulation, GLS includes the actual standard cells (flip-flops, logic gates) and introduces realistic propagation delays.
This step ensures that synthesis has not altered the functional behavior of the design and that the design is ready for physical implementation.

#### Files Used
Inputs:
| File Name           | Description                      |
| ------------------- | -------------------------------- |
| `counter_netlist.v` | Synthesized gate-level netlist   |
| `counter_tb.v`      | Testbench                        |
| `slow.v`            | Standard cell Verilog model file |
Outputs:
Waveforms with propagation delay
Functional validation of synthesized design

#### Working Directory
$Working_Directory/rtl2gds/gls

####  Simulation Command
xrun -gui -access +rwc -timescale 1ns/1ps \
../synthesis/output/counter_netlist.v counter_tb.v \
-v /home/install/FOUNDRY/digital/90nm/dig/vlog/slow.v

To run script: ./run_gls.sh

#### Key Requirements

* Standard cell model file (`slow.v`) must be included
* Timescale must be defined for all modules (Both in design and testbench verilog files)
* Testbench from RTL simulation can be reused

#### Observations

* Outputs show **slight delay after clock edge** due to gate-level implementation
* Propagation delays are introduced by standard cells
* Timing behavior is more realistic compared to RTL simulation

## 4. Physical Design Implementation Steps
### Overview
Physical design is the process of transforming the synthesized gate-level netlist into a final layout (GDSII) ready for fabrication.
In this project, Cadence Innovus is used to perform floorplanning, placement, routing, and verification of the 4-bit counter design.

This stage converts the logical representation into a physical silicon layout, ensuring that the design meets timing, area, and design rule constraints.

#### Working Directory
$Working_Directory/rtl2gds/implementation/

#### Files Used
Inputs:
| File Name             | Description                         |
| --------------------- | ----------------------------------- |
| `counter_netlist.v`   | Synthesized gate-level netlist      |
| `add_Default.globals` | Innovus initialization file         |
| `mmmc.tcl`            | Multi-mode multi-corner setup       |
| `innovus_script.tcl`  | Physical design automation script   |
| `counter_out.sdc`     | Timing constraints                  |
| LEF Files             | Technology & standard cell geometry |
Outputs:
| File Name           | Description                                                    |
| ------------------- | -------------------------------------------------------------- |
| `counter_netlist.v` | Final synthesized gate-level netlist used for physical design  |
| `counter.gds`       | Final fabrication-ready GDSII layout file                      |
| `counter.spef`      | Extracted parasitic file (resistance and capacitance data)     |
| `floorplan.enc`     | Saved design after floorplanning stage                         |
| `placement.enc`     | Saved design after placement stage                             |
| `cts.enc`           | Saved design after clock tree synthesis stage *(if performed)* |

Reports:
| File Name          | Description                                                      |
| ------------------ | ---------------------------------------------------------------- |
| `connectivity.rpt` | Report verifying net connectivity and ensuring no floating nodes |
| `geometry.rpt`     | Report checking layout geometry and design rule compliance       |
| `drc.rpt`          | Design Rule Check (DRC) violations report                        |
| `final_timing.rpt` | Post-route timing analysis report showing delays and slack       |
| `final_power.rpt`  | Report of dynamic and leakage power consumption                  |
| `final_area.rpt`   | Report showing total cell area and utilization                   |

#### Tool Used
Cadence Innovus

#### Key Physical Design Steps
i. Design Initialization
ii. Floorplanning
iii. Power Planning
iv. Placement
v. Clock Tree Synthesis (CTS)
vi. Routing
vii. Physical Verification
viii. RC Extraction
ix. Final Reports
x. GDSII Generation

#### Observations
Routing completed successfully with proper connectivity
No major DRC violations observed
Layout shows correct placement of standard cells and power grid
Design successfully transformed from netlist to physical layout

## Final Conclusion

This project highlights a complete ASIC design cycle and provides practical insight into both front-end and back-end design processes, emphasizing the importance of verification and optimization at every stage of the flow.
