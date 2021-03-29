vlib work
vlib activehdl

vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic" \
"../../../../SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz_clk_wiz.v" \
"../../../../SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz.v" \


vlog -work xil_defaultlib \
"glbl.v"

