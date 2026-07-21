module VGAwrapper(
    // Input from VGA
    input CLOCK_50,
    input [3:0] KEY,
	input [17:0] SW,
    
    // VGA Output Pins
    output VGA_CLK,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B
);

    // Internal Wires
    wire w_clk_25; 
    wire [9:0] w_h_count;
    wire [9:0] w_v_count;
    wire w_video_on;
    
    wire [3:0] w_cursor_x;
    wire [3:0] w_cursor_y;
    
    wire [7:0] w_red;
    wire [7:0] w_green;
    wire [7:0] w_blue;
	
	wire [3:0] w_switch_num;
    wire [3:0] w_cell_data;

    
	// Module Initializing
    // Sync Gen module
    VGAsync sync_unit (
        .clk(CLOCK_50),          
        .h_count(w_h_count),
        .v_count(w_v_count),
        .h_sync(VGA_HS),         
        .v_sync(VGA_VS),         
        .video_on(w_video_on),
        .clk_25(w_clk_25)
    );
    
    // Cursor Control module
    cursorControl cursor (
        .clk_25(w_clk_25),
        .btn_up(KEY[3]),
        .btn_down(KEY[2]),       
        .btn_left(KEY[1]),       
        .btn_right(KEY[0]),      
        .cx(w_cursor_x),         
        .cy(w_cursor_y)          
    );

    // Grid Drawer module
    gridDrawer draw_unit (
        .x(w_h_count),           
        .y(w_v_count),           
        .video_on(w_video_on),  
		// The cursor wires
        .cursor_x(w_cursor_x),   
        .cursor_y(w_cursor_y), 
		.cell_data(w_cell_data),
        .r(w_red),
        .g(w_green),
        .b(w_blue)                                                                                                              
    );
	
	//Input Decoder	module
    inputSwitch decoder (
        .SW(SW[8:0]),
        .num(w_switch_num)
    );

    // PlayerRAM module
    playerRAM memory (
        .clk_25(w_clk_25),
        .en(SW[17]),              // Left-most switch is Enter
        .cursor_x(w_cursor_x),
        .cursor_y(w_cursor_y),
        .data_in(w_switch_num),   // Number chosen by the player
        .vga_x(w_h_count),        // Where the VGA is currently drawing
        .vga_y(w_v_count),
        .data_out(w_cell_data)    // Number already in cell
    );

    // Output
    assign VGA_R = w_red;
    assign VGA_G = w_green;
    assign VGA_B = w_blue;
    
    // Invert clock 
    assign VGA_CLK = ~w_clk_25; 
    
    // Clock set to low
    assign VGA_BLANK_N = w_video_on;
    
    // Sync tied to 0
    assign VGA_SYNC_N  = 1'b0;

endmodule