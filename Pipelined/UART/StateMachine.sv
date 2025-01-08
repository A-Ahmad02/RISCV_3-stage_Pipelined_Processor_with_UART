`timescale 1ns / 1ps
`include "Header.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2023 08:52:18 AM
// Design Name: 
// Module Name: StateMachine
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


module StateMachine(output type_uart_state_e current_Tx, current_Rx,
                    input logic clk, rst, load_en, trans_en, wr_en, trans, 
                    input logic rd_en, rcv_en, rd
                );

type_uart_state_e next_Tx, next_Rx;

always_ff @(posedge clk or negedge rst) begin
    if(!rst) 
        current_Tx <= Idle;
    else
        current_Tx <= next_Tx;
end

always_comb begin
    case(current_Tx)
    Idle: if (load_en) next_Tx = Load;
            else if (wr_en) next_Tx = Write;
            else  next_Tx = Idle;
    Load: if (wr_en) next_Tx = Write;
            else  next_Tx = Idle;
    Write: if (trans_en) next_Tx = Transmit;
            else  next_Tx = Write;
    Transmit: if (trans) next_Tx = Transmit;
            else  next_Tx = Idle;
    default: next_Tx = Idle;
    endcase
end

always_ff @(posedge clk or negedge rst) begin
    if(!rst) 
        current_Rx <= Idle;
    else
        current_Rx <= next_Rx;
end

always_comb begin
    case(current_Rx)
    Idle:   if (rcv_en) next_Rx = Receive;
            else  next_Rx = Idle;
    Receive : if (rd_en) next_Rx = Read;
            else  next_Rx = Receive;
    Read    : if (rd) next_Rx = Idle;
            else  next_Rx = Read;
    default: next_Rx = Idle;
    endcase
end


endmodule


//always_comb begin
//    case(current)
//    Idle: RTS = 0;
//    Write: if (tx_start) RTS = 1;
//            else  RTS = 0;
//    Wait_: if (tx_start) RTS = 1;
//            else  RTS = 0;
//    Transmit: RTS = 0;
//    default: RTS = 0;
//    endcase
//end

//always_comb begin
//    case({en,tx_start,CTS,shift,current})
//    4'b0XXX,Idle: next <= Idle;
//    4'b1XXX,Idle: next <= Write;
    
//    4'b00XX,Write: next <= Wait_;
//    4'b10XX,Write: next <= Write;
//    4'bX1XX,Write: next <= Request;
    
//    4'bX0XX,Wait_: next <= Wait_;
//    4'bX1XX,Wait_: next <= Request;
    
//    4'bXX0X,Request: next <= Request;
//    4'bXX1X,Request: next <= Transmit;
    
//    4'bXXX0,Transmit: next <= Idle;
//    4'bXXX1,Transmit: next <= Transmit;
    
//    default: next <= Idle;
//    endcase
//end


//always_comb begin
//    case({en,tx_start,CTS,shift,current})
//    4'bXXXX,Idle: RTS <= 0;
    
//    4'bX0XX,Write: RTS <= 0;
//    4'bX1XX,Write: RTS <= 1;
    
//    4'bX0XX,Wait_: RTS <= 0;
//    4'bX1XX,Wait_: RTS <= 1;
    
//    4'bXX0X,Request: RTS <= 1;
//    4'bXX1X,Request: RTS <= 0;
    
//    4'bXXXX,Transmit: RTS <= 0;
    
//    default: RTS <= 0;
//    endcase
//end

