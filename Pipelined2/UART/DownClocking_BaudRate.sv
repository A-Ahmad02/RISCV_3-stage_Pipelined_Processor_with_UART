`timescale 1ns / 1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2023 05:15:32 PM
// Design Name: 
// Module Name: DownClocking_BaudRate
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


module DownClocking_BaudRate(input clock_in, rst,
                        input logic [26:0] baud_div,
                        output reg clock_out
                            );
	
	logic [BUS_WIDTH-1:0]  cnt;
	always_ff @ (posedge clock_in or negedge rst) // negedge clock_in or 
	begin
	 if (!rst) begin
		cnt <= 0;
		clock_out <= 0;
		end
    else if (cnt >= baud_div )begin 
          cnt <= 0;
          clock_out <= ~clock_out;
        end
	 else 
		cnt <= cnt+1;
	end

endmodule

	
//	always_comb begin
//		if (cnt >= 10)
//		      clock_out = 1;
//		else
//		      clock_out = 0;
//    end
	