`timescale 1ns / 1ps
`include "Header.svh"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2024 11:05:03 AM
// Design Name: 
// Module Name: Instr_Decoder_32
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

module BranchCond(input logic [2:0] br_type,
                   input logic [BUS_WIDTH-1:0] A, B,
                   output logic br_taken
                    );
type_B_op_e branch;
assign branch = type_B_op_e' (br_type);

    always_comb 
    begin
		case (branch) // Used funct3 to decide branch except br_type = 2 and 3
			beq : br_taken = (A==B)? 1:0;	                     //beq
			bne : br_taken = (A!=B)? 1:0;	                     //bne
			no_jump : br_taken = 0;	                            //no jump
			jump : br_taken = 1;	       //jalr,jal (unconditional jump)
			blt : br_taken = ($signed(A) < $signed(B))?  1:0;	 //blt
			bge : br_taken = ($signed(A) >= $signed(B))? 1:0;	 //bge
			bltu : br_taken = (A<B)?  1:0;	                     //bltu
			bgeu : br_taken = (A>=B)? 1:0;	                     //bgeu
			default: br_taken = 0;
        endcase
    end
                
endmodule
