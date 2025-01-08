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

module ControlPath( input logic [BUS_WIDTH-1:0] instDE, instMW,// {inst[30],inst[14:12]} // {funct7[30], funct3}
                input logic rst,clk,
                input type_f_ctr_s f_ctr,
                output type_d_ctr_s d_ctr,
                output type_e_ctr_s e_ctr,
                output type_m_ctr_s m_ctr_MW,
                output type_w_ctr_s w_ctr_MW,
                output type_csr_ctr_s csr_ctr_MW,
                output logic Flush
            );
            
type_m_ctr_s m_ctr;
type_w_ctr_s w_ctr;
type_csr_ctr_s csr_ctr;

logic [3:0] funct;
logic [4:0] rdDE, rs1DE, rs2DE, rdMW, rs1MW, rs2MW; 
logic reg_wr;
          
logic R,I,S,L,B,auipc,lui,jal,jalr,csr;
`define Type {R,I,S,L,B,auipc,lui,jal,jalr,csr} // Declare bus
`define Control {d_ctr.imm_gen, e_ctr.sel_A, e_ctr.sel_B, w_ctr.wb_sel, reg_wr, csr_ctr.reg_rd,csr_ctr.reg_wr}

assign funct = {instDE[30],instDE[14:12]};

type_alu_e alu;
 assign alu = type_alu_e'({R,I,lui,funct});  
 
type_opcode_e OPCODE, OPCODE_MW;
 assign OPCODE = type_opcode_e'(instDE[6:0]);  
 assign OPCODE_MW = type_opcode_e'(instMW[6:0]);  

assign rdDE  = instDE[11:7];
assign rs1DE = instDE[19:15];
assign rs2DE = instDE[24:20]; 

assign rdMW  = instMW[11:7];
assign rs1MW = instMW[19:15];
assign rs2MW = instMW[24:20]; 

// Decode ----> Execute pipeline
always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        d_ctr.reg_wrMW <= '0;
        m_ctr_MW <= '0;
        w_ctr_MW <= '0;
        csr_ctr_MW <= '0;
    end else begin
        d_ctr.reg_wrMW <= reg_wr;
        m_ctr_MW <= m_ctr;
        w_ctr_MW <= w_ctr;
        csr_ctr_MW <= csr_ctr;
    end
end  

