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

module Memory(  input logic clk, rst, uart_s_in,
                input logic [BUS_WIDTH-1:0]addr, wdata, pc, instMW, 
                input type_m_ctr_s m_ctr,
                
                input type_csr_ctr_s csr_ctr,
                input type_e2csr_data_s  e2csr_data,
//                input type_exc2csr_data_s exc2csr_data,
                
                output type_csr2f_fb_data_s csr2f_fb_data,
                output type_csr2f_ctr_s csr2f_ctr,
                output logic uart_s_out, [BUS_WIDTH-1:0]rdata, csr_rdata
            );

type_module2lsu_s       uart2lsu_data, dmem2lsu_data;
type_lsu2module_data_s  lsu2uart_data, lsu2dmem_data;
logic uart_exc;
//type_exc2csr_data_s     exc2csr;

//always_comb begin
//    exc2csr = exc2csr_data;
//    exc2csr.m_Dmem_misalign = ~(pc[1:0] == 2'b00);
//    exc2csr.m_Dmem_access_fault = ~(pc[BUS_WIDTH-1:ADDR] == 0);
//end
                        
Load_Store_Unit LSU(.m_ctr(m_ctr), .addr(addr), .wdata(wdata), .rdata(rdata),
                .uart2lsu_data(uart2lsu_data), .dmem2lsu_data(dmem2lsu_data),
                .lsu2uart_data(lsu2uart_data), .lsu2dmem_data(lsu2dmem_data)
                );

Data_Mem M2(.clk(clk), .lsu2dmem_data(lsu2dmem_data),.dmem2lsu_data(dmem2lsu_data));

UART U( .s_out(uart_s_out),.s_in(uart_s_in),.clk(clk),.rst(rst),
        .lsu2uart_data(lsu2uart_data),.uart2lsu_data(uart2lsu_data), .uart2csr(uart_exc)
        );

// CSR
CSR_Reg_file CSR_Reg(
    .clk(clk),.rst(rst), .csr_ctr(csr_ctr), .instMW(instMW),
    .e2csr_data(e2csr_data), .csr_pc(pc), .exc_uart(uart_exc),
    .csr_rdata(csr_rdata), .csr2f_fb_data(csr2f_fb_data), .csr2f_ctr(csr2f_ctr)
);

endmodule
