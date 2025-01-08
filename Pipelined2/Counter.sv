`timescale 1ns/1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
//
// Create Date: 01/25/2024 11:04:00 AM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//////////////////////////////////////////////////////////////////////////////////

module Counter( input logic [BUS_WIDTH-1-2:0] d,
            output logic [BUS_WIDTH-1-2:0] q
            );
             

    always_comb begin
        q = d+1;
     end
       
endmodule
