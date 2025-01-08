`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2023 04:16:48 PM
// Design Name: 
// Module Name: ShiftReg_10bit
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


module ShiftReg_10bit_Rx(output logic [9:0] data,
                        input logic clk,rst, en, in
                    );   
               
D_FlipFlop DFF1(.q(data[9]), .clk(clk) , .rst(rst), .en(en), .d(in), .load(1'b0));   // Async load

for ( genvar j = 1; j < 10; j++) begin
    D_FlipFlop DFF(.q(data[9-j]), .clk(clk) , .rst(rst), .en(en), .d(data[10-j]), .load(1'b0));  
end


endmodule
