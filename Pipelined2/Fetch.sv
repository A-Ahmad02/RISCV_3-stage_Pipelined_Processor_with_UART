`timescale 1ns/1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////

module Fetch(input logic clk,rst,
             input type_f_ctr_s f_ctr,
             input type_de2f_fb_data_s  de2f_fb_data,
             input type_csr2f_fb_data_s csr2f_fb_data,
             input type_csr2f_ctr_s csr2f_ctr,
             output type_f2de_data_s  f2de_data,
             output NO_FLUSH
             );

logic [BUS_WIDTH-1-2:0] pc_4_F;
logic [BUS_WIDTH-1:0] addrF, addr_mux1;

//logic exc_Imem_addr;

//always_comb begin
//    f2de_data.exc2csr_data = '0;
//    f2de_data.exc2csr_data.f_Imem_misalign = ~(f2de_data.pc[1:0] == 2'b00);
//    f2de_data.exc2csr_data.f_Imem_access_fault = ~(f2de_data.pc[BUS_WIDTH-1:ADDR] == 0);
//end

//assign exc_Imem_addr = ~(f2de_data.pc[1:0] == 2'b00) | ~(f2de_data.pc[BUS_WIDTH-1:ADDR] == 0); // Check for Misaligned access and mem size

// Fetch
Counter C1(.d(f2de_data.pc[BUS_WIDTH-1:2]),.q(pc_4_F)); // Counter Width is [BUS_WIDTH-1-2:0]
MUX2x1 m1(.sel1(f_ctr.br_taken),.in0({pc_4_F,2'b0}),.in1(de2f_fb_data.alu_out),.out(addr_mux1)); // MUX Width is [BUS_WIDTH-1:0]

MUX2x1 m2(.sel1(csr2f_ctr.epc_taken),.in0(addr_mux1),.in1(csr2f_fb_data.epc_evec),.out(addrF)); // MUX Width is [BUS_WIDTH-1:0]

FF_32bit PC1(.rst(rst),.clk(clk),.d(addrF),.q(f2de_data.pc),.en(1'b1)); // PC_FF
Instr_Mem M1(.addr(f2de_data.pc),.inst(f2de_data.inst));

FF_1bit PC2(.rst(rst),.clk(clk),.d(csr2f_ctr.epc_taken),.q(NO_FLUSH),.en(1'b1)); // PC_FF

endmodule
