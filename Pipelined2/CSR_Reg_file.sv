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
//////////////////////////////////////////////////////////////////////////////////

module CSR_Reg_file( input logic clk, rst, 
                input type_csr_ctr_s csr_ctr,
                input exc_uart,
                input type_e2csr_data_s  e2csr_data,
//                input type_exc2csr_data_s exc,
                input logic [BUS_WIDTH-1:0] csr_pc, instMW,
                
                output type_csr2f_fb_data_s csr2f_fb_data,
                output type_csr2f_ctr_s csr2f_ctr,
                output logic [BUS_WIDTH-1:0] csr_rdata
            );


// Machine mode CSRs for trap setup and handling
logic [BUS_WIDTH-1:0]   csr_mstatus_ff, csr_mie_ff, csr_mtvec_ff;
logic [BUS_WIDTH-1:0]   csr_mepc_ff, csr_mcause_ff, csr_mip_ff;
logic [BUS_WIDTH-1:0]   csr_mstatus_next, csr_mie_next, csr_mtvec_next;
logic [BUS_WIDTH-1:0]    csr_mcause_next, csr_mepc_next; // csr_mepc_next, csr_mip_next

logic [BUS_WIDTH-1:0]   csr_evec, base_evec, evec, data, mip_data, mip_clear_mask;

// Machine mode CSR write update flags for trap setup and handling registers
logic   csr_mstatus_wr_flag, csr_mie_wr_flag, csr_mtvec_wr_flag, csr_mepc_wr_flag;
//logic   csr_mcause_wr_flag, csr_mip_wr_flag;
logic   irq_exc, irq_exc_e, csr_mstatus_wr;

type_CSR_op_e csr_funct3;
assign csr_funct3 = type_CSR_op_e'({(csr_ctr.reg_wr | csr_ctr.reg_rd),instMW[14:12]});

type_csr_addr_e csr_addr;
assign csr_addr = type_csr_addr_e'(e2csr_data.addr[11:0]);  
         
assign mip_data = {13'b0,exc_uart,16'b0}; // Interrupt Coming from UART
//assign mip_data[16] = exc_uart; // Interrupt Coming from UART
           
// CSR read operation
always_comb begin
    csr_rdata = '0;
    if(csr_ctr.reg_rd) begin
        case (csr_addr)
             // Read machine mode trap setup registers
            CSR_ADDR_MSTATUS        : csr_rdata    = csr_mstatus_ff;
            CSR_ADDR_MIE            : csr_rdata    = csr_mie_ff;
            CSR_ADDR_MTVEC          : csr_rdata    = csr_mtvec_ff;
            // Read machine mode trap handling registers
            CSR_ADDR_MEPC           : csr_rdata    = csr_mepc_ff;
            CSR_ADDR_MCAUSE         : csr_rdata    = csr_mcause_ff;
            CSR_ADDR_MIP            : csr_rdata    = csr_mip_ff;           
        endcase // e2csr_data.addr
    end
end

// CSR write operation
always_comb begin
    csr_mstatus_wr_flag        = 1'b0; 
    csr_mie_wr_flag            = 1'b0;
    csr_mtvec_wr_flag          = 1'b0;
    csr_mepc_wr_flag           = 1'b0;
//    csr_mcause_wr_flag         = 1'b0; //
//    csr_mip_wr_flag            = 1'b0; //
    
    if (csr_ctr.reg_wr) begin
        case (csr_addr)
            // Machine mode flags for trap setup and handling registers write operation
            CSR_ADDR_MSTATUS        : csr_mstatus_wr_flag  = 1'b1;
            CSR_ADDR_MIE            : csr_mie_wr_flag      = 1'b1;
            CSR_ADDR_MTVEC          : csr_mtvec_wr_flag    = 1'b1;
            CSR_ADDR_MEPC           : csr_mepc_wr_flag     = 1'b1;
//            CSR_ADDR_MCAUSE         : csr_mcause_wr_flag   = 1'b1;
//            CSR_ADDR_MIP            : csr_mip_wr_flag      = 1'b1;              
        endcase 
    end
end

always_comb begin
    if (exc_uart)               csr_mcause_next = 'h80000010;   //  exception code 16 for UART interrupt
    else                        csr_mcause_next     = csr_mcause_ff; 
end

