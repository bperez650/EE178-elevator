`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 11:05:11 AM
// Design Name: 
// Module Name: top
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


module top(
input wire clk,
input wire f1, f2, f3, f4,
input wire up_f1, up_f2, up_f3, down_f4, down_f3, down_f2,
output wire [6:0] leds, //mapped to individual led segments
output wire [3:0] displays,  //mapped to "AN" signals
output wire dp,
output wire speaker,
input wire sos,
output wire sos_led
    );
    

wire [2:0] current_floor;
wire door_status;
wire flashing_LEDs;
wire move_down_LED;
wire move_up_LED;
wire [3:0] call;
//wire up;

main_fsm main1(
.clk(clk), .f1(f1), .f2(f2), .f3(f3), .f4(f4),
.up_f1(up_f1), .up_f2(up_f2), .down_f2(down_f2), .up_f3(up_f3), .down_f3(down_f3),
.down_f4(down_f4), .move_up_LED(move_up_LED), .move_down_LED(move_down_LED), .current_floor(current_floor), 
.door_status(door_status), .flashing_LEDs(flashing_LEDs), .call(call)); //, .up(up));

display dispaly1(.clk(clk), .leds(leds), .displays(displays), 
.dp(dp), .current_floor(current_floor), .door_status(door_status), .flashing_LEDs(flashing_LEDs),
.move_up_LED(move_up_LED), .move_down_LED(move_down_LED));

narrator narrator1(
.clk(clk), .speaker(speaker), .call(call), .current_floor(current_floor), .door_status(door_status), .sos(sos)); //, .up(up));

sos sos1(
.clk(clk), .sos(sos), .sos_led(sos_led));

endmodule
