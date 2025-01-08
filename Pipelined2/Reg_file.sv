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
//////////////////////////////////////////////////////////////////////////////////

module Reg_file( input logic wr, rst, clk,
                input logic [4:0] addr_rs1, addr_rs2, addr_rd,
                input logic [BUS_WIDTH-1:0] rd,
                output logic [BUS_WIDTH-1:0] rs1, rs2
            );
             
    logic [BUS_WIDTH-1:0] reg_file [31:0];
    
    always_comb begin   //Async Read
        rs1 <= reg_file[addr_rs1];
        rs2 <= reg_file[addr_rs2];
    end
    
    always_ff @(posedge clk or negedge rst) begin   // Sync write
        if(!rst)
			reg_file <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};//{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		else if(addr_rd==0)
            reg_file[0] <= 0;
		else if(wr)
            reg_file[addr_rd] <= rd;
         else
            reg_file <= reg_file;

    end
       
endmodule
