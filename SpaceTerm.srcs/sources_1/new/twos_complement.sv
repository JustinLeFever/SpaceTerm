
module twos_complement(
    input logic clk,
    input logic [15:0] in,
    output logic [15:0] out
);

always_ff @(posedge clk) begin
    out <= ~in + 1'b1;
end

endmodule
