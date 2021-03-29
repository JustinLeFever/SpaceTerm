// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Thu Apr 23 14:23:46 2020
// Host        : DESKTOP-1UQ86B2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/lefev/Desktop/SpaceTerm/SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz_stub.v
// Design      : CLK25MHz
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module CLK25MHz(CLK25MHZ, CLK100MHZ)
/* synthesis syn_black_box black_box_pad_pin="CLK25MHZ,CLK100MHZ" */;
  output CLK25MHZ;
  input CLK100MHZ;
endmodule
