`timescale 1ns / 1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2023 08:27:25 AM
// Design Name: 
// Module Name: CEP
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


module UART(output logic s_out, uart2csr,
            output type_module2lsu_s       uart2lsu_data,
            input type_lsu2module_data_s  lsu2uart_data,
            input logic clk, rst, s_in
                );
                

logic wr, wr_Udata, wr_Ubaud, wr_Uctr, wr_Uuie, Udata_clr;
logic Udata, Ubaud, Uctr, Uuip, Uuie, tx_complete, rx_complete;
logic baud, tx_start, baud_buffer_full,two_stop_bits, baud_2;
logic wr_data_rx, receive_flag, busy_rx, Udata_rx;

UART_Datapath DP(.clk(clk),.rst(rst),.s_in(s_in),.uart_sel(lsu2uart_data.sel), .rd_en(lsu2uart_data.rd_en), .dbus(lsu2uart_data.dbus),// Come into UART
                .wr_shift(wr), .wr_Udata(wr_Udata), .wr_Ubaud(wr_Ubaud), .wr_Uctr(wr_Uctr), .wr_Uuie(wr_Uuie),  // From Controller
                .Udata(Udata), .Ubaud(Ubaud), .Uctr(Uctr),.Uuie(Uuie), .Uuip(Uuip), .Udata_clr(Udata_clr),      // From Controller
                .tx_complete(tx_complete), .rx_complete(rx_complete),                                           // From Controller
                .wr_data_rx(wr_data_rx), .receive_flag(receive_flag), .busy_rx(busy_rx), .Udata_rx(Udata_rx),     // From Controller
                .baud(baud), .tx_start(tx_start), .baud_buffer_full(baud_buffer_full), .two_stop_bits(two_stop_bits),.baud_2(baud_2),// To controller 
                .s_out(s_out), .u_rd_data(uart2lsu_data.rd_data), .uart2csr(uart2csr)                           // Go out of UART         
                );

UART_Controller Ct(.clk(clk),.rst(rst),.s_in(s_in),.uart_sel(lsu2uart_data.sel), .wr_en(lsu2uart_data.wr_en), .dbus_addr(lsu2uart_data.dbus_addr), // Come into UART
                  .baud(baud), .tx_start(tx_start), .baud_buffer_full(baud_buffer_full),.two_stop_bits(two_stop_bits),.baud_2(baud_2),// From Datapath
                  .tx_complete(tx_complete), .rx_complete(rx_complete),                                        // to Datapath 
                  .wr(wr), .wr_Udata(wr_Udata), .wr_Ubaud(wr_Ubaud), .wr_Uctr(wr_Uctr), .wr_Uuie(wr_Uuie),     // to Datapath 
                  .Udata(Udata), .Ubaud(Ubaud), .Uctr(Uctr), .Uuie(Uuie), .Uuip(Uuip), .Udata_clr(Udata_clr),  // to Datapath
                  .wr_data_rx(wr_data_rx), .receive_flag(receive_flag), .busy_rx(busy_rx), .Udata_rx(Udata_rx)     // to Datapath
                );

                  
                
endmodule
