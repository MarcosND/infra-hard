module ctrl_unit (
    
    input wire  clk,
    input wire  reset,
    
    


    //fios de controle 
    output reg          PC_write,
    output reg          MEM_write,    
    output reg          IR_write,
    output reg          Mult_Div,
    output reg          HIWrite,
    output reg          LOWrite,
    output reg          AB_w,
    output reg          EPC_Write, // FALTA DECLARAR EM TODOS OS ESTADOS
    output reg          Regwrite,
    output reg          ALUOutCtrl,
    output reg          MDR_Write,
                    
    output reg      [2:0] Alu_control,
    output reg      [2:0] ShiftControl,
    output reg      [3:0] MEMtoReg, 
    output reg      [1:0] controleSS,
    output reg      [1:0] controleLS,
    output reg             mult_flag,
    output reg             div_flag,
    output reg             div_selector,
    
    
    //controladores dos muxes
    output reg [1:0]    M_writeReg,
    output reg [1:0]    IorD,
    output reg [1:0]    PCsource,
    output reg [1:0]    ExceptionControl,
    output reg [1:0]    ShiftAmt,
    output reg          ShiftSrc,
    output reg          AluSrcA,
    output reg [1:0]    AluSrcB,
 
    
    
    
    //Flags
    input wire      Overflow,
    input wire      Div0,
    input wire      Ng,
    input wire      Zr,
    input wire      Eq,
    input wire      Gt,
    input wire      Lt,
    input wire      ciclos_end,
    input wire      ciclos_end_01,
    
    //Fios de Dados
    input wire [5:0] OPCODE,
    input wire [5:0] FUNCTION
);   

//variaveis usadas

reg[6:0] STATE;

