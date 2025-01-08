`timescale 1ns / 1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 01/17/2024 11:04:00 AM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//////////////////////////////////////////////////////////////////////////////////

module Processor_tb;

logic rst, clk, s_out, s_in;

Pipelined_Processor UUT(
.rst(rst), .clk(clk), .uart_s_out(s_out), .uart_s_in(s_in)
);

initial // All initial blocks run in parallel
begin
    //initial value of clock
    clk = 1'b1;
    #2;
    //generating clock signal
    forever #10 clk = ~clk;
end

initial  //Driver
begin
    rst = 1'b1;
    #1;
    rst = 1'b0; // Active low reset
    #1;
    rst = 1'b1;
    #1000;

//    $finish;
end

assign     s_in = s_out; 

endmodule