`timescale 1ns / 1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2024 11:04:00 AM
// Design Name: 
// Module Name: ALU
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


module ALU( input logic [BUS_WIDTH-1:0] A, B,
            input logic [3:0] opselect_i,
            output logic over_under_flow, [BUS_WIDTH-1:0] out
            );

    always_comb begin
        over_under_flow = 1'b0;
        
        case(opselect_i)
        0 : begin 
                out = A + B ;              // Addition
                over_under_flow = ~(A[BUS_WIDTH-1]^B[BUS_WIDTH-1]) & (A[BUS_WIDTH-1]^out[BUS_WIDTH-1]);
            end
        1 : begin 
                out = A - B ;              // Subtraction
                over_under_flow = (A[BUS_WIDTH-1]^B[BUS_WIDTH-1]) & (A[BUS_WIDTH-1]^out[BUS_WIDTH-1]);
            end
        2 : out = A << B[4:0];         // Logical shift left   //max shifting limit of 31 bits = 2^5, so 5-bit binary number can do till 31 bit shift
        3 : out = A >> B[4:0];         // Logical shift right
        4 : out = A >>> B[4:0];        // Arithmetic Shift right
        5 : out = A & B;               // Logical and
        6 : out = A | B;               // Logical or
        7 : out = A ^ B;               // Logical xor
        8 : out = (A < B) ? 32'd1 : 32'd0 ;//  Set less than unsigned
        9 : out = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; //  Set less than signed
        10: out = B;                    // lui (pass imm)
        default: begin 
                    out = A + B ;              // Addition
                    over_under_flow = ~(A[BUS_WIDTH-1]^B[BUS_WIDTH-1]) & (A[BUS_WIDTH-1]^out[BUS_WIDTH-1]);
                end
        endcase

    end
       
endmodule
