`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2019 04:41:29 PM
// Design Name: 
// Module Name: sos
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


module sos(
input wire clk,
input wire sos,
output wire sos_led
);
    
reg [26:0] timer = 0;
reg timer2 = 0;

assign sos_led = timer2;

always @(posedge clk) begin
    if(!sos) begin
        timer <= 0;
        timer2 <= 0; end
    else begin
        if (timer >= 50000000) begin 
        timer2 <= ~timer2;  
        timer <= 0; end
        else timer <= timer + 1; end
end
endmodule
