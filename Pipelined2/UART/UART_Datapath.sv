`timescale 1ns / 1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2023 04:54:29 PM
// Design Name: 
// Module Name: Datapath
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


module UART_Datapath(input logic [BUS_WIDTH-1:0] dbus,
                input logic wr_shift, clk, rst,  wr_Uctr, wr_Udata, wr_Ubaud, wr_Uuie, uart_sel, rd_en, Udata_clr, 
                input logic Udata, Ubaud, Uctr, Uuie, Uuip, tx_complete, rx_complete, 
                input logic s_in, wr_data_rx, receive_flag, busy_rx, Udata_rx,
                output logic two_stop_bits, baud_2, uart2csr,
                output logic s_out, baud, tx_start, baud_buffer_full, 
                output logic [BUS_WIDTH-1:0] u_rd_data
                );  
logic [BUS_WIDTH-1:0] baud_div, data_tx,  control, baud_buffer, baud_buff, data_rx, u_data_rx; 
logic [BUS_WIDTH-1:0] u_data, u_ctr, u_baud, u_uip, uie, uip;
logic [9:0] shift_reg_rx;

 
// Generate Baud
DownClocking_BaudRate DC1(.clock_in(clk), .baud_div({baud_div[26:1],1'b1}), .rst(rst), .clock_out(baud));  // baud_div has max 27 bits as log2(10^8)=26.5754bits
// Generate Baud/2
DownClocking_BaudRate DC2(.clock_in(clk), .baud_div({(baud_div[26:1])>>1,1'b1}), .rst(rst), .clock_out(baud_2)); 

// Write to U_Rx_DATA register
MUX2x1 m5(.sel1(two_stop_bits),.in0({busy_rx,23'b0,shift_reg_rx[8:1]}),.in1({busy_rx,23'b0,shift_reg_rx[9:2]}),.out(u_data_rx)); // MUX Width is [BUS_WIDTH-1:0]
FF_32bit U_Rx_DATA( .rst(rst), .clk(clk), .en(wr_data_rx), .d(u_data_rx), .q(data_rx) );

// Write to U_Tx_DATA register
MUX2x1 m1(.sel1(Udata_clr),.in0({1'b1,dbus[30:0]}),.in1(32'b0),.out(u_data)); // MUX Width is [BUS_WIDTH-1:0]
FF_32bit U_Tx_DATA( .rst(rst), .clk(clk), .en(wr_Udata), .d(u_data), .q(data_tx) );

// Maintain U_BAUD buffer for writes out of load state
MUX2x1 m3(.sel1(Ubaud),.in1({1'b1,dbus[30:0]}),.in0(32'b0),.out(baud_buff)); // writes out of load stage
FF_32bit U_BAUD_BUFFER( .rst(rst), .clk(clk), .en(Ubaud), .d(baud_buff), .q(baud_buffer) );
MUX2x1 m2(.sel1(Ubaud),.in1(dbus),.in0(baud_buffer),.out(u_baud)); // writes only in load stage
FF_32bit U_BAUD( .rst(rst), .clk(clk), .en(wr_Ubaud), .d(u_baud), .q(baud_div) );

// Maintain U_CTR Register (bit0 is Tx_start and bit1 decides one ortwo stop bits)
MUX2x1 m4(.sel1(Uctr),.in1(dbus),.in0(control & 'hFFFFFFFC),.out(u_ctr)); // MUX Width is [BUS_WIDTH-1:0]
FF_32bit U_CTR ( .rst(rst), .clk(clk), .en(wr_Uctr) , .d(u_ctr), .q(control) );


assign tx_start = control[0];
assign two_stop_bits = control[1];
assign baud_buffer_full = baud_buffer[31];

// Transmission Shift Register
ShiftReg_10bit_Tx Sr_Tx(.out(s_out), .data({data_tx[7:0],1'b0,1'b1}), .clk(baud), .rst(rst), .en(1'b1), .sel(wr_shift));   
// Receiving Shift Register
ShiftReg_10bit_Rx Sr_Rx(.in(s_in), .data(shift_reg_rx), .clk(baud_2), .rst(rst), .en(receive_flag));   
  
//  Handles UART register reads
always_comb begin
    if(uart_sel & rd_en) 
            case({Udata, Ubaud, Uctr, Udata_rx, Uuie, Uuip}) 
                6'b100000     : u_rd_data <= data_tx & 'h80000000;
                6'b010000     : u_rd_data <= baud_div;
                6'b001000     : u_rd_data <= control; 
                6'b000100     : u_rd_data <= data_rx & ~'h80000000; 
                6'b000010     : u_rd_data <= uie; 
                6'b000001     : u_rd_data <= uie; 
                default    : u_rd_data <= 32'b0; // Default is None 
            endcase  
    else
        u_rd_data <= 32'b0;
end    

logic [1:0] uart_interrupt_pending;

// Reading the UART_Rx_DATA clears the receive complete interrupt bit 1 of uip(uip & 'hFFFFFFFD)
MUX2x1 m6(.sel1(Udata_rx),.in0({30'b0,uart_interrupt_pending}),.in1(uip & 'hFFFFFFFD),.out(u_uip)); // MUX Width is [BUS_WIDTH-1:0]
FF_32bit U_IP( .rst(rst), .clk(clk), .en(uart2csr|Udata_rx), .d(u_uip), .q(uip) );
FF_32bit U_IE( .rst(rst), .clk(clk), .en(wr_Uuie), .d(dbus), .q(uie) );

// Instantiate UART interrupt module
uart_interrupt uart_interrupt_inst (
    .clk(clk), .rst_n(rst),
    .uart_tx_complete(tx_complete), // Replace with  UART TX completion signal
    .uart_rx_complete(rx_complete), // Replace with  UART RX completion signal
    .uart_interrupt_enable_tx(uie[0]), // Replace with  UART TX interrupt enable signal
    .uart_interrupt_enable_rx(uie[1]), // Replace with  UART RX interrupt enable signal
    .uart_interrupt_pending(uart_interrupt_pending), // Connect to  UART interrupt pending register
    .mip_uarte(uart2csr) // Connect to  MIP register for UART interrupt flag
);

module uart_interrupt (
    input logic clk,
    input logic rst_n,
    input logic uart_tx_complete,
    input logic uart_rx_complete,
    input logic uart_interrupt_enable_tx,
    input logic uart_interrupt_enable_rx,
    output reg [1:0] uart_interrupt_pending,
    output reg mip_uarte // Added output for UART interrupt
);

// Internal registers to store interrupt enable flags
reg interrupt_enable_tx;
reg interrupt_enable_rx;

// Internal registers to store interrupt pending flags
reg [1:0] interrupt_pending;

always_comb begin
    if (!rst_n) begin  // Initialize signals
        interrupt_enable_tx <= 1'b0;
        interrupt_enable_rx <= 1'b0;
        interrupt_pending <= 2'b00;
        mip_uarte <= 1'b0;
    end else begin // Update interrupt enable flags
        interrupt_enable_tx <= uart_interrupt_enable_tx;
        interrupt_enable_rx <= uart_interrupt_enable_rx;
        
        interrupt_pending[0] <= uart_tx_complete;     // Update interrupt pending flags
        interrupt_pending[1] <= uart_rx_complete; 
         
        mip_uarte <= (interrupt_pending[0] & interrupt_enable_tx) | (interrupt_pending[1] &  & interrupt_enable_rx);           // Update UART interrupt flag
    end
end

assign uart_interrupt_pending = interrupt_pending;

endmodule

          
endmodule
