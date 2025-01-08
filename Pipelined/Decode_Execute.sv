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

module Decode_Execute(
            input logic clk,rst,
            input type_d_ctr_s d_ctr,
            input type_e_ctr_s e_ctr,
            input type_f2de_data_s  f2de_data_pipe_ff,
            input type_mw2de_fb_data_s  mw2de_fb_data,
            
            output type_f_ctr_s f_ctr,
            output type_de2mw_data_s  de2mw_data,
            output type_de2f_fb_data_s  de2f_fb_data
		        );

type_d2e_data_s  d2e_data;
assign de2mw_data.pc = f2de_data_pipe_ff.pc;
assign de2mw_data.inst = f2de_data_pipe_ff.inst;
assign de2f_fb_data.alu_out = de2mw_data.alu_out;

//always_comb begin
//    de2mw_data.exc2csr_data = f2de_data_pipe_ff.exc2csr_data;
//    de2mw_data.exc2csr_data.d_illegal_opcode = d_ctr.illegal_opcode;
//end

// Decode
Decode DEC(
    .clk(clk),.rst(rst),.d_ctr(d_ctr),
    .instDE(f2de_data_pipe_ff.inst),.instMW(mw2de_fb_data.inst),.wbdataMW(mw2de_fb_data.wbdata), 
    .d2e_data(d2e_data)
);
                
// Execute
Execute EXE(
    .e_ctr(e_ctr), 
    .d2e_data(d2e_data),.pc(f2de_data_pipe_ff.pc),
    .mw2de_fb_data(mw2de_fb_data), 
    .br_taken(f_ctr), .rdata2(de2mw_data.wdata), .addr(de2mw_data.alu_out),
    .e2csr_data(de2mw_data.e2csr_data) //,.over_under_flow(de2mw_data.exc2csr_data.e_over_under_flow) 
);

endmodule
