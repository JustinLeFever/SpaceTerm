`timescale 1ns / 1ps

module testbench();

logic clk = 0;
logic [3:0] Red, Green, Blue;
logic h_sync = 0, v_sync = 0;
logic BTNC;

vga UUT(clk, Red, Green, Blue, h_sync, v_sync, BTNC);

always #5 clk = ~clk;

initial begin
    @(posedge clk) BTNC = 0;
    repeat(400) @(posedge clk);
    @(posedge clk) BTNC = 1;
    repeat(400) @(posedge clk);
    @(posedge clk) BTNC = 0;
    $stop;
end

endmodule
