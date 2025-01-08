`timescale 1ns / 1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2023 04:55:18 PM
// Design Name: 
// Module Name: Controller
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


module UART_Controller(output logic wr, wr_Udata, wr_Ubaud, wr_Uctr, wr_Uuie, Udata, Ubaud, Uctr, Uuip, Uuie, Udata_clr,
                  output logic tx_complete, rx_complete,
                  output logic wr_data_rx, receive_flag, busy_rx, Udata_rx,
                  input logic clk, rst, baud, wr_en, uart_sel, tx_start, baud_buffer_full, 
                  input logic two_stop_bits, s_in, baud_2,
                  input logic [BUS_WIDTH-1:0] dbus_addr
                );
                
logic [3:0] cnt, load_val, cnt3; 
type_uart_state_e state_Tx, state_Rx;
logic shift_en_n, shift_en, cnt2,receive_en;
logic transmit, load, idle_Tx, idle_Rx, start_bit, receive, read;
 
    always_comb begin    // Check instruction type (9-bit Decoder)
        if (!uart_sel) 
            {Udata, Ubaud, Uctr, Udata_rx, Uuip, Uuie} <= 6'b000000;  
        else begin 
            case(dbus_addr[4:0]) 
                'h0     : {Udata, Ubaud, Uctr, Udata_rx, Uuip, Uuie} <= 6'b100000;
                'h4     : {Udata, Ubaud, Uctr, Udata_rx, Uuip, Uuie} <= 6'b010000;
                'h8     : {Udata, Ubaud, Uctr, Udata_rx, Uuip, Uuie} <= 6'b001000;
                'hC     : {Udata, Ubaud, Uctr, Udata_rx, Uuip, Uuie} <= 6'b000100; 
                'h10    : {Udata, Ubaud, Uctr, Udata_rx, Uuip, Uuie} <= 6'b000010; 
                'h14    : {Udata, Ubaud, Uctr, Udata_rx, Uuip, Uuie} <= 6'b000001; 
                default     : {Udata, Ubaud, Uctr, Udata_rx, Uuip, Uuie} <= 6'b000000;  // Default is None 
            endcase    
        end 
    end

StateMachine FSM(.current_Tx(state_Tx), .current_Rx(state_Rx), .clk(clk), .rst(rst), 
                .load_en(wr_en & (Udata|Ubaud)), .wr_en(tx_start), .trans_en(1'b1), 
                .trans(shift_en), .rd_en(wr_data_rx), .rcv_en(start_bit), .rd(1'b1)
                );
Comparator_3bit Cp1(.out(wr), .in0(Write), .in1(state_Tx));
Comparator_3bit Cp2(.out(transmit), .in0(Transmit), .in1(state_Tx));
Comparator_3bit Cp4(.out(load), .in0(Load), .in1(state_Tx));
Comparator_3bit Cp5(.out(idle_Tx), .in0(Idle), .in1(state_Tx));
Comparator_3bit Cp7(.out(idle_Rx), .in0(Idle), .in1(state_Rx));
Comparator_3bit Cp8(.out(receive), .in0(Receive), .in1(state_Rx));
Comparator_3bit Cp9(.out(read), .in0(Read), .in1(state_Rx));

//MUX2x1_4bit m1(.sel1(two_stop_bits),.in0(4'b1010),.in1(4'b1011),.out(load_val)); // 10/11 based on two_stop_bits value
MUX2x1_4bit m1(.sel1(two_stop_bits),.in0(4'b1011),.in1(4'b1100),.out(load_val)); // 10/11 based on two_stop_bits value

Reloadable_DownCounter Rd(.rst(rst), .baud(baud), .load(wr), .sel(load_val), .cnt(cnt)); // Reloads 10/11 to complete 10/11 cycles 
Comparator_4bit Cp3(.out(shift_en_n), .in0(4'b0000), .in1(cnt));
not n1(shift_en,shift_en_n);

assign wr_Udata = (Udata & wr_en & idle_Tx) | (shift_en_n & transmit) ;
assign wr_Ubaud = (Ubaud & wr_en & idle_Tx) | (baud_buffer_full & ~transmit);
assign wr_Uctr  = (Uctr & wr_en); 
assign wr_Uuie  = (Uuie & wr_en); 
assign Udata_clr = (shift_en_n & transmit);
assign tx_complete = (shift_en_n & transmit); 
assign rx_complete = read ;

DownCounter_1bit D1(.rst(rst), .clk(baud_2), .load(start_bit), .load_val(1'b1), .cnt(cnt2)); // Reloads 1  to sample start bit after 1 cycles of baud_16 
assign receive_flag = (cnt2 == '0) & receive;
Edge_to_Pulse Et(.pulse(receive_en), .clk(clk), .rst(rst), .level(receive_flag));
Reloadable_DownCounter Rd2(.rst(rst), .baud(receive_en), .load(start_bit), .sel(load_val), .cnt(cnt3)); // Reloads 10 to complete 10 cycles 
assign wr_data_rx = (cnt3 == '0) & receive;

assign start_bit = (s_in == 0) & idle_Rx;
assign busy_rx = receive;

endmodule
