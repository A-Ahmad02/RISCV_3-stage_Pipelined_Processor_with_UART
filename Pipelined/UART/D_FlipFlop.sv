`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2023 10:04:56 PM
// Design Name: 
// Module Name: D-FlipFlop
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


module D_FlipFlop(  output logic q,
                    input logic clk, rst, en, d, load
                    );

always_ff @ (posedge clk or negedge rst or posedge load)
begin
    if (!rst)
        q <= 1'b1;
    else if (load)
        q <= d;
    else
        begin
            if (en)
            q <= d;
            else
            q <= q;
        end
end

endmodule