Full_Forwarding_Unit FU2(
    .rdMW(rdMW), .rs1DE(rs1DE), .rs2DE(rs2DE),.opcode_MW(OPCODE_MW), 
    .reg_wrMW(d_ctr.reg_wrMW), .br_taken(f_ctr.br_taken), 
    .rs1_valid(R|I|L|jalr|S|B), .rs2_valid(R|S|B),
    .For_A(e_ctr.For_A), .For_B(e_ctr.For_B), .Flush(Flush)
);
  
 
    always_comb begin    // Check instruction type (9-bit Decoder)
        d_ctr.illegal_opcode <= 1'b0;
        if (!rst) 
            `Type <= 0;  
        else begin 
            case(OPCODE)//Type {R,I,S,L,B,auipc,lui,jal,jalr,csr} 
                R_type      :`Type <= 10'b1000000000; 
                I_type_imm  :`Type <= 10'b0100000000; 
                S_type      :`Type <= 10'b0010000000; 
                I_type_load :`Type <= 10'b0001000000;
                B_type      :`Type <= 10'b0000100000; 
                U_type_auipc:`Type <= 10'b0000010000;
                U_type_lui  :`Type <= 10'b0000001000;
                J_type_jal  :`Type <= 10'b0000000100;
                I_type_jalr :`Type <= 10'b0000000010;
                I_type_jalr :`Type <= 10'b0000000010;
                CSR_type    :`Type <= 10'b0000000001;
                default     : begin`Type <= 0; // Default is None 
                                d_ctr.illegal_opcode <= 1'b1;
                                end
            endcase    
        end 
    end
    
    always_comb begin  //  Choosing alu_op using: R,I,lui,funct7,funct3
            case(alu)// R_type, I_type,lui_Type, funct7[30], funct3
                add      :  e_ctr.alu_op <= 0;
                addi     :  e_ctr.alu_op <= 0;
                sub      :  e_ctr.alu_op <= 1;
                sll      :  e_ctr.alu_op <= 2;
                slli     :  e_ctr.alu_op <= 2;
                srl      :  e_ctr.alu_op <= 3;
                srli     :  e_ctr.alu_op <= 3;
                sra      :  e_ctr.alu_op <= 4; 
                srai     :  e_ctr.alu_op <= 4;
                and_     :  e_ctr.alu_op <= 5;
                andi     :  e_ctr.alu_op <= 5;
                or_      :  e_ctr.alu_op <= 6;
                ori      :  e_ctr.alu_op <= 6;
                xor_     :  e_ctr.alu_op <= 7;
                xori     :  e_ctr.alu_op <= 7;
                sltu     :  e_ctr.alu_op <= 8;
                sltiu    :  e_ctr.alu_op <= 8;
                slt      :  e_ctr.alu_op <= 9;
                slti     :  e_ctr.alu_op <= 9;
                lui_     :  e_ctr.alu_op <= 10;
                default  :  e_ctr.alu_op <= 0; // Default is add
            endcase    
    end
    
    always_comb begin//for wr_en
        m_ctr.wr_en <= S;
    end

    always_comb begin//for rd_en
        m_ctr.rd_en <= L;
    end

    always_comb begin//3-bit Encoder    // for br_type
        case({jal,jalr,B})
            3'b100 : e_ctr.br_type <= 3 ; // jal  (unconditional jump)
            3'b010 : e_ctr.br_type <= 3 ; // jalr (unconditional jump)
            3'b001 : e_ctr.br_type <= funct[2:0] ;// funct 3 of B_Type (possible due to exploitable design of branch_cond)
            default: e_ctr.br_type <= 2;   //no jump
        endcase
    end

assign csr_ctr.is_mret = (instDE == 'h30200073 );// 'h30200073 -> 0011000 00010 00000 000 00000 1110011 MRET
       
    always_comb begin // 9 bit Encoder
        case(`Type)//Type {R,I,S,L,B,auipc,lui,jal,jalr,csr}
                         //Control {imm_gen,sel_A, sel_B,wb_sel,reg_wr,csr_ctr.reg_rd,csr_ctr.reg_wr}
            10'b1000000000 :`Control<= {3'bzzz,1'b1,1'b1,2'b01,1'b1,1'b0,1'b0};//R
            10'b0100000000 :begin if (funct[1:0]==2'b01)
                                    `Control<= {3'b101,1'b1,1'b0,2'b01,1'b1,1'b0,1'b0};//I_slli + srli + srai
                                else
                                    `Control<= {3'b000,1'b1,1'b0,2'b01,1'b1,1'b0,1'b0};//I
                            end
            10'b0010000000 :`Control<= {3'b001,1'b1,1'b0,2'bzz,1'b0,1'b0,1'b0};//S
            10'b0001000000 :`Control<= {3'b000,1'b1,1'b0,2'b00,1'b1,1'b0,1'b0};//L
            10'b0000100000 :`Control<= {3'b010,1'b0,1'b0,2'bzz,1'b0,1'b0,1'b0};//B
            10'b0000010000 :`Control<= {3'b011,1'b0,1'b0,2'b01,1'b1,1'b0,1'b0};//auipc
            10'b0000001000 :`Control<= {3'b011,1'b1,1'b0,2'b01,1'b1,1'b0,1'b0};//lui
            10'b0000000100 :`Control<= {3'b100,1'b0,1'b0,2'b10,1'b1,1'b0,1'b0};//jal
            10'b0000000010 :`Control<= {3'b000,1'b1,1'b0,2'b10,1'b1,1'b0,1'b0};//jalr
            10'b0000000001 :`Control<= {3'b110,1'bz,1'bz,2'b11,1'b1,1'b1,1'b1};//csr
            default: `Control <= 0; // All control signals 0 for None Type
        endcase
    end
    
endmodule


//////////////////////////////////////////////////////////////////////////////////      
//opcode    Type     Description             ALU     sel_A   sel_B   wb_sel  imm_gen     br_type   alu_op  reg_wr      d_wr
// 3:       I-Type   Load                    yes     1       1       2       0           none      0       1           0
// 19:      I-Type   immediate operation     yes     1       1       1       0           none      xxxx    1           0
// 23:      U-Type   auipc                   yes     0       1       1       4(u)        none      0       1           0
// 35:      S-Type   Store                   yes     1       1       z       1           none      0       0           1
// 51:      R-Type   register operation      yes     1       0       1       z           none      xxxx    1           0
// 55:      U-Type   lui                     no      1       1       1       4(u)        none      copy    1           0
// 99:      B-Type   conditional branch      yes     0       1       z       2           xxx       0       0           0
// 103:     I-Type   jalr                    yes     1       1       0       0           uncond    0       1           0
// 111:     J-Type   jal                     yes     1       1       0       3           uncond    0       1           0
//////////////////////////////////////////////////////////////////////////////////

//    always_comb begin // 9 bit Encoder
//        case(`Type)//Type {R,I,S,L,B,auipc,lui,jal,jalr}
//                         //Control {imm_gen,sel_A, sel_B,wb_sel,reg_wr}
//            9'b100000000 :`Control<= {3'bzzz,1'b1,1'b1,2'b01,1'b1};//R
//            9'b010000000 :`Control<= {3'b000,1'b1,1'b0,2'b01,1'b1};//I
//            9'b001000000 :`Control<= {3'b001,1'b1,1'b0,2'bzz,1'b0};//S
//            9'b000100000 :`Control<= {3'b000,1'b1,1'b0,2'b00,1'b1};//L
//            9'b000010000 :`Control<= {3'b010,1'b0,1'b0,2'bzz,1'b0};//B
//            9'b000001000 :`Control<= {3'b011,1'b0,1'b0,2'b01,1'b1};//auipc
//            9'b000000100 :`Control<= {3'b011,1'b1,1'b0,2'b01,1'b1};//lui
//            9'b000000010 :`Control<= {3'b100,1'b0,1'b0,2'b10,1'b1};//jal
//            9'b000000001 :`Control<= {3'b000,1'b1,1'b0,2'b10,1'b1};//jalr
//            default: `Control <= 0; // All control signals 0 for None Type
//        endcase
//    end

