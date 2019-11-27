// File: narrator.v
// This is the top level design for EE178 Lab #6.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator timestep should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module narrator (
  input  wire clk,
  input wire [3:0] call,
  input wire [2:0] current_floor,
  input wire door_status,
  //input wire up,
  output wire speaker
  );
  
  // Create a test circuit to exercise the chatter
  // module, rather than using switches and a
  // button.
  
  reg   [6:0] counter = 0;
  reg   [5:0] data;
  wire write;
  wire busy;
  reg restart = 1;
  reg [1:0] state1 = 0;
  reg [3:0] call_st;
  reg door_st;
  //reg move_st;

  always @(posedge clk) begin
    if (restart) counter <= 0;
    if (!busy) counter <= counter + 1; end


  always @(posedge clk) begin
      case(state1)
        0 : if(call) begin 
                state1 <= 1; 
                call_st <= call; 
                //move_st <= up;  
                door_st <= door_status; end
            else state1 <= 0;
        1 : state1 <= 2;
        2 : if(counter[6:2] > 15) begin 
                state1 <= 0;
                call_st <= 0; end
            else state1 <= 2;
        default : state1 <= 0;
      endcase
  end
  
    always @(posedge clk) begin
      case(state1)
        0 : restart <= 1;
        1 : restart <= 0;
        2 : begin
            case(call_st)
                4'b0001: //floor
                    case(current_floor)
                        1 :  case (counter[6:2])
                              0:  data <= 6'h04;
                              1:  data <= 6'h2E; 
                              2:  data <= 6'h0F; 
                              3:  data <= 6'h0B; 
                              default: data <= 6'h04;
                            endcase                        
                        2 :  case (counter[6:2])
                              0:  data <= 6'h04;
                              1:  data <= 6'h0D; 
                              2:  data <= 6'h1F; 
                              default: data <= 6'h04;
                            endcase
                        3 :  case (counter[6:2])
                              0:  data <= 6'h04;
                              1:  data <= 6'h1D; 
                              2:  data <= 6'h0E;
                              3:  data <= 6'h13; 
                              default: data <= 6'h04;
                            endcase
                        4 :  case (counter[6:2])
                              0:  data <= 6'h04;
                              1:  data <= 6'h28; 
                              2:  data <= 6'h28; 
                              3:  data <= 6'h3A; 
                              default: data = 6'h04;
                            endcase
                        endcase//floor
                        
//                4'b0010 : //up/down
//                    case(move_st)
//                        0 : case (counter[6:2]) //going down
//                              0:  data <= 6'h04;
//                              1:  data <= 6'h21; 
//                              2:  data <= 6'h20; 
//                              3:  data <= 6'h0B; 
//                              default: data <= 6'h04;
//                            endcase                        
//                        1 :  case (counter[6:2])    //going up
//                              0:  data <= 6'h04;
//                              1:  data <= 6'h0F; 
//                              2:  data <= 6'h01; 
//                              3:  data <= 6'h02; 
//                              4:  data <= 6'h09;
//                              default: data <= 6'h04;
//                            endcase
//                    endcase //up/down
                            
                4'b0100 : //door
                    case(door_st)
                        0 : case (counter[6:2]) //door closed
                              0:  data <= 6'h04;
                              1:  data <= 6'h2A; 
                              2:  data <= 6'h2D; 
                              3:  data <= 6'h35; 
                              4:  data <= 6'h37;
                              default: data <= 6'h04;
                            endcase                        
                        1 :  case (counter[6:2])    //door open
                              0:  data <= 6'h04;
                              1:  data <= 6'h35; 
                              2:  data <= 6'h09; 
                              3:  data <= 6'h07; 
                              4:  data <= 6'h0B;
                              default: data <= 6'h04;
                            endcase
                    endcase //door
                default : data <= 6'h04;
            endcase//call_st
            end
        default : restart <= 1;
      endcase//state1
  end
  


  assign write = (counter[1:0] == 2'b00);
  
  // Instantiate the chatter module, which is
  // driven by the test circuit.

  chatter chatter_inst (
    .data(data),
    .write(write),
    .busy(busy),
    .clk(clk),
    .speaker(speaker)
//    .state(state)
  );

endmodule
