set_property SRC_FILE_INFO {cfile:c:/Users/lefev/Desktop/SpaceTerm/SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz.xdc rfile:../../../SpaceTerm.srcs/sources_1/ip/CLK25MHz/CLK25MHz.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports CLK100MHZ]] 0.1
