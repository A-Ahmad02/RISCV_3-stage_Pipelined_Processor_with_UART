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


module DownCounter_1bit(input rst, clk, load,
                    input logic load_val,
                    output logic cnt
    );
    
   always @(posedge clk or negedge rst)
    begin
    if(!rst)
        cnt <= '0;
    else if (load)
        cnt <= load_val;
    else 
        cnt <= cnt - 1;
    end
    
endmodule
    
