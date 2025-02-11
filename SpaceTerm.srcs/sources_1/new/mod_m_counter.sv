// Adapted from Chu's listing 4.13
module mod_m_counter (
	input logic clk,
	input logic [25:0] M,
	output logic max_tick,
	output logic [25:0] q = 0 // output register with initial value
);

// register with next-state logic
always_ff @(posedge clk) begin
   if (q >= (M-1)) q <= 0;
   else            q <= q + 1;
end

// output logic
assign max_tick = (q == (M-1));

endmodule

