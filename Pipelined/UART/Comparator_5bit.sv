`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2023 05:45:20 PM
// Design Name: 
// Module Name: Comparator_5bit
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


module Comparator_5bit(output logic out,
                        input [4:0] in0, in1
                    );
always_comb begin
    if(in0 == in1)
        out = 1'b1;
    else
        out = 1'b0;
end                    

endmodule