// MSB of funct3 used to check if immediate type csr 
MUX2x1 m3(.sel1(csr_pc[14]),.in0(e2csr_data.data),.in1({27'b0, csr_pc[19:15]}),.out(data)); 

    always_comb begin  //  Choosing csr data to feed to csr_mstatus_ff
            case(csr_funct3)// csr, funct3
                csrrw | csrrwi      :  csr_mstatus_next <= data;
                csrrs | csrrsi      :  csr_mstatus_next <= (csr_mstatus_ff | data) ;
                csrrc | csrrci      :  csr_mstatus_next <= (csr_mstatus_ff & ~data) ;
                default  :  csr_mstatus_next <= data; 
            endcase    
    end

    always_comb begin  //  Choosing csr data to feed to csr_mie_ff
            case(csr_funct3)// csr, funct3
                csrrw | csrrwi      :  csr_mie_next <= data ;
                csrrs | csrrsi      :  csr_mie_next <= (csr_mie_ff | data) ;
                csrrc | csrrci      :  csr_mie_next <= (csr_mie_ff & ~data) ;
                default  :  csr_mie_next <= data; 
            endcase    
    end
    
    always_comb begin  //  Choosing csr data to feed to csr_mtvec_ff
            case(csr_funct3)// csr, funct3
                csrrw | csrrwi      :  csr_mtvec_next <= data ;
                csrrs | csrrsi      :  csr_mtvec_next <= (csr_mtvec_ff | data) ;
                csrrc | csrrci      :  csr_mtvec_next <= (csr_mtvec_ff & ~data) ;
                default  :  csr_mtvec_next <= data; 
            endcase    
    end

// Copy previous MIE into new MPIE of mstatus reg(has 2 editable bitsas MPP=2'b11)
FF_32bit CSR_MSTAT_FF(.rst(rst),.clk(clk),.d({csr_mstatus_next[31:13],2'b11,csr_mstatus_next[10:8],csr_mstatus_ff[3],csr_mstatus_next[6:0]} & 'h00001888),.q(csr_mstatus_ff),.en(csr_mstatus_wr_flag)); 
FF_32bit CSR_MIE_FF(.rst(rst),.clk(clk),.d((csr_mie_next & 'h00010888)),.q(csr_mie_ff),.en(csr_mie_wr_flag));  // MSB 6 bitsfor system exceptions
FF_32bit CSR_MTVEC_FF(.rst(rst),.clk(clk),.d(csr_mtvec_next ),.q(csr_mtvec_ff),.en(csr_mtvec_wr_flag)); 

MUX2x1 m4(.sel1(instMW == 'h00000013),.in0({csr_pc[BUS_WIDTH-1:2], 2'b00}),.in1({csr_pc[BUS_WIDTH-1:2]-1, 2'b00}),.out(csr_mepc_next)); // MUX Width is [BUS_WIDTH-1:0]
FF_32bit CSR_MEPC_FF(.rst(rst),.clk(clk),.d(csr_mepc_next),.q(csr_mepc_ff),.en(csr2f_ctr.epc_taken)); // csr2f_ctr.epc_taken
FF_32bit CSR_MCAUSE_FF(.rst(rst),.clk(clk),.d(csr_mcause_next & 'h8000001F),.q(csr_mcause_ff),.en(1'b1)); // csr_mstatus_wr|csr_mcause_wr_flag
FF_32bit CSR_MIP_FF(.rst(rst),.clk(clk),.d((mip_data|csr_mip_ff) & ~mip_clear_mask),.q(csr_mip_ff),.en(1'b1) ); 

// Exception/Interrupt and UART interrupt condition is considered 
assign irq_exc = ((csr_mip_ff[16] & csr_mie_ff[16]) | (csr_mip_ff[7] & csr_mie_ff[7]) | (csr_mip_ff[11] & csr_mie_ff[11])) & csr_mstatus_ff[3]; // MIP -> meip and mtip, MIE -> meie and mtie, MSTATUS -> mie,

// Address Calculation in CSR for epc_evec
assign base_evec = {csr_mtvec_ff[BUS_WIDTH-1:2],2'b0};
assign evec = (csr_mcause_ff<<2) + base_evec;
MUX2x1 m2(.sel1(csr_mtvec_ff[0]),.in0(base_evec),.in1(evec),.out(csr_evec)); // MUX Width is [BUS_WIDTH-1:0]
  
MUX2x1 m1(.sel1(csr_ctr.is_mret),.in0(csr_evec),.in1(csr_mepc_ff),.out(csr2f_fb_data.epc_evec)); // MUX Width is [BUS_WIDTH-1:0]

assign csr2f_ctr.epc_taken = csr_ctr.is_mret | irq_exc_e;
  
// Clear MIP mask
always_comb begin
    if (csr2f_ctr.epc_taken & irq_exc & (csr_mcause_ff == 'h80000010))
        mip_clear_mask  = 'h80000010;
    else
        mip_clear_mask  = 'h00000000;
end
  
Edge_to_Pulse Et(.pulse(irq_exc_e), .clk(clk), .rst(rst), .level(irq_exc));
    
endmodule


//always_comb begin
//    csr_mtvec_next = csr_mtvec_ff;
//    if(csr_mtvec_wr_flag) begin
//        case(csr_wdata[0])   // csr_wdata[0] is the MODE_BIT
//            0:  csr_mtvec_next = {csr_wdata[(BUS_WIDTH-1):2],{2-1{1'b0}},csr_wdata[0]}; // Direct
//            1:  csr_mtvec_next = {csr_wdata[(BUS_WIDTH-1):6],{6-1{1'b0}},csr_wdata[0]}; // Vectored
//        endcase  
//    end 
//end
