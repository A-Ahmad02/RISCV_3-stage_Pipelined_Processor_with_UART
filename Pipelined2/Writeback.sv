`timescale 1ns/1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////

module Writeback(input logic [BUS_WIDTH-1:0] pc, rdata, data_addrMW, csr_rdata,
		 input logic [1:0] wb_sel,
		 output logic [BUS_WIDTH-1:0] wbdataMW
		);

logic [BUS_WIDTH-1-2:0] pc_4_MW;

// Writeback
Counter C2(.d(pc[BUS_WIDTH-1:2]),.q(pc_4_MW)); //PC+4 (+1 here) // Counter Width is [BUS_WIDTH-1-2:0]
MUX4x1 m4(.sel2(wb_sel),.in0(rdata),.in1(data_addrMW),.in2({pc_4_MW,2'b0}),.in3(csr_rdata),.out(wbdataMW));

endmodule