// Parametros (Constantes)

    //Estados principais da maquina
    parameter ST_RESET        = 7'b0000000;    
    parameter ST_FETCH_1      = 7'b0000001;
    parameter ST_FETCH_2      = 7'b0000010;
    parameter ST_DECODE       = 7'b0000011;
    parameter ST_DECODE_2     = 7'b0000100;
    parameter ST_ADD_1        = 7'b0000101;
    parameter ST_SUB          = 7'b0000110;
    parameter ST_AND          = 7'b0000111;
    parameter ST_CLOSE_ARITH  = 7'b0001000;
    parameter ST_SHIFT_WSHAMT = 7'b0001001;
    parameter ST_SHIFT_NSHAMT = 7'b0001110;
    parameter ST_SLL          = 7'b0001010;
    parameter ST_SRA          = 7'b0001011;
    parameter ST_SRL          = 7'b0001100;
    parameter ST_SRAV         = 7'b0001111;
    parameter ST_SLLV         = 7'b0010000;
    parameter ST_SHIFT_END_1  = 7'b0001101;
    parameter ST_SLT          = 7'b0010001;
    parameter ST_RTE          = 7'b0010010;
    parameter ST_ADDI_ADDIU   = 7'b0010011;
    parameter ST_ADDI         = 7'b0010100; 
    parameter ST_ADDIU        = 7'b0010101;
    parameter ST_BRANCH_START = 7'b0010110;
    parameter ST_BRANCH_END   = 7'b0010111; // 23
    parameter ST_STORE        = 7'b0011000;
    parameter ST_STORE_WAIT   = 7'b0011001;
    parameter ST_STORE_WAIT_2 = 7'b0011010; // 26
    parameter ST_SW           = 7'b0011011;
    parameter ST_SH           = 7'b0011100;
    parameter ST_SB           = 7'b0011101; // 29
    parameter ST_LUI          = 7'b0011110; // 30
    parameter ST_JR           = 7'b0011111; // 31
    parameter ST_J            = 7'b0100000; // 32
    parameter ST_SLTI         = 7'b0100001; // 33
    parameter ST_LOAD         = 7'b0100010; // 34
    parameter ST_LOAD_WAIT    = 7'b0100011; // 35
    parameter ST_LOAD_WAIT_2  = 7'b0100100; // 36
    parameter ST_LW           = 7'b0100101; // 37
    parameter ST_LH           = 7'b0100110; // 38
    parameter ST_LB           = 7'b0100111; // 39, ultimo state adicionar a partir daqui
    parameter ST_BREAK        = 7'b0101000; // 40
    parameter ST_MFHI         = 7'b0101001; // 41
    parameter ST_MFLO         = 7'b0101010; // 42
    parameter ST_MULT_1       = 7'b0101100; // 44
    parameter ST_MULT_2       = 7'b0101101; // 45
    parameter ST_JAL_1        = 7'b0101110; // 46
    parameter ST_JAL_2        = 7'b0101111; // 47
    parameter ST_DIV_1        = 7'b0110000; //48
    parameter ST_DIV_2        = 7'b0110001; // 49
    parameter ST_DIV_0_1      = 7'b0110010; // 50
    parameter ST_DIV_0_2      = 7'b0110011; // 51
    parameter ST_OVERFLOW_1   = 7'b0110100;// 52
    parameter ST_OVERFLOW_2   = 7'b0110101;// 53
    parameter ST_DIVM_1       = 7'b0110110; // 54
    parameter ST_DIVM_2       = 7'b0110111; // 55
    parameter ST_DIVM_2_WAIT  = 7'b0111000; //56
    parameter ST_DIVM_3       = 7'b0111001; // 57
    parameter ST_DIVM_4       = 7'b0111010; // 58
    parameter ST_DIVM_4_WAIT  = 7'b0111011; // 59
    parameter ST_OVERFLOW_3   = 7'b0111100; //60
    parameter ST_OVERFLOW_4   = 7'b0111101; // 61
    parameter ST_SRAM_1       = 7'b0111110; //62
    parameter ST_SRAM_2       = 7'b0111111; //63
    parameter ST_SRAM_3       = 7'b1000000; //64
    parameter ST_SRAM_4       = 7'b1000001; //65
    parameter ST_SRAM_5       = 7'b1000010; //66
    parameter ST_SRAM_6       = 7'b1000011; //67
    parameter ST_STORE_END     = 7'b1000111;
    parameter ST_CLOSE_WRITE  = 7'b1111111;
   
    
    
    

    //Opcode
    parameter R     = 6'b000000;
    parameter ADDI  = 6'b001000;
    parameter ADDIU = 6'b001001;
    parameter BEQ   = 6'b000100;
    parameter BNE   = 6'b000101;
    parameter BLE   = 6'b000110;
    parameter BGT   = 6'b000111;
    parameter LB    = 6'b100000;
    parameter LH    = 6'b100001;
    parameter LUI   = 6'b001111;
    parameter LW    = 6'b100011;
    parameter SB    = 6'b101000;
    parameter SH    = 6'b101001;
    parameter SLTI  = 6'b001010;
    parameter SW    = 6'b101011;
    parameter J     = 6'b000010;
    parameter JAL   = 6'b000011;
    parameter SRAM  = 6'b000001;

    // Function
    parameter FUNCT_ADD = 6'b100000;
    parameter FUNCT_SUB = 6'b100010;
    parameter FUNCT_AND = 6'b100100;
    parameter FUNCT_SLL = 6'b000000;
    parameter FUNCT_SLLV = 6'b000100;
    parameter FUNCT_SRA = 6'b000011;
    parameter FUNCT_SRAV = 6'b000111;
    parameter FUNCT_SRL = 6'b000010;
    parameter FUNCT_SLT = 6'b101010;
    parameter FUNCT_RTE = 6'b010011;
    parameter FUNCT_JR = 6'b001000;
    parameter FUNCT_MULT 	= 6'b011000;
    parameter FUNCT_DIV	 = 6'b011010;
    parameter FUNCT_DIVM  = 6'b000101;
    parameter FUNCT_BREAK = 6'b001101;
    parameter FUNCT_MFHI = 6'b010000;
    parameter FUNCT_MFLO = 6'b010010;

