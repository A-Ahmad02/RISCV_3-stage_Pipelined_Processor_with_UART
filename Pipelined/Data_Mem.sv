`timescale 1ns/1ps
`include "Header.svh"

//////////////////////////////////////////////////////////////////////////////////
//
// Create Date: 01/25/2024 11:04:00 AM
// Design Name: 
// Module Name: Data_Mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//////////////////////////////////////////////////////////////////////////////////


module Data_Mem(input logic clk, 
                input type_lsu2module_data_s  lsu2dmem_data,
                output type_module2lsu_s       dmem2lsu_data
            );
             
    logic [WIDTH-1:0] mem [DEPTH-1:0];
    logic [10:0] addr_;
    assign addr_ = lsu2dmem_data.dbus_addr[10:0];
    
    initial begin
        $readmemh("C:/DriveA/Workspaces/Vivado/CA_Lab/E4/data.mem", mem);
    end
      
    always_ff @(posedge clk) begin
        if(lsu2dmem_data.wr_en & lsu2dmem_data.sel) begin
            {mem[addr_+3],mem[addr_+2],mem[addr_+1],mem[addr_]} <= lsu2dmem_data.dbus;
            $writememh("C:/DriveA/Workspaces/Vivado/CA_Lab/E4/data.mem", mem);
        end
        else
            mem <= mem;
    end 
    
    always_comb begin
        if(lsu2dmem_data.rd_en & lsu2dmem_data.sel) 
            dmem2lsu_data.rd_data <= {mem[addr_+3],mem[addr_+2],mem[addr_+1],mem[addr_]};
        else
            dmem2lsu_data.rd_data <= 32'b0;
    end
    
endmodule


//    always_ff @ (posedge clk) begin
//         $writememh("C:/DriveA/Workspaces/Vivado/CA_Lab/E4/data.mem", mem);
//    end