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

module Pipelined_Processor( input logic clk, rst, uart_s_in,
                            output logic uart_s_out
                            );

logic [BUS_WIDTH-1:0] instDE,instMW; 
logic Flush;
type_d_ctr_s d_ctr;
type_e_ctr_s e_ctr;
type_m_ctr_s m_ctr;
type_w_ctr_s w_ctr;
type_f_ctr_s f_ctr;
type_csr_ctr_s csr_ctr;


// .funct({inst[30],inst[25],inst[14:12]}),.opcode(inst[6:0]),
ControlPath c1(
    .clk(clk), .rst(rst), .instDE(instDE), .instMW(instMW), .f_ctr(f_ctr), 
    .d_ctr(d_ctr), .e_ctr(e_ctr), .m_ctr_MW(m_ctr), .w_ctr_MW(w_ctr), .csr_ctr_MW(csr_ctr), .Flush(Flush)
);

DataPath dp1(
    .clk(clk),.rst(rst), .uart_s_out(uart_s_out), 
    .d_ctr(d_ctr), .e_ctr(e_ctr), .m_ctr_MW(m_ctr), .w_ctr_MW(w_ctr), .csr_ctr_MW(csr_ctr), .Flush(Flush),
    .instDE(instDE),.instMW(instMW), .f_ctr(f_ctr), .uart_s_in(uart_s_in)
);

endmodule
