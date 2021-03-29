-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Thu Apr 23 14:23:46 2020
-- Host        : DESKTOP-1UQ86B2 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/lefev/Desktop/SpaceTerm/SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz_stub.vhdl
-- Design      : CLK25MHz
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLK25MHz is
  Port ( 
    CLK25MHZ : out STD_LOGIC;
    CLK100MHZ : in STD_LOGIC
  );

end CLK25MHz;

architecture stub of CLK25MHz is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "CLK25MHZ,CLK100MHZ";
begin
end;
