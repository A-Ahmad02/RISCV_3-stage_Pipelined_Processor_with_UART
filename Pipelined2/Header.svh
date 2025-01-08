`ifndef HEADER
 `define HEADER

    parameter BUS_WIDTH = 32;
    parameter WIDTH = 8;
    parameter DEPTH = 2048;
    parameter ADDR = 11;
    
    typedef enum logic [6:0] {    // Dec 
        R_type      = 7'b0110011, //  51 
        I_type_load = 7'b0000011, //   3 
        I_type_imm  = 7'b0010011, //  19
        I_type_jalr = 7'b1100111, // 103
        S_type      = 7'b0100011, //  35 
        U_type_auipc= 7'b0010111, //  23 
        U_type_lui  = 7'b0110111, //  55
        B_type      = 7'b1100011, //  99
        J_type_jal  = 7'b1101111,  // 111
        CSR_type    = 7'b1110011 
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
    
    typedef enum logic [3:0] {  // {csr,funct3}  
        csrrw   = 4'b1001,
        csrrs   = 4'b1010,
        csrrc   = 4'b1011,
        csrrwi  = 4'b1101,
        csrrsi  = 4'b1110, 
        csrrci  = 4'b1111   
    } type_CSR_op_e;
   
       
    typedef enum logic [11:0] {  // CSR Register addresses from 2.2 CSR listing table 7
        CSR_ADDR_MSTATUS        = 'h300,
        CSR_ADDR_MIE            = 'h304,
        CSR_ADDR_MTVEC          = 'h305,
        CSR_ADDR_MEPC           = 'h341,
        CSR_ADDR_MCAUSE         = 'h342,
        CSR_ADDR_MIP            = 'h344
    } type_csr_addr_e;
     
    typedef enum logic [2:0] {  // UART State Machine  
        Idle        = 3'b000,
        Load        = 3'b001,
        Write       = 3'b010,
        Transmit    = 3'b011,
        Receive     = 3'b100,
        Read        = 3'b101 
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

//    typedef struct packed {
//        logic f_Imem_misalign;          // Check for Misaligned access
//        logic f_Imem_access_fault;      // Check for mem size
//        logic d_illegal_opcode;
//        logic e_over_under_flow;
//        logic m_Dmem_misalign;          // Check for Misaligned access
//        logic m_Dmem_access_fault;      // Check for mem size
//        logic m_async_irq;              // External interupt (UART)
//    }type_exc2csr_data_s;
          
    typedef struct packed {
        logic [BUS_WIDTH-1:0] pc;
        logic [BUS_WIDTH-1:0] inst;
//        type_exc2csr_data_s exc2csr_data;
    }type_f2de_data_s;
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] imm32;
        logic [BUS_WIDTH-1:0] rdata1;
        logic [BUS_WIDTH-1:0] rdata2;
    }type_d2e_data_s;
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] addr;
        logic [BUS_WIDTH-1:0] data;
    }type_e2csr_data_s;
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] pc;
        logic [BUS_WIDTH-1:0] inst;
        logic [BUS_WIDTH-1:0] alu_out;
        logic [BUS_WIDTH-1:0] wdata;
//        type_exc2csr_data_s exc2csr_data;
        type_e2csr_data_s e2csr_data;
    }type_de2mw_data_s;
    
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] alu_out;
        logic [BUS_WIDTH-1:0] wbdata;
        logic [BUS_WIDTH-1:0] inst;
    }type_mw2de_fb_data_s;
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] alu_out;
    }type_de2f_fb_data_s; 
    
    typedef struct packed {
        logic [BUS_WIDTH-1:0] epc_evec;
    }type_csr2f_fb_data_s;
    
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
        logic illegal_opcode;
    }type_d_ctr_s;
    
    typedef struct packed {
        logic br_taken;
    }type_f_ctr_s;
    
    typedef struct packed {
        logic epc_taken;
    }type_csr2f_ctr_s;
    
    typedef struct packed {
        logic reg_wr;
        logic reg_rd;
        logic is_mret;
    }type_csr_ctr_s;
    


`endif


//typedef enum logic [9:0] {  // {funct7, funct3}
//    lb      = {7'b0000000,3'b000},
//    lh      = {7'b0000000,3'b001},
//    lw      = {7'b0000000,3'b010},
////    ld      = {7'b0000000,3'b011},
//    lbu     = {7'b0000000,3'b100},
//    lhu     = {7'b0000000,3'b101}
////    lwu     = {7'b0000000,3'b110}  
//} type_I_load_op;

//typedef enum logic [9:0] {  // {funct7, funct3}    
//    sb    = {7'b0000000,3'b000},
//    sh    = {7'b0000000,3'b001},
//    sw    = {7'b0000000,3'b010} 
////    sd    = {7'b0000000,3'b011}    
//} type_S_op;



//typedef enum logic [9:0] {  // {funct7, funct3}
//    add     = {7'b0000000,3'b000},
//    sub     = {7'b0100000,3'b000},
//    sll     = {7'b0000000,3'b001},
//    slt     = {7'b0000000,3'b010},
//    sltu    = {7'b0000000,3'b011},
//    xor_    = {7'b0000000,3'b100},
//    srl     = {7'b0000000,3'b101},
//    sra     = {7'b0100000,3'b101},
//    or_     = {7'b0000000,3'b110}, 
//    and_    = {7'b0000000,3'b111} 
//} type_R_op;

//typedef enum logic [9:0] {  // {funct7, funct3}    
//    addi    = {7'b0000000,3'b000},
//    slli    = {7'b0000000,3'b001},
//    slti    = {7'b0000000,3'b010},
//    sltiu   = {7'b0000000,3'b011}, 
//    xori    = {7'b0000000,3'b100},
//    srli    = {7'b0000000,3'b101},
//    srali   = {7'b0100000,3'b101}, 
//    ori     = {7'b0000000,3'b110},
//    andi    = {7'b0000000,3'b111}    
//} type_I_imm_op;


//typedef enum logic [9:0] {  // {funct7, funct3}    
//    jalr    = {7'b0000000,3'b000} 
//} type_I_jump_op;

//typedef enum logic [9:0] {  // {funct7, funct3}    
//    jal    = {7'b0000000,3'b000} 
//} type_J_op;

//typedef enum logic [9:0] {  // {funct7, funct3}    
//    auipc   = {7'b0000000,3'b000},
//    lui     = {7'b0000000,3'b001}    
//} type_U_op;



//typedef enum logic [4:0] {  // {funct7[30], funct7[25], funct3}
//    add     = {2'b00,3'b000},
//    sub     = {2'b10,3'b000},
//    sll     = {2'b00,3'b001},
//    slt     = {2'b00,3'b010},
//    sltu    = {2'b00,3'b011},
//    xor_    = {2'b00,3'b100},
//    srl     = {2'b00,3'b101},
//    sra     = {2'b10,3'b101},
//    or_     = {2'b00,3'b110}, 
//    and_    = {2'b00,3'b111}, 
     
//    addi    = {2'bxx,3'b000},
//    slli    = {2'b00,3'b001},
//    slti    = {2'bxx,3'b010},
//    sltiu   = {2'bxx,3'b011}, 
//    xori    = {2'bxx,3'b100},
//    srli    = {2'b00,3'b101},
//    srai    = {2'b10,3'b101}, 
//    ori     = {2'bxx,3'b110},
//    andi    = {2'bxx,3'b111} 
//} type_R_I_op_e;
