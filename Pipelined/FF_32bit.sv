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

module FF_32bit( input logic rst, clk, en, [BUS_WIDTH-1:0] d,
            output logic [BUS_WIDTH-1:0] q
            );
             

    always_ff @(posedge clk or negedge rst) begin
        if(!rst)
			q <= 0;
		else begin
		    if (en)
                q <= d;
            else
                q <= q;
          end
    end
       
endmodule
