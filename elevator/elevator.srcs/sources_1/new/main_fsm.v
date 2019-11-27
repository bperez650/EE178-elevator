`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 11:03:30 AM
// Design Name: 
// Module Name: main_fsm
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

module main_fsm(
input wire clk,
input wire f1, f2, f3, f4,
input wire up_f1, up_f2, up_f3, down_f4, down_f3, down_f2,
output reg move_up_LED,
output reg move_down_LED,
output reg [2:0] current_floor,
output reg door_status,
output reg flashing_LEDs,
//output reg up
output reg [3:0] call
    );

localparam [3:0] idle = 4'b0000;
localparam [3:0] request_ISR = 4'b0001;
localparam [3:0] slow_start = 4'b0010;
localparam [3:0] move10 = 4'b0011;
localparam [3:0] floor_inc = 4'b0100;
localparam [3:0] reset = 4'b0101;
localparam [3:0] moveV = 4'b0110;
localparam [3:0] reset1 = 4'b0111;
localparam [3:0] reset2 = 4'b1000;
localparam [3:0] move20 = 4'b1001;
localparam [3:0] slow_finish = 4'b1010;
localparam [3:0] open_door = 4'b1011;
localparam [3:0] waiting = 4'b1100;
localparam [3:0] close_door = 4'b1101;

   

reg [3:0] state = 0;
reg [2:0] final_floor = 1;
reg [26:0] timer = 0;
reg [4:0] timer2 = 0;
reg rst = 0;
reg up = 0;
reg down = 0;
reg rst2 = 0;
reg [4:0] var = 0;
reg stop = 0;

initial begin
current_floor = 1;
end

wire request;
wire F1, F2, F3, F4;
//wire f1v, f2v, f3v, f4v;


assign F1 = f1; //|| f1v;
assign F2 = f2; //|| f2v;
assign F3 = f3; //|| f3v;
assign F4 = f4; //|| f4v;
assign request = up_f1||up_f2||up_f3||down_f4||down_f3||down_f2||F1||F2||F3||F4;


//vio_0 myvio (
//  .clk(clk),                // input wire clk
//  .probe_in0(state),    // input wire [3 : 0] probe_in0
//  .probe_in1(current_floor),    // input wire [2 : 0] probe_in1
//  .probe_out0(f1v),  // output wire [0 : 0] probe_out0
//  .probe_out1(f2v),  // output wire [0 : 0] probe_out1
//  .probe_out2(f3v),  // output wire [0 : 0] probe_out2
//  .probe_out3(f4v)  // output wire [0 : 0] probe_out3
//);

//fsm_ila myila (
//	.clk(clk), // input wire clk
//	.probe0(current_floor), // input wire [2:0]  probe0  
//	.probe1(state),// input wire [3:0]  probe1 
//    .probe2(F1), // input wire [0:0]  probe2 
//	.probe3(F2), // input wire [0:0]  probe3 
//	.probe4(F3), // input wire [0:0]  probe4 
//	.probe5(F4), // input wire [0:0]  probe5
//	.probe6(timer2), // input wire [4:0]  probe6 
//	.probe7(timer)//, // input wire [26:0]  probe7
//	//.probe8(final_floor) // input wire [2:0]  probe8

//);

//timer
always @(posedge clk) begin
    if(rst) begin
        timer = 0;
        timer2 = 0; end
    else begin
        if (timer == 25000000) begin 
            timer2 = timer2 + 1;  
            timer = 0; end
        else timer = timer + 1; 
    end
end
        

//final floor calculation
always @(posedge request) begin
    if(F1||up_f1) final_floor = 3'b001;
    else if(F2||up_f2||down_f2) final_floor = 3'b010;
    else if(F3||up_f3||down_f3) final_floor = 3'b011;
    else if(F4||down_f4) final_floor = 3'b100; end

//main state machine
always @(posedge clk) begin
    case(state) 
        idle : if(request) state <= request_ISR; 
            else state <= idle;
               
        request_ISR : if(current_floor == final_floor) state <= open_door;
            else state <= slow_start;
            
        slow_start : if(timer2 == 5) state <= move10;
            else state <= slow_start;
                      
        move10 : if(timer2 == 20) state <= floor_inc;
            else state <= move10;
        
        floor_inc : state <= reset;
        
        reset : state <= moveV;
        
        moveV : if(timer2==var && stop) state <= reset1;
            else if(timer2==var && !stop) state <= reset2;
            else state <= moveV;
                                                  
        reset1 : state <= slow_finish;
            
        reset2 : state <= move20;
        
        move20 : if(timer2 == 20) state <= floor_inc;
            else state <= move20;
        
        slow_finish: if(timer2 == 5) state <= open_door;
            else state <= slow_finish;
        
        open_door : state <= waiting;
        
        waiting :  if(timer2 == 20) state <= close_door;    //wait 5s
            else state <= waiting;
            
        close_door : state <= idle;
                    
        default : state <= idle;
    endcase
end

//outputs state machine
always @(posedge clk) begin
    case(state) 
        idle : begin
            up <= 0;
            down <= 0;
            call <= 0;
            rst <= 0;
            move_down_LED <= 0;
            move_up_LED <= 0; 
            door_status <= 0; 
            flashing_LEDs <= 0; end
               
        request_ISR : begin
            if(current_floor>final_floor) begin
                up <= 0;
                down <= 1; end
            else if(current_floor<final_floor) begin
                up <= 1;
                down <= 0; end
            else begin
                up <= 0;
                down <= 0; end
            //call <= 4'b0010;
            rst <= 1;
            move_down_LED <= 0;
            move_up_LED <= 0; 
            door_status <= 0;
            flashing_LEDs <= 0; end
            
        slow_start : begin
            call <= 4'b0000;
            rst <= 0;
            if(up) begin
                move_up_LED <= 1;
                move_down_LED <= 0; end
            else begin
                move_up_LED <= 0;
                move_down_LED <= 1; end
            flashing_LEDs <= timer2[0]; 
            door_status <= 0; end
            
        move10 : begin
            call <= 4'b0000;
            rst <= 0;
            if(up) begin
                move_up_LED <= 1;
                move_down_LED <= 0; end
            else begin
                move_up_LED <= 0;
                move_down_LED <= 1; end
            flashing_LEDs <= timer2[1]; 
            door_status <= 0; end

        floor_inc : begin
            call <= 4'b0001;
            rst <= 1; 
            if(up) begin
                current_floor <= current_floor + 1; end
            else begin
                current_floor <= current_floor - 1; end
            move_down_LED <= 0;
            move_up_LED <= 0; 
            door_status <= 0; 
            flashing_LEDs <= 0; end
            
        reset : begin
            if(current_floor == final_floor) begin
                var = 10;
                stop = 1; end
            else begin
                var = 20;
                stop = 0; end
            call <= 0;
            rst <= 0; 
            move_down_LED <= 0;
            move_up_LED <= 0; 
            door_status <= 0; 
            flashing_LEDs <= 0; end
            
        moveV : begin
            call <= 4'b0000;
            rst <= 0;
            if(up) begin
                move_up_LED <= 1;
                move_down_LED <= 0; end
            else begin
                move_up_LED <= 0;
                move_down_LED <= 1; end
            flashing_LEDs <= timer2[1]; 
            door_status <= 0; end
            
        reset1 : begin
            call <= 4'b0000;
            rst <= 1;
            move_down_LED <= 0;
            move_up_LED <= 0; 
            door_status <= 0;
            flashing_LEDs <= 0; end
            
        reset2 : begin
            call <= 0;
            rst <= 1; 
            move_down_LED <= 0;
            move_up_LED <= 0; 
            door_status <= 0; 
            flashing_LEDs <= 0; end
            
        move20 : begin 
            call <= 4'b0000;
            rst <= 0;
            if(up) begin
                move_up_LED <= 1;
                move_down_LED <= 0; end
            else begin
                move_up_LED <= 0;
                move_down_LED <= 1; end
            flashing_LEDs <= timer2[1]; 
            door_status <= 0; end
            
        slow_finish : begin
            call <= 4'b0000;
            rst <= 0;
            if(up) begin
                move_up_LED <= 1;
                move_down_LED <= 0; end
            else begin
                move_up_LED <= 0;
                move_down_LED <= 1; end
            flashing_LEDs <= timer2[0]; 
            door_status <= 0; end

        open_door : begin
            call <= 4'b0100;
            rst <= 0; 
            move_down_LED <= 0;
            move_up_LED <= 0; 
            door_status <= 1;
            flashing_LEDs <= 0; end
        
        waiting : begin
            call <= 0;
            rst <= 0;  
            move_down_LED <= 0;
            move_up_LED <= 0; 
            door_status <= 1;
            flashing_LEDs <= 0; end
            
        close_door : begin
            call <= 4'b0100;
            rst <= 0;
            move_down_LED <= 0;
            move_up_LED <= 0; 
            door_status <= 0;
            flashing_LEDs <= 0; end
                    
        default : begin
            up <= 0;
            down <= 0;
            call <= 0;
            rst <= 0; 
            move_down_LED <= 0;
            move_up_LED <= 0; 
            door_status <= 0;
            flashing_LEDs <= 0; end
    endcase
end
//assign display_packet = {door_status, current_floor, move_up_LED, move_down_LED};


endmodule
