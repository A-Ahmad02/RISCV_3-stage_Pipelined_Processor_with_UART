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

module Load_Store_Unit( input type_m_ctr_s m_ctr,
                        input logic [BUS_WIDTH-1:0]addr, [BUS_WIDTH-1:0]wdata, 
                        input type_module2lsu_s       uart2lsu_data, dmem2lsu_data,
                        output logic [BUS_WIDTH-1:0] rdata,
                        output type_lsu2module_data_s  lsu2uart_data, lsu2dmem_data
                      );

type_module2lsu_s       module2lsu_data;
type_lsu2module_data_s  lsu2module_data;

assign lsu2module_data.sel = 1'b1;
assign lsu2module_data.dbus = wdata;
assign lsu2module_data.dbus_addr = addr;
assign lsu2module_data.wr_en = m_ctr.wr_en;
assign lsu2module_data.rd_en = m_ctr.rd_en;
assign rdata = module2lsu_data.rd_data;

// LSU <-----> UART pipeline
always_comb begin
    if (m_ctr.wr_en | m_ctr.rd_en) begin
        case(addr[31:28]) 
            4'b0000     : begin lsu2dmem_data   <= lsu2module_data;
                                lsu2uart_data   <= '0;
                                module2lsu_data <= dmem2lsu_data;
                          end
            4'b1000     : begin lsu2uart_data   <= lsu2module_data;
                                lsu2dmem_data   <= '0;
                                module2lsu_data <= uart2lsu_data;
                          end
            default     : begin lsu2uart_data   <= '0;
                                lsu2dmem_data   <= '0;
                                module2lsu_data <= '0;
                          end
        endcase  
    end
    else begin
        lsu2uart_data   <= '0;
        lsu2dmem_data   <= '0;
        module2lsu_data <= '0;
    end
end
 

endmodule
