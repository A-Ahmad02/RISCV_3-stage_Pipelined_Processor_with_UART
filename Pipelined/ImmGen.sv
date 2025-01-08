`timescale 1ns / 1ps
`include "Header.svh"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2024 11:05:03 AM
// Design Name: 
// Module Name: ImmGen
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

module ImmGen(input logic [BUS_WIDTH-1:0] instr,
                input logic [2:0] imm_gen,
                output logic [BUS_WIDTH-1:0] imm32 
                    );
    always_comb begin
        case(imm_gen)
        3'b000: imm32 = {{20{instr[31]}}, instr[31:20]};         // I-type (jalr and L)
        3'b001: imm32 = {{20{instr[31]}}, instr[31:25], instr[11:7]};// S-type (stores)
        3'b010: imm32 = {{20{instr[31]}}, instr[7],  instr[30:25], instr[11:8], 1'b0};   // B-type
        3'b011: imm32 = {instr[31:12], 12'b0};// U-type (auipc and lui)
        3'b100: imm32 = {{12{instr[31]}}, instr[19:12],  instr[20], instr[30:21], 1'b0};// J-type (jal)
        3'b101: imm32 = {{27{instr[31]}}, instr[24:20]};//I_type (slli + srli + srai)
        3'b110: imm32 = {20'b0, instr[31:20]};         // CSR_type (0 extended)
        default:imm32 = 32'bz; // undefined (For R-Type and undefined cases)
        endcase
    end
                
endmodule

    
//    always_comb 
//    begin
//        case(instr_i[6:0])
//            R_type      :   imm32 = 32'b0;
//            I_type_load :   imm32 = {20'b0,instr_i[31:20]};
//            I_type_imm  :   imm32 = {20'b0,instr_i[31:20]};
//            I_type_jump :   imm32 = {20'b0,instr_i[31:20]};
//            S_type      :   imm32 = {20'b0,instr_i[31:25],instr_i[11:7]};
//            B_type      :   imm32 = {20'b0,instr_i[31:25],instr_i[11:7]};
//            U_type_1    :   imm32 = {12'b0,instr_i[31:12]};
//            U_type_2    :   imm32 = {12'b0,instr_i[31:12]};
//            J_type      :   imm32 = {12'b0,instr_i[31:12]};
//            default     :   imm32 = 32'b0;
//        endcase
//    end
