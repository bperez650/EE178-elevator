// File: fsm.v
// This is the FSM module for EE178 Lab #6.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator timestep should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

 module fsm (
  output wire        busy,
  input  wire        period_expired,
  input  wire        data_arrived,
  input  wire        val_match,
  output wire        load_ptrs,
  output wire        increment,
  output wire        sample_capture,
  input  wire        clk
  //output reg [2:0] state
  );

  // Describe the actual circuit for the assignment.
  reg [2:0] counter = 0;
  reg [2:0] state = 0;
  
   //state = 0;
   
  always @(posedge clk) begin
    if(out[0] || out[2]) counter = 0;
    else counter = counter + 1;
  end
  
  always @(posedge clk) begin
    case(state) 
        //idle wait for data_arrived
        0 : if(data_arrived) state = 1;
            else state = 0;
        //wait for period expired
        1 : if(period_expired) state = 2;
            else state = 1;
        //load ptrs
        2 : state = 3;
        //counter
        3 : if(counter == 2) state = 4;
            else state = 3;
        //capture data
        4 : if(val_match) state = 0;
            else state = 5;
        //wait for period expired
        5 : if(period_expired) state = 6;
            else state = 5;
        //increment
        6 : state = 3;
        default : state = 0;
    endcase
  end

 reg [3:0] out;
 assign {busy, increment, sample_capture, load_ptrs} = out;
 always @* begin
    if(state == 0) out = 4'b0000;
    if(state == 1) out = 4'b1000;
    if(state == 2) out = 4'b1001;
    if(state == 3) out = 4'b1000;
    if(state == 4) out = 4'b1010;
    if(state == 5) out = 4'b1000;
    if(state == 6) out = 4'b1100;
end
    
    
      
endmodule
