`timescale 1ns / 1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2024 11:03:10 AM
// Design Name: 
// Module Name: MUX2x1
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

module MUX2x1_1bit(  input logic sel1,in0,in1,
                output logic  out
                );
    
    always @(sel1 or in0 or in1) begin
        case(sel1)
            1'b0: begin out= in0 ; end
            1'b1: begin out= in1 ; end
        endcase
    end
endmodule

