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


module ShiftReg_10bit_Tx(output logic out,
                    input logic [9:0] data,
                    input logic clk,rst,sel,en
                );   
                 
logic [8:0] Q;   
logic [9:0] d_in;

MUX2x1_1bit M3(.sel1(sel), .in0(1'b1), .in1(data[9]),  .out(d_in[0]));
D_FlipFlop DFF1(.q(Q[8]), .clk(clk) , .rst(rst), .en(en), .d(d_in[0]), .load(sel));   // Async load

for ( genvar j = 1; j < 9; j++) begin
    MUX2x1_1bit M2(.sel1(sel), .in0(Q[8-j+1]), .in1(data[9-j]), .out(d_in[j]));
    D_FlipFlop DFF(.q(Q[8-j]), .clk(clk) , .rst(rst), .en(en), .d(d_in[j]), .load(sel));  
end

MUX2x1_1bit M4(.sel1(sel), .in0(Q[0]), .in1(data[0]), .out(d_in[9]));
D_FlipFlop DFF2(.q(out), .clk(clk) , .rst(rst), .en(en), .d(d_in[9]), .load(sel));   

endmodule
