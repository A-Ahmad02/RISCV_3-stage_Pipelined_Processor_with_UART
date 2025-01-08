`timescale 1ns/1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
//
// Create Date: 01/25/2024 11:04:00 AM
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//////////////////////////////////////////////////////////////////////////////////

module Full_Forwarding_Unit( input logic [4:0] rdMW, rs1DE, rs2DE,
                input logic reg_wrMW, rs1_valid, rs2_valid, br_taken, // Check the validity of the source operands from EXE stage
                input type_opcode_e opcode_MW,
                output logic Flush, [1:0] For_A,For_B
            );
    logic For_W, For_A_M, For_B_M;
    
    // Data Hazard detection
    assign For_A_M = ((rs1DE == rdMW) & reg_wrMW) & rs1_valid;
    assign For_B_M = ((rs2DE == rdMW) & reg_wrMW) & rs2_valid;
    
    // Load Hazard detection in Memory-Writeback
    assign For_W = (opcode_MW == I_type_load) & (For_A_M | For_B_M) ;
    
    // Generate the forwarding signals
    assign For_A = (For_W & For_A_M) + For_A_M;
    assign For_B = (For_W & For_B_M) + For_B_M;
    
    assign Flush = br_taken;
    
    
endmodule
