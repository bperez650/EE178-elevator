`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2019 05:35:04 PM
// Design Name: 
// Module Name: elevator_tb
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


module elevator_tb();

reg clk;
reg f1, f2, f3, f4;
reg up_f1, up_f2, up_f3, down_f4, down_f3, down_f2;
reg sos;
wire [6:0] leds; //mapped to individual led segments
wire [3:0] displays;  //mapped to "AN" signals
wire dp;
wire speaker;
wire sos_led;

top DUT(
.clk(clk), .f1(f1), .f2(f2), .f3(f3), .f4(f4),
.up_f1(up_f1), .up_f2(up_f2), .down_f2(down_f2), .up_f3(up_f3), .down_f3(down_f3),
.down_f4(down_f4), .leds(leds), .displays(displays), 
.dp(dp), .sos(sos), .sos_led(sos_led), .speaker(speaker));

initial begin
    #100;
    clk = 1'b0;
end
    
initial begin
    forever
        #5 clk = ~clk;
end

initial begin
    f1 <= 0;
    f2 <= 0;
    f3 <= 0; 
    f4 <= 0;
    up_f1 <= 0;
    up_f2 <= 0;
    up_f3 <= 0;
    down_f4 <= 0;
    down_f3 <= 0;
    down_f2 <= 0; 
    sos <= 0; end
    
initial begin
    #1000;
    f4 <= 1;
    #400;
    f4 <=0; 
    #40000;
    f2 <= 1;
    #400;
    f2 <= 0;
    #40000;
    f1 <= 1; 
    #400;
    f1<= 0;
end

endmodule
