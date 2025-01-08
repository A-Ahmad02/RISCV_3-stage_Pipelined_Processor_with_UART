`timescale 1ns/1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////

module Execute( input type_e_ctr_s e_ctr, 
                input type_d2e_data_s  d2e_data,
                input type_mw2de_fb_data_s  mw2de_fb_data,
		        input logic [BUS_WIDTH-1:0] pc,
                output logic br_taken, //over_under_flow,
                output type_e2csr_data_s e2csr_data,
		        output logic [BUS_WIDTH-1:0] rdata2, addr
		);

logic [BUS_WIDTH-1:0] rdata1, ALU_A, ALU_B;
logic over_under_flow;

assign e2csr_data.data = rdata1;
assign e2csr_data.addr = d2e_data.imm32;

// Execute
MUX3x1 mf1(.sel2(e_ctr.For_A),.in0(d2e_data.rdata1),.in1(mw2de_fb_data.alu_out),.in2(mw2de_fb_data.wbdata),.out(rdata1)); 
MUX3x1 mf2(.sel2(e_ctr.For_B),.in0(d2e_data.rdata2),.in1(mw2de_fb_data.alu_out),.in2(mw2de_fb_data.wbdata),.out(rdata2)); 

MUX2x1 m2(.sel1(e_ctr.sel_A),.in0(pc),.in1(rdata1),.out(ALU_A));
MUX2x1 m3(.sel1(e_ctr.sel_B),.in0(d2e_data.imm32),.in1(rdata2),.out(ALU_B));

BranchCond b1(.br_type(e_ctr.br_type),.A(rdata1), .B(rdata2), .br_taken(br_taken));
ALU A1(.opselect_i(e_ctr.alu_op),.A(ALU_A),.B(ALU_B),.out(addr), .over_under_flow(over_under_flow));

endmodule
