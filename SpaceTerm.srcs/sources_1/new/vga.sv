/*
*   Top level module for drawing onto the monitor
*   Defines the monitor/system paramaters, as well as the simulation parameters
*/

module vga(
    input logic CLK100MHZ,
    output logic [3:0] Red, Green, Blue,
    output logic h_sync, v_sync,
    
    // FPGA Buttons
    input logic BTNC,
    
    // Keyboard stuff
    input logic PS2_DATA,
    input logic PS2_CLK
);

// Instantiate pullup resistors on the PS2 pins (taken from lab 8)
PULLUP ps2c_pu (.O(PS2_CLK));
PULLUP ps2d_pu (.O(PS2_DATA));

//////////////////////////////////////////////
// Parameter and variable declarations
//////////////////////////////////////////////

// Timing parameters for vga 640x480 display
localparam HD = 640; // horizontal display width
localparam HF = 16;   // horizontal front porch width
localparam HR = 96;  // horizontal retrace width
localparam HB = 48;  // horizontal back porch width
localparam HT = HD+HF+HR+HB; // horizontal total width
localparam VD = 480; // vertical display height
localparam VF = 10;    // vertical front porch height
localparam VR = 2;    // vertical retrace height
localparam VB = 35;   // vertical back porch height
localparam VT = VD+VF+VR+VB; // vertical total height
// Keyboard Codes
localparam SPACE_KEY = 8'h29;
localparam W_KEY = 8'h1D;
localparam A_KEY = 8'h1C;
localparam S_KEY = 8'h1B;
localparam D_KEY = 8'h23;
localparam TAB_KEY = 8'h0D;
localparam BACK_SPACE_KEY = 8'h66;
localparam ENTER_KEY = 8'h5A;
localparam BREAK_CODE = 8'hF0;
// Celstial system parameters
localparam NUM_PLANETS = 5; // If any number above 6, only results in 6 planets anyways. Not sure why, might be due to timing issues with having a 25MHz clock? No timing errors though...
localparam DEFAULT_ORBIT_SPEED = 10000;

// Video column/row and clock declarations
logic [15:0] pixel_row = 0, pixel_column = 0;
logic CLK25MHZ;
logic [3:0] r, g, b;
logic [12:0] colors[NUM_PLANETS:0];
logic [12:0] ring_colors[NUM_PLANETS:0];
// Other declarations
logic [7:1] random_number;
logic has_ring [NUM_PLANETS:0];
// Basic properties of the planets
logic [10:0] xs [NUM_PLANETS:0];    // Array of x coordinates for celestial bodies (xs[0] is the sun)
logic [10:0] ys [NUM_PLANETS:0];    // Array of y coordinates for celestial bodies (ys[0] is the sun)
logic [10:0] rs [NUM_PLANETS:0];    // Array of radius values for celestial bodies {rs[0] is the sun)
// Variables for circle_math instantiations
logic [18:0] x_centers [NUM_PLANETS:0];     // Array of x center calculations based on circle equation
logic [18:0] y_centers [NUM_PLANETS:0];     // Array of y center calculations based on circle equation
logic [19:0] x_plus_y_sqs [NUM_PLANETS:0];  // Array of x^2 + y^2 values for each celestial body
logic [18:0] r_sqs [NUM_PLANETS:0];         // Array of r^2 values for each celestial body
// Variables for orbits of each celestial body
logic [7:0] orbit_angles_sin [NUM_PLANETS:0];
logic [7:0] orbit_angles_cos [NUM_PLANETS:0];
logic [15:0] sin_orbits [NUM_PLANETS:0];
logic [15:0] cos_orbits [NUM_PLANETS:0];
logic [15:0] cos_orbits_comp [NUM_PLANETS:0];
logic [15:0] sin_orbits_comp [NUM_PLANETS:0];
logic [9:0] orbit_distances [NUM_PLANETS:0];
logic [15:0] orbit_speed = DEFAULT_ORBIT_SPEED;
logic max_tick_orbits [NUM_PLANETS:0];
// Variables for keyboard data
reg meta;
reg reset;
logic resetPressed;
logic rx_done_tick;
logic [7:0] rxData;
logic panUp = 0, panLeft = 0, panDown = 0, panRight = 0;
logic breakPending = 0;
logic max_tick_pan;
logic [10:0] view_pos_x = 0;
logic [10:0] view_pos_y = 0;

// Initialize the values so that they are not 'unknown'
initial begin
    for (int i = 0; i <= NUM_PLANETS; i++) begin
        orbit_angles_cos[i] = 0;
        orbit_angles_sin[i] = 0;
        colors[i] = 0;
        ring_colors[i] = 0;
    end
end

// Generate a power on reset
always_ff @(posedge CLK100MHZ) begin
	meta <= 0;
	reset <= meta;
