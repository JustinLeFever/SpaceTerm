vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 "+incdir+../../../ipstatic" \
"../../../../SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz_clk_wiz.v" \
"../../../../SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz.v" \


vlog -work xil_defaultlib \
"glbl.v"

