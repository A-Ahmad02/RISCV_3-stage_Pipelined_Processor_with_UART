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

module Memory_Writeback(input logic clk, rst, uart_s_in,

                input type_m_ctr_s m_ctr,
                input type_w_ctr_s w_ctr,
                input type_de2mw_data_s  de2mw_data_pipe_ff,
                
                input type_csr_ctr_s csr_ctr,
                
                output  uart_s_out,
                output type_csr2f_fb_data_s csr2f_fb_data,
                output type_csr2f_ctr_s csr2f_ctr,
                output type_mw2de_fb_data_s  mw2de_fb_data
                );

logic [BUS_WIDTH-1:0] rdata, csr_rdata;
                
assign mw2de_fb_data.alu_out = de2mw_data_pipe_ff.alu_out;
assign mw2de_fb_data.inst = de2mw_data_pipe_ff.inst;


// Memory
Memory MEM(
    .clk(clk),.rst(rst),.addr(de2mw_data_pipe_ff.alu_out), .wdata(de2mw_data_pipe_ff.wdata), .uart_s_in(uart_s_in),
    .m_ctr(m_ctr), .rdata(rdata), .uart_s_out(uart_s_out), .instMW(de2mw_data_pipe_ff.inst),
    .pc(de2mw_data_pipe_ff.pc), .csr_ctr(csr_ctr), .e2csr_data(de2mw_data_pipe_ff.e2csr_data), // .exc2csr_data(de2mw_data_pipe_ff.exc2csr_data),
    .csr2f_fb_data(csr2f_fb_data), .csr_rdata(csr_rdata), .csr2f_ctr(csr2f_ctr)
);

// Writeback
Writeback WB(
    .pc(de2mw_data_pipe_ff.pc), .rdata(rdata), .data_addrMW(de2mw_data_pipe_ff.alu_out), .csr_rdata(csr_rdata),
    .wb_sel(w_ctr.wb_sel),.wbdataMW(mw2de_fb_data.wbdata)
);

endmodule
