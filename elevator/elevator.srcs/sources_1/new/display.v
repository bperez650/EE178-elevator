`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 11:06:22 AM
// Design Name: 
// Module Name: display
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module display(
input wire clk,
output reg [6:0] leds, //mapped to individual led segments
output reg [3:0] displays,  //mapped to "AN" signals
output wire dp,
input wire [2:0] current_floor,
input wire door_status,
input wire move_up_LED,
input wire move_down_LED,
input wire flashing_LEDs
);

localparam [3:0] f1 = 4'h1;
localparam [3:0] f2 = 4'h2;
localparam [3:0] f3 = 4'h3;
localparam [3:0] f4 = 4'h4;
localparam [3:0] left_open = 4'h5;
localparam [3:0] right_open = 4'h6;
localparam [3:0] left_closed = 4'h7;
localparam [3:0] right_closed = 4'h8;
localparam [3:0] off = 4'h9;
localparam [3:0] up_top_flash = 4'hA;
localparam [3:0] up_bottom_flash = 4'hB;
localparam [3:0] down_top_flash = 4'hC;
localparam [3:0] down_bottom_flash = 4'hD;




wire [1:0] display_sel;
reg [19:0] counter = 0; 
reg [3:0] val;
assign dp = 1;

assign display_sel = counter[19:18];    //divides clock down to ~ 10ms total and 2.5 ms for each ssd

always @(posedge clk) begin
    counter <= counter + 1; end //counter wraps around
    
always @* begin
    case(display_sel)
        2'b00 : begin
             displays <= 4'b1110;  //rightmost ssd on
             val <= {1'b0, current_floor};
             end
             
        2'b01 : begin
             displays <= 4'b1101;
             if(move_up_LED && flashing_LEDs) 
                val <= up_top_flash;
            else if(move_up_LED && !flashing_LEDs) 
                val <= up_bottom_flash;
            else if(move_down_LED && flashing_LEDs) 
                val <= down_top_flash;
            else if(move_down_LED && !flashing_LEDs) 
                val <= down_bottom_flash;
            else val <= off;
       
             end
             
        2'b10 : begin
             displays <= 4'b1011;
             if(door_status)
                 val <= right_open;
             else val <= right_closed;
             end
    
        2'b11 : begin
             displays <= 4'b0111;    //leftmost ssd on
             if(door_status)
                 val <= left_open;
             else val <= left_closed;
             end
        
        default : begin 
                  displays <= 4'b1111;   //all ssds off
                  end
     endcase
 end

 always @*
 begin
    case(val)
        f1 : leds <= 7'b1001111; // "1" 
        f2 : leds <= 7'b0010010; // "2" 
        f3 : leds <= 7'b0000110; // "3" 
        f4 : leds <= 7'b1001100; // "4" 
        left_open : leds <= 7'b0110001; 
        right_open : leds <= 7'b0000111; 
        left_closed : leds <= 7'b0000111; 
        right_closed : leds <= 7'b0110001; 
        off : leds <= 7'b1111111; // "off" 
        up_top_flash : leds <= 7'b0011101;
        up_bottom_flash : leds <= 7'b0101011;
        down_top_flash : leds <= 7'b1010101;
        down_bottom_flash : leds <= 7'b1100011;
        
        default : leds <= 7'b0001000; // "A" 
    endcase
end
endmodule
