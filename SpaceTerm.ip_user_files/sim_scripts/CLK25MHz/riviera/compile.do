vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic" \
"../../../../SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz_clk_wiz.v" \
"../../../../SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz.v" \


vlog -work xil_defaultlib \
"glbl.v"

