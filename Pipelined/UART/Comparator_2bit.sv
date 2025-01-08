`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2023 05:02:15 PM
// Design Name: 
// Module Name: Comparator_2bit
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


module Comparator_2bit(output logic out,
                        input [1:0] in0, in1
                    );
always_comb begin
    if(in0 == in1)
        out = 1'b1;
    else
        out = 1'b0;
end                    

endmodule
