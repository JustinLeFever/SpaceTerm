
module lfsr(
    input logic clk,
    output logic [7:1] lfsr = 1
);

logic d1;
assign d1 = lfsr[7]^lfsr[6]^lfsr[5]^lfsr[3];

always_ff @(posedge clk) lfsr[7:1] <= {lfsr[6:1], d1};

endmodule