end

//////////////////////////////////
// Module declarations
//////////////////////////////////

// 25 MHz clock for 640x480 @ 60Hz
CLK25MHz vga_clock (
    .CLK25MHZ(CLK25MHZ),
    .CLK100MHZ(CLK100MHZ)
);

// Keyboard presses
ps2rx ps2rx0(
	.clk(CLK25MHZ),
	.reset(reset),
    .ps2d(PS2_DATA),
	.ps2c(PS2_CLK),
	.rx_en(1'b1),
	.rx_idle(),
	.rx_done_tick(rx_done_tick),
	.dout(rxData[7:0])
);

//// LFSR for generating random numbers
lfsr lfsr_0 (
    .clk(CLK25MHZ),
    .lfsr(random_number)
);

mod_m_counter pan0 (
    .clk(CLK25MHZ),
    .M(337500),
    .max_tick(max_tick_pan),
    .q()
);

// Modules in for loops to create the same number as planets
genvar i;
generate
    for (i = 0; i <= NUM_PLANETS; i++) begin
        circle_math bodies (
            .clk(CLK25MHZ),
            .column(pixel_column),
            .row(pixel_row),
            .x(xs[i]),
            .y(ys[i]),
            .radius(rs[i]),
            .x_coord(x_centers[i]),
            .y_coord(y_centers[i]),
            .x_squared_plus_y_squared(x_plus_y_sqs[i]),
            .radius_squared(r_sqs[i])
        );
    end
    
    // Mod-M counters for setting orbital speed
    for (i = 0; i <= NUM_PLANETS; i++) begin
        mod_m_counter orbitCntr (
            .clk(CLK25MHZ),
            .M(orbit_distances[i]*orbit_speed),
            .max_tick(max_tick_orbits[i]),
            .q()
        );
    end

    for (i = 0; i <= NUM_PLANETS; i++) begin
        // Sin and Cos for orbital calculations
        sin_rom sin0 (
            .clk(CLK25MHZ),
            .addr_r(orbit_angles_sin[i]),
            .dout(sin_orbits[i])
        );
        sin_rom cos0 (
            .clk(CLK25MHZ),
            .addr_r(orbit_angles_cos[i]),
            .dout(cos_orbits[i])
        );
        // Two's complement modules for the appropriate sin table values (pi to 2pi, or indexes 127 to 255)
        twos_complement sin_comp (
            .clk(CLK25MHZ),
            .in(sin_orbits[i]),
            .out(sin_orbits_comp[i])
        );
        twos_complement cos_comp (
            .clk(CLK25MHZ),
            .in(cos_orbits[i]),
            .out(cos_orbits_comp[i])
        );
    end
    
endgenerate

///////////////////////////////////////////////////
// Always blocks for drawing, animation, etc.
///////////////////////////////////////////////////

// Iterating through all the pixels on the monitor
always_ff @(posedge CLK25MHZ) begin
    if (pixel_column < (HT-1)) pixel_column <= pixel_column + 1;    // If less than max value, keep incrementing
    else begin
        pixel_column <= 0;                                          // else reset to 0, indicating a new row
        if (pixel_row < (VT-1) ) pixel_row <= pixel_row + 1;        // Increment our row value if less than max value
        else pixel_row <= 0;                                        // else that also gets reset to 0, and indicates a new frame
    end
end

// Generating frame buffer to output in the r, g, and b values, which later get directly assigned to the VGA connector's Red, Green, and Blue values
always_ff @(posedge CLK25MHZ) begin
    {r, g, b} <= 12'h000;   // Black background is the first thing to put in frame buffer
    
    for (int i = 0; i <= 6; i++) begin
        if (x_plus_y_sqs[i] < r_sqs[i]) {r, g, b} <= colors[i];
        if (has_ring[i]) begin
            if ((x_plus_y_sqs[i] > r_sqs[i]+60) & (x_plus_y_sqs[i] < r_sqs[i]+100)) {r, g, b} <= ring_colors[i];
        end
    end
end

logic [3:0] count = 0;
// For setting the position and radius and color of all objects on screen
always_ff @(posedge CLK25MHZ) begin
    // Initialization of the simulation. Uses BTNC for randomness (random time when user presses the button)
    if (BTNC & (count < NUM_PLANETS)) begin
        // Central star radius and color
        rs[0] <= (random_number > 20) ? 20 : random_number + 10;
        colors[0] <= 12'hFF0;
        // Rest of planets
        rs[count+1] <= (random_number > 6) ? 6 : random_number + 2;
        orbit_distances[count+1] <= (random_number > HD/2) ? (HD/2) - 20 : random_number + 80;
        // Randomize color for each planet (the central star is always yellow)
        colors[count+1] <= random_number*random_number;
        ring_colors[count+1] <= 12'h324 + random_number;
        count <= count + 1;
        // 2^7 = 128
        if (random_number > 63) has_ring[count+1] <= 1;
        else has_ring[count+1] <= 0;
    end
    else begin
        // Each planet's position in its orbit is calculated here
        for (int i = 1; i <= NUM_PLANETS; i++) begin
            if (cos_orbits[i][15] == 0 & sin_orbits[i][15] == 0) begin              // 1st orbit angle between 0 and 64
                xs[i] <= xs[0] - (orbit_distances[i] * cos_orbits[i]/(2**15 - 1));
                ys[i] <= ys[0] - (orbit_distances[i] * sin_orbits[i]/(2**15 - 1));
            end
            else if (cos_orbits[i][15] == 1 & sin_orbits[i][15] == 0) begin         // 2nd orbit angle between 64 and 128
                xs[i] <= xs[0] + (orbit_distances[i] * (cos_orbits_comp[i])/(2**15 + 1));
                ys[i] <= ys[0] - (orbit_distances[i] * sin_orbits[i]/(2**15 - 1));
            end
            else if (cos_orbits[i][15] == 1 & sin_orbits[i][15] == 1) begin         // 3rd orbit angle between 128 and 192
                xs[i] <= xs[0] + (orbit_distances[i] * (cos_orbits_comp[i])/(2**15 + 1));
                ys[i] <= ys[0] + (orbit_distances[i] * (sin_orbits_comp[i])/(2**15 + 1));
            end
            else if (cos_orbits[i][15] == 0 & sin_orbits[i][15] == 1) begin         // 4th orbit angle between 192 and 256
                xs[i] <= xs[0] - (orbit_distances[i] * cos_orbits[i]/(2**15 - 1));
                ys[i] <= ys[0] + (orbit_distances[i] * (sin_orbits_comp[i])/(2**15 + 1));
            end
            // Sun is set separately
            // Only need to add the view position from panning around to the star and not to the planets because
            // each planet orbits whatever the current position of the star is anyways. Otherwise the sun would be
            // moving twice as fast as the planets
            xs[0] <= HD/2 + view_pos_x;
            ys[0] <= VD/2 + view_pos_y;
        end
    end
end

// Leveraged from lab 9
always_ff @(posedge CLK25MHZ) begin
    if (rx_done_tick) begin
        // Panning logic
        if (rxData == W_KEY) panUp <= !breakPending;
        if (rxData == A_KEY) panLeft <= !breakPending;
        if (rxData == S_KEY) panDown <= !breakPending;
        if (rxData == D_KEY) panRight <= !breakPending;
        
        // For adjusting the rate at which the orbit angle increments, thus changing the orbital speed
        if (rxData == TAB_KEY & orbit_speed > 500) begin
            orbit_speed <= orbit_speed - 500;
        end
        else if (rxData == BACK_SPACE_KEY & orbit_speed < 65000) begin
            orbit_speed <= orbit_speed + 500;
        end
        else if (rxData == ENTER_KEY) begin
            orbit_speed <= DEFAULT_ORBIT_SPEED;
        end
        
        breakPending <= (rxData == BREAK_CODE);
    end
end

// Updating the position of the view x and y positions in their own variables. Added as an offset to the central star's position
always_ff @(posedge CLK25MHZ) begin
    if (panUp) view_pos_y <= view_pos_y - max_tick_pan;
    if (panDown) view_pos_y <= view_pos_y + max_tick_pan;
    if (panLeft) view_pos_x <= view_pos_x - max_tick_pan;
    if (panRight) view_pos_x <= view_pos_x + max_tick_pan;
end

// Increment each planet's orbit angle individually so they can have differing orbital speeds
always @(posedge CLK25MHZ) begin
    for (int i = 0; i <= NUM_PLANETS; i++) begin
        orbit_angles_sin[i] = orbit_angles_sin[i] + max_tick_orbits[i];
        orbit_angles_cos[i] = 64 - orbit_angles_sin[i];
    end
end

// Generating signal to be sent to display
always_ff @(posedge CLK25MHZ) begin
    if ((pixel_column >= HD) | (pixel_row >= VD)) {Red, Green, Blue} <= 12'h000;   // Blanking
    else {Red, Green, Blue} <= {r, g, b};
    
    h_sync <= (pixel_column >= (HD+HF)) && (pixel_column <= (HD+HF+HR));    // Pulse the horizontal-sync at these pixel_column values to signify a new row
    v_sync <= (pixel_row >= (VD+VF)) && (pixel_row <= (VD+VF+VR));          // Pulse the vertical-sync at these pixel_row values to signifiy a new frame
end

endmodule
