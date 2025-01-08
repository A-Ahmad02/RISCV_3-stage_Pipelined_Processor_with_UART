`timescale 1ns / 1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2023 11:33:32 AM
// Design Name: 
// Module Name: Reloadable_DownCounter_10bit
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


module Loaded_DownCounter(input rst, clk, 
                    input reg [3:0] sel,
                    output logic [3:0] cnt
    );
//    logic reload;
   always @(posedge clk or negedge rst)
    begin
    if(!rst)
        cnt <= sel;
    else if (cnt=='d0)
        cnt <= 0;
    else 
        cnt <= cnt - 1;
    end
    
endmodule
    
