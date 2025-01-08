`timescale 1ns/1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
//
// Create Date: 01/25/2024 11:04:00 AM
// Design Name: 
// Module Name: Instr_Mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//////////////////////////////////////////////////////////////////////////////////


module Instr_Mem( input logic [BUS_WIDTH-1:0]addr, 
                output logic [BUS_WIDTH-1:0]inst
            );
             
    logic [WIDTH-1:0] mem [DEPTH-1:0];
    
    initial begin
        $readmemh("C:/DriveA/Workspaces/Vivado/CA_Lab/CEP/cep_baud2_3.mem", mem);
    end
      
    always_comb begin
        inst <= {mem[addr],mem[addr+1],mem[addr+2],mem[addr+3]};
    end
    
endmodule
