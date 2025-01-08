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

module DataPath(input logic clk,rst, Flush, uart_s_in,
                input type_d_ctr_s d_ctr,
                input type_e_ctr_s e_ctr,
                input type_m_ctr_s m_ctr_MW,
                input type_w_ctr_s w_ctr_MW,
                input type_csr_ctr_s csr_ctr_MW,
                output type_f_ctr_s f_ctr,
                output logic uart_s_out, [BUS_WIDTH-1:0] instDE, instMW);

type_f2de_data_s  f2de_data_pipe_ff, f2de_data;
type_de2mw_data_s  de2mw_data_pipe_ff, de2mw_data;
type_mw2de_fb_data_s  mw2de_fb_data;
type_de2f_fb_data_s  de2f_fb_data;

type_csr2f_fb_data_s csr2f_fb_data;
type_csr2f_ctr_s csr2f_ctr;

logic NO_FLUSH;

assign instDE = f2de_data_pipe_ff.inst;
assign instMW = de2mw_data_pipe_ff.inst;


// Fetch
Fetch FETCH(
    .clk(clk),.rst(rst),.f_ctr(f_ctr), .csr2f_ctr(csr2f_ctr),
    .csr2f_fb_data(csr2f_fb_data), .de2f_fb_data(de2f_fb_data),
    .f2de_data(f2de_data), .NO_FLUSH(NO_FLUSH)
);

// Fetch <-----> Decode pipeline
always_ff @(posedge clk or negedge rst) begin
    if (!rst) 
        f2de_data_pipe_ff <= '0;
    else if (Flush & NO_FLUSH) begin
         f2de_data_pipe_ff.pc <= f2de_data.pc;// - 4;
         f2de_data_pipe_ff.inst <= f2de_data.inst;
         end
    else if (Flush) begin
         f2de_data_pipe_ff.pc <= f2de_data.pc;
         f2de_data_pipe_ff.inst <= 'h00000013;
    end else
        f2de_data_pipe_ff <= f2de_data;
end

// Decode
Decode_Execute DEC_EXE(
    .clk(clk), .rst(rst),
    .d_ctr(d_ctr), .e_ctr(e_ctr), 
    .f2de_data_pipe_ff(f2de_data_pipe_ff), 
    .mw2de_fb_data(mw2de_fb_data),
    .f_ctr(f_ctr), .de2mw_data(de2mw_data), .de2f_fb_data(de2f_fb_data)
);

// Execute ----> Memory pipeline
always_ff @(posedge clk or negedge rst) begin
    if (!rst) 
        de2mw_data_pipe_ff <= '0;
    else
        de2mw_data_pipe_ff <= de2mw_data;
end  

// Memory
Memory_Writeback MEM_WB(
    .clk(clk), .rst(rst), .m_ctr(m_ctr_MW),.w_ctr(w_ctr_MW), .csr_ctr(csr_ctr_MW),
    .de2mw_data_pipe_ff(de2mw_data_pipe_ff),  .uart_s_in(uart_s_in),
    .mw2de_fb_data(mw2de_fb_data), .uart_s_out(uart_s_out),
    .csr2f_fb_data(csr2f_fb_data), .csr2f_ctr(csr2f_ctr)
);


endmodule
