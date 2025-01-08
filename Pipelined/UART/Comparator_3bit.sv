`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2023 11:04:01 AM
// Design Name: 
// Module Name: Comparator_3bit
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


module Comparator_3bit(output logic out,
                        input [2:0] in0, in1
                    );
always_comb begin
    if(in0 == in1)
        out = 1'b1;
    else
        out = 1'b0;
end                    

endmodule
