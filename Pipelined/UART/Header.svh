`ifndef HEADER
 `define HEADER

    parameter BUS_WIDTH = 32;
    parameter WIDTH = 8;
    parameter DEPTH = 2048;
    //parameter ADDR = 11;
    
    typedef enum logic [6:0] {    // Dec 
        R_type      = 7'b0110011, //  51 
        I_type_load = 7'b0000011, //   3 
        I_type_imm  = 7'b0010011, //  19
        I_type_jalr = 7'b1100111, // 103
        S_type      = 7'b0100011, //  35 
        U_type_auipc= 7'b0010111, //  23 
        U_type_lui  = 7'b0110111, //  55
        B_type      = 7'b1100011, //  99
        J_type_jal  = 7'b1101111  // 111
    } type_opcode_e;
    
    typedef enum logic [6:0] {  // {R,I,lui, funct7[30], funct3}
    // if it is R_type R=1 and if I_type_imm R=0
        add     = {3'b100,1'b0,3'b000},
        sub     = {3'b100,1'b1,3'b000},
        sll     = {3'b100,1'b0,3'b001},
        slt     = {3'b100,1'b0,3'b010},
        sltu    = {3'b100,1'b0,3'b011},
        xor_    = {3'b100,1'b0,3'b100},
        srl     = {3'b100,1'b0,3'b101},
        sra     = {3'b100,1'b1,3'b101},
        or_     = {3'b100,1'b0,3'b110}, 
        and_    = {3'b100,1'b0,3'b111}, 
         
        addi    = {3'b010,1'bx,3'b000},
        slli    = {3'b010,1'b0,3'b001},
        slti    = {3'b010,1'bx,3'b010},
        sltiu   = {3'b010,1'bx,3'b011}, 
        xori    = {3'b010,1'bx,3'b100},
        srli    = {3'b010,1'bx,3'b101},
        srai    = {3'b010,1'b1,3'b101}, 
        ori     = {3'b010,1'bx,3'b110},
        andi    = {3'b010,1'bx,3'b111},
        
        lui_    = {3'b001,1'bx,3'bxxx}
    } type_alu_e;
    
    
    typedef enum logic [2:0] {  // {funct3}    
        beq    = 3'b000,
        bne    = 3'b001,
        no_jump= 3'b010,
        jump   = 3'b011,
        blt    = 3'b100,
        bge    = 3'b101, 
        bltu   = 3'b110,
        bgeu   = 3'b111    
    } type_B_op_e;
    
    typedef enum logic [11:0] {  // CSR Register addresses from 2.2 CSR listing table 7
        CSR_ADDR_MSTATUS        = 'h300,
        CSR_ADDR_MIE            = 'h304,
        CSR_ADDR_MTVEC          = 'h305,
        CSR_ADDR_MEPC           = 'h341,
        CSR_ADDR_MCAUSE         = 'h342,
        CSR_ADDR_MIP            = 'h344
    } type_csr_addr_e;
    
    typedef enum logic [1:0] {  // UART State Machine  
        Idle        = 2'b00,
        Load        = 2'b01,
        Write       = 2'b10,
        Transmit    = 2'b11 
    } type_uart_state_e;
    
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] dbus;
        logic [BUS_WIDTH-1:0] dbus_addr;
        logic wr_en;
        logic rd_en;
        logic sel;
    }type_lsu2module_data_s; 
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] rd_data;
    }type_module2lsu_s;  

          
    typedef struct packed {
        logic [BUS_WIDTH-1:0] pc;
        logic [BUS_WIDTH-1:0] inst;
    }type_f2de_data_s;
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] imm32;
        logic [BUS_WIDTH-1:0] rdata1;
        logic [BUS_WIDTH-1:0] rdata2;
    }type_d2e_data_s;
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] pc;
        logic [BUS_WIDTH-1:0] inst;
        logic [BUS_WIDTH-1:0] alu_out;
        logic [BUS_WIDTH-1:0] wdata;
    }type_de2mw_data_s;
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] alu_out;
        logic [BUS_WIDTH-1:0] wbdata;
    }type_mw2de_fb_data_s;
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] alu_out;
    }type_de2f_fb_data_s;
    
    typedef struct packed {
        logic [1:0] wb_sel;
    }type_w_ctr_s;
    
    typedef struct packed {
        logic wr_en;
        logic rd_en;
    }type_m_ctr_s;
    
    typedef struct packed {
        logic sel_A;
        logic sel_B;
        logic [1:0] For_A;
        logic [1:0] For_B;
        logic [2:0] br_type;
        logic [3:0] alu_op;
    }type_e_ctr_s;
    
    typedef struct packed {
        logic reg_wrMW;
        logic [2:0] imm_gen;
    }type_d_ctr_s;
    
    typedef struct packed {
        logic br_taken;
    }type_f_ctr_s;


`endif
