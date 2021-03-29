vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr "+incdir+../../../ipstatic" \
"../../../../SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz_clk_wiz.v" \
"../../../../SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz.v" \


vlog -work xil_defaultlib \
"glbl.v"

