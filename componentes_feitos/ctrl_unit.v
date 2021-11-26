module ctrl_unit (
    
    input wire  clk,
    input wire  reset,
    
    


    //fios de controle 
    output reg          PC_write,
    output reg          MEM_write,    
    output reg          IR_write,
    output reg          Mult_Div,
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
    //output reg      [1:0] Exception,

    
    
    //controladores dos muxes
    output reg [1:0]    M_writeReg,
    output reg [1:0]    IorD,
    output reg [1:0]    PCsource,
    output reg [1:0]    ShiftAmt,
    output reg          ShiftSrc,
    output reg          AluSrcA,
    output reg [1:0]    AluSrcB,
 
    
    
    
    //Flags
    input wire      Overflow,
    input wire      Ng,
    input wire      Zr,
    input wire      Eq,
    input wire      Gt,
    input wire      Lt,
    
    //Fios de Dados
    input wire [5:0] OPCODE,
    input wire [5:0] FUNCTION
);   

//variaveis usadas

reg[5:0] STATE;

// Parametros (Constantes)

    //Estados principais da maquina
    parameter ST_RESET = 6'b000000;    
    parameter ST_FETCH_1 = 6'b000001;
    parameter ST_FETCH_2 = 6'b000010;
    parameter ST_DECODE = 6'b000011;
    parameter ST_DECODE_2 = 6'b000100;
    parameter ST_ADD_1 = 6'b000101;
    parameter ST_SUB = 6'b000110;
    parameter ST_AND = 6'b000111;
    parameter ST_CLOSE_ARITH = 6'b001000;
    parameter ST_SHIFT_WSHAMT = 6'b001001;
    parameter ST_SHIFT_NSHAMT = 6'b001110;
    parameter ST_SLL = 6'b001010;
    parameter ST_SRA = 6'b001011;
    parameter ST_SRL = 6'b001100;
    parameter ST_SRAV = 6'b001111;
    parameter ST_SLLV = 6'b010000;
    parameter ST_SHIFT_END_1 = 6'b001101;
    parameter ST_SLT = 6'b010001;
    parameter ST_RTE = 6'b010010;
    parameter ST_ADDI_ADDIU = 6'b010011;
    parameter ST_ADDI = 6'b010100; 
    parameter ST_ADDIU = 6'b010101;
    parameter ST_BRANCH_START = 6'b010110;
    parameter ST_BRANCH_END = 6'b010111; // 23
    parameter ST_STORE = 6'b011000;
    parameter ST_STORE_WAIT = 6'b011001;
    parameter ST_STORE_WAIT_2 = 6'b011010; // 26
    parameter ST_SW = 6'b011011;
    parameter ST_SH = 6'b011100;
    parameter ST_SB = 6'b011101; // 29
    parameter ST_LUI = 6'b011110; // 30
    parameter ST_JR = 6'b011111; // 31
    parameter ST_J = 6'b100000; // 32
    parameter ST_SLTI = 6'b100001 ; // 33
    parameter ST_LOAD = 6'b100010; // 34
    parameter ST_LOAD_WAIT = 6'b100011; // 35
    parameter ST_LOAD_WAIT_2 = 6'b100100; // 36
    parameter ST_LW = 6'b100101; // 37
    parameter ST_LH = 6'b100110; // 38
    parameter ST_LB = 6'b100111; // 39, ultimo state adicionar a partir daqui
    parameter ST_CLOSE_WRITE = 6'b111111;
    
    
    

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
    //sram

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
              STATE = ST_LW;
            end
            LB: begin
              STATE = ST_LB;
            end
            LH: begin
              STATE = ST_LH;
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
        
        
        STATE = ST_SHIFT_END_1;

        end

        ST_SRA: begin
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

        STATE = ST_STORE_WAIT_2;
        end

        ST_STORE_WAIT_2 : begin

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
        MDR_Write           = 1'b1;//

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
        
        
        STATE = ST_FETCH_1;

        end


        endcase     
    
    
    end
    
end





endmodule