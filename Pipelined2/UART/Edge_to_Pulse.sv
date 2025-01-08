`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2023 08:32:26 PM
// Design Name: 
// Module Name: Level_to_Pulse
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


module Edge_to_Pulse(output pulse,
                    input logic clk,rst, level
    );
wire Q;
D_FlipFlop DFF(.q(Q), .clk(clk) , .rst(rst), .en(1'b1), .d(level),.load(1'b0));  
and a1(pulse,~Q,level);
endmodule
