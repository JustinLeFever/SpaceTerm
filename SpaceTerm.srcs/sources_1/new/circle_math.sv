
module circle_math (
    input logic clk,
    input logic [15:0] column, row,
    input logic [10:0] x, y,
    input logic [10:0] radius,
    output logic [18:0] x_coord, y_coord,
    output logic [19:0] x_squared_plus_y_squared,
    output logic [18:0] radius_squared
);

always @(posedge clk) begin
    x_coord <= (column > x) ? (column - x) : (x - column);
    y_coord <= (row > y) ? (row - y) : (y - row);
    x_squared_plus_y_squared <= x_coord**2 + y_coord**2;
    radius_squared <= radius**2;
end

endmodule
