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
// 
//////////////////////////////////////////////////////////////////////////////////

module Decode(input logic clk,rst,
            input type_d_ctr_s d_ctr,
            input logic [BUS_WIDTH-1:0] instDE, instMW, wbdataMW, 
            output type_d2e_data_s  d2e_data
		);
		
logic [4:0] addr_rs1, addr_rs2, addr_rd;
assign addr_rs1 = instDE[19:15];
assign addr_rs2 = instDE[24:20];
assign addr_rd  = instMW[11:7];

// Decode
ImmGen im(.instr(instDE), .imm_gen(d_ctr.imm_gen), .imm32(d2e_data.imm32));

Reg_file R1(.wr(d_ctr.reg_wrMW), .rst(rst), .clk(clk),
        .addr_rs1(addr_rs1), .addr_rs2(addr_rs2), .addr_rd(addr_rd), 
        .rs1(d2e_data.rdata1), .rs2(d2e_data.rdata2),.rd(wbdataMW)
        );

endmodule