always @(posedge clk) begin
        if (reset || STATE == ST_RESET)begin
          
       

        //Define os sinais, zerando eles
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b10; 
        PC_write            = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b1;
        AluSrcA             = 1'b0;
        AluSrcB             = 2'b00;
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b1000;
        PCsource            = 2'b00;
        IorD                = 2'b00;
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        STATE = ST_FETCH_1;
         
        end
    
    else begin
        case (STATE)
            ST_FETCH_1: begin
             //Define os sinais
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00; 
        PC_write            = 1'b0; 
        MEM_write           = 1'b0;
        IR_write            = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b0; // 
        AluSrcA             = 1'b0;
        AluSrcB             = 2'b01; // 
        Alu_control         = 3'b001; //
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; //
        PCsource            = 2'b00;
        IorD                = 2'b00;  
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0; 
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
                
        STATE = ST_FETCH_2;   
            
        end
            
        ST_FETCH_2: begin
           
              //Define os sinais
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b1; // 
        MEM_write           = 1'b0;
        IR_write            = 1'b1; //
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0;
        AluSrcB             = 2'b01; 
        Alu_control         = 3'b001;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b10; //
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        STATE = ST_DECODE;
        
        end
            ST_DECODE: begin
             //Define os sinais
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  //
        MEM_write           = 1'b0;
        IR_write            = 1'b0; //
        AB_w                = 1'b1; //
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; //
        AluSrcB             = 2'b10; //
        Alu_control         = 3'b001; //
        ALUOutCtrl          = 1'b1; //
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00; //
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_DECODE_2;
            end
        ST_DECODE_2: begin
             //Define os sinais
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0; 
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; //
        AluSrcB             = 2'b00; //
        Alu_control         = 3'b000; 
        ALUOutCtrl          = 1'b0; //
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00; 
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
            
        case (OPCODE)
            R: begin
              case(FUNCTION)
                FUNCT_ADD: begin
                  STATE = ST_ADD_1;
                end
                FUNCT_SUB: begin
                  STATE = ST_SUB;
                end
                FUNCT_AND: begin
                  STATE = ST_AND;
                end
                FUNCT_SLL: begin
                  STATE = ST_SHIFT_WSHAMT;
                end
                FUNCT_SRA: begin
                  STATE = ST_SHIFT_WSHAMT;
                end
                FUNCT_SRL: begin
                  STATE = ST_SHIFT_WSHAMT;
                end
                FUNCT_SLLV: begin
                  STATE = ST_SHIFT_NSHAMT;
                end
                FUNCT_SRAV: begin
                  STATE = ST_SHIFT_NSHAMT;
                end
                FUNCT_SLT: begin
                  STATE = ST_SLT;
                end
                FUNCT_RTE: begin
                  STATE = ST_RTE;
                end
                FUNCT_JR: begin
                  STATE = ST_JR;
                end
                FUNCT_MULT: begin
                  STATE = ST_MULT_1;
                end
                FUNCT_DIV: begin
                  STATE = ST_DIV_1;
                end
                FUNCT_DIVM: begin
                    STATE = ST_DIVM_1;
                end
                FUNCT_BREAK: begin
                    STATE = ST_BREAK;
                end
                FUNCT_MFHI: begin
                    STATE = ST_MFHI;
                end
                FUNCT_MFLO: begin
                    STATE = ST_MFLO;
                end
              endcase
            end

            BEQ: begin
              STATE = ST_BRANCH_START;
            end

            BNE: begin
              STATE = ST_BRANCH_START;
            end

            BGT: begin
              STATE = ST_BRANCH_START;
            end

            BLE: begin
              STATE = ST_BRANCH_START;
            end

            ADDI: begin
              STATE = ST_ADDI_ADDIU;
            end

            ADDIU: begin
              STATE = ST_ADDI_ADDIU;            
            end         
            SB: begin
              STATE = ST_STORE;
            end
            SH: begin
              STATE = ST_STORE;
            end
            SW: begin
              STATE = ST_STORE;
            end
            LUI: begin
              STATE = ST_LUI;
            end
            J: begin
              STATE = ST_J;
            end
            SLTI: begin
              STATE = ST_SLTI;
            end
            LW: begin
              STATE = ST_LOAD;
            end
            LB: begin
              STATE = ST_LOAD;
            end
            LH: begin
              STATE = ST_LOAD;
            end
            JAL: begin
              STATE = ST_JAL_1;
            end
            SRAM: begin
              STATE = ST_SRAM_1;
            end

          endcase
            
        end
            ST_ADD_1: begin
             //Define os sinais
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b00; //
        Alu_control         = 3'b001;
        ALUOutCtrl          = 1'b1; // 
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

                STATE = ST_CLOSE_ARITH;
        end

            ST_SUB: begin
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b00; //
        Alu_control         = 3'b010; //
        ALUOutCtrl          = 1'b1; //
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

                STATE = ST_CLOSE_ARITH;
        end
            ST_AND: begin
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b00; //
        Alu_control         = 3'b011; //
        ALUOutCtrl          = 1'b1; //
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

                STATE = ST_CLOSE_ARITH;
        end
            ST_CLOSE_ARITH: begin
              //Define os sinais
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0; 
        M_writeReg          = 2'b01; //
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b1; //
        AluSrcA             = 1'b0; //
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000; //
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0101; //
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_CLOSE_WRITE;

            end
            ST_SHIFT_WSHAMT: begin
              //Define os sinais
        ShiftAmt            = 2'b01; //
        ShiftControl        = 3'b001; //
        ShiftSrc            = 1'b1; //
        M_writeReg          = 2'b00; 
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000; 
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

            case (FUNCTION)
                FUNCT_SLL: begin
                  STATE = ST_SLL;
                end
                FUNCT_SRA: begin
                  STATE = ST_SRA;
                end
                FUNCT_SRL: begin
                  STATE = ST_SRL;
                end
            endcase

        end
        ST_SLL: begin
               //Define os sinais, vai zerar tudo
        ShiftAmt            = 2'b00; //
        ShiftControl        = 3'b010; // 
        ShiftSrc            = 1'b0; //
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        STATE = ST_SHIFT_END_1;

        end

        ST_SRA: begin
               
        ShiftAmt            = 2'b00; //
        ShiftControl        = 3'b100; // 
        ShiftSrc            = 1'b0; //
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        STATE = ST_SHIFT_END_1;
        
        end
        ST_SRL: begin
               //Define os sinais, vai zerar tudo
        ShiftAmt            = 2'b00; //
        ShiftControl        = 3'b011; // 
        ShiftSrc            = 1'b0; //
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        STATE = ST_SHIFT_END_1;

        end

        ST_SHIFT_NSHAMT: begin
               //Define os sinais, vai zerar tudo
        ShiftAmt            = 2'b00; //
        ShiftControl        = 3'b001; // 
        ShiftSrc            = 1'b0; //
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        case (FUNCTION)
                FUNCT_SRAV: begin
                  STATE = ST_SRAV;
                end
                FUNCT_SLLV: begin
                  STATE = ST_SLLV;
                end
            endcase

        end

        ST_SRAV: begin
               //Define os sinais, vai zerar tudo
        ShiftAmt            = 2'b00; //
        ShiftControl        = 3'b100; // 
        ShiftSrc            = 1'b0; //
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        STATE = ST_SHIFT_END_1;

        end

        ST_SLLV: begin
               //Define os sinais, vai zerar tudo
        ShiftAmt            = 2'b00; //
        ShiftControl        = 3'b010; // 
        ShiftSrc            = 1'b0; //
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        STATE = ST_SHIFT_END_1;

        end

        ST_SHIFT_END_1: begin
               //Define os sinais, vai zerar tudo
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000;  
        ShiftSrc            = 1'b0; 
        M_writeReg          = 2'b01; //
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b1; //
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0110; //
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        STATE = ST_CLOSE_WRITE;

        end

        ST_SLT: begin
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b01; //
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b1; //
        AluSrcA             = 1'b1;  //
        AluSrcB             = 2'b00; //
        Alu_control         = 3'b111; //
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0111; //
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

          STATE = ST_CLOSE_WRITE;
        end

        
        
        ST_RTE: begin
          
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b1;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b01;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;


      STATE = ST_CLOSE_WRITE;


        end
      
        ST_ADDI_ADDIU: begin

        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;
        EPC_Write           = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b11; //
        Alu_control         = 3'b001;
        ALUOutCtrl          = 1'b1;  // Sim, é pra mudar
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        if (OPCODE == ADDI) begin  // Faz a verificação pra saber qual caso ir depois da mudança de estado padrão
          STATE = ST_ADDI;
        end 
        else begin
          STATE = ST_ADDIU;
        end
        
      end

        ST_ADDI: begin
        
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00; //
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b1; //
        AluSrcA             = 1'b0;  //
        AluSrcB             = 2'b00; // 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0101; //
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_CLOSE_WRITE;  


        end

        ST_ADDIU: begin
        
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00; //
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b1; //
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0101; //
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_CLOSE_WRITE;
          


        end 
            
        
        ST_BRANCH_START: begin
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        PC_write            = 1'b0;
        M_writeReg          = 2'b00;
        EPC_Write           = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b111; //
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b11; //
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        

        STATE = ST_BRANCH_END;

        end

        ST_BRANCH_END: begin
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        EPC_Write           = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b111; //
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b11; //
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        case (OPCODE)
          BEQ: begin
            if (Eq == 1) begin
            PC_write            = 1'b1;
            end else begin
            PC_write            = 1'b0;
            end
          end
          BNE: begin
            if (Eq == 0) begin
            PC_write            = 1'b1;
            end else begin
            PC_write            = 1'b0;
            end
          end
          BGT: begin
            if (Gt == 1) begin
            PC_write            = 1'b1;
            end else begin
            PC_write            = 1'b0;
            end
          end
          BLE: begin
          if (Gt == 0) begin
            PC_write            = 1'b1;
            end else begin
            PC_write            = 1'b0;
            end
          end
        endcase


        STATE = ST_CLOSE_WRITE;

        end

        ST_STORE : begin

        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;//
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b11; //
        Alu_control         = 3'b001;//
        ALUOutCtrl          = 1'b1;//
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b10;//
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_STORE_WAIT;  
        end

        ST_STORE_WAIT : begin

        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;//
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b11; //
        Alu_control         = 3'b001;//
        ALUOutCtrl          = 1'b0;//
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b10; //
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_STORE_WAIT_2;
        end

        ST_STORE_WAIT_2 : begin

        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;//
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b11; //
        Alu_control         = 3'b001;//
        ALUOutCtrl          = 1'b0;//
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b10; //
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_STORE_END;
        end

        ST_STORE_END: begin

        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;//
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b11; //
        Alu_control         = 3'b001;//
        MDR_Write           = 1'b1; //
        ALUOutCtrl          = 1'b0; //
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        case(OPCODE)
          SW : begin
            STATE = ST_SW;
          end
          SH: begin
            STATE = ST_SH;
          end
          SB: begin
            STATE = ST_SB;
          end
        endcase
      end

        ST_SW: begin

        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b1;//
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b10; //  
        controleSS          = 2'b00;//
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_CLOSE_WRITE;
        end

        ST_SH: begin
         
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b1;//
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b10; //  
        controleSS          = 2'b10;//
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_CLOSE_WRITE;
        end

        ST_SB: begin

        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b1;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b10; //
        controleSS          = 2'b01;//
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_CLOSE_WRITE;
        end

        
        
        ST_LUI: begin
        
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00; // 
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b1; //  
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0100; //
        PCsource            = 2'b00;
        IorD                = 2'b00;
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        
        STATE = ST_CLOSE_WRITE;



        end 

        ST_JR: begin

        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b1; // 
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;//
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b10; //
        IorD                = 2'b00;
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_CLOSE_WRITE;
        
        end

        ST_J: begin
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b1;//  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;//
        IorD                = 2'b00;
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_CLOSE_WRITE;
        end

        ST_SLTI: begin
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00; // 
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b1; //
        AluSrcA             = 1'b1; // 
        AluSrcB             = 2'b11; // 
        Alu_control         = 3'b111; // 
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0111; ///
        PCsource            = 2'b00;
        IorD                = 2'b00;
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;

        STATE = ST_CLOSE_WRITE;

          
        end 
        
        ST_LOAD: begin
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; // 
        AluSrcB             = 2'b11; //
        Alu_control         = 3'b001; //
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b11; //
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b0;
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;
        
        STATE = ST_LOAD_WAIT;

        end
        
          ST_LOAD_WAIT: begin
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b1; // 
          AluSrcB             = 2'b11; //
          Alu_control         = 3'b001; //
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b11; //
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0;
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

        STATE = ST_LOAD_WAIT_2;

        end
        
        ST_LOAD_WAIT_2: begin
        ShiftAmt            = 2'b00; 
        ShiftControl        = 3'b000; 
        ShiftSrc            = 1'b0;
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        EPC_Write           = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; // 
        AluSrcB             = 2'b11; //
        Alu_control         = 3'b001; //
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b11; //
        controleSS          = 2'b00;
        controleLS          = 2'b00;
        MDR_Write           = 1'b1; //
        Mult_Div            = 1'b0;
        HIWrite             = 1'b0;
        LOWrite             = 1'b0;
        ExceptionControl    = 2'b00;
        mult_flag           = 1'b0;
        div_flag            = 1'b0;
        div_selector        = 1'b0;


        case (OPCODE)
          LW: begin
            STATE = ST_LW;
          end
          LH: begin
            STATE = ST_LH;
          end
          LB: begin
            STATE = ST_LB;
          end 
        endcase
        
        end
        
        ST_LW: begin
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b1;  //
          AluSrcA             = 1'b0;  
          AluSrcB             = 2'b00; 
          Alu_control         = 3'b000; 
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0011; //
          PCsource            = 2'b00;
          IorD                = 2'b00; 
          controleSS          = 2'b00;
          controleLS          = 2'b00; //
          MDR_Write           = 1'b0;
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;



        STATE = ST_CLOSE_WRITE;

        end

        ST_LH: begin
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00; //
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b1; //
          AluSrcA             = 1'b0; 
          AluSrcB             = 2'b00; 
          Alu_control         = 3'b000; 
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0011; //
          PCsource            = 2'b00;
          IorD                = 2'b00; 
          controleSS          = 2'b00;
          controleLS          = 2'b10; //
          MDR_Write           = 1'b0;
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;


        STATE = ST_CLOSE_WRITE;

        end

        ST_LB: begin
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b1; //
          AluSrcA             = 1'b0; 
          AluSrcB             = 2'b00; 
          Alu_control         = 3'b000; 
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0011; // 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b01;//
          MDR_Write           = 1'b0;
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;


        STATE = ST_CLOSE_WRITE;

        end

        
        ST_BREAK: begin
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b1;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0; //
          AluSrcB             = 2'b01; //
          Alu_control         = 3'b010; //
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b10; // 
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_CLOSE_WRITE;
        

        end 
        ST_MFHI: begin
          
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b01; //
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b1; // 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; //
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0;  
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_CLOSE_WRITE;
       
       
       
        end

        ST_MFLO: begin
        
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b01; //
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b1; // 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0001; //
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          ExceptionControl    = 2'b00; 
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_CLOSE_WRITE;
          


        end 

        ST_MULT_1: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0; // 
          HIWrite             = 1'b0; //
          LOWrite             = 1'b0; //
          mult_flag           = 1'b1; //
          ExceptionControl    = 2'b00;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_MULT_2;
        end

        ST_MULT_2: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          mult_flag           = 1'b0;
          ExceptionControl    = 2'b00;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          if (ciclos_end == 0) begin

              STATE = ST_MULT_2;  

          end else begin
              HIWrite = 1'b1;
              LOWrite = 1'b1;

              STATE = ST_CLOSE_WRITE;

          end

        end
        
        
        ST_JAL_1: begin
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0; //
          AluSrcB             = 2'b00; 
          Alu_control         = 3'b000; 
          ALUOutCtrl          = 1'b1; //
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

        
        STATE = ST_JAL_2;
        end

        ST_JAL_2: begin
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b11; //
          PC_write            = 1'b1; //  
          EPC_Write           = 1'b0; 
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b1; //
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0101; //
          PCsource            = 2'b00; //
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

        
        STATE = ST_CLOSE_WRITE;


        end
        
        ST_DIV_1: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b1; //
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          div_selector        = 1'b0;
          div_flag            = 1'b1; //
          mult_flag           = 1'b0;
          

          STATE = ST_DIV_2;

        end

        ST_DIV_2: begin
          
          
          
          div_flag            = 1'b0;
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b1;  //
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          div_selector        = 1'b0; //
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          

          if (ciclos_end_01 == 0) begin

              STATE = ST_DIV_2;  

          end else begin
              HIWrite = 1'b1;
              LOWrite = 1'b1;

              STATE = ST_CLOSE_WRITE;

          end

        

      end

        ST_DIVM_1: begin
          
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b1; //
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000; //
          ALUOutCtrl          = 1'b1; //
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b10; //
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_DIVM_2;
        end

        ST_DIVM_2: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0; //
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000; //
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b11; //
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;


          STATE = ST_DIVM_3;
        
        end

        ST_DIVM_3: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0; //
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000; //
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b11; //
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b1; //
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;


          STATE = ST_DIVM_4;

        end

        ST_DIVM_4: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0; //
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000; //
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b11; //
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          div_flag            = 1'b1;
          div_selector        = 1'b1;
          mult_flag           = 1'b0;
          
          STATE = ST_DIVM_4_WAIT;

        end

        ST_DIVM_4_WAIT: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          div_flag            = 1'b1;
          div_selector        = 1'b1;
          mult_flag           = 1'b0;
          

          STATE = ST_DIV_2;
        end

        ST_DIV_0_1: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_DIV_0_2;
        end

        ST_DIV_0_2: begin
          
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;


        end

        ST_OVERFLOW_1: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_OVERFLOW_2;

        end

        ST_OVERFLOW_2: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_OVERFLOW_3;
        end

        ST_OVERFLOW_3: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_OVERFLOW_4;

        end

        ST_OVERFLOW_4: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_CLOSE_WRITE;
        end

        ST_SRAM_1: begin
          
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b1; //
          AluSrcB             = 2'b11; //
          Alu_control         = 3'b001; //
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b11; //
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_SRAM_2;
          
        end
        ST_SRAM_2: begin
          //WAIT
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b1; //
          AluSrcB             = 2'b11; //
          Alu_control         = 3'b001; //
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b11; //
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_SRAM_3;
          
        end

        ST_SRAM_3: begin
          //wait
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b1; //
          AluSrcB             = 2'b11; //
          Alu_control         = 3'b001; //
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b11; //
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_SRAM_4;
          
        end

        ST_SRAM_4: begin
          
          ShiftAmt            = 2'b10; //
          ShiftControl        = 3'b001; //
          ShiftSrc            = 1'b1; //
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_SRAM_5;

        end

         ST_SRAM_5: begin
          
          ShiftAmt            = 2'b0; 
          ShiftControl        = 3'b100; // 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_SRAM_6;

        end

        ST_SRAM_6: begin
          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00; //
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b1; // 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0110; //
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;

          STATE = ST_CLOSE_WRITE;




        end



        
        ST_CLOSE_WRITE: begin

          ShiftAmt            = 2'b00; 
          ShiftControl        = 3'b000; 
          ShiftSrc            = 1'b0;
          M_writeReg          = 2'b00;
          PC_write            = 1'b0;  
          EPC_Write           = 1'b0;
          MEM_write           = 1'b0;
          IR_write            = 1'b0; 
          AB_w                = 1'b0;
          Regwrite            = 1'b0; 
          AluSrcA             = 1'b0;
          AluSrcB             = 2'b00;
          Alu_control         = 3'b000;
          ALUOutCtrl          = 1'b0;
          MEMtoReg            = 4'b0000; 
          PCsource            = 2'b00;
          IorD                = 2'b00;
          controleSS          = 2'b00;
          controleLS          = 2'b00;
          MDR_Write           = 1'b0; 
          Mult_Div            = 1'b0;
          HIWrite             = 1'b0;
          LOWrite             = 1'b0;
          ExceptionControl    = 2'b00;
          mult_flag           = 1'b0;
          div_flag            = 1'b0;
          div_selector        = 1'b0;
        
        STATE = ST_FETCH_1;

        end


        endcase     
    
    
    end
    
end





endmodule