//    always_comb begin // 9 bit Encoder
//        case({funct,`Type})//Type {R,I,S,L,B,auipc,lui,jal,jalr}
//                         //Control {imm_gen,sel_A, sel_B,wb_sel,reg_wr}
//            13'bxxxx100000000 :`Control<= {3'bzzz,1'b1,1'b1,2'b01,1'b1};//R
//            13'bxxxx010000000 :`Control<= {3'b000,1'b1,1'b0,2'b01,1'b1};//I
//            13'bxx01010000000 :`Control<= {3'b101,1'b1,1'b0,2'b01,1'b1};//I_slli + srli + srai
//            13'bxxxx001000000 :`Control<= {3'b001,1'b1,1'b0,2'bzz,1'b0};//S
//            13'bxxxx000100000 :`Control<= {3'b000,1'b1,1'b0,2'b00,1'b1};//L
//            13'bxxxx000010000 :`Control<= {3'b010,1'b0,1'b0,2'bzz,1'b0};//B
//            13'bxxxx000001000 :`Control<= {3'b011,1'b0,1'b0,2'b01,1'b1};//auipc
//            13'bxxxx000000100 :`Control<= {3'b011,1'b1,1'b0,2'b01,1'b1};//lui
//            13'bxxxx000000010 :`Control<= {3'b100,1'b0,1'b0,2'b10,1'b1};//jal
//            13'bxxxx000000001 :`Control<= {3'b000,1'b1,1'b0,2'b10,1'b1};//jalr
//            default: `Control <= 0; // All control signals 0 for None Type
//        endcase
//    end

//    always_comb 
//    begin
//        {csr_ctr.reg_rd,csr_ctr.reg_wr} = 2'b00;
        
//        if ((csr_funct3 == csrrw) | (csr_funct3 == csrrwi)) // Used funct3 to decide reg_wr and reg_rd of csr_ctr
//			 begin 	                     //csrrw or csrrwi
//                 if(rdDE == '0)
//                    {csr_ctr.reg_rd,csr_ctr.reg_wr} = 2'b01;
//                 else
//                    {csr_ctr.reg_rd,csr_ctr.reg_wr} = 2'b11;
//             end
//		else if ((csr_funct3 == csrrc) | (csr_funct3 == csrrci) | (csr_funct3 == csrrs) | (csr_funct3 == csrrsi)) 
//			 begin 	                     //csrrs or csrrsi or csrrc or csrrci
//                 if(rs1DE == '0)
//                    {csr_ctr.reg_rd,csr_ctr.reg_wr} = 2'b10;
//                 else
//                    {csr_ctr.reg_rd,csr_ctr.reg_wr} = 2'b11;
//             end
//		else
//		      {csr_ctr.reg_rd,csr_ctr.reg_wr} = 2'b00;
//    end