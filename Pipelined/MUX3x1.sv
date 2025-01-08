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

module MUX3x1(  input logic [1:0] sel2,
                input logic [BUS_WIDTH-1:0] in0,in1,in2,
                output logic [BUS_WIDTH-1:0] out
                );
    
    always @(sel2 or in0 or in1 or in2) begin
        case(sel2)
            2'b00   : out = in0 ;
            2'b01   : out = in1 ;
            2'b10   : out = in2 ;
            default : out = 0 ;
        endcase
    end
endmodule

